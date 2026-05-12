# BrioDo — Top 10 진입 6개월 로드맵

**목표**: Play Store 한국 **생산성 카테고리 Top 10** 진입
**기간**: 2026-05-12 ~ 2026-11-12 (26주)
**버전 마일스톤**: v1.2.0 (Month 3) · v1.3.0 (Month 6)
**작성**: 2026-05-12 (전략 재구성)

> ⚠️ **이전 SPRINT_PLAN의 가정을 폐기합니다.** "기능 100개를 다 만들면 Top 10에 진입한다"는 가정은 틀렸습니다. Top 10은 *코드 게임*이 아니라 *Distribution & Retention 게임*입니다. 이 문서는 그 가정 위에 다시 작성됐습니다.

---

## 📐 전략 핵심 4가지

| 원칙 | 의미 |
|------|------|
| **1. 차별점 압축** | 100개 기능 나열이 아니라 *2개 무기*(잠금화면 위젯, AI 자연어)를 극단적으로 강화 |
| **2. Growth 운영** | 코드 이슈와 별개로 ASO/리텐션/바이럴을 **상시 운영 항목**으로 트래킹 (`growth` 라벨) |
| **3. 측정 기반** | 모든 의사결정은 D1/D7/D30 리텐션, 별점, K-factor 데이터로 |
| **4. 솔로 캐파 인정** | 월 2~3개 P0를 처리하는 현실 속도로 설계. 무리한 일정으로 동기 잃지 않기 |

---

## 🎯 KPI (성공 지표)

| 지표 | 시작 (2026-05) | Month 3 | Month 6 (Top 10 목표) |
|------|---------------|---------|----------------------|
| **D1 리텐션** | 측정 안 됨 | 40% | 60% |
| **D7 리텐션** | 측정 안 됨 | 25% | 40% |
| **D30 리텐션** | 측정 안 됨 | 15% | 25% |
| **Play Store 별점** | 4.x | 4.5+ | **4.6+ with 1000+ 리뷰** |
| **K-factor (바이럴 계수)** | 0 | 0.1 | **0.2+** |
| **MAU** | ? | 1만 | **10만** |
| **AI 자연어 정확도 (한국어)** | ? | 95% | **99%** |
| **카테고리 순위 (생산성/한국)** | ? | Top 50 | **Top 10** |

---

## 🗺 6개월 로드맵

### Month 1 (2026-05-12 ~ 06-08) — **측정 기반 구축 + 자산 제작**
> 무엇을 개선해야 할지 *알기 위해* 먼저 측정과 자산이 필요합니다.

