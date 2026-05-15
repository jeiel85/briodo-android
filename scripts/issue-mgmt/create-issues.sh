#!/bin/bash
# Script to create 100 GitHub Issues for BrioDo Top 10 improvements
# Run from D:\Project\BrioDo

set -e

echo "Creating 100 GitHub Issues for BrioDo..."

# UI/UX Improvements (1-20)
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    
    echo "Creating: $title"
    gh issue create --title "$title" --body "$body" --label "$labels" 2>&1 || echo "Failed to create: $title"
    sleep 0.3
}

# 1-20: UI/UX
create_issue "[UI/UX] 홈 화면 위젯 개선 (다양한 크기 지원)" "## 설명
홈 화면 위젯이 다양한 크기(1x1, 2x2, 4x1, 4x2)를 지원하도록 개선합니다.

## 요구사항
- [ ] 1x1, 2x2, 4x1, 4x2 크기 지원
- [ ] 위젯 테마 커스터마이징 (투명도, 색상)
- [ ] 위젯에서 직접 할 일 추가 기능
- [ ] 위젯에서 완료 표시 가능하도록 개선

## 라벨
enhancement, ux, roadmap" "enhancement,ux,roadmap"

create_issue "[UI/UX] 제스처 컨트롤 개선" "## 설명
스와이프 액션과 롱프레스 메뉴를 개선합니다.

## 요구사항
- [ ] 왼쪽/오른쪽 스와이프 메뉴 개선
- [ ] 스와이프로 우선순위 변경
- [ ] 스와이프로 날짜 변경
- [ ] 롱프레스 액션 추가 (빠른 메뉴)

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 다크 모드/테마 고도화" "## 설명
시스템 테마 자동 감지와 다양한 컬러 테마를 지원합니다.

## 요구사항
- [ ] 시스템 테마 자동 감지
- [ ] 다양한 컬러 테마 지원 (Material You)
- [ ] 고대비 모드 지원
- [ ] 사용자 정의 테마 색상 선택

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 애니메이션/전환 효과 추가" "## 설명
할 일 완료, 추가, 삭제 시 애니메이션을 추가합니다.

## 요구사항
- [ ] 할 일 완료 시 체크 애니메이션
- [ ] 페이지 전환 시 부드러운 트랜지션
- [ ] 할 일 추가/삭제 시 애니메이션
- [ ] 로딩 스켈레톤 UI 적용

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 폰트/접근성 개선" "## 설명
시스템 폰트 크기 연동과 접근성을 향상시킵니다.

## 요구사항
- [ ] 시스템 폰트 크기 연동
- [ ] 접근성 향상 (TalkBack 완벽 지원)
- [ ] 키보드 네비게이션 최적화
- [ ] 고대비 모드 준수

## 라벨
enhancement, ux,accessibility" "enhancement,ux,accessibility"

create_issue "[UI/UX] 인디케이터/배지 개선" "## 설명
앱 아이콘 배지와 다양한 시각적 구분 요소를 추가합니다.

## 요구사항
- [ ] 앱 아이콘 배지 카운트 (미완료 할 일 수)
- [ ] 우선순위별 색상 인디케이터
- [ ] 마감임박 표시 (빨간색 테두리 등)
- [ ] 오늘/지연된 할 일 시각적 구분

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 캘린더 뷰 개선" "## 설명
월간/주간/일간 뷰와 드래그 앤 드롭을 지원합니다.

## 요구사항
- [ ] 월간/주간/일간 뷰 추가
- [ ] 드래그 앤 드롭으로 날짜 변경
- [ ] 이벤트 컬러 코딩
- [ ] 캘린더 겹침 해결

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 검색/필터 UI 개선" "## 설명
검색바 상단 고정과 고급 필터를 추가합니다.

## 요구사항
- [ ] 검색바 상단 고정
- [ ] 고급 필터 (우선순위, 태그, 날짜 범위)
- [ ] 저장된 검색 필터
- [ ] 검색 결과 하이라이트

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 온보딩/튜토리얼 추가" "## 설명
첫 실행 시 인터랙티브 튜토리얼을 추가합니다.

## 요구사항
- [ ] 첫 실행 시 인터랙티브 튜토리얼
- [ ] 기능 소개 슬라이더
- [ ] 툴팁 / 힌트 시스템
- [ ] 빈 상태(empty state) 일러스트레이션

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 에러 처리 UI 개선" "## 설명
친절한 에러 메시지와 오프라인 상태 표시를 개선합니다.

## 요구사항
- [ ] 친절한 에러 메시지 디자인
- [ ] 재시도 버튼 개선
- [ ] 오프라인 상태 표시 (스낵바)
- [ ] 동기화 상태 표시 (스피너/체크)

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 다국어 지원 확장" "## 설명
영어/한국어 외에 더 많은 언어를 지원합니다.

