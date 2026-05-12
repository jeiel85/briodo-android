import { useState, useMemo } from 'react'
import { translations } from '../constants/translations'

const PREF_KEY = 'briodo-lang-pref'

function getSystemLang() {
  const sysLang = navigator.language.split('-')[0]
  return ['en', 'ja', 'zh'].includes(sysLang) ? sysLang : 'ko'
}

export function useLanguage() {
  const [langPref, setLangPref] = useState(() => {
    return localStorage.getItem(PREF_KEY) || 'auto'
  })

  const lang = langPref === 'auto' ? getSystemLang() : langPref

  // t는 두 가지 방식 모두 지원:
  //   t.key          (객체 액세스 — 권장)
  //   t('key')       (함수 호출 — 레거시 호환)
  // 일부 호출 지점이 함수처럼 사용하고 있어 양쪽 모두 안전하게 동작하도록 한다.
  const t = useMemo(() => {
    const dict = translations[lang] || translations.ko
    const fn = (key) => dict[key]
    Object.assign(fn, dict)
    return fn
  }, [lang])

  const setLangPrefAndSave = (pref) => {
    setLangPref(pref)
    localStorage.setItem(PREF_KEY, pref)
  }

  return { lang, langPref, setLangPref: setLangPrefAndSave, t }
}
