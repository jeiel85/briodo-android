import { useState, useEffect, useCallback } from 'react'
import { doc, getDoc, setDoc, onSnapshot, serverTimestamp } from 'firebase/firestore'
import { db } from '../firebase'

/**
 * Pro 구독 플랜 타입
 */
export const PRO_PLANS = {
  MONTHLY: {
    id: 'pro_monthly',
    name: 'Pro Monthly',
    price: 4900, // KRW
    period: 'month',
    features: [
      'unlimited_ai',
      'custom_themes',
      'no_ads',
      'advanced_stats',
      'priority_sync',
    ],
  },
  YEARLY: {
    id: 'pro_yearly',
    name: 'Pro Yearly',
    price: 39900, // KRW
    period: 'year',
    discount: 32, // %
    features: [
      'unlimited_ai',
      'custom_themes',
      'no_ads',
      'advanced_stats',
      'priority_sync',
      'family_sharing', // 연간 플랜만
    ],
  },
  FAMILY: {
    id: 'pro_family',
    name: 'Pro Family',
    price: 8900, // KRW
    period: 'month',
    features: [
      'unlimited_ai',
      'custom_themes',
      'no_ads',
      'advanced_stats',
      'priority_sync',
      'family_sharing',
      'up_to_6_members',
    ],
  },
}

/**
 * Pro 기능 제한 설정
 */
export const PRO_LIMITS = {
  FREE: {
    ai_requests_per_day: 10,
    custom_themes: false,
    ads: true,
    advanced_stats: false,
    priority_sync: false,
    family_sharing: false,
  },
  PRO: {
    ai_requests_per_day: Infinity,
    custom_themes: true,
    ads: false,
    advanced_stats: true,
    priority_sync: true,
    family_sharing: true,
  },
}

/**
 * Pro 구독 상태 관리 훅
 */