## 요구사항
- [ ] 10개 언어 지원 (일본어, 중국어, 스페인어 등)
- [ ] 시스템 언어 자동 감지
- [ ] 번역 누락 체크
- [ ] RTL 언어 지원 (아랍어 등)

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 숏컷/빠른 액션" "## 설명
앱 아이콘 롱프레스 메뉴와 알림에서 직접 관리를 추가합니다.

## 요구사항
- [ ] 앱 아이콘 롱프레스 메뉴 (Android 7.1+)
- [ ] 알림에서 직접 완료/미루기
- [ ] 앱바 단축 아이콘
- [ ] 실시간 배지 업데이트

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 리스트 뷰 옵션" "## 설명
그리드 뷰와 컴팩트 모드 등 다양한 뷰 옵션을 추가합니다.

## 요구사항
- [ ] 그리드 뷰 / 리스트 뷰 전환
- [ ] 썸네일 표시 (첨부파일 있을 경우)
- [ ] 컴팩트 모드 / 편안 모드
- [ ] 정렬 옵션 (이름, 날짜, 우선순위)

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 태그/라벨 UI 개선" "## 설명
태그 색상 커스터마이징과 태그 클라우드 뷰를 추가합니다.

## 요구사항
- [ ] 태그 색상 커스터마이징
- [ ] 태그 클라우드 뷰
- [ ] 태그 자동완성
- [ ] 태그별 필터링 개선

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 알림 UI 개선" "## 설명
알림 센터와 알림 채널 설정을 개선합니다.

## 요구사항
- [ ] 알림 센터에서 할 일 관리
- [ ] 알림 그룹핑 (Android 7.0+)
- [ ] 알림 채널 설정 (Android 8.0+)
- [ ] 알림 사운드/진동 커스터마이징

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 통계 대시보드" "## 설명
완료율 그래프와 생산성 트렌드를 시각화합니다.

## 요구사항
- [ ] 완료율 그래프 (원형/막대)
- [ ] 주간/월간 생산성 트렌드
- [ ] 태그별 통계
- [ ] 시간대별 생산성 히트맵

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 개인화 홈" "## 설명
오늘의 할 일 포커스와 AI 기반 추천을 추가합니다.

## 요구사항
- [ ] 오늘의 할 일 포커스 뷰
- [ ] 추천 작업 (AI 기반)
- [ ] 날씨 정보 연동
- [ ] 인사말 (Good morning 등)

## 라벨
enhancement, ux,ai" "enhancement,ux,ai"

create_issue "[UI/UX] 드래그 앤 드롭" "## 설명
할 일 순서 변경과 리스트 간 이동을 드래그로 지원합니다.

## 요구사항
- [ ] 할 일 순서 변경
- [ ] 리스트 간 이동
- [ ] 캘린더로 드래그
- [ ] 폴더/프로젝트로 이동

## 라벨
enhancement, ux" "enhancement,ux"

create_issue "[UI/UX] 음성 입력 UI" "## 설명
음성 입력 버튼 애니메이션과 실시간 표시를 개선합니다.

## 요구사항
- [ ] 음성 입력 버튼 애니메이션
- [ ] 음성 인식 결과 실시간 표시
- [ ] 명령어 힌트 표시
- [ ] 음성 프로필 설정

## 라벨
enhancement, ux,ai" "enhancement,ux,ai"

create_issue "[UI/UX] 공유/익스포트 UI" "## 설명
공유 시트와 내보내기 옵션을 개선합니다.

## 요구사항
- [ ] 공유 시트 개선
- [ ] 내보내기 옵션 (PDF, CSV, JSON)
- [ ] 인쇄 레이아웃 개선
- [ ] QR 코드로 공유

## 라벨
enhancement, ux" "enhancement,ux"

# 21-50: Features
create_issue "[Feature] 하위 작업 (Subtasks) 지원" "## 설명
무제한 하위 작업 생성과 진행률 표시를 추가합니다.

## 요구사항
- [ ] 무제한 하위 작업 생성
- [ ] 하위 작업 진행률 표시
- [ ] 하위 작업 마감일 설정
- [ ] 하위 작업 완료 시 부모 업데이트

## 참고
Top 10 앱(Todoist, TickTick)의 핵심 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 습관 추적 (Habit Tracker)" "## 설명
습관 생성과 통계, 알림을 추가합니다.

## 요구사항
- [ ] 습관 생성 (매일/매주/매월)
- [ ] 습관 통계 (연속일, 성공률)
- [ ] 습관 캘린더 뷰
- [ ] 습관 알림 및 리마인더

