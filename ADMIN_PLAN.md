# BrioDo 관리자 대시보드 구축 계획서 (Admin Dashboard Plan)

## 1. 개요
BrioDo 앱의 사용자 활동 데이터, 업적 달성 현황 및 API 호출량을 모니터링하고 관리하기 위한 전용 웹 대시보드 구축 계획입니다.

## 2. 보안 전략 (Security First)
관리자 페이지는 민감한 사용자 데이터에 접근하므로 강력한 보안 계층을 적용합니다.

### 2.1 Firebase Custom Claims 기반 권한 제어
- Firebase Authentication의 `Custom Claims` 기능을 사용하여 특정 UID에 `{admin: true}` 속성을 부여합니다.
- 클라이언트 사이드 뿐만 아니라 서버 사이드(Firestore Rules)에서 이 토큰을 검증합니다.

### 2.2 Firestore Security Rules 설정
```javascript
match /databases/{database}/documents {
  // 모든 데이터에 대해 관리자 권한 확인
  match /{document=**} {
    allow read, write: if request.auth != null && request.auth.token.admin == true;
  }
}
```

## 3. 주요 기능 명세

### 3.1 사용자 관리 (User Management)
- **전체 사용자 목록 조회:** 가입일, 마지막 접속일, 이메일 등.
- **업적 현황 상세:** 각 사용자가 획득한 업적 리스트 및 진행률 확인.
- **데이터 초기화:** 테스트용 계정의 데이터를 초기화하는 기능.

### 3.2 API 사용량 모니터링 (Usage Tracking)
- **LLM 호출 통계:** 일별/월별 전체 AI 호출 횟수.
- **사용자별 쿼터 관리:** 특정 사용자의 API 남용 방지를 위한 호출 제한 모니터링.

### 3.3 대시보드 통계 (Global Stats)
- 총 가입자 수 및 활성 사용자(DAU/WAU) 시각화.
- 가장 많이 달성된 업적 TOP 5.
- 시스템 오류 로그 집계.

## 4. 구현 단계 (Phases)

### Phase 1: 기반 설정 (Foundation)
- [ ] 관리자 권한 부여 스크립트 작성 (Admin SDK 활용).
- [ ] `firestore.rules` 업데이트.
- [ ] 관리자 전용 레이아웃 및 보호된 라우트(ProtectedRoute) 설정.

### Phase 2: 데이터 연동 (Data Integration)
- [ ] 모든 사용자의 업적 및 활동 데이터를 가져오는 전용 Hook 작성.
- [ ] API 호출 로그 저장을 위한 Firestore 컬렉션 구조 설계 (필요 시).

### Phase 3: UI/UX 구현 (Interface)
- [ ] 테이블 형태의 사용자 리스트 뷰.
- [ ] `Recharts` 등을 활용한 통계 그래프.
- [ ] 관리자 전용 로그인 페이지 (또는 기존 로그인 연동).

## 5. 정책 준수 사항
- **개인정보 보호:** 관리자 페이지 내에서 이메일 외의 개인정보(전화번호 등)는 최소화하여 노출.
- **로그 기록:** 관리자가 수행한 민감한 작업(데이터 삭제 등)에 대한 이력 저장.
