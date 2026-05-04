import { openDB } from 'idb';

const DB_NAME = 'briodo-db';
const DB_VERSION = 2; // 버전 업: 신뢰성 개선을 위한 새로운 저장소 추가
const STORE_TODOS = 'todos';
const STORE_HISTORY = 'history';
const STORE_SYNC_QUEUE = 'syncQueue';
const STORE_SYNC_METADATA = 'syncMetadata'; // 동기화 메타데이터 저장소
const STORE_OFFLINE_LOG = 'offlineLog'; // 오프라인 작업 로그

// 동기화 설정 상수
const SYNC_CONFIG = {
  MAX_RETRY_ATTEMPTS: 5,
  BASE_RETRY_DELAY_MS: 1000,
  MAX_RETRY_DELAY_MS: 30000,
  BATCH_SIZE: 10,
  LOW_BANDWIDTH_THRESHOLD_KBPS: 50, // 50kbps 이하를 저대역폭으로 간주
  SYNC_DEBOUNCE_MS: 500, // 동기화 디바운스 시간
  CONFLICT_RESOLUTION_STRATEGY: 'timestamp', // 'timestamp' | 'server-wins' | 'client-wins'
};

export async function initDB() {
  return await openDB(DB_NAME, DB_VERSION, {
    upgrade(db, oldVersion) {
      if (!db.objectStoreNames.contains(STORE_TODOS)) {
        db.createObjectStore(STORE_TODOS, { keyPath: 'id' });
      }
      if (!db.objectStoreNames.contains(STORE_HISTORY)) {
        db.createObjectStore(STORE_HISTORY, { keyPath: 'id', autoIncrement: true });
      }
      if (!db.objectStoreNames.contains(STORE_SYNC_QUEUE)) {
        const queueStore = db.createObjectStore(STORE_SYNC_QUEUE, { keyPath: 'id', autoIncrement: true });
        queueStore.createIndex('action', 'action');
        queueStore.createIndex('timestamp', 'timestamp');
        queueStore.createIndex('retryCount', 'retryCount');
        queueStore.createIndex('priority', 'priority'); // 우선순위 인덱스 추가
      }
      // v2: 새로운 저장소들
      if (oldVersion < 2) {
        if (!db.objectStoreNames.contains(STORE_SYNC_METADATA)) {
          const metaStore = db.createObjectStore(STORE_SYNC_METADATA, { keyPath: 'key' });
          metaStore.createIndex('lastSyncAt', 'lastSyncAt');
        }
        if (!db.objectStoreNames.contains(STORE_OFFLINE_LOG)) {
          db.createObjectStore(STORE_OFFLINE_LOG, { keyPath: 'id', autoIncrement: true });
        }
      }
    },
  });
}

export async function getLocalTodos() {
  const db = await initDB();
  return await db.getAll(STORE_TODOS);
}

export async function saveLocalTodo(todo) {
  const db = await initDB();
  // 오프라인 신뢰성: updatedAt 타임스탬프 자동 추가
  const todoWithTimestamp = {
    ...todo,
    localUpdatedAt: Date.now(),
    _version: (todo._version || 0) + 1, // 낙관적 락 버전
  };
  await db.put(STORE_TODOS, todoWithTimestamp);
  return todoWithTimestamp;
}

export async function saveLocalTodosBatch(todos) {
  const db = await initDB();
  const tx = db.transaction(STORE_TODOS, 'readwrite');
  for (const todo of todos) {
    const todoWithTimestamp = {
      ...todo,
      localUpdatedAt: Date.now(),
      _version: (todo._version || 0) + 1,
    };
    tx.store.put(todoWithTimestamp);
  }
  await tx.done;
}

export async function deleteLocalTodo(id) {
  const db = await initDB();
  await db.delete(STORE_TODOS, id);
}

// ==================== 동기화 큐 개선 ====================

/**
 * 동기화 큐에 작업 추가 (개선된 버전)
 * @param {string} action - 'set' | 'delete'
 * @param {string} todoId - 할 일 ID
 * @param {object} payload - 작업 데이터
 * @param {object} options - 추가 옵션
 */
