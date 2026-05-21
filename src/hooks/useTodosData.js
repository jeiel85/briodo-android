import { useState, useEffect, useRef, useCallback } from 'react'
import { Network } from '@capacitor/network'
import {
  collection, onSnapshot, query, where,
  doc, updateDoc, serverTimestamp, setDoc, deleteDoc, getDoc
} from "firebase/firestore"
import { db } from '../firebase'
import {
  getLocalTodos, saveLocalTodosBatch, saveLocalTodo, deleteLocalTodo,
  addSyncQueue, getSyncQueue, clearSyncQueue, incrementRetryCount,
  getSyncQueueStats, resolveConflict, measureNetworkQuality,
  shouldSyncInLowBandwidth, setSyncMetadata, addOfflineLog,
  SYNC_CONFIG
} from '../db'
import { syncEventToGoogle, deleteEventFromGoogle, fetchEventsFromGoogle } from '../calendar'
import { cancelNotification, scheduleNotification } from './useNotifications'
import { track, EVENTS } from '../analytics'

const sortTodos = (list) => list.sort((a, b) => {
  const dtA = new Date(`${a.date} ${a.time && a.time.includes(':') ? a.time : '00:00'}`)
  const dtB = new Date(`${b.date} ${b.time && b.time.includes(':') ? b.time : '00:00'}`)
  return dtA - dtB
})

/**
 * 개선된 동기화 훅
 * - 지수 백오프 재시도
 * - 타임스탬프 기반 충돌 해결
 * - 저대역폭 모드
 * - 동기화 상태 추적
 */