## 참고
TickTick의 핵심 차별화 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 뽀모도로 타이머 (Pomodoro Timer)" "## 설명
25분 집중 / 5분 휴식 타이머와 위젯을 추가합니다.

## 요구사항
- [ ] 25분 집중 / 5분 휴식 타이머
- [ ] 사용자 정의 시간 설정
- [ ] 타이머 위젯 (홈 화면)
- [ ] 세션 통계 및 기록

## 참고
TickTick, Any.do 등의 주요 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 아이젠하워 매트릭스 (Eisenhower Matrix)" "## 설명
4분면 뷰으로 우선순위를 자동 분류합니다.

## 요구사항
- [ ] 4분면 뷰 (긴급/중요)
- [ ] 드래그로 사분면 이동
- [ ] 우선순위 자동 분류
- [ ] 매트릭스 통계

## 참고
TickTick의 차별화 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 자연어 처리 (NLP) 개선" "## 설명
\"내일 오전 10시 회의\" 등의 자연어를 자동 파싱합니다.

## 요구사항
- [ ] \"내일 오전 10시 회의\" → 자동 파싱
- [ ] \"매주 월요일마다\" → 반복 설정
- [ ] 우선순위 자동 감지 (\"긴급한\" 등)
- [ ] 태그 자동 추출

## 참고
Todoist, TickTick의 핵심 기능입니다.

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[Feature] 반복 작업 개선" "## 설명
복잡한 반복 규칙과 예외 처리를 추가합니다.

## 요구사항
- [ ] 복잡한 반복 규칙 (매월 첫째 주 등)
- [ ] 반복 작업 예외 처리
- [ ] 반복 작업 일시 중지
- [ ] 반복 패턴 템플릿

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 위치 기반 알림" "## 설명
특정 장소 도착 시 알림과 지오펜싱을 추가합니다.

## 요구사항
- [ ] 특정 장소 도착 시 알림
- [ ] 지오펜싱 (Geofencing)
- [ ] 장소별 할 일 리스트
- [ ] 위치 히스토리 기반 추천

## 참고
Todoist, Any.do의 프리미엄 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 첨부파일 지원" "## 설명
이미지, 파일, 음성 녹음 첨부를 추가합니다.

## 요구사항
- [ ] 이미지 첨부 (갤러리/카메라)
- [ ] 파일 첨부 (PDF, DOC 등)
- [ ] 음성 녹음 첨부
- [ ] 클라우드 파일 링크 (Google Drive 등)

## 참고
Microsoft To Do, Any.do 등의 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 협업/공유" "## 설명
할 일 공유와 실시간 동기화, 댓글을 추가합니다.

## 요구사항
- [ ] 할 일 공유 (가족/팀)
- [ ] 공유 목록 실시간 동기화
- [ ] 댓글 / @멘션
- [ ] 권한 관리 (보기/편집/관리자)

## 참고
Todoist, Any.do의 핵심 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 프로젝트/폴더" "## 설명
무제한 프로젝트 생성과 템플릿을 추가합니다.

## 요구사항
- [ ] 무제한 프로젝트 생성
- [ ] 프로젝트 색상/아이콘
- [ ] 프로젝트 템플릿
- [ ] 프로젝트 간 이동

## 참고
Todoist, TickTick의 핵심 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 시간 추적 (Time Tracking)" "## 설명
할 일에 소요 시간 기록과 통계를 추가합니다.

## 요구사항
- [ ] 할 일에 소요 시간 기록
- [ ] 시작/중지 타이머
- [ ] 시간대별 리포트
- [ ] 시간 기반 생산성 분석

## 참고
고급 생산성 앱의 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 태그 시스템 고도화" "## 설명
중첩 태그와 AI 기반 자동 생성을 추가합니다.

## 요구사항
- [ ] 중첩 태그 (parent/child)
- [ ] 태그 자동 생성 (AI)
- [ ] 태그 필터링 고급 검색
- [ ] 태그별 통계 대시보드

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[Feature] 캘린더 통합 고도화" "## 설명
Google Calendar 양방향 동기화와 Outlook/Apple 연동을 추가합니다.

## 요구사항
- [ ] Google Calendar 양방향 동기화
- [ ] Outlook Calendar 연동
- [ ] Apple Calendar 연동 (iOS)
- [ ] 캘린더 구독 (iCal)

## 참고
BrioDo는 이미 기본 연동이 있지만 고도화가 필요합니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 이메일 연동" "## 설명
Gmail에서 할 일 생성과 이메일 알림을 추가합니다.

## 요구사항
- [ ] Gmail에서 할 일 생성
- [ ] 이메일 첨부/링크 저장
- [ ] 이메일 알림
- [ ] 이메일로 할 일 전송

## 참고
Microsoft To Do의 핵심 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 스마트 리스트/필터" "## 설명
사용자 정의 스마트 리스트와 복합 조건 필터를 추가합니다.

## 요구사항
- [ ] 사용자 정의 스마트 리스트
- [ ] 복합 조건 필터 (AND/OR)
- [ ] 저장된 필터 즐겨찾기
- [ ] 필터 공유

## 참고
Todoist의 핵심 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 템플릿 시스템" "## 설명
할 일/프로젝트 템플릿과 마켓플레이스를 추가합니다.

## 요구사항
- [ ] 할 일 템플릿 (장보기 등)
- [ ] 프로젝트 템플릿
- [ ] 템플릿 마켓플레이스
- [ ] 템플릿 공유

## 참고
Todoist, Asana의 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 백업/복원" "## 설명
자동 클라우드 백업과 선택적 복원을 추가합니다.

## 요구사항
- [ ] 자동 클라우드 백업 (Firebase)
- [ ] 로컬 백업 (JSON)
- [ ] 백업 스케줄링
- [ ] 선택적 복원

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 가져오기/내보내기" "## 설명
Todoist, Google Tasks 가져오기와 CSV/Excel 내보내기를 추가합니다.

## 요구사항
- [ ] Todoist 가져오기
- [ ] Google Tasks 가져오기
- [ ] CSV/Excel 내보내기
- [ ] PDF 리포트 생성

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 음성 비서 연동" "## 설명
Google Assistant, Bixby, Siri 숏컷 연동을 추가합니다.

## 요구사항
- [ ] Google Assistant 연동
- [ ] Bixby 연동 (Samsung)
- [ ] Siri 숏컷 (iOS)
- [ ] 음성 명령어 커스터마이징

## 참고
Any.do, Todoist의 기능입니다.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 위젯 개선" "## 설명
투두위젯/캘린더 위젯 통합과 커스터마이징을 추가합니다.

## 요구사항
- [ ] 투두위젯/캘린더 위젯 통합
- [ ] 위젯 색상 테마
- [ ] 위젯 투명도 조절
- [ ] 위젯 새로고침 주기

## 라벨
enhancement, ux, roadmap" "enhancement,ux,roadmap"

create_issue "[Feature] 알림 스마트화" "## 설명
알림 스누즈와 스마트 알림을 추가합니다.

## 요구사항
- [ ] 알림 스누즈 (5분, 10분, 1시간)
- [ ] 알림 시간대 설정 (방해 금지 모드)
- [ ] 할 일 기반 스마트 알림
- [ ] 알림 히스토리

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 빠른 추가 (Quick Add)" "## 설명
글로벌 플로팅 버튼과 알림창에서 빠른 추가를 추가합니다.

## 요구사항
- [ ] 글로벌 플로팅 버튼
- [ ] 알림창에서 빠른 추가
- [ ] 위젯에서 빠른 추가
- [ ] 음성으로 빠른 추가

## 라벨
enhancement, ux, roadmap" "enhancement,ux,roadmap"

create_issue "[Feature] 할 일 우선순위 고도화" "## 설명
4단계 우선순위와 자동 조정(AI)을 추가합니다.

## 요구사항
- [ ] 4단계 우선순위 (낮음/보통/높음/긴급)
- [ ] 우선순위별 색상/아이콘
- [ ] 우선순위 자동 조정 (AI)
- [ ] 우선순위별 필터

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 마감일 관리" "## 설명
마감일 카운트다운과 임박 알림을 추가합니다.

## 요구사항
- [ ] 마감일 카운트다운
- [ ] 마감일 임박 알림 (1일 전, 1시간 전)
- [ ] 지연된 할 일 표시
- [ ] 마감일 일괄 변경

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 검색 엔진 고도화" "## 설명
전문 검색과 최근 검색 기록을 추가합니다.

## 요구사항
- [ ] 전문 검색 (Full-text search)
- [ ] 검색 결과 하이라이트
- [ ] 검색 필터 (날짜, 태그, 우선순위)
- [ ] 최근 검색 기록

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 북마크/즐겨찾기" "## 설명
중요한 할 일 북마크와 폴더를 추가합니다.

## 요구사항
- [ ] 중요한 할 일 북마크
- [ ] 북마크 폴더
- [ ] 북마크 동기화
- [ ] 북마크 공유

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 메모/노트" "## 설명
할 일에 리치 텍스트 메모와 첨부파일을 추가합니다.

## 요구사항
- [ ] 할 일에 리치 텍스트 메모
- [ ] 첨부파일 포함 메모
- [ ] 메모 검색
- [ ] 메모 내보내기

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 리마인더 고도화" "## 설명
위치 기반 리마인더와 특정 앱 실행 시 리마인더를 추가합니다.

## 요구사항
- [ ] 위치 기반 리마인더
- [ ] 특정 앱 실행 시 리마인더
- [ ] 반복 리마인더 패턴
- [ ] 리마인더 히스토리

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Feature] 대시보드 위젯" "## 설명
오늘의 생산성 위젯과 완료율 원형 차트 위젯을 추가합니다.

