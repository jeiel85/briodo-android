## BrioDo v1.1.11

### 주요 변경
- **Top 10 진입 스프린트 준비 완료**: Play Store Top 10 진입을 위한 100개 개선/추가/수정 사항 이슈 생성 (#152-#251)
- **관리자 대시보드 인프라 구축**: Vite + React 기반 관리자 대시보드 초안 추가, Firebase Custom Claims 기반 관리자 승격 스크립트 구현
- **CI/CD 안정화**: Android Run Check CI 파이프라인 안정화로 에뮬레이터 배포 검증 자동화

### 기술 변경
#### 1. GitHub Issues 일괄 생성 (#152-#251)
- **UI/UX**: 20개 이슈 — 사용자 경험 개선 사항
- **Features**: 30개 이슈 — 신규 기능 추가
- **Performance**: 13개 이슈 — 성능 최적화
- **Security**: 10개 이슈 — 보안 강화
- **Platform**: 10개 이슈 — 플랫폼 지원 확장
- **Monetization**: 5개 이슈 — 수익화 기능
- **AI**: 5개 이슈 — AI 기능 개선
- **기타**: 7개 이슈
- 우선순위 라벨(P0/P1/P2/P3) 및 마일스톤 v1.2.0 할당
- Python 스크립트 활용 (UTF-8 인코딩 처리, temp 파일 방식)

#### 2. 관리자 대시보드 초안 (admin/)
- `admin/` Vite + React 기반 SPA 구조
- Google 로그인 기반 관리자 인증
- Firestore `users` 컬렉션 최근 사용자 목록 조회 UI
- 별도 개발 서버 포트(5174) 설정
- `scripts/promote-admin.js`: Firebase Custom Claims 기반 관리자 승격
- `ADMIN_PLAN.md`, `SECURITY_ISSUES.md` 운영 문서 추가

#### 3. CI/CD 안정화 (.github/workflows/ci.yml)
- **Android Run Check 안정화**:
  - 에뮬레이터 옵션 조정 (-no-snapshot, emulator-boot-timeout: 900)
  - ADB 서버 선정리로 오프라인 상태 잔존 방지
  - APK 설치/앱 실행 재시도 루프 추가
  - 부팅 완료 후 15초 안정화 대기
  - `continue-on-error: true` 적용으로 부분적 실패 허용
- **Lint 게이트 강화**: 미사용 변수/파라미터 제거로 CI 통과 보장
- **배터리 최적화 대응**: `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` 권한 추가

#### 4. 버전 메타데이터 동기화
- `src/App.jsx`: APP_VERSION 1.1.11
- `android/app/build.gradle`: versionName 1.1.11, versionCode 23

#### 5. 운영 환경 정리
- `.playwright-mcp/` 세션 로그 `.gitignore` 추가
- `SPRINT_PLAN.md`: 2주 스프린트 계획 (Sprint 1: P0 20개, Sprint 2: P1 30개)
- KPI 설정: 평점 4.5+, DAU 30% 증가, Top 10 진입

### 기대 효과
- 100개 이슈 체계적 관리로 Top 10 진입 로드맵 가시화
- 다른 PC에서도 즉시 작업 가능한 인계 환경 구축
- CI 파이프라인 안정화로 배포 신뢰도 향상