export function useTodosData(user, { completionCalendarMode = 'status', lang = 'ko' } = {}) {
  const [todos, setTodos] = useState([])
  const [isOnline, setIsOnline] = useState(true)
  const [syncStatus, setSyncStatus] = useState({
    isSyncing: false,
    queueSize: 0,
    lastSyncAt: null,
    error: null,
    isLowBandwidth: false,
  })
  
  // Refs for sync control
  const syncInProgressRef = useRef(false)
  const syncDebounceTimerRef = useRef(null)
  const networkQualityRef = useRef({ isLowBandwidth: false, latencyMs: 0 })

  /**
   * 개선된 동기화 큐 처리
   * - 지수 백오프
   * - 배치 처리
   * - 충돌 해결
   */
  const processSyncQueue = useCallback(async (options = {}) => {
    if (!user || syncInProgressRef.current) return
    
    const { force = false, batchSize = SYNC_CONFIG.BATCH_SIZE } = options
    
    // 네트워크 품질 확인
    if (!force && !isOnline) {
      console.log('[Sync] Skipped: offline')
      return
    }
    
    syncInProgressRef.current = true
    setSyncStatus(prev => ({ ...prev, isSyncing: true, error: null }))
    
    try {
      // 네트워크 품질 측정 (주기적으로)
      if (Math.random() < 0.3) { // 30% 확률로 측정
        const quality = await measureNetworkQuality()
        networkQualityRef.current = quality
        setSyncStatus(prev => ({ ...prev, isLowBandwidth: quality.isLowBandwidth }))
      }
      
      // 저대역폭 최적화
      const queueStats = await getSyncQueueStats()
      if (networkQualityRef.current.isLowBandwidth) {
        const optimized = shouldSyncInLowBandwidth(queueStats.total)
        console.log('[Sync] Low bandwidth mode:', optimized)
      }
      
      // 처리할 큐 가져오기 (우선순위 순)
      const queue = await getSyncQueue({ 
        prioritize: true, 
        limit: networkQualityRef.current.isLowBandwidth ? 3 : batchSize 
      })
      
      if (queue.length === 0) {
        setSyncStatus(prev => ({ ...prev, isSyncing: false, queueSize: 0 }))
        syncInProgressRef.current = false
        return
      }
      
      console.log(`[Sync] Processing ${queue.length} items (queue: ${queueStats.total})`)
      
      let successCount = 0
      let failCount = 0
      
      for (const item of queue) {
        // 재시도 대기 중인 항목 스킵
        if (item.nextRetryAt && item.nextRetryAt > Date.now()) {
          console.log(`[Sync] Skipping ${item.todoId}: retry after ${new Date(item.nextRetryAt).toLocaleTimeString()}`)
          continue
        }
        
        // 최대 재시도 횟수 초과 시 스킵
        if (item.retryCount >= SYNC_CONFIG.MAX_RETRY_ATTEMPTS) {
          console.warn(`[Sync] Max retries exceeded for ${item.todoId}`)
          failCount++
          continue
        }
        
        try {
          if (item.action === 'set') {
            // 서버 데이터와 충돌 검사
            const serverDoc = await getDoc(doc(db, 'todos', item.todoId))
            
            if (serverDoc.exists()) {
              const serverData = serverDoc.data()
              const localData = item.payload
              
              // 충돌 해결
              const resolution = resolveConflict(
                { ...localData, localUpdatedAt: item.clientTimestamp },
                serverData
              )
              
              if (resolution.winner === 'server' && 
                  item.clientTimestamp < (serverData.updatedAt?.toMillis?.() || 0)) {
                console.log(`[Sync] Conflict resolved: server wins for ${item.todoId}`)
                // 로컬 데이터 업데이트
                await saveLocalTodo(resolution.merged)
                setTodos(prev => prev.map(t => t.id === item.todoId ? resolution.merged : t))
              }
            }
            
            // 서버에 저장
            const finalPayload = { ...item.payload }
            if (!finalPayload.createdAt || typeof finalPayload.createdAt === 'number') {
              finalPayload.createdAt = serverTimestamp()
            }
            finalPayload.updatedAt = serverTimestamp()
            finalPayload._syncedAt = Date.now()
            
            await setDoc(doc(db, 'todos', item.todoId), finalPayload, { merge: true })
            
          } else if (item.action === 'delete') {
            await deleteDoc(doc(db, 'todos', item.todoId))
            if (item.payload?.googleEventId) {
              await deleteEventFromGoogle(item.payload.googleEventId).catch(() => {})
            }
          }
          
          // 성공: 큐에서 제거
          await clearSyncQueue(item.id)
          successCount++
          
        } catch (error) {
          console.error(`[Sync] Failed for ${item.todoId}:`, error)
          
          // 실패: 재시도 카운트 증가
          await incrementRetryCount(item, error)
          failCount++
          
          // 네트워크 오류 시 즉시 중단 (나머지는 다음 기회에)
          if (error.code === 'unavailable' || error.code === 'network-request-failed') {
            console.log('[Sync] Network error, pausing sync')
            setIsOnline(false)
            break
          }
        }
      }
      
      // 동기화 메타데이터 업데이트
      await setSyncMetadata('lastSync', {
        at: Date.now(),
        successCount,
        failCount,
        queueSize: queueStats.total - successCount,
      })
      
      const remainingStats = await getSyncQueueStats()
      setSyncStatus(prev => ({
        ...prev,
        isSyncing: false,
        queueSize: remainingStats.total,
        lastSyncAt: Date.now(),
        error: failCount > 0 ? `${failCount}개 동기화 실패` : null,
      }))
      
      console.log(`[Sync] Completed: ${successCount} success, ${failCount} failed, ${remainingStats.total} remaining`)
      
    } catch (e) {
      console.error('[Sync] Process error:', e)
      setSyncStatus(prev => ({ ...prev, isSyncing: false, error: e.message }))
    } finally {
      syncInProgressRef.current = false
    }
  }, [user, isOnline])

  // 네트워크 상태 감지 및 오프라인 큐 처리 (개선됨)
  useEffect(() => {
    let networkListener = null
    let cancelled = false
    let syncInterval = null
    
    const handleNetworkChange = async (status) => {
      setIsOnline(status.connected)
      
      if (status.connected && user) {
        // 디바운스된 동기화 실행
        if (syncDebounceTimerRef.current) {
          clearTimeout(syncDebounceTimerRef.current)
        }
        syncDebounceTimerRef.current = setTimeout(() => {
          if (!cancelled) processSyncQueue()
        }, SYNC_CONFIG.SYNC_DEBOUNCE_MS)
      } else if (!status.connected) {
        // 오프라인 로그
        addOfflineLog('network_offline', { timestamp: Date.now() })
      }
    }
    
    // 주기적 동기화 (온라인 상태일 때)
    syncInterval = setInterval(() => {
      if (user && isOnline && !syncInProgressRef.current) {
        getSyncQueueStats().then(stats => {
          if (stats.pending > 0) {
            processSyncQueue()
          }
        })
      }
    }, 30000) // 30초마다 체크
    
    Network.getStatus().then(status => {
      if (cancelled) return
      setIsOnline(status.connected)
      if (status.connected && user) processSyncQueue()
    })
    
    Network.addListener('networkStatusChange', handleNetworkChange).then(l => {
      if (cancelled) { l.remove(); return }
      networkListener = l
    })
    
    return () => {
      cancelled = true
      networkListener?.remove()
      if (syncDebounceTimerRef.current) clearTimeout(syncDebounceTimerRef.current)
      if (syncInterval) clearInterval(syncInterval)
    }
  }, [user, processSyncQueue, isOnline])

  // 동기화 상태 주기적 업데이트
  useEffect(() => {
    if (!user) return
    
    const updateStats = async () => {
      const stats = await getSyncQueueStats()
      setSyncStatus(prev => ({ ...prev, queueSize: stats.total }))
    }
    
    updateStats()
    const interval = setInterval(updateStats, 5000)
    return () => clearInterval(interval)
  }, [user])

  // 로그인 시 게스트 todos를 Firestore로 마이그레이션 (개선됨)
  useEffect(() => {
    if (!user) return
    
    const migrateGuestTodos = async () => {
      try {
        const all = await getLocalTodos()
        const guests = all.filter(t => !t.uid && !t.completed)
        if (guests.length === 0) return
        
        console.log(`[Migration] ${guests.length} guest todos to migrate`)
        
        // 배치 처리로 마이그레이션
        const batchSize = 5
        for (let i = 0; i < guests.length; i += batchSize) {
          const batch = guests.slice(i, i + batchSize)
          await Promise.all(batch.map(async (todo) => {
            try {
              const newDocRef = doc(collection(db, 'todos'))
              const { id: oldId, createdAt: _, ...rest } = todo
              const payload = { 
                ...rest, 
                uid: user.uid,
                localUpdatedAt: Date.now(),
                _migratedAt: Date.now(),
              }
              await setDoc(newDocRef, { ...payload, createdAt: serverTimestamp() })
              await deleteLocalTodo(oldId)
              await saveLocalTodo({ ...payload, id: newDocRef.id })
            } catch (e) {
              console.error('Migration error for todo:', todo.id, e)
            }
          }))
        }
        
        await addOfflineLog('migration_complete', { 
          count: guests.length, 
          timestamp: Date.now() 
        })
        
      } catch (e) { 
        console.error('Guest migration error:', e) 
      }
    }
    
    migrateGuestTodos()
  }, [user?.uid])

  // Firestore 실시간 동기화 + 로컬 DB / 게스트 모드 로컬 전용
  useEffect(() => {
    let unsubscribe = null

    const loadLocalAndSync = async () => {
      if (user) {
        // 로컬 DB 우선 즉시 렌더링
        const localData = await getLocalTodos()
        if (localData && localData.length > 0) {
          setTodos(sortTodos(localData))
        }

        // 로그인 시 1회만 Google Calendar 역동기화
        const syncCalendarOnce = async (firestoreList) => {
          try {
            const events = await fetchEventsFromGoogle()
            if (!events || events.length === 0) return firestoreList
            let updated = false
            const list = [...firestoreList]
            for (const ev of events) {
              const matchIndex = list.findIndex(t => t.googleEventId === ev.id)
              if (matchIndex >= 0) {
                const match = list[matchIndex]
                const evUpdated = new Date(ev.updated).getTime()
                const localUpdated = match.localUpdatedAt || 
                  match.updatedAt?.toMillis?.() || 
                  match.createdAt?.toMillis?.() || 0
                  
                // 충돌 해결: 더 최신 데이터 적용
                if (evUpdated > localUpdated + 60000) {
                  const dt = ev.start?.date || ev.start?.dateTime?.split('T')[0]
                  const time = ev.start?.dateTime ? ev.start.dateTime.substring(11, 16) : ''
                  const updatedTodo = {
                    text: (ev.summary || '').replace(/^(✅\s+)?(🔵|🟡|🔴|🚨)\s+B\]\s*/u, '').replace(/^B\]\s*/, '') || '제목 없음',
                    description: ev.description || '',
                    date: dt || match.date,
                    time,
                    updatedAt: serverTimestamp(),
                    localUpdatedAt: Date.now(),
                  }
                  await updateDoc(doc(db, "todos", match.id), updatedTodo)
                  list[matchIndex] = { ...match, ...updatedTodo }
                  updated = true
                }
              }
            }
            return updated ? list : firestoreList
          } catch (calErr) {
            console.error('Calendar sync error:', calErr)
            return firestoreList
          }
        }

        // Firestore 실시간 구독
        let calendarSyncDone = false
        const q = query(collection(db, "todos"), where("uid", "==", user.uid))
        unsubscribe = onSnapshot(q, async (snapshot) => {
          let list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }))

          // 최초 1회만 Google Calendar 역동기화
          if (!calendarSyncDone) {
            calendarSyncDone = true
            list = await syncCalendarOnce(list)
          }

          setTodos(sortTodos(list))
          try { 
            await saveLocalTodosBatch(list) 
          } catch (e) { 
            console.error("Local DB Sync error:", e) 
          }
        }, (error) => {
          console.error("Firestore sync error:", error)
          // Firestore 구독 실패 시 오프라인 모드로 전환
          if (error.code === 'unavailable' || error.code === 'network-request-failed') {
            setIsOnline(false)
            setSyncStatus(prev => ({ 
              ...prev, 
              error: '서버 연결 실패 - 오프라인 모드로 전환' 
            }))
          }
        })
      } else {
        // 게스트 모드: uid 없는 로컬 todos만 표시
        const localData = await getLocalTodos()
        const guestTodos = localData.filter(t => !t.uid)
        setTodos(sortTodos(guestTodos))
      }
    }

    loadLocalAndSync()
    return () => { if (unsubscribe) unsubscribe() }
  }, [user])

  const toggleComplete = async (e, id, completed, instanceDate = null) => {
    e.stopPropagation()
    const nowCompleting = !completed
    try {
      const target = todos.find(t => t.id === id)
      if (nowCompleting && target) {
        const createdAt = target.createdAt || Date.now()
        const ageSeconds = Math.max(0, Math.floor((Date.now() - createdAt) / 1000))
        track(EVENTS.TODO_COMPLETE, {
          has_subtasks: Array.isArray(target.subtasks) && target.subtasks.length > 0,
          age_seconds: ageSeconds,
          is_recurring: !!(target.recurrence && target.recurrence.type && target.recurrence.type !== 'none'),
        })
      }

      // 반복 일정 인스턴스
      if (target?.recurrence?.type && target.recurrence.type !== 'none' && instanceDate) {
        const updatedCompletions = { ...(target.completions || {}), [instanceDate]: nowCompleting }
        const updatedTodo = { ...target, completions: updatedCompletions }
        setTodos(prev => prev.map(t => t.id === id ? updatedTodo : t))
        await saveLocalTodo(updatedTodo)
        if (user) {
          if (isOnline) {
            await setDoc(doc(db, "todos", id), { completions: updatedCompletions }, { merge: true })
          } else {
            await addSyncQueue('set', id, { completions: updatedCompletions }, { priority: 1 }) // 높은 우선순위
          }
        }
        return
      }
      
      const updatePayload = { 
        completed: nowCompleting,
        completedAt: nowCompleting ? Date.now() : null,
        localUpdatedAt: Date.now(),
      }

      setTodos(prev => prev.map(t => t.id === id ? { ...t, ...updatePayload } : t))
      if (target) await saveLocalTodo({ ...target, ...updatePayload })
      if (target) {
        if (nowCompleting) {
          cancelNotification(id)
        } else if (target.reminderOffset !== null && target.reminderOffset !== undefined) {
          scheduleNotification({ ...target, completed: false })
        }
      }

      if (user) {
        if (isOnline) {
          try {
            await setDoc(doc(db, "todos", id), updatePayload, { merge: true })

            if (completionCalendarMode === 'delete') {
              if (nowCompleting) {
                if (target?.googleEventId) {
                  setTimeout(async () => {
                    await deleteEventFromGoogle(target.googleEventId)
                    await setDoc(doc(db, "todos", id), { googleEventId: null }, { merge: true })
                    await saveLocalTodo({ ...target, completed: true, googleEventId: null })
                    setTodos(prev => prev.map(t => t.id === id ? { ...t, googleEventId: null } : t))
                  }, 100)
                }
              } else {
                setTimeout(async () => {
                  const newEventId = await syncEventToGoogle({ ...target, completed: false, googleEventId: null })
                  if (newEventId) {
                    await setDoc(doc(db, "todos", id), { googleEventId: newEventId }, { merge: true })
                    await saveLocalTodo({ ...target, completed: false, googleEventId: newEventId })
                    setTodos(prev => prev.map(t => t.id === id ? { ...t, googleEventId: newEventId } : t))
                  }
                }, 100)
              }
            } else {
              if (target?.googleEventId) {
                setTimeout(() => syncEventToGoogle({ ...target, completed: nowCompleting }), 100)
              }
            }
          } catch (syncError) {
            // 동기화 실패 시 큐에 추가
            console.warn('Online sync failed, queuing:', syncError)
            await addSyncQueue('set', id, updatePayload, { priority: 1 })
          }
        } else {
          await addSyncQueue('set', id, updatePayload, { priority: 1 })
        }
      }
    } catch (e) { console.error(e) }
  }

  const toggleSubtaskComplete = async (todoId, subtaskId) => {
    try {
      const target = todos.find(t => t.id === todoId)
      if (!target) return
      const updatedSubtasks = (target.subtasks || []).map(st =>
        st.id === subtaskId ? { ...st, completed: !st.completed } : st
      )
      const updatedTodo = { 
        ...target, 
        subtasks: updatedSubtasks,
        localUpdatedAt: Date.now(),
      }
      setTodos(prev => prev.map(t => t.id === todoId ? updatedTodo : t))
      await saveLocalTodo(updatedTodo)
      if (user) {
        if (isOnline) {
          try {
            await setDoc(doc(db, "todos", todoId), { subtasks: updatedSubtasks }, { merge: true })
          } catch {
            await addSyncQueue('set', todoId, { subtasks: updatedSubtasks })
          }
        } else {
          await addSyncQueue('set', todoId, { subtasks: updatedSubtasks })
        }
      }
    } catch (e) { console.error('toggleSubtaskComplete error:', e) }
  }

  const deleteTodo = async (e, id) => {
    e.stopPropagation()
    try {
      const target = todos.find(t => t.id === id)
      track(EVENTS.TODO_DELETE, {
        was_completed: !!target?.completed,
        is_recurring: !!(target?.recurrence && target.recurrence.type && target.recurrence.type !== 'none'),
      })
      setTodos(prev => prev.filter(t => t.id !== id))
      await deleteLocalTodo(id)
      cancelNotification(id)
      if (user) {
        if (isOnline) {
          try {
            await deleteDoc(doc(db, "todos", id))
            if (target?.googleEventId) {
              setTimeout(() => deleteEventFromGoogle(target.googleEventId), 100)
            }
          } catch {
            await addSyncQueue('delete', id, { googleEventId: target?.googleEventId || null })
          }
        } else {
          await addSyncQueue('delete', id, { googleEventId: target?.googleEventId || null })
        }
      }
    } catch (e) { console.error(e) }
  }

  // 수동 동기화 트리거 함수
  const triggerSync = useCallback(async () => {
    await processSyncQueue({ force: true })
  }, [processSyncQueue])

  return {
    todos,
    setTodos,
    isOnline,
    syncStatus,
    toggleComplete,
    toggleSubtaskComplete,
    deleteTodo,
    triggerSync, // 수동 동기화 함수
  }
}
