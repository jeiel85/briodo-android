#!/usr/bin/env node
/**
 * BrioDo NLP 정확도 측정 스크립트
 *
 * 골든셋 (tests/nlp-golden/{lang}.json)을 Gemini에 보내고,
 * 정답과 비교하여 date/time/tag 정확도를 산출한다.
 *
 * 관련 이슈: #221
 *
 * Usage:
 *   node scripts/measure-nlp.js                       # 전체 언어
 *   node scripts/measure-nlp.js --lang=ko             # 한국어만
 *   node scripts/measure-nlp.js --id=ko-005           # 단건
 *   node scripts/measure-nlp.js --dry-run             # API 호출 없이 스키마 검증만
 *   node scripts/measure-nlp.js --model=gemini-2.5-flash  # 모델 override
 *
 * Env:
 *   GEMINI_API_KEY (또는 .env.local의 VITE_GEMINI_API_KEY)
 */

import { readFile, mkdir, writeFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'
import process from 'node:process'

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = join(__dirname, '..')
const GOLDEN_DIR = join(ROOT, 'tests', 'nlp-golden')
const REPORTS_DIR = join(GOLDEN_DIR, 'reports')

const DEFAULT_MODEL = 'gemini-2.5-flash-lite'
const SUPPORTED_LANGS = ['ko', 'en', 'ja', 'zh']

// ---- args ----
const args = process.argv.slice(2).reduce((acc, a) => {
  const m = a.match(/^--([a-zA-Z][a-zA-Z0-9-]*)(?:=(.+))?$/)
  if (m) acc[m[1]] = m[2] ?? true
  return acc
}, {})

const langFilter = args.lang ? [args.lang] : SUPPORTED_LANGS
const idFilter = args.id || null
const dryRun = !!args['dry-run']
const model = args.model || DEFAULT_MODEL

// ---- env ----
async function loadEnv() {
  for (const file of ['.env.local', '.env']) {
    try {
      const raw = await readFile(join(ROOT, file), 'utf8')
      for (const line of raw.split('\n')) {
        const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/)
        if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^["']|["']$/g, '')
      }
    } catch {
      // file not present — skip
    }
  }
}

// ---- prompt builder (App.jsx의 getAiFullAnalysis와 동일 스키마) ----
function buildPrompt(lang, input, today) {
  const date = new Date(today + 'T00:00:00')
  const dayNames = {
    ko: ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'],
    en: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    ja: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
    zh: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
  }
  const todayInfo = `${today} (${dayNames[lang][date.getDay()]})`

  if (lang === 'ja') {
    return `今日: ${todayInfo}\n入力: "${input}"\n\n以下のJSONのみで回答:\n{"categories":["タグ1"],"date":"YYYY-MM-DD","time":"HH:MM またはnull","refinedText":"要点"}\n\nルール:\n- categories: タスクのカテゴリタグ1~2個 (仕事,個人,健康,学習 など)\n- date: 日付(YYYY-MM-DD)。相対表現は今日を基準に計算\n- time: 時間があればHH:MM、なければnull\n- refinedText: 日付/時間を除いた要点`
  }
  if (lang === 'zh') {
    return `今天: ${todayInfo}\n输入: "${input}"\n\n只用以下JSON回复:\n{"categories":["标签1"],"date":"YYYY-MM-DD","time":"HH:MM 或 null","refinedText":"核心内容"}\n\n规则:\n- categories: 1-2个任务分类标签 (工作,个人,健康,学习 等)\n- date: 日期(YYYY-MM-DD)。相对表达从今天计算\n- time: 有时间则HH:MM，没有则null\n- refinedText: 去除日期/时间后的核心内容`
  }
  if (lang === 'en') {
    return `Today: ${todayInfo}\nInput: "${input}"\n\nRespond with ONLY this JSON:\n{"categories":["tag1"],"date":"YYYY-MM-DD","time":"HH:MM or null","refinedText":"core content"}\n\nRules:\n- categories: 1-2 task category tags (work, personal, health, study, etc.)\n- date: date (YYYY-MM-DD). Relative expressions calculated from today\n- time: HH:MM if specified, null if not\n- refinedText: core content without date/time`
  }
  return `오늘: ${todayInfo}\n입력: "${input}"\n\n반드시 아래 JSON만 응답하세요:\n{"categories":["태그1"],"date":"YYYY-MM-DD","time":"HH:MM 또는 null","refinedText":"핵심 내용"}\n\n규칙:\n- categories: 할일 성격 태그 1~2개 (업무,개인,건강,학습 등)\n- date: 날짜(YYYY-MM-DD). 상대적 표현은 오늘 기준 계산\n- time: 시간 있으면 HH:MM, 없으면 null\n- refinedText: 날짜/시간 제외한 핵심 내용`
}

// ---- Gemini caller (REST API, no extra deps) ----
async function callGemini(prompt, apiKey, modelName) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.1, responseMimeType: 'application/json' },
    }),
  })
  if (!res.ok) {
    const errText = await res.text()
    throw new Error(`HTTP ${res.status}: ${errText.slice(0, 200)}`)
  }
  const data = await res.json()
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text
  if (!text) throw new Error('No text in response')
  return text
}

