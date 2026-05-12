## BrioDo v1.1.12

### 주요 변경
- **Top 10 진입 측정 인프라 도입(#253)**: Firebase Analytics 통합으로 D1/D7/D30 리텐션과 핵심 funnel을 측정할 수 있게 했습니다. 사용자 가시 변화 없음, 측정 코드만 추가.
- **리뷰 응답 SLA 운영 시작(#252)**: Play Store 리뷰에 24시간 내 응답하는 운영 정책과 카피 템플릿(버그/요청/오해/긍정) 4개 언어 도입.
- **AI 자연어 정확도 KPI 인프라(#221)**: 한국어 30개 골든셋과 측정 스크립트, CI 수동 트리거 워크플로우 추가. 분기별 정확도 회귀 측정 가능.
- **Top 10 진입 6개월 로드맵 재구성**: "기능 100개 = Top 10 진입" 가정을 폐기하고 Growth 운영(ASO/리텐션/바이럴) 중심 전략으로 재편. P0 20개 → 16개(Growth 11 + 차별점 5)로 압축.

### 기술 변경

#### 1. Firebase Analytics 통합 (src/analytics.js 신규 + 6개 파일 계측)
- `src/analytics.js`: `track()`/`identify()`/`EVENTS` 래퍼. measurementId 미설정 시 자동 no-op
- `src/firebase.js`: `measurementId` 설정 + `isAnalyticsSupported()` 가드
- 13개 표준 이벤트 계측:
  - 생애주기: `first_open`, `session_start`
  - Todo: `todo_create`(source: manual/ai/voice/widget), `todo_complete`(age_seconds), `todo_delete`
  - AI/음성: `ai_input_used`(lang/has_date/has_time/has_tag), `voice_input_used`(native/web)
  - 차별점: `widget_added`, `lockscreen_open` (placeholder, 후속 PR)
  - 구독: `subscription_view`
  - 온보딩: `onboarding_start`/`complete`/`skip`
- 환경변수: `VITE_FIREBASE_MEASUREMENT_ID`
- 모든 파라미터에 `app_version` 자동 부착, PII 마스킹은 기존 `maskPII` 그대로 활용

#### 2. NLP 정확도 골든셋 (#221 토대)
- `tests/nlp-golden/SCHEMA.md`: 스키마 정의 + 작성 가이드 + KPI 목표(한국어 99%)
- `tests/nlp-golden/ko.json`: 30 cases (easy 17 / medium 8 / hard 5) — 절대/상대 날짜, 시간 형식, 종일, 모호 표현, edge case
- `tests/nlp-golden/{en,ja,zh}.json`: empty placeholder
- `scripts/measure-nlp.js`: Gemini REST API 직접 호출, dry-run/단건/언어 필터/모델 override 지원
- `.github/workflows/nlp-accuracy.yml`: 수동 트리거(workflow_dispatch) + PR 시 schema 검증만
- `package.json`: `test:nlp`, `test:nlp:dry` 스크립트 추가

#### 3. 운영 문서 신규/갱신
- `SPRINT_PLAN.md`: 전면 재작성 — Month 1~6 단계별 로드맵, KPI 표, 위험 요소
- `TOP10_BLUEPRINT.md`: 옛 P0 기준임을 명시하는 deprecation 노트 추가
- `README.md`: v1.1.11 최신 기능(#145/#146 등) 및 새 아키텍처 반영
- `docs/ANALYTICS.md`: 13개 이벤트 스키마 + BigQuery 코호트 SQL 예시
- `docs/REVIEW_SLA.md`: 별점 4.6+ 운영 SLA, 카피 가이드, 에스컬레이션 정책
- `docs/marketing/`: 자산 디렉토리 + COPY_GUIDE.md(4개 언어) + 영상 시나리오
- `docs/marketing/review-templates/`: 리뷰 응답 템플릿 4종 × 4개 언어

#### 4. GitHub 이슈 정리
- Open 108 → 104: 중복 #151, 구현 완료 #145/#146/#196 close
- P 라벨 중복 26건 → 0건 (Security/Performance P2 유지, Other P3 유지)
- P0 재구성: 따라잡기 기능 15개 P2로 강등, Growth 운영 11개 신규/재오픈 (#134/#135/#136/#149/#221/#252~#257)
- 신규 `growth` 라벨

#### 5. 버전 메타데이터
- `src/App.jsx`: `APP_VERSION` `1.1.12`
- `android/app/build.gradle`: `versionName 1.1.12`, `versionCode 24`

### 기대 효과
- 측정 가능한 baseline 확보 → 다음 릴리즈부터 데이터 기반 의사결정
- 리뷰 응답 운영으로 별점 평균 상승 → ASO 노출 가산점
- NLP 정확도 회귀 방지 → 차별점 침식 차단
- 100개 기능 나열 대신 차별점 압축 + Growth 운영 → Top 10 진입 경로 명확화

### 후속 작업 (다음 릴리즈)
- v1.1.12 출시 후 D1/D7/D30 baseline 측정 (BigQuery)
- 한국어 골든셋 30 → 200 케이스로 확장
- #149 친구 초대 보상 프로그램 구현 시작
- #135 바이럴 공유 카드 + #168 공유 UI 통합

### 사용자 가시 변화
- **없음**. 측정/운영 인프라 릴리즈입니다. UI/기능 변경 없음.
- 다음 v1.2.0부터 가시 변화 시작 (온보딩 개선, 공유 카드, 친구 초대 등).