export function useSubscription(user) {
  const [subscription, setSubscription] = useState(null)
  const [isPro, setIsPro] = useState(false)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [aiUsageToday, setAiUsageToday] = useState(0)

  /**
   * 구독 상태 확인
   */
  const checkSubscription = useCallback(async () => {
    if (!user) {
      setIsPro(false)
      setSubscription(null)
      setLoading(false)
      return false
    }

    try {
      const subRef = doc(db, 'subscriptions', user.uid)
      const subSnap = await getDoc(subRef)
      
      if (subSnap.exists()) {
        const subData = subSnap.data()
        const isActive = subData.status === 'active' && 
          subData.expiresAt?.toMillis() > Date.now()
        
        setSubscription(subData)
        setIsPro(isActive)
        return isActive
      } else {
        setSubscription(null)
        setIsPro(false)
        return false
      }
    } catch (err) {
      console.error('Subscription check error:', err)
      setError(err.message)
      return false
    }
  }, [user])

  /**
   * AI 사용량 확인
   */
  const checkAiUsage = useCallback(async () => {
    if (!user) {
      setAiUsageToday(0)
      return
    }

    try {
      const today = new Date().toISOString().split('T')[0]
      const usageRef = doc(db, 'aiUsage', `${user.uid}_${today}`)
      const usageSnap = await getDoc(usageRef)
      
      if (usageSnap.exists()) {
        setAiUsageToday(usageSnap.data().count || 0)
      } else {
        setAiUsageToday(0)
      }
    } catch (err) {
      console.error('AI usage check error:', err)
      setAiUsageToday(0)
    }
  }, [user])

  /**
   * AI 사용량 증가
   */
  const incrementAiUsage = useCallback(async () => {
    if (!user) return false

    try {
      const today = new Date().toISOString().split('T')[0]
      const usageRef = doc(db, 'aiUsage', `${user.uid}_${today}`)
      
      // 로컬 상태 먼저 업데이트
      setAiUsageToday(prev => prev + 1)
      
      // Firestore 업데이트
      await setDoc(usageRef, {
        userId: user.uid,
        date: today,
        count: aiUsageToday + 1,
        updatedAt: serverTimestamp(),
      }, { merge: true })
      
      return true
    } catch (err) {
      console.error('AI usage increment error:', err)
      return false
    }
  }, [user, aiUsageToday])

  /**
   * AI 사용 가능 여부 확인
   */
  const canUseAi = useCallback(() => {
    if (isPro) return true
    return aiUsageToday < PRO_LIMITS.FREE.ai_requests_per_day
  }, [isPro, aiUsageToday])

  /**
   * 남은 AI 사용 횟수
   */
  const getRemainingAiRequests = useCallback(() => {
    if (isPro) return Infinity
    return Math.max(0, PRO_LIMITS.FREE.ai_requests_per_day - aiUsageToday)
  }, [isPro, aiUsageToday])

  /**
   * Pro 기능 사용 가능 여부 확인
   */
  const canUseProFeature = useCallback((feature) => {
    if (isPro) return true
    return PRO_LIMITS.FREE[feature] !== false
  }, [isPro])

  /**
   * 구독 시작 (실제 결제는 별도로 처리)
   */
  const startSubscription = useCallback(async (planId, paymentMethod = 'test') => {
    if (!user) throw new Error('User not authenticated')

    try {
      const plan = Object.values(PRO_PLANS).find(p => p.id === planId)
      if (!plan) throw new Error('Invalid plan')

      const now = new Date()
      const expiresAt = new Date(now)
      
      if (plan.period === 'month') {
        expiresAt.setMonth(expiresAt.getMonth() + 1)
      } else if (plan.period === 'year') {
        expiresAt.setFullYear(expiresAt.getFullYear() + 1)
      }

      const subscriptionData = {
        userId: user.uid,
        planId: plan.id,
        planName: plan.name,
        status: 'active',
        paymentMethod,
        startedAt: serverTimestamp(),
        expiresAt: serverTimestamp(expiresAt),
        updatedAt: serverTimestamp(),
        features: plan.features,
      }

      await setDoc(doc(db, 'subscriptions', user.uid), subscriptionData)
      
      // 구독 시작 이벤트 로그
      await setDoc(doc(db, 'subscriptionEvents', `${user.uid}_${Date.now()}`), {
        userId: user.uid,
        event: 'subscription_started',
        planId: plan.id,
        timestamp: serverTimestamp(),
      })

      setSubscription(subscriptionData)
      setIsPro(true)
      
      return subscriptionData
    } catch (err) {
      console.error('Subscription start error:', err)
      setError(err.message)
      throw err
    }
  }, [user])

  /**
   * 구독 취소
   */
  const cancelSubscription = useCallback(async () => {
    if (!user || !subscription) return

    try {
      await setDoc(doc(db, 'subscriptions', user.uid), {
        status: 'cancelled',
        cancelledAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }, { merge: true })

      // 구독 취소 이벤트 로그
      await setDoc(doc(db, 'subscriptionEvents', `${user.uid}_${Date.now()}`), {
        userId: user.uid,
        event: 'subscription_cancelled',
        planId: subscription.planId,
        timestamp: serverTimestamp(),
      })

      setSubscription(prev => ({ ...prev, status: 'cancelled' }))
    } catch (err) {
      console.error('Subscription cancel error:', err)
      setError(err.message)
    }
  }, [user, subscription])

  // 실시간 구독 상태 구독
  useEffect(() => {
    if (!user) {
      setIsPro(false)
      setSubscription(null)
      setLoading(false)
      return
    }

    setLoading(true)
    
    const subRef = doc(db, 'subscriptions', user.uid)
    const unsubscribe = onSnapshot(subRef, (doc) => {
      if (doc.exists()) {
        const subData = doc.data()
        const isActive = subData.status === 'active' && 
          subData.expiresAt?.toMillis() > Date.now()
        
        setSubscription(subData)
        setIsPro(isActive)
      } else {
        setSubscription(null)
        setIsPro(false)
      }
      setLoading(false)
    }, (err) => {
      console.error('Subscription snapshot error:', err)
      setError(err.message)
      setLoading(false)
    })

    // AI 사용량 확인
    checkAiUsage()

    return () => unsubscribe()
  }, [user, checkAiUsage])

  // AI 사용량 주기적 갱신
  useEffect(() => {
    if (!user) return
    
    const interval = setInterval(checkAiUsage, 60000) // 1분마다 갱신
    return () => clearInterval(interval)
  }, [user, checkAiUsage])

  return {
    // 상태
    isPro,
    subscription,
    loading,
    error,
    aiUsageToday,
    
    // 상수
    plans: PRO_PLANS,
    limits: isPro ? PRO_LIMITS.PRO : PRO_LIMITS.FREE,
    
    // 메서드
    checkSubscription,
    canUseAi,
    canUseProFeature,
    getRemainingAiRequests,
    incrementAiUsage,
    startSubscription,
    cancelSubscription,
  }
}

export default useSubscription