function parseAnalysis(rawText) {
  const cleaned = rawText.replace(/```json|```/g, '').trim()
  const match = cleaned.match(/\{[\s\S]*\}/)
  if (!match) throw new Error('No JSON in response')
  const obj = JSON.parse(match[0])
  if (obj.date && !/^\d{4}-\d{2}-\d{2}$/.test(obj.date)) obj.date = null
  if (obj.time === 'null') obj.time = null
  return obj
}

// ---- comparators ----
function dateMatches(expected, actual) {
  return (expected ?? null) === (actual ?? null)
}
function timeMatches(expected, actual) {
  return (expected ?? null) === (actual ?? null)
}
function tagOverlaps(expected, actual) {
  const exp = (expected ?? []).map(String)
  const act = (actual ?? []).map(String)
  if (exp.length === 0) return true
  return exp.some((t) => act.includes(t))
}

// ---- schema validation (dry-run mode에서도 동작) ----
function validateCase(c) {
  const errors = []
  if (!c.id || !/^[a-z]{2}-\d{3}$/.test(c.id)) errors.push('id format invalid (expected: xx-NNN)')
  if (!c.input || typeof c.input !== 'string') errors.push('input missing')
  if (!c.today || !/^\d{4}-\d{2}-\d{2}$/.test(c.today)) errors.push('today must be YYYY-MM-DD')
  if (!c.expected) errors.push('expected missing')
  else {
    if (c.expected.date !== null && !/^\d{4}-\d{2}-\d{2}$/.test(c.expected.date ?? '')) errors.push('expected.date must be YYYY-MM-DD or null')
    if (c.expected.time !== null && !/^\d{2}:\d{2}$/.test(c.expected.time ?? '')) errors.push('expected.time must be HH:MM or null')
    if (!Array.isArray(c.expected.categories)) errors.push('expected.categories must be array')
  }
  return errors
}