## 요구사항
- [ ] 오늘의 생산성 위젯
- [ ] 완료율 원형 차트 위젯
- [ ] 태그 클라우드 위젯
- [ ] 캘린더 미니 위젯

## 라벨
enhancement, ux, roadmap" "enhancement,ux,roadmap"

create_issue "[Feature] 오프라인 큐 개선" "## 설명
오프라인 작업 큐와 충돌 해결을 개선합니다.

## 요구사항
- [ ] 오프라인 작업 큐잉
- [ ] 충돌 해결 (Conflict resolution)
- [ ] 동기화 진행률 표시
- [ ] 오프라인 모드 표시

## 라벨
enhancement, stability, roadmap" "enhancement,stability,roadmap"

# 51-65: Performance
create_issue "[Performance] 가상화/지연 로딩" "## 설명
긴 리스트 가상화와 이미지 지연 로딩을 추가합니다.

## 요구사항
- [ ] 긴 리스트 가상화 (VirtualizedList)
- [ ] 이미지 지연 로딩 (Lazy loading)
- [ ] 무한 스크롤 (Infinite scroll)
- [ ] 페이지네이션

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 캐싱 전략" "## 설명
메모리 캐시와 디스크 캐시를 구현합니다.

## 요구사항
- [ ] 메모리 캐시 (LRU)
- [ ] 디스크 캐시 (IndexedDB)
- [ ] API 응답 캐싱
- [ ] 이미지 캐싱

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] Firebase 최적화" "## 설명
Firestore 쿼리 최적화와 배치 쓰기를 개선합니다.

