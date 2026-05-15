import { useCallback, useEffect, useMemo, useState } from 'react'
import { httpsCallable } from 'firebase/functions'
import { functions } from '../firebase'

const DEFAULT_STATUS = {
  daily: 0,
  monthly: 0,
  dailyLimit: 10,
  monthlyLimit: 100,
  remainingDaily: 10,
  remainingMonthly: 100,
  exhausted: false,
  exhaustedReason: null,
  unavailable: false,
}

export function useAiUsageQuota(user) {
  const [status, setStatus] = useState(DEFAULT_STATUS)
  const [loading, setLoading] = useState(false)

  const refresh = useCallback(async () => {
    if (!user) {
      setStatus(DEFAULT_STATUS)
      return DEFAULT_STATUS
    }

    setLoading(true)
    try {
      const getAiUsageStatus = httpsCallable(functions, 'getAiUsageStatus')
      const response = await getAiUsageStatus()
      const next = { ...DEFAULT_STATUS, ...(response?.data || {}), unavailable: false }
      setStatus(next)
      return next
    } catch (error) {
      console.warn('[AI Usage] status check failed:', error?.message || String(error))
      setStatus(prev => ({ ...prev, unavailable: true }))
      return null
    } finally {
      setLoading(false)
    }
  }, [user])

  const applyUsageStatus = useCallback((usage) => {
    if (!usage) return
    setStatus(prev => ({ ...prev, ...usage, unavailable: false }))
  }, [])

  const markExhausted = useCallback((reason = 'daily') => {
    setStatus(prev => ({
      ...prev,
      exhausted: true,
      exhaustedReason: reason,
      remainingDaily: reason === 'daily' ? 0 : prev.remainingDaily,
      remainingMonthly: reason === 'monthly' ? 0 : prev.remainingMonthly,
      daily: reason === 'daily' ? prev.dailyLimit : prev.daily,
      monthly: reason === 'monthly' ? prev.monthlyLimit : prev.monthly,
    }))
  }, [])

  useEffect(() => {
    refresh()
  }, [refresh])

  useEffect(() => {
    if (!user) return
    const timer = setInterval(refresh, 60000)
    return () => clearInterval(timer)
  }, [refresh, user])

  return useMemo(() => ({
    ...status,
    loading,
    refresh,
    applyUsageStatus,
    markExhausted,
  }), [applyUsageStatus, loading, markExhausted, refresh, status])
}
