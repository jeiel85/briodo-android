# Play Console 업로드 체크리스트 — v1.3.0 / vc34

이 문서는 사용자가 직접 수행해야 하는 단계입니다 (Play Console 계정 권한 필요).

## 사전 확인

- [ ] Play Console 계정: **pedaiah85@gmail.com** (jeiel85 아님)
- [ ] 바탕화면에 두 파일 모두 있는지:
  - `BrioDo-v1.3.0-vc34.aab`
  - `BrioDo-v1.3.0-vc34-release-notes.txt`
- [ ] 패키지명이 `app.briodo` 그대로인지 (Play Store가 v1.1.17 업데이트로 인식)
- [ ] versionCode가 **34** (Play 최신 vc30 이상)

## 업로드 절차

1. https://play.google.com/console 에서 **pedaiah85** 계정 선택
2. **BrioDo** 앱 → 좌측 메뉴 **테스트 → 내부 테스트** 진입
3. **새 릴리스 만들기** 버튼
4. App Bundle 영역에 `BrioDo-v1.3.0-vc34.aab` 드래그
5. **출시 노트** 입력란에 `BrioDo-v1.3.0-vc34-release-notes.txt` 내용을 그대로 붙여넣기 (꺾쇠 태그 그대로)
6. 저장 → 검토 → **출시 시작**

## 출시 후 확인

- [ ] Play Console **출시 개요**에서 vc34가 활성화됐는지
- [ ] 내부 테스트 트랙 링크로 자기 디바이스에서 업데이트 받기 (Capacitor v1.1.17 → Flutter v1.3.0 이전이 자연스러운지)
- [ ] 업데이트 후 첫 실행에서 데이터(Firestore todos) 그대로인지 — Google 로그인 한 계정 기준
- [ ] 알림 권한 다이얼로그 정상 작동
- [ ] 언어 변경 정상 작동
- [ ] Google Calendar 동기화 토글 정상 작동 (calendar 권한 추가 동의 화면 떠야 정상)

## 차단 사유 대비

- **Capacitor v1.1.17이 같은 패키지로 운영 중**이라 자동 업데이트로 흐름. 사용자가 명시적으로 거부할 수 없음.
- 사용자 데이터 손실 위험은 **Google 로그인된 사용자**에게는 없음 (Firestore 그대로). 익명 사용자는 v1.1.17의 익명 UID가 사라지면서 todo orphan 위험 → Flutter는 로컬 저장으로 시작하니 새 todo부터 정상.
- Calendar 동기화는 새 OAuth scope 동의가 필요해 첫 실행 시 다시 동의 요구. 정상 동작.

## 출시 후 Firebase 측 작업

- Firestore 룰은 이미 배포 완료 (`firebase deploy --only firestore:rules` 실행됨, 2026-05-21)
- Analytics는 빌드만 들어가면 자동 수집