## 요구사항
- [ ] Firestore 쿼리 최적화 (인덱스)
- [ ] 배치 쓰기 (Batch writes)
- [ ] 트랜잭션 최적화
- [ ] 읽기/쓰기 비용 절감

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] IndexedDB 최적화" "## 설명
인덱스 생성과 대량 데이터 청크 단위 처리를 개선합니다.

## 요구사항
- [ ] 인덱스 생성
- [ ] 대량 데이터 청크 단위 처리
- [ ] 커서 기반 쿼리
- [ ] 저장소 한도 관리

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 번들 크기 최적화" "## 설명
코드 스플리팅과 트리 쉐이킹을 적용합니다.

## 요구사항
- [ ] 코드 스플리팅 (Code splitting)
- [ ] 트리 쉐이킹 (Tree shaking)
- [ ] 사용하지 않는 코드 제거
- [ ] 라이브러리 최적화 (lodash → 개별 함수)

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 이미지 최적화" "## 설명
이미지 압축과 썸네일 생성을 추가합니다.

## 요구사항
- [ ] 이미지 압축 (WebP)
- [ ] 썸네일 생성
- [ ] 이미지 리사이징
- [ ] CDN 연동

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 렌더링 최적화" "## 설명
React.memo 적용과 불필요한 리렌더링 방지를 추가합니다.

## 요구사항
- [ ] React.memo 적용
- [ ] useMemo/useCallback 활용
- [ ] 불필요한 리렌더링 방지
- [ ] 가상 DOM 최적화

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 네트워크 최적화" "## 설명
요청 병합과 중복 요청 방지를 추가합니다.

## 요구사항
- [ ] 요청 병합 (Request batching)
- [ ] 중복 요청 방지 (Deduplication)
- [ ] 오프라인 큐 관리
- [ ] 재시도 로직 (Exponential backoff)

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 시작 시간 단축" "## 설명
초기 번들 크기 감소와 서비스 워커 프리캐시를 추가합니다.

## 요구사항
- [ ] 초기 번들 크기 감소
- [ ] 지연 로딩 (Lazy loading)
- [ ] 서비스 워커 프리캐시
- [ ] 스플래시 스크린 최적화

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 메모리 관리" "## 설명
메모리 누수 탐지와 큰 객체 해제를 추가합니다.

## 요구사항
- [ ] 메모리 누수 탐지
- [ ] 큰 객체 해제
- [ ] 이벤트 리스너 정리
- [ ] 가비지 컬렉션 힌트

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 배터리 최적화" "## 설명
백그라운드 작업 최적화와 Doze 모드 대응을 추가합니다.

## 요구사항
- [ ] 백그라운드 작업 최적화
- [ ] 위치 업데이트 빈도 조절
- [ ] 동기화 주기 조정
- [ ] Doze 모드 대응

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 데이터베이스 마이그레이션" "## 설명
버전 관리 마이그레이션과 롤백 스크립트를 추가합니다.