| # | 이슈 | 산출물 |
|---|------|--------|
| [#253](https://github.com/jeiel85/BrioDo/issues/253) | D1/D7/D30 리텐션 측정 파이프라인 | Firebase Analytics 이벤트, BigQuery export, Looker 대시보드 |
| [#256](https://github.com/jeiel85/BrioDo/issues/256) | 차별점 마케팅 자산 제작 | Play Store 신규 스크린샷 4종, 30초 데모 영상 |
| [#252](https://github.com/jeiel85/BrioDo/issues/252) | 리뷰 응답 SLA 운영 시작 | 응답 카피 템플릿 4종, 주 1회 리뷰 회고 루틴 |

### Month 2 (06-09 ~ 07-06) — **차별점 코어 강화 + 바이럴 준비**
| # | 이슈 | 산출물 |
|---|------|--------|
| [#221](https://github.com/jeiel85/BrioDo/issues/221) | NLP 정확도 99% 도전 | 골든셋 800케이스, CI 회귀 테스트, 정확도 리포트 v1 |
| [#159](https://github.com/jeiel85/BrioDo/issues/159) | 온보딩/튜토리얼 추가 | 인터랙티브 3-step 온보딩, D1 리텐션 +10%p 목표 |
| [#135](https://github.com/jeiel85/BrioDo/issues/135) | 바이럴 루프 (자랑하기 공유) | 업적/연속 사용 공유 카드, 카카오톡/X 채널별 카피 |
| [#168](https://github.com/jeiel85/BrioDo/issues/168) | 공유/익스포트 UI | #135와 통합되는 캔버스 공유 카드 |

### Month 3 (07-07 ~ 08-03) — **바이럴 가동 + v1.2.0 출시**
| # | 이슈 | 산출물 |
|---|------|--------|
| [#149](https://github.com/jeiel85/BrioDo/issues/149) | 친구 초대 보상 프로그램 | 초대 코드 시스템, 양방 보상, 어뷰징 방지 |
| [#254](https://github.com/jeiel85/BrioDo/issues/254) | 푸시 카피/타이밍 A/B 테스트 | Firebase Remote Config로 카피 변형 배포 |
| - | **v1.2.0 출시** | 측정 데이터 기반 리뷰 |

### Month 4 (08-04 ~ 08-31) — **외부 노출 폭격**
| # | 이슈 | 산출물 |
|---|------|--------|
| [#255](https://github.com/jeiel85/BrioDo/issues/255) | 인플루언서/유튜버 시드 캠페인 PoC | 한국 productivity 유튜버 30명 시드, promo code 추적 |
| [#136](https://github.com/jeiel85/BrioDo/issues/136) | 메이커 커뮤니티 (재개) | Disquiet/Product Hunt 포스팅 2~3건, 빌드 인 퍼블릭 톤 |

### Month 5 (09-01 ~ 09-28) — **알고리즘 챔피언십**
| # | 이슈 | 산출물 |
|---|------|--------|
| [#134](https://github.com/jeiel85/BrioDo/issues/134) | ASO 키워드 점령 (월간 사이클 정착) | 타겟 키워드별 노출 순위 트래킹, 분기 A/B 1회 |
| [#257](https://github.com/jeiel85/BrioDo/issues/257) | Google Play Editor's Choice 신청 | Crash-free 99.5%, ANR < 0.47% 달성, 신청서 제출 |

### Month 6 (09-29 ~ 11-12) — **제품 차별점 마무리 + v1.3.0**
| # | 이슈 | 산출물 |
|---|------|--------|
| [#152](https://github.com/jeiel85/BrioDo/issues/152) | 홈 화면 위젯 다양한 크기 | 1x1 / 2x2 / 4x2 RemoteViews, 위젯 직접 추가 |
| [#219](https://github.com/jeiel85/BrioDo/issues/219) | 개인화 홈 (AI 추천 카드) | 오늘의 최우선 작업 추천, 컨텍스트 인사말 |
| [#220](https://github.com/jeiel85/BrioDo/issues/220) | 음성 입력 UI (파동 시각화) | Canvas 기반 음성 파동, 인식 텍스트 실시간 스트리밍 |
| - | **v1.3.0 출시** | Top 10 진입 진단 + 다음 분기 계획 |

---

## 🔍 Month 1 세부 작업 분해

### #253 — D1/D7/D30 리텐션 측정 파이프라인

**Week 1** (5/12 ~ 5/18): 측정 이벤트 정의 + Firebase Analytics 통합
- [ ] `src/analytics.js` 모듈 신설 (Firebase Analytics 래퍼)
- [ ] 이벤트 스키마 문서화: `first_open`, `session_start`, `todo_create`, `todo_complete`, `ai_input_used`, `widget_used`, `subscription_view`
- [ ] App.jsx에 `first_open` 추적 추가 (게스트 모드 포함)
- [ ] 주요 액션 후크에 이벤트 호출 삽입 (`useTodosData.js`, `useSubscription.js`)

**Week 2** (5/19 ~ 5/25): BigQuery 연결 + 코호트 쿼리
- [ ] Firebase Console에서 BigQuery 일일 export 활성화
- [ ] 코호트 쿼리 작성: 가입일자별 D1/D7/D30 returning ratio
- [ ] Looker Studio 대시보드 구성: 일간 가입자, 코호트 매트릭스, 핵심 액션 funnel

**Week 3** (5/26 ~ 6/1): 검증 + 첫 리포트
- [ ] 실제 디바이스에서 이벤트 수신 확인 (Galaxy S24 + Lenovo Y700)
- [ ] 첫 코호트 리포트 작성 (현재 baseline 측정)
- [ ] **가장 큰 이탈 구간 1개 식별** → Month 2 우선순위 입력

**Week 4** (6/2 ~ 6/8): 자동화
- [ ] 주간 리포트 자동 생성 (Firebase Functions Scheduled)
- [ ] Slack/Discord 알림 또는 이메일 리포트 (선택)

### #256 — 차별점 마케팅 자산 제작

**Week 1**: Play Store 스크린샷 4종
- [ ] #1 잠금화면 위젯 — "잠금 해제 없이 할 일 추가" (S24 캡처)
- [ ] #2 AI 자연어 — "내일 오후 3시 팀 회의" 인풋 + 자동 파싱 결과
- [ ] #3 AI 브리핑 — 페르소나형 카피 적용 화면
- [ ] #4 홈 화면 — 오늘 할 일 + Pro 구독 hook
- [ ] Featured graphic (1024x500) — 1줄 가치 제안

**Week 2**: 30초 데모 영상
- [ ] 시나리오 작성: 잠금화면 → AI 자연어 입력 → 캘린더 동기화
- [ ] S24 화면 녹화 + Lenovo Y700 보조 컷
- [ ] CapCut/iMovie 편집, 음악 라이선스 확인 (저작권 free)
- [ ] Play Store 영상 슬롯 업로드 + 유튜브 비공개 백업

**Week 3**: 정사각 카드 + GIF
- [ ] 인스타/X용 정사각 카드 5종 (기능별)
- [ ] 블로그/Disquiet용 GIF 모음 (위젯 인터랙션, AI 파싱, 공유 카드)

**Week 4**: 카피 자산 + Play Store 적용
- [ ] 1줄 가치 제안 한/영/일/중 4개 언어
- [ ] FAQ 형식 답변 카피 (#252 리뷰 응답용)
- [ ] Play Store 신규 자산 일괄 업로드 + A/B 테스트 설정

### #252 — 리뷰 응답 SLA 운영

**Week 1**: 정책 수립 + 카피 템플릿
- [ ] SLA 문서 작성 (`docs/REVIEW_SLA.md`): 24시간 내 응답, 별점 1~3점 우선
- [ ] 응답 카피 템플릿 4종: 버그/요청/오해/긍정
- [ ] Play Console 모바일 알림 ON (실시간 리뷰 도착 트리거)

**Week 2~4**: 운영 시작
- [ ] 매일 1회 Play Console 리뷰 확인 루틴
- [ ] 부정 리뷰에서 추출한 이슈를 GitHub Issue로 등록
- [ ] 주 1회 (월요일) 리뷰 회고 — 별점 변화, 응답률, 응답 후 별점 상향률

---

## 🟢 Growth 라벨 운영 원칙

- **`growth` 라벨이 붙은 이슈는 닫지 않습니다.** 모두 *상시 운영 항목*입니다.
- 코드 이슈와 섞이지 않도록 GitHub Projects 보드에서 별도 column으로 관리 권장
- 주 1회 회고 → 측정 기반으로 다음 주 우선순위 조정

---

## 📋 P0 외 우선순위 처리 원칙

- **P1 (32개)**: Month 4~6에 점진적으로. Top 10 진입 후 differentiation 확장 단계.
- **P2 (37개)**: v1.3.0 이후 검토. 따라잡기 기능은 사용자 데이터 근거 있을 때만 승격.
- **P3 (10개)**: 장기 — Top 10 진입 후 안정화 단계에서 처리.

---

## ⚠️ 위험 요소

| 위험 | 영향 | 완화 |
|------|------|------|
| 솔로 개발자 번아웃 | Roadmap 좌초 | 월 2~3개 이슈로 보수적 설계, 측정 주도 |
| Google이 Tasks에 Gemini 통합 | 차별점 침식 | NLP 정확도 99% + 잠금화면 위젯으로 격차 유지 |
| 광고 예산 부족 | 다운로드 가속 한계 | 바이럴 (#149) + 시드 캠페인 (#255) 의존 |
| 별점 폭락 (4.3 이하) | ASO/추천 노출 차단 | #252 리뷰 SLA로 사전 차단, 1점 리뷰 즉시 응답 |

---

## 🔗 참고

- **GitHub Issues**: https://github.com/jeiel85/BrioDo/issues
- **Growth 라벨 이슈 (11개)**: https://github.com/jeiel85/BrioDo/issues?q=is%3Aopen+label%3Agrowth
- **P0 이슈 (16개)**: https://github.com/jeiel85/BrioDo/issues?q=is%3Aopen+label%3AP0
- **Top 10 청사진 (기술 디테일)**: [TOP10_BLUEPRINT.md](TOP10_BLUEPRINT.md) — *기술 청사진은 별도 갱신 예정 (옛 P0 기준)*