export async function addSyncQueue(action, todoId, payload = null, options = {}) {
  const db = await initDB();
  
  const queueItem = {
    action,
    todoId,
    payload,
    timestamp: Date.now(),
    retryCount: 0,
    priority: options.priority || calculatePriority(action, payload),
    lastError: null,
    nextRetryAt: null,
    // 충돌 해결용 메타데이터
    clientTimestamp: Date.now(),
    serverTimestamp: payload?.updatedAt || null,
  };
  
  // 동일한 todoId의 이전 대기 작업이 있으면 병합
  const existingQueue = await getSyncQueue();
  const existingItem = existingQueue.find(item => item.todoId === todoId && item.action === action);
  
  if (existingItem) {
    // 같은 작업이면 데이터 병합 (최신 데이터 우선)
    const mergedPayload = { ...existingItem.payload, ...payload, localUpdatedAt: Date.now() };
    await db.put(STORE_SYNC_QUEUE, {
      ...existingItem,
      payload: mergedPayload,
      timestamp: Date.now(), // 우선순위 갱신
      priority: queueItem.priority,
    });
  } else {
    await db.put(STORE_SYNC_QUEUE, queueItem);
  }
  
  // 오프라인 로그 기록
  await addOfflineLog('queue_add', { action, todoId, timestamp: queueItem.timestamp });
  
  return queueItem;
}

/**
 * 작업 우선순위 계산
 */
function calculatePriority(action, payload) {
  // delete > set (삭제가 더 중요 - 데이터 무결성)
  if (action === 'delete') return 1;
  // 완료 상태 변경은 높은 우선순위
  if (payload?.completed !== undefined) return 2;
  // 일반 수정
  return 3;
}

export async function getSyncQueue(options = {}) {
  const db = await initDB();
  const { prioritize = true, limit } = options;
  
  let queue = await db.getAll(STORE_SYNC_QUEUE);
  
  if (prioritize) {
    // 우선순위 정렬: priority asc, timestamp asc (오래된 것부터)
    queue.sort((a, b) => {
      if (a.priority !== b.priority) return a.priority - b.priority;
      return a.timestamp - b.timestamp;
    });
  }
  
  if (limit && limit > 0) {
    queue = queue.slice(0, limit);
  }
  
  return queue;
}

export async function getSyncQueueStats() {
  const queue = await getSyncQueue({ prioritize: false });
  return {
    total: queue.length,
    pending: queue.filter(item => !item.nextRetryAt || item.nextRetryAt <= Date.now()).length,
    retrying: queue.filter(item => item.retryCount > 0).length,
    failed: queue.filter(item => item.retryCount >= SYNC_CONFIG.MAX_RETRY_ATTEMPTS).length,
    byAction: {
      set: queue.filter(item => item.action === 'set').length,
      delete: queue.filter(item => item.action === 'delete').length,
    },
  };
}

export async function clearSyncQueue(id) {
  const db = await initDB();
  await db.delete(STORE_SYNC_QUEUE, id);
}

/**
 * 재시도 횟수 증가 및 다음 재시도 시간 계산 (지수 백오프)
 */
export async function incrementRetryCount(queueItem, error) {
  const db = await initDB();
  
  const newRetryCount = (queueItem.retryCount || 0) + 1;
  
  // 지수 백오프 + 지터 (무작위성 추가로 thundering herd 방지)
  const baseDelay = Math.min(
    SYNC_CONFIG.BASE_RETRY_DELAY_MS * Math.pow(2, newRetryCount - 1),
    SYNC_CONFIG.MAX_RETRY_DELAY_MS
  );
  const jitter = Math.random() * 0.3 * baseDelay; // ±30% 지터
  const nextRetryAt = Date.now() + baseDelay + jitter;
  
  const updated = {
    ...queueItem,
    retryCount: newRetryCount,
    lastError: error?.message || String(error),
    nextRetryAt,
  };
  
  await db.put(STORE_SYNC_QUEUE, updated);
  
  // 실패 로그 기록
  if (newRetryCount >= SYNC_CONFIG.MAX_RETRY_ATTEMPTS) {
    await addOfflineLog('sync_failed_permanent', {
      todoId: queueItem.todoId,
      action: queueItem.action,
      retryCount: newRetryCount,
      error: error?.message,
    });
  }
  
  return updated;
}