## 요구사항
- [ ] 버전 관리 마이그레이션
- [ ] 롤백 스크립트
- [ ] 데이터 무결성 검증
- [ ] 마이그레이션 로깅

## 라벨
enhancement, performance, stability, roadmap" "enhancement,performance,stability,roadmap"

create_issue "[Performance] 에러 핸들링" "## 설명
전역 에러 바운더리와 에러 리포팅을 추가합니다.

## 요구사항
- [ ] 전역 에러 바운더리
- [ ] 에러 리포팅 (Firebase Crashlytics)
- [ ] 사용자 친화적 에러 메시지
- [ ] 에러 복구 로직

## 라벨
enhancement, stability, roadmap" "enhancement,stability,roadmap"

create_issue "[Performance] 로깅/모니터링" "## 설명
성능 로깅과 사용자 행동 추적을 추가합니다.

## 요구사항
- [ ] 성능 로깅 (Performance API)
- [ ] 사용자 행동 추적 (Analytics)
- [ ] 네트워크 요청 로깅
- [ ] 디버그 모드

## 라벨
enhancement, performance, roadmap" "enhancement,performance,roadmap"

create_issue "[Performance] 테스트 커버리지" "## 설명
단위 테스트, 통합 테스트, E2E 테스트를 추가합니다.

## 요구사항
- [ ] 단위 테스트 (Jest)
- [ ] 통합 테스트 (React Testing Library)
- [ ] E2E 테스트 (Playwright)
- [ ] 성능 테스트 (Lighthouse CI)

## 라벨
enhancement, stability, roadmap" "enhancement,stability,roadmap"

# 66-75: Security
create_issue "[Security] 인증 보안 강화" "## 설명
생체 인식 인증과 PIN/패턴 잠금을 추가합니다.

## 요구사항
- [ ] 생체 인식 인증 (Fingerprint/FaceID)
- [ ] PIN/패턴 잠금
- [ ] 자동 로그아웃 (세션 타임아웃)
- [ ] 다중 인증 (2FA)

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 데이터 암호화" "## 설명
로컬 데이터 암호화와 전송 계층 보안을 강화합니다.

## 요구사항
- [ ] 로컬 데이터 암호화 (AES-256)
- [ ] 전송 계층 보안 (TLS 1.3)
- [ ] 키 관리 (Android Keystore)
- [ ] 암호화된 백업

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 권한 관리" "## 설명
최소 권한 원칙과 런타임 권한 요청을 개선합니다.

## 요구사항
- [ ] 최소 권한 원칙
- [ ] 런타임 권한 요청
- [ ] 권한 사용 투명성
- [ ] 권한 거부 대응

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 개인정보 보호" "## 설명
GDPR 준수와 데이터 삭제 요청 처리를 추가합니다.

## 요구사항
- [ ] GDPR 준수
- [ ] 데이터 삭제 요청 처리
- [ ] 개인정보 취급 방침
- [ ] 데이터 내보내기 (GDPR)

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] Firebase 보안" "## 설명
Firestore 보안 규칙 강화와 Firebase App Check을 추가합니다.

## 요구사항
- [ ] Firestore 보안 규칙 강화
- [ ] Firebase App Check
- [ ] API 키 제한
- [ ] 앱 무단 복제 방지

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 네트워크 보안" "## 설명
인증서 고정과 SSL 핀닝을 추가합니다.

## 요구사항
- [ ] 인증서 고정 (Certificate pinning)
- [ ] SSL 핀닝
- [ ] MITM 방지
- [ ] VPN 탐지

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 데이터 백업 보안" "## 설명
백업 암호화와 안전한 전송을 추가합니다.

## 요구사항
- [ ] 백업 암호화
- [ ] 안전한 전송 (HTTPS)
- [ ] 백업 무결성 검증
- [ ] 기기 간 보안 전송

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 세션 관리" "## 설명
보안 쿠키와 CSRF 방지를 추가합니다.

## 요구사항
- [ ] 보안 쿠키 (HttpOnly, Secure)
- [ ] CSRF 방지
- [ ] 세션 하이재킹 방지
- [ ] 동시 로그인 제한

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 콘텐츠 보안 정책" "## 설명
CSP 헤더 설정과 XSS 방지를 추가합니다.

## 요구사항
- [ ] CSP 헤더 설정
- [ ] XSS 방지
- [ ] 인젝션 공격 방어
- [ ] 입력값 검증/삭제

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

create_issue "[Security] 보안 감사" "## 설명
정기적인 보안 검사와 취약점 스캔을 추가합니다.

## 요구사항
- [ ] 정기적인 보안 검사
- [ ] 의존성 취약점 스캔 (npm audit)
- [ ] 침투 테스트
- [ ] 보안 로깅

