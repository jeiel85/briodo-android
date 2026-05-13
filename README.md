<div align="center">

# ⚡ BrioDo

### *Do it with brio. 활기차게, 해내다.*

**AI와 함께하는 스마트 할 일 관리 앱 — Android**

<br>

[![Google Play](https://img.shields.io/badge/Google_Play-다운로드-3DDC84?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=app.briodo)
[![ONE Store](https://img.shields.io/badge/ONE_Store-다운로드-E2002B?style=for-the-badge&logoColor=white)](https://m.onestore.co.kr/mobilepoc/apps/appsDetail.omp?prodId=OA01005559)
[![GitHub Release](https://img.shields.io/github/v/release/jeiel85/BrioDo?style=for-the-badge&logo=github&color=181717)](https://github.com/jeiel85/BrioDo/releases/latest)
[![CI](https://img.shields.io/github/actions/workflow/status/jeiel85/BrioDo/ci.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=CI)](https://github.com/jeiel85/BrioDo/actions)

<br>

![Platform](https://img.shields.io/badge/Android-API_26+-3DDC84?style=flat-square&logo=android&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)
![Capacitor](https://img.shields.io/badge/Capacitor-8-119EFF?style=flat-square&logo=capacitor&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Gemini](https://img.shields.io/badge/Gemini_AI-2.5_Flash-8E75B2?style=flat-square&logo=google&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

</div>

---

## 📖 문서

| 문서 | 설명 |
|------|------|
| [AGENTS.md](AGENTS.md) | AI 에이전트 개발 지침 |
| [DEVELOPMENT.md](DEVELOPMENT.md) | 시스템 설계 및 개발 환경 |
| [SPRINT_PLAN.md](SPRINT_PLAN.md) | Top 10 진입 6개월 로드맵 |
| [docs/INDEX.md](docs/INDEX.md) | **전체 문서 네비게이션** |
| [PROJECT_HISTORY.md](PROJECT_HISTORY.md) | 개발 세션 이력 |
| [GitHub Issues](https://github.com/jeiel85/BrioDo/issues) | 이슈 트래커 |

## 📖 소개

BrioDo는 **AI 자연어 처리 + Google 캘린더 연동 + 잠금화면 위젯**을 결합한 Android 할 일 관리 앱입니다.

"내일 오후 3시 팀 회의"처럼 자연어로 말하거나 입력하면 AI가 날짜·시간·태그를 자동 추출하고, Google 캘린더와 실시간 동기화합니다. 오프라인에서도 완벽히 동작하며, 잠금화면에서 바로 할 일을 확인하고 편집할 수 있습니다.

BrioDo는 **AI 자연어 처리 + Google 캘린더 연동 + 잠금화면 위젯**을 결합한 Android 할 일 관리 앱입니다.

"내일 오후 3시 팀 회의"처럼 자연어로 말하거나 입력하면 AI가 날짜·시간·태그를 자동 추출하고, Google 캘린더와 실시간 동기화합니다. 오프라인에서도 완벽히 동작하며, 잠금화면에서 바로 할 일을 확인하고 편집할 수 있습니다.

<br>

## ✨ 주요 기능

<table>
<tr>
<td width="50%">

### 🤖 AI 스마트 입력
- **자연어 처리** — "내일 오후 3시 팀 회의" → 날짜·시간·태그 자동 추출
- **음성 인식** — 네이티브 Android 음성 인식
- **멀티 모델 폴백** — 기본 모델 실패 시 자동 대체
- **AI 브리핑** — 오전·저녁 일정 요약 알림
- **서버사이드 Rate Limit** — Firebase Functions 기반 일 10회 / 월 100회 안전 제어

</td>
<td width="50%">

### 📋 할 일 관리
- **오프라인 우선** — IndexedDB v2 로컬 저장 → Firestore 자동 동기화
- **지수 백오프 재시도** — 최대 5회, 1~16초 대기로 안정적 복구
- **타임스탬프 충돌 해결** — 로컬/서버 비교 후 최신본 채택
- **우선순위 큐** — `delete > completed > 수정` 순으로 동기화
- **저대역폭 자동 감지** — 배치 크기 자동 조절, 수동 동기화 버튼 제공
- **게스트 모드** — 로그인 없이 사용, 로그인 시 자동 마이그레이션
- **하위 태스크** — 할 일 내 체크리스트
- **반복 일정** — 매일 / 매주 / 매월

</td>
</tr>
<tr>
<td width="50%">

### 🔔 알림 & 리마인더
- **로컬 알림** — 네이티브 Android 알림
- **유연한 알림 시각** — 정각·10분·30분·1시간 전
- **종일 일정** — 별도 알림 시각 지정 가능

</td>
<td width="50%">

### 📅 Google 캘린더 연동
- **전용 캘린더 자동 생성** — 삭제 시 자동 복구
- **양방향 실시간 동기화** — 추가·수정·삭제 즉시 반영
- **OAuth 자동 갱신** — 토큰 만료 자동 처리

</td>
</tr>
<tr>
<td width="50%">

### 🔒 잠금화면 위젯
- **할 일 표시** — 오늘 / 전체 선택
- **인라인 편집** — 잠금화면에서 직접 완료·수정·추가
- **8종 퀵 버튼** — 플래시, 카메라, 계산기, QR 등
- **글자 크기** — 소·중·대 3단계

</td>
<td width="50%">

### 🎨 테마 & 개인화
- **5가지 테마** — 라이트·다크·시스템·랜덤·Material You
- **4개 언어** — 한국어 / English / 日本語 / 中文
- **폰트 크기** — 7단계 세밀 조정 (UI 밀도 자동 적용)
- **106개 업적** — confetti 애니메이션 + 공유 카드

</td>
</tr>
<tr>
<td width="50%">

### 💎 Pro 구독
- **Pro Monthly** — ₩4,900 / 월
- **Pro Yearly** — ₩39,900 / 년 (32% 할인)
- **Pro Family** — ₩8,900 / 월 (최대 6명)
- **AI 사용량 무제한 · 광고 제거 · 우선 지원**

</td>
<td width="50%">

### 🛠 관리자 대시보드
- **별도 Vite 앱** — `admin/` 디렉토리에서 독립 실행
- **관리자 클레임 인증** — Firebase Custom Claim 검증
- **사용자 조회** — Firestore 사용자 목록 / 구독 상태 확인

</td>
</tr>
</table>

<br>

## 🛠 기술 스택

| 영역 | 기술 |
|------|------|
| **프론트엔드** | React 19 + Vite 8 + JavaScript (ES2024) |
| **모바일 래핑** | Capacitor 8 (Android) |
| **인증** | Firebase Authentication + Google OAuth |
| **클라우드 DB** | Firebase Firestore |
| **로컬 DB** | IndexedDB v2 (`idb`) — `syncMetadata`, `offlineLog` 저장소 |
| **서버리스** | Firebase Cloud Functions (Node 22) — AI Rate Limit |
| **AI** | Google Gemini `gemini-2.5-flash-lite` (멀티 모델 폴백) |
| **광고/결제** | `@capacitor-community/admob` (Pro 구독 시 제거) |
| **음성** | `@capacitor-community/speech-recognition` |
| **캘린더** | Google Calendar API v3 |
| **알림** | `@capacitor/local-notifications` |
| **스타일** | 커스텀 CSS + Material Design 3 토큰 (Manrope + Inter) |
| **PWA** | Vite PWA Plugin + Workbox (Service Worker, 오프라인 캐싱) |
| **관리자 앱** | 별도 Vite 앱 (`admin/`) — React 19 + Firebase |

<br>

## 🏗 아키텍처

```
사용자 입력
  ├── 즉시 IndexedDB 저장  ──→  UI 즉시 반영
  ├── 온라인  ──→  Firestore 저장  +  Google Calendar 동기화
  └── 오프라인  ──→  우선순위 SyncQueue 대기
                     ├── 지수 백오프 재시도 (최대 5회, 1~16s)
                     ├── 타임스탬프 기반 충돌 해결
                     └── 저대역폭 시 배치 크기 자동 축소

AI 호출 (Gemini)
  └── Firebase Functions  ──→  Firestore rate limit 검증 (일 10회 / 월 100회)
                              └── Pro 구독자는 무제한
```

```
BrioDo/
├── src/                          # 메인 앱 (React 19 + Capacitor)
│   ├── App.jsx                   # 루트 컴포넌트, 상태 오케스트레이션
│   ├── firebase.js               # Firebase + Gemini 초기화
│   ├── calendar.js               # Google Calendar API (싱글톤)
│   ├── db.js                     # IndexedDB v2 (syncMetadata, offlineLog)
│   ├── hooks/
│   │   ├── useAuth.js            # 로그인/로그아웃, OAuth 토큰 자동 갱신
│   │   ├── useTodosData.js       # 할 일 CRUD, 충돌 해결, 우선순위 큐
│   │   ├── useSubscription.js    # Pro 구독 상태 / AI 사용량 추적
│   │   ├── useAchievements.js    # 업적 시스템 (106개)
│   │   ├── useNotifications.js   # 로컬 알림 스케줄링
│   │   ├── useTheme.js           # 테마/폰트/상태바 관리
│   │   └── useLanguage.js        # i18n (ko/en/ja/zh)
│   └── components/
│       ├── Header.jsx            # 날짜, 태그 필터, 검색
│       ├── TodoList.jsx          # 할 일 목록 + 하위태스크
│       ├── SmartInputModal.jsx   # AI 자연어 + 음성 입력 (사용량 표시)
│       ├── SubscriptionModal.jsx # Pro 업그레이드 UI (월/연/패밀리)
│       ├── LockScreenView.jsx    # 잠금화면 위젯
│       └── SettingsModal.jsx     # 설정 + 구독 관리
│
├── functions/                    # Firebase Cloud Functions (Node 22)
│   └── index.js                  # AI Rate Limit (Firestore 기반)
│
├── admin/                        # 관리자 대시보드 (별도 Vite 앱)
│   └── src/
│       ├── App.jsx               # 클레임 인증 + 사용자 조회
│       └── firebase.js           # 관리자용 Firebase 초기화
│
└── scripts/
    └── release.js                # 릴리즈 자동화 (npm run release)
```

<br>

## 📦 다운로드

<div align="center">

<a href="https://play.google.com/store/apps/details?id=app.briodo">
  <img src="https://img.shields.io/badge/Google_Play-다운로드-3DDC84?style=for-the-badge&logo=google-play&logoColor=white" alt="Google Play에서 받기" />
</a>
&nbsp;
<a href="https://m.onestore.co.kr/mobilepoc/apps/appsDetail.omp?prodId=OA01005559">
  <img src="https://img.shields.io/badge/ONE_Store-다운로드-E2002B?style=for-the-badge&logoColor=white" alt="원스토어에서 받기" />
</a>

**또는 [GitHub Releases](https://github.com/jeiel85/BrioDo/releases/latest)에서 APK 직접 다운로드**

[Obtainium](https://github.com/ImranR98/Obtainium) 사용 시 이 저장소 URL을 추가하면 자동 업데이트를 받을 수 있습니다.

</div>

<br>

## 🚀 개발 환경 설정

### 1. 의존성 설치

```bash
git clone https://github.com/jeiel85/BrioDo.git
cd BrioDo
npm install --legacy-peer-deps
```

### 2. 환경 변수 설정

`.env` 파일 생성:

```env
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
VITE_GEMINI_API_KEY=your_gemini_api_key
```

### 3. 웹 개발 서버

```bash
npm run dev
```

### 4. Android 빌드 및 설치

```bash
npm run build
npx cap sync android
cd android && ./gradlew assembleDebug

adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n app.briodo/.MainActivity
```

### 5. 릴리즈 자동화

```bash
npm run release <버전>   # 예: npm run release 1.1.12
# → versionName/versionCode 자동 범프, 커밋, 태그(v1.1.12) 푸시
# → GitHub Actions가 서명 APK 빌드 + GitHub Release 자동 생성
```

### 6. Firebase Functions (서버사이드 AI Rate Limit)

```bash
cd functions
npm install
npm run serve            # 로컬 에뮬레이터
npm run deploy           # 배포
```

### 7. 관리자 대시보드

```bash
cd admin
npm install
npm run dev              # 별도 포트에서 실행 (관리자 클레임 보유 계정 필요)
```

<br>

## 🧪 테스트

| 유형 | 수량 | 설명 |
|------|------|------|
| E2E 기능 테스트 | 27개 | 기본 동작, 할 일 관리, 설정, 반응형 |
| 시각적 회귀 테스트 | 102개 | 레이아웃, 텍스트, 오버랩, 브레이크포인트 |
| **총합** | **129개** | Chromium · Android Chrome · iOS Safari |

```bash
npx playwright test                       # 전체
npx playwright test --project=chromium   # 특정 브라우저
```

<br>

## 🗺 로드맵

- [x] Google Play Store 출시
- [x] ONE Store 출시
- [x] 잠금화면 위젯
- [x] PWA 데스크톱 지원
- [x] AI 브리핑 & Nudge
- [x] 업적 시스템 (106개)
- [x] AI Rate Limit (Firebase Functions, 일 10회 / 월 100회)
- [x] 오프라인 신뢰성 극대화 (지수 백오프 + 충돌 해결 + 우선순위 큐)
- [x] Pro 구독 모델 (월간 / 연간 / 패밀리)
- [x] 관리자 대시보드 (별도 Vite 앱)
- [x] 릴리즈 자동화 스크립트
- [x] Firebase Analytics 측정 파이프라인
- [ ] 인앱 결제 실제 연동 (Google Play Billing) — [#209](https://github.com/jeiel85/BrioDo/issues/209)
- [ ] iOS 지원
- [ ] Android 홈 화면 위젯 다양한 크기 — [#152](https://github.com/jeiel85/BrioDo/issues/152)
- [ ] 태블릿 최적화 레이아웃

> **현행 로드맵**: [SPRINT_PLAN.md](SPRINT_PLAN.md) — Top 10 진입 6개월 계획
> **GitHub Issues**: https://github.com/jeiel85/BrioDo/issues

<br>

## 📜 오픈소스 라이선스

| 라이브러리 | 라이선스 |
|-----------|----------|
| React | MIT |
| Vite | MIT |
| Capacitor | MIT |
| Firebase JS SDK | Apache 2.0 |
| @google/genai | Apache 2.0 |
| idb | ISC |
| canvas-confetti | ISC |

이 프로젝트는 **MIT 라이선스** 하에 공개됩니다.

---

<div align="center">

*BrioDo — Do it with brio.* ⚡

</div>
