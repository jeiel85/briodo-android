# 🛡️ BrioDo 보안 점검 리포트 및 해결 과제

본 문서는 프로젝트 공개(Play Store 배포 등) 전 보안 취약점을 점검하고 조치한 내역과, 향후 대응이 필요한 이슈들을 정리한 리포트입니다.

> **GitHub Issues**: 보안 관련 이슈는 [`security` 라벨](https://github.com/jeiel85/BrioDo/issues?q=is%3Aopen+label%3Asecurity)로 추적합니다.

---

## ✅ 조치 완료된 항목

### 1. [심각] 하드코딩된 앱 서명 비밀번호 제거
- **위치**: `STORE_DEPLOY.md`
- **문제**: 배포 가이드 문서에 키스토어 및 키 비밀번호가 평문으로 노출되어 있었습니다.
- **조치**: `${env.STORE_PASSWORD}`와 같은 환경 변수 참조 형식으로 변경하였습니다. 실제 값은 빌드 환경(CI/CD)의 Secret 변수로 관리해야 합니다.

### 2. XSS 공격 방지를 위한 CSP 적용
- **위치**: `index.html`
- **문제**: 콘텐츠 보안 정책(CSP) 메타 태그가 부재하여 외부 악성 스크립트 실행 위험이 있었습니다.
- **조치**: Firebase, Google API 등 필수 서비스만 허용하는 엄격한 CSP 정책을 추가하였습니다.

### 3. 관리자 대시보드 보안 규칙 적용
- **위치**: `firestore.rules`
- **문제**: 관리자 페이지(`admin/`)에서 사용자 목록을 조회하려 했으나, Firestore 규칙에 관련 권한 설정이 누락되어 접근이 거부되는 상태였습니다.
- **조치**: `request.auth.token.admin == true`인 경우에만 `users` 컬렉션을 읽을 수 있도록 규칙을 보완하였습니다.

---

## ⚠️ 향후 대응 필요 (GitHub 이슈 등록 권장)

다음 항목들은 현재 환경에서 완전한 자동 조치가 어렵거나, 사용자의 수동 개입이 필요한 부분입니다.

### 이슈 1: 의존성 보안 취약점 패치 (High Severity)
- **설명**: `vite`, `tar`, `xmldom` 등 일부 라이브러리에서 고위험 보안 취약점이 발견되었습니다.
- **상태**: `npm audit fix`를 시도했으나 Capacitor 버전 충돌(v8 vs v6)로 인해 자동 업데이트가 중단되었습니다.
- **대응**: 
  1. `capacitor-google-auth` 플러그인을 v8과 호환되는 최신 버전으로 업데이트하거나 대체품을 찾아야 합니다.
  2. 수동으로 `package.json`의 버전을 조정하며 `npm install --legacy-peer-deps`를 통해 패치를 진행해야 합니다.
- **GitHub 이슈**: [#231](https://github.com/jeiel85/BrioDo/issues/231) 외 `security` 라벨

### 이슈 2: Google OAuth Access Token 스토리지 보안
- **설명**: 현재 Google Calendar 연동을 위한 Access Token을 `localStorage`에 저장하고 있습니다.
- **위험**: XSS 공격 시 토큰이 탈취될 수 있습니다. (현재 CSP로 위험을 낮췄으나 근본적인 조치는 아님)
- **대응**: 
  - Capacitor 환경에서는 `Capacitor Cookies`나 `Secure Storage` 플러그인을 사용하여 시스템 보안 영역에 토큰을 저장하도록 리팩토링하는 것을 권장합니다.
- **GitHub 이슈**: [#239](https://github.com/jeiel85/BrioDo/issues/239) 외

### 이슈 3: Firebase 관리자 권한(Custom Claims) 설정 프로세스
- **설명**: Firestore 규칙은 준비되었으나, 실제 특정 유저에게 `admin` 권한을 부여하는 프로세스가 필요합니다.
- **대응**: 
  - `scripts/promote-admin.js`를 실행하여 실제 관리자 계정의 이메일에 `admin: true` 클레임을 부여해야 합니다. (Firebase Admin SDK 필요)
- **상태**: `scripts/promote-admin.js` 구현 완료. 관리자 계정에 수동 적용 필요.

### 이슈 4: API 키 노출 방지 (Secrets Management)
- **설명**: `src/firebase.js` 등에서 환경 변수를 사용하고 있으나, 빌드 결과물에는 해당 키들이 포함됩니다.
- **대응**: 
  - Firebase API 키 자체는 노출되어도 큰 위험은 없으나(Firestore Rules로 보호되므로), Firestore 규칙과 앱 체크(App Check)를 활성화하여 비정상적인 접근을 차단해야 합니다.
- **GitHub 이슈**: [#231](https://github.com/jeiel85/BrioDo/issues/231) (App Check), [#236](https://github.com/jeiel85/BrioDo/issues/236) 외

---

*이 리포트는 Gemini CLI 보안 검사 도구를 통해 생성되었습니다. 배포 전 각 이슈를 GitHub에 등록하고 하나씩 해결하시기 바랍니다.*
