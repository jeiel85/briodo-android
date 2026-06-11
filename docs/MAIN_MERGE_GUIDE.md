# `flutter-rewrite` → `main` 통합 가이드

Flutter V1 (v1.4.0+vc35)이 Play Store 내부 테스트 검증을 마쳤다고 판단한 시점에 수행할 작업입니다. **사용자(박용은) 명시 승인 후 수동 실행** — 자동화하지 않습니다.

## 현 상태 (2026-05-22)

- `D:/Project/BrioDo` — Capacitor 프로젝트. `main` 브랜치 = Play Store v1.1.17/vc30
- `D:/Project/briodo_flutter` — Flutter 프로젝트. `flutter-rewrite` 브랜치 = 로컬 v1.4.0/vc35
- **같은 리모트** `github.com/jeiel85/briodo-android` 의 다른 브랜치
- 둘은 unrelated histories (별도 init)

## 통합 절차

### A. 사전 확인

- [ ] v1.4.0+vc35가 Play Console 내부 테스트에서 충분히 검증됨
- [ ] 사용자/지인 디바이스에서 클라이언트별 작동 확인
- [ ] Firestore 보안 룰이 신규 필드(subtasks/recurrence/reminderOffset)에 영향 없는지 확인 (현재 룰은 검증 안 함 — 추가 안전)
- [ ] Capacitor v1.1.17이 ASD 자동 업데이트로 Flutter 빌드로 흡수될 때 사용자 데이터 손실 없는지 (Google 로그인 한 유저는 OK, 익명 유저는 v1.1.17 익명 UID 사라지면서 로컬로 fallback)

### B. 권한 분리 결정

Capacitor `main`을 백업으로 살릴지, 완전 폐기할지:
- **권장: 완전 폐기.** Capacitor 폴더는 `D:/Project/_BrioDo_capacitor_archive`로 이동해 로컬 백업. 리모트는 Flutter 단일 소스.
- 대안: Capacitor를 별도 브랜치 `capacitor-legacy`로 유지 (긴급 핫픽스용)

### C. 머지

```bash
# Flutter 리포 디렉토리 변경 → 새 단일 소스가 되도록 정리
cd D:/Project
mv BrioDo BrioDo-capacitor-archive   # Capacitor 보관 (선택)
mv briodo_flutter BrioDo             # Flutter를 정식 BrioDo 폴더로

cd BrioDo
git remote -v                         # origin = github.com/jeiel85/briodo-android
git fetch origin
git checkout flutter-rewrite          # 이미 위치
git push origin flutter-rewrite       # 최신 상태 push (이미 됨)

# 옵션 1: main을 강제로 flutter-rewrite로 덮어쓰기 (가장 깔끔)
git checkout -b main-old              # 기존 main 백업 브랜치
git push origin main-old              # GitHub에도 백업
git checkout flutter-rewrite
git branch -f main flutter-rewrite    # 로컬 main 포인터 이동
git push origin main --force          # ⚠️ GitHub main 강제 푸시

# 옵션 2: merge --allow-unrelated-histories (히스토리 양쪽 보존, 충돌 많음)
git checkout main
git merge flutter-rewrite --allow-unrelated-histories
# → src/, capacitor.config, package.json 등 모든 곳 충돌. 일일이 "use ours" (flutter-rewrite 쪽) 선택.
```

권장: **옵션 1**. Capacitor 잔재가 main에 남으면 검색/탐색에 노이즈.

### D. 머지 후 정리

- [ ] Capacitor 잔재 확인: `src/`, `dist/`, `capacitor.config.ts`, `ionic.config.json`, `vite.config.ts`, `index.html` 등 모두 사라졌는지
- [ ] `package.json`, `package-lock.json` 제거 확인
- [ ] `functions/` Firebase Cloud Functions 폴더 — Flutter는 사용 안 함, 별도 백업 후 폐기 가능
- [ ] `.github/workflows/` CI 파일들 — Flutter용으로 재작성 필요 (또는 우선 제거)
- [ ] `android/` 하위 — Flutter 자동 생성된 구조만 남았는지
- [ ] README.md / CHANGELOG.md / docs/ 등 Capacitor 관련 문서 업데이트 또는 제거

### E. 검증

- [ ] `flutter analyze` 0 issues
- [ ] `flutter build appbundle --release` 성공
- [ ] git log에서 머지 흔적 확인

### F. 메모리 업데이트

- `next-session.md`에 "Capacitor 폐기 완료, Flutter 단일 소스 진입"으로 기록
- `reference_aab_build.md`를 Capacitor 절차(npm run release)에서 Flutter 절차(pubspec bump + flutter build appbundle)로 교체

## 비상 절차 (롤백)

만약 머지 후 문제 발견 시:
```bash
git checkout main-old        # 백업 브랜치
git branch -f main main-old
git push origin main --force # 다시 main을 Capacitor 시절로 복원
```
GitHub에 main-old 브랜치를 만들어둔 게 안전망.
