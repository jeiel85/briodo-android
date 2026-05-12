import { initializeApp } from "firebase/app"
import { getAuth, GoogleAuthProvider } from "firebase/auth"
import { getFirestore } from "firebase/firestore"
import { getFunctions } from "firebase/functions"
import { getAnalytics, isSupported as isAnalyticsSupported } from "firebase/analytics"

// Firebase App Check - 환경 변수에 따라 활성화 여부 결정
const APP_CHECK_ENABLED = import.meta.env.VITE_APP_CHECK_ENABLED === 'true'

if (APP_CHECK_ENABLED) {
  console.log('[AppCheck] App Check is enabled for this environment')
}

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID
}

// Firebase 설정 유효성 검사
if (!firebaseConfig.apiKey || firebaseConfig.apiKey.includes('placeholder')) {
  console.warn('[Firebase] Warning: Firebase API Key is missing or using a placeholder value.')
  console.warn('[Firebase] Current Config:', { ...firebaseConfig, apiKey: '***' })
}

let fbApp
let auth
let db
let functions
let analytics = null

try {
  fbApp = initializeApp(firebaseConfig)
  auth = getAuth(fbApp)
  db = getFirestore(fbApp)
  functions = getFunctions(fbApp, "asia-northeast3")
} catch (error) {
  console.error('[Firebase] Critical initialization error:', error)
  // 폴백: 서비스 호출 시 에러가 나더라도 모듈 로딩은 성공하도록 설정
  fbApp = fbApp || {}
  auth = auth || { currentUser: null, onAuthStateChanged: (cb) => { cb(null); return () => {} } }
  db = db || {}
  functions = functions || {}
}

// Analytics는 지원되는 환경에서만 초기화 (SSR/Node/일부 브라우저 제외)
if (firebaseConfig.measurementId && fbApp.name) {
  isAnalyticsSupported()
    .then((supported) => {
      if (supported) {
        analytics = getAnalytics(fbApp)
        console.log('[Analytics] Firebase Analytics initialized')
      }
    })
    .catch((err) => console.warn('[Analytics] Support check failed:', err))
}

export const getAnalyticsInstance = () => analytics

export { fbApp, auth, db, functions }

export const googleProvider = new GoogleAuthProvider()
googleProvider.addScope('https://www.googleapis.com/auth/calendar.app.created')

// Firebase App Check 초기화 - 현재 비활성화 (릴리즈 시 활성화)
// eslint-disable-next-line no-unused-vars
export const initAppCheck = () => {
  if (!APP_CHECK_ENABLED) {
    console.log('[AppCheck] Disabled - set APP_CHECK_ENABLED = true to enable')
    return
  }

  try {
    // Dynamic import to avoid loading when disabled
    import('firebase/app-check').then(({ initializeAppCheck, ReCaptchaEnterpriseProvider }) => {
      const reCaptchaEnterpriseProvider = new ReCaptchaEnterpriseProvider()
      initializeAppCheck(fbApp, {
        provider: reCaptchaEnterpriseProvider,
        isTokenAutoRefreshEnabled: true
      })
      console.log('[AppCheck] Initialized with Play Integrity')
    }).catch(err => {
      console.error('[AppCheck] Failed to load:', err)
    })
  } catch (error) {
    console.error('[AppCheck] Initialization failed:', error)
  }
}

// Pro Features - 릴리즈 시 활성화
export const PRO_ENABLED = true

// 구독 설정
export const SUBSCRIPTION_CONFIG = {
  enabled: true,
  trialDays: 7, // 묶음 체험 기간
  gracePeriodDays: 3, // 구독 만료 후 유예 기간
}
