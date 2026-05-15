import { useCallback, useState } from 'react'

/**
 * Pro monetization is intentionally paused.
 *
 * Keep this hook as a compatibility boundary so existing callers can safely
 * ask about feature access without exposing subscription terms or prices in
 * the app until the paid offering is ready for review again.
 */
export const PRO_ENABLED = false

export const PRO_PLANS = {}

export const PRO_LIMITS = {
  FREE: {
    ai_requests_per_day: Infinity,
    custom_themes: true,
    ads: false,
    advanced_stats: true,
    priority_sync: true,
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

export function useSubscription() {
  const [loading] = useState(false)

  const checkSubscription = useCallback(async () => false, [])
  const canUseAi = useCallback(() => true, [])
  const canUseProFeature = useCallback((feature) => PRO_LIMITS.FREE[feature] !== false, [])
  const getRemainingAiRequests = useCallback(() => Infinity, [])
  const incrementAiUsage = useCallback(async () => true, [])
  const startSubscription = useCallback(async () => {
    throw new Error('Pro monetization is currently paused.')
  }, [])
  const cancelSubscription = useCallback(async () => {}, [])

  return {
    isPro: false,
    subscription: null,
    loading,
    error: null,
    aiUsageToday: 0,
    plans: PRO_PLANS,
    limits: PRO_LIMITS.FREE,
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
