/**
 * BrioDo Analytics — Firebase Analytics 래퍼
 *
 * 모든 이벤트는 docs/ANALYTICS.md 스키마를 따릅니다.
 * 측정 비활성 환경(Analytics 미지원/measurementId 없음)에서는 no-op으로 동작합니다.
 *
 * 사용:
 *   import { track, EVENTS } from './analytics'
 *   track(EVENTS.TODO_CREATE, { source: 'ai', has_calendar: true })
 */

import { logEvent, setUserId, setUserProperties } from 'firebase/analytics'
import { getAnalyticsInstance } from './firebase'

export const EVENTS = Object.freeze({
  FIRST_OPEN: 'first_open',
  SESSION_START: 'session_start',

  TODO_CREATE: 'todo_create',
  TODO_COMPLETE: 'todo_complete',
  TODO_DELETE: 'todo_delete',

  AI_INPUT_USED: 'ai_input_used',
  VOICE_INPUT_USED: 'voice_input_used',

  WIDGET_ADDED: 'widget_added',
  LOCKSCREEN_OPEN: 'lockscreen_open',

  ONBOARDING_START: 'onboarding_start',
  ONBOARDING_COMPLETE: 'onboarding_complete',
  ONBOARDING_SKIP: 'onboarding_skip',
})

const debug = import.meta.env.DEV
const APP_VERSION = '1.1.15'

export function track(eventName, params = {}) {
  const analytics = getAnalyticsInstance()
  const enriched = { ...params, app_version: APP_VERSION }
  if (debug) {
    console.log(`[Analytics] ${eventName}`, enriched)
  }
  if (!analytics) return
  try {
    logEvent(analytics, eventName, enriched)
  } catch (err) {
    console.warn(`[Analytics] Failed to log ${eventName}:`, err)
  }
}

export function identify(userId) {
  const analytics = getAnalyticsInstance()
  if (!analytics) return
  try {
    setUserId(analytics, userId)
  } catch (err) {
    console.warn('[Analytics] setUserId failed:', err)
  }
}

export function setProps(props) {
  const analytics = getAnalyticsInstance()
  if (!analytics) return
  try {
    setUserProperties(analytics, props)
  } catch (err) {
    console.warn('[Analytics] setUserProperties failed:', err)
  }
}

/**
 * `first_open`은 Firebase Analytics가 자동으로 측정하지만,
 * 코호트 정확도를 위해 localStorage 기반으로 한 번만 명시 호출합니다.
 */
const FIRST_OPEN_KEY = 'briodo-first-open-logged'
export function trackFirstOpenOnce() {
  try {
    if (localStorage.getItem(FIRST_OPEN_KEY)) return
    track(EVENTS.FIRST_OPEN)
    localStorage.setItem(FIRST_OPEN_KEY, String(Date.now()))
  } catch (err) {
    console.warn('[Analytics] trackFirstOpenOnce failed:', err)
  }
}