## 라벨
enhancement, security, roadmap" "enhancement,security,roadmap"

# 76-85: Platform
create_issue "[Platform] Wear OS 지원" "## 설명
Wear OS 앱 개발과 시계에서 할 일 관리를 추가합니다.

## 요구사항
- [ ] Wear OS 앱 개발
- [ ] 시계에서 할 일 확인/완료
- [ ] 음성 입력 (Wear OS)
- [ ] 시계 전용 위젯

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] iOS 버전" "## 설명
Capacitor iOS 빌드와 Siri 숏컷 연동을 추가합니다.

## 요구사항
- [ ] Capacitor iOS 빌드
- [ ] iOS 디자인 가이드 준수
- [ ] Siri 숏컷 연동
- [ ] Apple Watch 지원

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] 웹 버전 (PWA)" "## 설명
프로그레시브 웹 앱과 홈 화면 추가를 추가합니다.

## 요구사항
- [ ] 프로그레시브 웹 앱
- [ ] 오프라인 지원 (Service Worker)
- [ ] 홈 화면 추가
- [ ] 웹 푸시 알림

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] 태블릿 최적화" "## 설명
태블릿 전용 레이아웃과 마스터/디테일 뷰를 추가합니다.

## 요구사항
- [ ] 태블릿 전용 레이아웃
- [ ] 마스터/디테일 뷰
- [ ] 멀티윈도우 지원
- [ ] S 펜 지원 (Samsung)

## 라벨
enhancement, ux, roadmap" "enhancement,ux,roadmap"

create_issue "[Platform] 폴더블 디스플레이" "## 설명
갤럭시 Z Fold/Flip 대응과 힌지 각도 감지를 추가합니다.

## 요구사항
- [ ] 갤럭시 Z Fold/Flip 대응
- [ ] 힌지 각도 감지
- [ ] 연속 모드/플립 모드
- [ ] 멀티 윈도우

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] Android Automotive" "## 설명
차량용 인터페이스와 음성 제어를 추가합니다.

## 요구사항
- [ ] 차량용 인터페이스
- [ ] 음성 제어
- [ ] 운전 모드
- [ ] 크고 쉬운 터치

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] Android TV" "## 설명
TV용 인터페이스와 리모컨 네비게이션을 추가합니다.

## 요구사항
- [ ] TV용 인터페이스
- [ ] 리모컨 네비게이션
- [ ] TV 전용 위젯
- [ ] 10피트 UI

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] 크롬 확장프로그램" "## 설명
Chrome Extension과 브라우저에서 빠른 추가를 추가합니다.

## 요구사항
- [ ] Chrome Extension
- [ ] 브라우저에서 빠른 추가
- [ ] 웹페이지 저장
- [ ] 알림 동기화

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] 데스크톱 앱" "## 설명
Electron 래퍼와 시스템 트레이 아이콘을 추가합니다.

## 요구사항
- [ ] Electron 래퍼
- [ ] 시스템 트레이 아이콘
- [ ] 바로가기 키 (Global shortcut)
- [ ] 데스크톱 알림

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Platform] 스마트 홈 연동" "## 설명
Google Home 연동과 스마트 스피커 알림을 추가합니다.

## 요구사항
- [ ] Google Home 연동
- [ ] Alexa 스킬
- [ ] 스마트 스피커 알림
- [ ] 홈 오토메이션 트리거

## 라벨
enhancement, roadmap" "enhancement,roadmap"

# 86-90: Monetization
create_issue "[Monetization] 구독 모델 (Pro)" "## 설명
월간/연간 구독과 Google Play Billing 연동을 추가합니다.

## 요구사항
- [ ] 월간/연간 구독
- [ ] Google Play Billing 연동
- [ ] 구독 혜택 (무제한, 고급 기능)
- [ ] 무료 체험 기간

## 라벨
enhancement, monetization, roadmap" "enhancement,monetization,roadmap"

create_issue "[Monetization] 인앱 구매" "## 설명
테마 팩과 고급 위젯, 내보내기 옵션을 추가합니다.

## 요구사항
- [ ] 테마 팩
- [ ] 고급 위젯
- [ ] 내보내기 옵션
- [ ] 백업 스토리지

## 라벨
enhancement, monetization, roadmap" "enhancement,monetization,roadmap"

create_issue "[Monetization] 광고 통합" "## 설명
배너 광고와 보상형 광고를 추가합니다.

## 요구사항
- [ ] 배너 광고 (AdMob)
- [ ] 보상형 광고 (추가 기능 잠금 해제)
- [ ] 광고 제거 옵션
- [ ] 광고 개인정보 보호

## 라벨
enhancement, monetization, roadmap" "enhancement,monetization,roadmap"

