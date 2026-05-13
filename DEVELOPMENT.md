# BrioDo — 시스템 설계 및 개발 가이드

이 문서는 BrioDo 프로젝트의 시스템 설계, 보안 정책, 개발 환경 설정 및 스토어 운영 가이드를 통합하여 관리합니다.

---

## 🏗️ 시스템 설계

### 1. 수익 모델 — Pro 구독
- **Pro Monthly**: ₩4,900/월
- **Pro Yearly**: ₩39,900/년 (32% 할인)
- **Pro Family**: ₩8,900/월 (최대 6명)
- **Pro 혜택**: AI 무제한, 광고 제거, 커스텀 테마, 우선 지원
- **관련 이슈**: [#209](https://github.com/jeiel85/BrioDo/issues/209)

> ⚠️ 브리오(Brio) 재화 시스템은 v1.0.4에서 폐기되었습니다. 상세는 [docs/brio-system.md](docs/brio-system.md) (참고용) 참조.

### 2. 업적 시스템
- 총 106개의 업적이 정의되어 있으며, `useAchievements.js`에서 로직을 관리합니다.
- 달성 내역은 Firestore `userSettings` 컬렉션에 동기화됩니다.
- 상세 업적 목록: [docs/achievements.md](docs/achievements.md) (공개 50개), [ACHIEVEMENTS_SECRET.md](ACHIEVEMENTS_SECRET.md) (비공개 50개).

---

## 🔒 보안 및 키 관리 (Security & Keys)

### 1. 주요 환경 파일 (gitignore 대상)
- `.env`: VITE_GEMINI_API_KEY, VITE_FIREBASE_* (각 PC에서 직접 생성)
- `android/app/google-services.json`: Firebase 설정 파일
- `keystore.properties`: 릴리즈 서명 자격증명
- `android/app/blenddo-release.jks`: 키스토어 파일 (절대 분실 금지)

### 2. Google 로그인 — SHA-1 핑거프린트 관리
Google 로그인은 앱 서명 SHA-1이 Firebase Console에 등록된 값과 일치해야 동작합니다.
**새 PC 추가 시 절차:**
1. 현재 keystore SHA-1 확인:
   ```bash
   keytool -list -v -keystore android/keystore/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Firebase Console → 프로젝트 설정 → Android 앱 → 디지털 지문 추가.
3. 새 `google-services.json` 다운로드 후 교체.

### 3. GitHub Secrets 설정 (CI/CD용)
CI 빌드 시 실제 API 키 주입을 위해 아래 시크릿이 필요합니다.
- `VITE_FIREBASE_*`, `VITE_GEMINI_API_KEY`
- `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`

---

## 🚀 릴리즈 및 배포 전략

### 1. CI/CD 동작 방식
- `main` 푸시: 웹 빌드 테스트 + ESLint (품질 검증용).
- `v1.x.x` 태그 푸시: Android 릴리즈 빌드 실행 → 서명 APK 생성 및 GitHub Release 자동 업로드.

### 2. 수동 릴리즈 절차 (상세)
1. 버전 번호 수정 (`App.jsx`, `build.gradle`).
2. 커밋 및 `main` 푸시.
3. `git tag v1.x.x` 및 `git push origin v1.x.x`.
4. CI 완료 후 GitHub Release 에셋(`app-release.apk`) 확인.

---

## 💻 개발 환경 설정 (New PC Setup)

### 1. 초기 설정 체크리스트
1. `git clone` 또는 `git pull`.
2. `npm install --legacy-peer-deps`.
3. `node_modules` 패치 적용 (AGENTS.md 참조).
4. 환경 파일(`.env`, `google-services.json`, `keystore.properties`) 복사.

### 2. Claude Code 자동 승인 권한
`~/.claude/settings.json`에 빌드 및 ADB 실행 권한을 추가하여 업무 효율을 높입니다.

---

## 📈 향후 계획 (Roadmap)

- **현행 로드맵**: [SPRINT_PLAN.md](SPRINT_PLAN.md) — Top 10 진입 6개월 계획
- **기술 청사진**: [TOP10_BLUEPRINT.md](TOP10_BLUEPRINT.md) (참고용 — 우선순위는 SPRINT_PLAN.md 기준)
- **GitHub Issues**: https://github.com/jeiel85/BrioDo/issues
  - [P0 (16개)](https://github.com/jeiel85/BrioDo/issues?q=is%3Aopen+label%3AP0)
  - [Growth 라벨 (11개)](https://github.com/jeiel85/BrioDo/issues?q=is%3Aopen+label%3Agrowth)
