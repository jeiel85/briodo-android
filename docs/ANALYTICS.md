# BrioDo Analytics 이벤트 스키마

**버전**: v1 (2026-05-12 도입)
**측정 도구**: Firebase Analytics (Web SDK) → BigQuery → Looker Studio
**관련 이슈**: [#253](https://github.com/jeiel85/BrioDo/issues/253)

## 목적

D1/D7/D30 리텐션 측정과 핵심 액션 funnel 분석을 위한 표준 이벤트 정의. *Top 10 진입 KPI*의 측정 기반입니다.

## 환경 설정

```env
# .env에 추가 (Firebase Console > 프로젝트 설정 > 일반 > 내 앱 > measurementId)
VITE_FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX
```

`measurementId`가 없으면 Analytics는 자동으로 no-op 모드로 동작합니다. 로컬 개발에서는 굳이 설정할 필요 없으며, 콘솔에 `[Analytics] event_name {...}` 로그만 출력됩니다.

## 사용법

```js
import { track, EVENTS } from './analytics'

track(EVENTS.TODO_CREATE, { source: 'ai', has_calendar: true })
```

모든 이벤트에는 자동으로 `app_version`이 부착됩니다.

## 이벤트 카탈로그

### 세션/생애주기

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `first_open` | (자동) | 앱 최초 실행 1회만. `localStorage`로 가드 |
| `session_start` | `platform`: `'android' \| 'web' \| 'ios'` | 앱 시작 시 매번 |

### Todo 액션 (핵심 funnel)

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `todo_create` | `source`: `'manual' \| 'ai' \| 'voice' \| 'widget' \| 'lockscreen'`, `has_calendar`: boolean | 할 일 생성 |
| `todo_complete` | `has_subtasks`: boolean, `age_seconds`: number | 할 일 완료. `age_seconds` = 생성 후 경과 시간 |
| `todo_delete` | `reason`: `'manual' \| 'recurring'` | 삭제 |

### AI / 음성

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `ai_input_used` | `lang`: `'ko' \| 'en' \| 'ja' \| 'zh'`, `success`: boolean, `has_date`: boolean, `has_time`: boolean, `has_tag`: boolean | AI 자연어 파싱 1회 |
| `voice_input_used` | `lang`, `success`: boolean | 음성 인식 1회 |

### 차별점 기능 (위젯/잠금화면)

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `widget_added` | `size`: `'1x1' \| '2x2' \| '4x2'` (#152 후) | 위젯 설치 |
| `lockscreen_open` | (없음) | 잠금화면 위젯 진입 |

### 구독

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `subscription_view` | `plan_viewed`: `'monthly' \| 'yearly' \| 'family' \| 'all'` | Pro 모달 열림 |
| `subscription_purchase` | `plan`, `price_krw`: number | 결제 완료 (placeholder, #209 연동 시 활성화) |

### 온보딩

| 이벤트 | 파라미터 | 설명 |
|--------|---------|------|
| `onboarding_start` | (없음) | 온보딩 모달 노출 |
| `onboarding_complete` | `seconds_spent`: number | 끝까지 완료 |
| `onboarding_skip` | `step`: number | 중간 이탈 |

## 코호트/Funnel 분석

### D1/D7/D30 리텐션 코호트 (BigQuery 예시)

```sql
WITH cohort AS (
  SELECT
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(MIN(event_timestamp))) AS install_date
  FROM `<PROJECT>.analytics_<ID>.events_*`
  WHERE event_name = 'first_open'
  GROUP BY user_pseudo_id
),
returns AS (
  SELECT DISTINCT
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS open_date
  FROM `<PROJECT>.analytics_<ID>.events_*`
  WHERE event_name = 'session_start'
)
SELECT
  c.install_date,
  COUNT(DISTINCT c.user_pseudo_id) AS cohort_size,
  COUNT(DISTINCT IF(DATE_DIFF(r.open_date, c.install_date, DAY) = 1, c.user_pseudo_id, NULL)) AS d1,
  COUNT(DISTINCT IF(DATE_DIFF(r.open_date, c.install_date, DAY) = 7, c.user_pseudo_id, NULL)) AS d7,
  COUNT(DISTINCT IF(DATE_DIFF(r.open_date, c.install_date, DAY) = 30, c.user_pseudo_id, NULL)) AS d30
FROM cohort c
LEFT JOIN returns r USING (user_pseudo_id)
GROUP BY c.install_date
ORDER BY c.install_date DESC;
```

### 핵심 funnel

`first_open` → `session_start` → `todo_create` → `todo_complete`

각 단계별 전환율을 측정해 D1 리텐션이 떨어지는 구간을 식별합니다.

## 운영 원칙

1. **새 이벤트 추가 시 본 문서를 먼저 갱신.** PR에 스키마 변경 명시.
2. **개인정보(PII)는 절대 파라미터로 보내지 않음.** 할 일 내용, 사용자 이름, 이메일 등 금지.
3. **이벤트 이름은 snake_case.** Firebase Analytics 표준 따름.
4. **파라미터는 Firebase Analytics 한도 준수**: 이벤트당 최대 25개 파라미터, 파라미터 값 100자.
5. **고카디널리티 값 피함.** 예: 타임스탬프 raw 값, UUID — 대신 bucket으로.

## 다음 단계

- [ ] Capacitor 네이티브 측정으로 확장 (`@capacitor-firebase/analytics`) — Android Advertising ID 기반 정확도 향상
- [ ] BigQuery 일일 export 활성화 (Firebase Console)
- [ ] Looker Studio 대시보드 구성
- [ ] Funnel 전환율 baseline 측정 → MEMORY 기록
