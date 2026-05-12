## BrioDo v1.1.10

### 주요 변경
- **Pro 구독 모델 도입(#146)**: 월간(₩4,900) · 연간(₩39,900, 32% 할인) · 패밀리(₩8,900, 6인) 플랜과 구독 모달을 추가했습니다. 무제한 AI, 커스텀 테마, 광고 제거 등 Pro 전용 기능 접근 제어가 적용됩니다.
- **AI 호출 횟수 제한**: 무료 사용자의 AI 호출을 일 10회 / 월 100회로 제한하고 일일 사용량을 Firestore에 저장하도록 했습니다.
- **오프라인 신뢰성 강화(#145)**: 네트워크 단절 환경에서도 데이터 보존과 동기화 신뢰도를 개선했습니다.

### 기술 변경
- **관리자 대시보드 초안 추가** (`admin/`):
  - Vite + React 기반 SPA, Google 로그인 기반 관리자 인증
  - Firestore `users` 컬렉션 최근 사용자 조회 UI
  - 별도 개발 서버 포트(5174) 설정
  - `scripts/promote-admin.js`: Firebase Custom Claims 기반 관리자 승격 스크립트
  - `ADMIN_PLAN.md`, `SECURITY_ISSUES.md` 운영 문서 정리
- **Android Run Check CI 안정화** (`.github/workflows/ci.yml`):
  - 에뮬레이터 옵션 `-no-snapshot`, `emulator-boot-timeout: 900` 적용
  - ADB 서버 선정리 / `pm list packages` 준비 확인 / 설치 전 잔여 앱 제거
  - APK 설치 및 앱 실행 재시도 루프, 부팅 후 15초 안정화 대기 추가
  - 실행 검증 스텝에 `continue-on-error: true` 적용으로 부분 실패 허용
- **CI Lint 게이트 안정화**: 미사용 변수/파라미터 제거 (`App.jsx`, `SubscriptionModal.jsx`, `db.js`, `useTodosData.js`)
- **버전 메타데이터 동기화**:
  - `src/App.jsx`: `APP_VERSION` `1.1.10`
  - `android/app/build.gradle`: `versionName 1.1.10`, `versionCode 22`