/**
 * 동기화 메타데이터 관리
 */
export async function setSyncMetadata(key, value) {
  const db = await initDB();
  await db.put(STORE_SYNC_METADATA, {
    key,
    value,
    updatedAt: Date.now(),
  });
}

export async function getSyncMetadata(key) {
  const db = await initDB();
  const result = await db.get(STORE_SYNC_METADATA, key);
  return result?.value;
}

/**
 * 오프라인 작업 로그
 */
export async function addOfflineLog(eventType, data) {
  const db = await initDB();
  await db.put(STORE_OFFLINE_LOG, {
    eventType,
    data,
    timestamp: Date.now(),
  });
}

export async function getOfflineLogs(limit = 100) {
  const db = await initDB();
  const logs = await db.getAll(STORE_OFFLINE_LOG);
  return logs.sort((a, b) => b.timestamp - a.timestamp).slice(0, limit);
}

export async function clearOfflineLogs() {
  const db = await initDB();
  const logs = await db.getAll(STORE_OFFLINE_LOG);
  const tx = db.transaction(STORE_OFFLINE_LOG, 'readwrite');
  for (const log of logs) {
    tx.store.delete(log.id);
  }
  await tx.done;
}

// ==================== 충돌 해결 ====================

/**
 * 타임스탬프 기반 충돌 해결
 * @param {object} localTodo - 로컬 데이터
 * @param {object} serverTodo - 서버 데이터
 * @returns {object} { winner: 'local' | 'server', merged: object }
 */
export function resolveConflict(localTodo, serverTodo) {
  const strategy = SYNC_CONFIG.CONFLICT_RESOLUTION_STRATEGY;
  
  const localTime = localTodo.localUpdatedAt || localTodo.updatedAt?.toMillis?.() || 0;
  const serverTime = serverTodo.updatedAt?.toMillis?.() || serverTodo.localUpdatedAt || 0;
  
  switch (strategy) {
    case 'server-wins':
      return { winner: 'server', merged: serverTodo };
    case 'client-wins':
      return { winner: 'local', merged: { ...serverTodo, ...localTodo, localUpdatedAt: Date.now() } };
    case 'timestamp':
    default:
      if (localTime > serverTime) {
        // 로컬이 더 최신 - 버전 증가 후 로컬 우선
        return {
          winner: 'local',
          merged: { ...localTodo, _version: (serverTodo._version || 0) + 1 },
        };
      } else {
        // 서버가 더 최신
        return { winner: 'server', merged: serverTodo };
      }
  }
}

// ==================== 네트워크 품질 측정 ====================

/**
 * 네트워크 품질 측정 및 저대역폭 감지
 */
export async function measureNetworkQuality() {
  try {
    const startTime = performance.now();
    // 작은 리소스로 핑 테스트 (Firebase 연결 확인용)
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);
    
    const response = await fetch('https://www.google.com/favicon.ico', {
      method: 'HEAD',
      signal: controller.signal,
      cache: 'no-cache',
    });
    
    clearTimeout(timeoutId);
    const endTime = performance.now();
    const latencyMs = endTime - startTime;
    
    // 대략적인 대역폭 추정 (간단한 휴리스틱)
    const estimatedKbps = latencyMs < 100 ? 1000 : latencyMs < 500 ? 100 : 50;
    
    return {
      isOnline: response.ok,
      latencyMs,
      estimatedKbps,
      isLowBandwidth: estimatedKbps < SYNC_CONFIG.LOW_BANDWIDTH_THRESHOLD_KBPS,
    };
  } catch (error) {
    return {
      isOnline: false,
      latencyMs: Infinity,
      estimatedKbps: 0,
      isLowBandwidth: true,
    };
  }
}

/**
 * 저대역폭 모드에서의 동기화 최적화
 */
export function shouldSyncInLowBandwidth(queueLength) {
  // 저대역폭 시 배치 크기 줄이고 주기 늘리기
  return {
    batchSize: Math.min(queueLength, 3), // 한 번에 최대 3개만
    enableCompression: true,
    retryImmediately: false,
  };
}

// 설정 내보내기
export { SYNC_CONFIG };

// 이전 버전 호환성을 위한 별칭
export const getAllSyncQueue = getSyncQueue;