create_issue "[Monetization] 추천 프로그램" "## 설명
친구 초대 보상과 추천 코드 생성을 추가합니다.

## 요구사항
- [ ] 친구 초대 보상
- [ ] 추천 코드 생성
- [ ] 보상 포인트 시스템
- [ ] 리더보드

## 라벨
enhancement, monetization, roadmap" "enhancement,monetization,roadmap"

create_issue "[Monetization] 엔터프라이즈 플랜" "## 설명
팀 관리 기능과 관리자 대시보드를 추가합니다.

## 요구사항
- [ ] 팀 관리 기능
- [ ] 관리자 대시보드
- [ ] 고급 통계/리포트
- [ ] 우선 지원

## 라벨
enhancement, monetization, roadmap" "enhancement,monetization,roadmap"

# 91-95: AI
create_issue "[AI] AI 일정 추천" "## 설명
과거 패턴 분석으로 최적 시간 추천과 스마트 스케줄링을 추가합니다.

## 요구사항
- [ ] 과거 패턴 분석으로 최적 시간 추천
- [ ] AI 기반 작업 우선순위
- [ ] 스마트 스케줄링
- [ ] 충돌 감지 및 해결

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[AI] AI 태그 추출 고도화" "## 설명
콘텐츠 기반 자동 태그와 의미론적 유사도 분석을 추가합니다.

## 요구사항
- [ ] 콘텐츠 기반 자동 태그
- [ ] 의미론적 유사도 분석
- [ ] 태그 제안 (ML 모델)
- [ ] 태그 클러스터링

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[AI] AI 생산성 코치" "## 설명
개인화된 생산성 팁과 작업 습관 분석을 추가합니다.

## 요구사항
- [ ] 개인화된 생산성 팁
- [ ] 작업 습관 분석
- [ ] 개선 제안
- [ ] 동기부여 메시지

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[AI] AI 음성 비서 고도화" "## 설명
자연어 처리 고도화와 대화형 할 일 관리를 추가합니다.

## 요구사항
- [ ] 자연어 처리 고도화
- [ ] 대화형 할 일 관리
- [ ] 컨텍스트 기억
- [ ] 다국어 지원

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

create_issue "[AI] AI 요약/리포트" "## 설명
일일/주간/월간 요약과 AI 생성 생산성 리포트를 추가합니다.

## 요구사항
- [ ] 일일/주간/월간 요약
- [ ] AI 생성 생산성 리포트
- [ ] 트렌드 분석
- [ ] 이상 탐지 (Anomaly detection)

## 라벨
enhancement, ai, roadmap" "enhancement,ai,roadmap"

# 96-100: Other
create_issue "[Other] 게임화 (Gamification)" "## 설명
경험치(XP) 시스템과 레벨업/배지 획득을 추가합니다.

## 요구사항
- [ ] 경험치 (XP) 시스템
- [ ] 레벨업 / 배지 획득
- [ ] 리더보드 (친구/전체)
- [ ] 연속 달성 (Streak) 보상

## 참고
Todoist Karma 시스템의 벤치마킹.

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Other] 접근성 (Accessibility) 향상" "## 설명
WCAG 2.1 AA 준수와 스크린 리더 최적화를 추가합니다.

## 요구사항
- [ ] WCAG 2.1 AA 준수
- [ ] 스크린 리더 최적화
- [ ] 키보드 전용 네비게이션
- [ ] 고대비/큰 글씨 모드

## 라벨
enhancement, accessibility, roadmap" "enhancement,accessibility,roadmap"

create_issue "[Other] 현지화 (Localization) 확장" "## 설명
10개 언어 지원과 문화적 맞춤을 추가합니다.

## 요구사항
- [ ] 10개 언어 지원
- [ ] 문화적 맞춤 (날짜/시간 형식)
- [ ] 현지 휴일/캘린더
- [ ] 통화/단위 변환

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Other] 데이터 시각화" "## 설명
인터랙티브 차트와 히트맵을 추가합니다.

## 요구사항
- [ ] 인터랙티브 차트 (Recharts)
- [ ] 히트맵 (Heatmap)
- [ ] 산포도 (Scatter plot)
- [ ] 타임라인 뷰

## 라벨
enhancement, roadmap" "enhancement,roadmap"

create_issue "[Other] 소셜 기능" "## 설명
친구 추가/팔로우와 피드 공유를 추가합니다.

## 요구사항
- [ ] 친구 추가/팔로우
- [ ] 피드 공유 (완료한 할 일)
- [ ] 댓글/좋아요
- [ ] 소셜 리더보드

## 라벨
enhancement, roadmap" "enhancement,roadmap"

echo ""
echo "=== All 100 issues creation attempted ==="
echo "Check 'gh issue list --limit 110' to verify"