// ---- main per-lang runner ----
async function runLang(lang, apiKey) {
  const path = join(GOLDEN_DIR, `${lang}.json`)
  let cases
  try {
    cases = JSON.parse(await readFile(path, 'utf8'))
  } catch (e) {
    console.warn(`[${lang}] cannot load ${path}: ${e.message}`)
    return null
  }

  if (idFilter) {
    cases = cases.filter((c) => c.id === idFilter)
    if (cases.length === 0) return null
  }

  // schema validation first
  const schemaIssues = []
  for (const c of cases) {
    const errs = validateCase(c)
    if (errs.length > 0) schemaIssues.push({ id: c.id ?? '<no-id>', errors: errs })
  }
  if (schemaIssues.length > 0) {
    console.error(`[${lang}] Schema validation failed:`)
    for (const s of schemaIssues) console.error(`  - ${s.id}: ${s.errors.join('; ')}`)
    return { lang, summary: { total: cases.length, schema_errors: schemaIssues.length }, failures: [] }
  }

  if (dryRun) {
    console.log(`[${lang}] Dry run OK — ${cases.length} cases, schema valid.`)
    return { lang, summary: { total: cases.length, dry_run: true }, failures: [] }
  }

  if (cases.length === 0) {
    console.log(`[${lang}] No cases. Skipping.`)
    return null
  }

  const failures = []
  let dateOk = 0, timeOk = 0, tagOk = 0, allOk = 0

  for (let i = 0; i < cases.length; i++) {
    const c = cases[i]
    process.stdout.write(`[${lang}] ${i + 1}/${cases.length} ${c.id}... `)
    try {
      const prompt = buildPrompt(lang, c.input, c.today)
      const raw = await callGemini(prompt, apiKey, model)
      const actual = parseAnalysis(raw)
      const dOk = dateMatches(c.expected.date, actual.date)
      const tOk = timeMatches(c.expected.time, actual.time)
      const gOk = tagOverlaps(c.expected.categories, actual.categories)
      if (dOk) dateOk++
      if (tOk) timeOk++
      if (gOk) tagOk++
      if (dOk && tOk && gOk) {
        allOk++
        process.stdout.write('OK\n')
      } else {
        const reasons = []
        if (!dOk) reasons.push(`date ${c.expected.date} ≠ ${actual.date}`)
        if (!tOk) reasons.push(`time ${c.expected.time} ≠ ${actual.time}`)
        if (!gOk) reasons.push(`tags ${JSON.stringify(c.expected.categories)} ∩ ${JSON.stringify(actual.categories)} = ∅`)
        process.stdout.write(`FAIL — ${reasons.join('; ')}\n`)
        failures.push({ id: c.id, input: c.input, expected: c.expected, actual, reasons })
      }
    } catch (e) {
      process.stdout.write(`ERROR — ${e.message}\n`)
      failures.push({ id: c.id, input: c.input, expected: c.expected, actual: null, reasons: [`exception: ${e.message}`] })
    }
    // 짧은 rate limit 회피
    await new Promise((r) => setTimeout(r, 200))
  }

  const total = cases.length
  return {
    lang,
    summary: {
      total,
      date_accuracy: +(dateOk / total).toFixed(4),
      time_accuracy: +(timeOk / total).toFixed(4),
      tag_overlap: +(tagOk / total).toFixed(4),
      overall: +(allOk / total).toFixed(4),
    },
    failures,
  }
}

async function main() {
  await loadEnv()
  const apiKey = process.env.GEMINI_API_KEY || process.env.VITE_GEMINI_API_KEY

  if (!dryRun && !apiKey) {
    console.error('ERROR: GEMINI_API_KEY (or VITE_GEMINI_API_KEY) not set in env or .env/.env.local')
    process.exit(1)
  }

  console.log(`[measure-nlp] model=${model} dry_run=${dryRun} langs=${langFilter.join(',')}${idFilter ? ' id=' + idFilter : ''}\n`)

  const results = []
  for (const lang of langFilter) {
    const result = await runLang(lang, apiKey)
    if (result) results.push(result)
  }

  const report = {
    timestamp: new Date().toISOString(),
    model,
    dry_run: dryRun,
    args: { lang: args.lang ?? null, id: idFilter, model_override: !!args.model },
    summary: Object.fromEntries(results.map((r) => [r.lang, r.summary])),
    failures: results.flatMap((r) => r.failures.map((f) => ({ lang: r.lang, ...f }))),
  }

  console.log('\n=== SUMMARY ===')
  for (const r of results) {
    if (r.summary.dry_run) {
      console.log(`  ${r.lang}: schema OK (${r.summary.total} cases)`)
    } else if (r.summary.schema_errors) {
      console.log(`  ${r.lang}: SCHEMA ERRORS ${r.summary.schema_errors}/${r.summary.total}`)
    } else {
      console.log(`  ${r.lang}: overall=${(r.summary.overall * 100).toFixed(1)}%  date=${(r.summary.date_accuracy * 100).toFixed(1)}%  time=${(r.summary.time_accuracy * 100).toFixed(1)}%  tag=${(r.summary.tag_overlap * 100).toFixed(1)}%  (n=${r.summary.total})`)
    }
  }

  if (!dryRun && results.length > 0) {
    await mkdir(REPORTS_DIR, { recursive: true })
    const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
    const reportPath = join(REPORTS_DIR, `${stamp}.json`)
    await writeFile(reportPath, JSON.stringify(report, null, 2), 'utf8')
    console.log(`\nReport: ${reportPath}`)
  }

  // exit 1 if any failures (CI에서 활용 가능)
  const hasFailures = results.some((r) => r.failures && r.failures.length > 0)
  process.exit(hasFailures && !dryRun ? 1 : 0)
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
