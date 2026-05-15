# Script to create 100 GitHub Issues for BrioDo Top 10 improvements
# Fixed version with proper Korean text handling

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$issues = @(
    # UI/UX Improvements (1-20)
    @{title="[UI/UX] 홈 화면 위젯 개선 (다양한 크기 지원)"; body="## 설명`n홈 화면 위젯이 다양한 크기(1x1, 2x2, 4x1, 4x2)를 지원하도록 개선합니다.`n`n## 요구사항`n- [ ] 1x1, 2x2, 4x1, 4x2 크기 지원`n- [ ] 위젯 테마 커스터마이징 (투명도, 색상)`n- [ ] 위젯에서 직접 할 일 추가 기능`n- [ ] 위젯에서 완료 표시 가능하도록 개선`n`n## 라벨`nenhancement, ux, roadmap"; labels="enhancement,ux,roadmap"},
    @{title="[UI/UX] 제스처 컨트롤 개선"; body="## 설명`n스와이프 액션과 롱프레스 메뉴를 개선합니다.`n`n## 요구사항`n- [ ] 왼쪽/오른쪽 스와이프 메뉴 개선`n- [ ] 스와이프로 우선순위 변경`n- [ ] 스와이프로 날짜 변경`n- [ ] 롱프레스 액션 추가 (빠른 메뉴)`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 다크 모드/테마 고도화"; body="## 설명`n시스템 테마 자동 감지와 다양한 컬러 테마를 지원합니다.`n`n## 요구사항`n- [ ] 시스템 테마 자동 감지`n- [ ] 다양한 컬러 테마 지원 (Material You)`n- [ ] 고대비 모드 지원`n- [ ] 사용자 정의 테마 색상 선택`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 애니메이션/전환 효과 추가"; body="## 설명`n할 일 완료, 추가, 삭제 시 애니메이션을 추가합니다.`n`n## 요구사항`n- [ ] 할 일 완료 시 체크 애니메이션`n- [ ] 페이지 전환 시 부드러운 트랜지션`n- [ ] 할 일 추가/삭제 시 애니메이션`n- [ ] 로딩 스켈레톤 UI 적용`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 폰트/접근성 개선"; body="## 설명`n시스템 폰트 크기 연동과 접근성을 향상시킵니다.`n`n## 요구사항`n- [ ] 시스템 폰트 크기 연동`n- [ ] 접근성 향상 (TalkBack 완벽 지원)`n- [ ] 키보드 네비게이션 최적화`n- [ ] 고대비 모드 준수`n`n## 라벨`nenhancement, ux,accessibility"; labels="enhancement,ux,accessibility"},
    @{title="[UI/UX] 인디케이터/배지 개선"; body="## 설명`n앱 아이콘 배지와 다양한 시각적 구분 요소를 추가합니다.`n`n## 요구사항`n- [ ] 앱 아이콘 배지 카운트 (미완료 할 일 수)`n- [ ] 우선순위별 색상 인디케이터`n- [ ] 마감임박 표시 (빨간색 테두리 등)`n- [ ] 오늘/지연된 할 일 시각적 구분`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 캘린더 뷰 개선"; body="## 설명`n월간/주간/일간 뷰와 드래그 앤 드롭을 지원합니다.`n`n## 요구사항`n- [ ] 월간/주간/일간 뷰 추가`n- [ ] 드래그 앤 드롭으로 날짜 변경`n- [ ] 이벤트 컬러 코딩`n- [ ] 캘린더 겹침 해결`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 검색/필터 UI 개선"; body="## 설명`n검색바 상단 고정과 고급 필터를 추가합니다.`n`n## 요구사항`n- [ ] 검색바 상단 고정`n- [ ] 고급 필터 (우선순위, 태그, 날짜 범위)`n- [ ] 저장된 검색 필터`n- [ ] 검색 결과 하이라이트`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 온보딩/튜토리얼 추가"; body="## 설명`n첫 실행 시 인터랙티브 튜토리얼을 추가합니다.`n`n## 요구사항`n- [ ] 첫 실행 시 인터랙티브 튜토리얼`n- [ ] 기능 소개 슬라이더`n- [ ] 툴팁 / 힌트 시스템`n- [ ] 빈 상태(empty state) 일러스트레이션`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 에러 처리 UI 개선"; body="## 설명`n친절한 에러 메시지와 오프라인 상태 표시를 개선합니다.`n`n## 요구사항`n- [ ] 친절한 에러 메시지 디자인`n- [ ] 재시도 버튼 개선`n- [ ] 오프라인 상태 표시 (스낵바)`n- [ ] 동기화 상태 표시 (스피너/체크)`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 다국어 지원 확장"; body="## 설명`n영어/한국어 외에 더 많은 언어를 지원합니다.`n`n## 요구사항`n- [ ] 10개 언어 지원 (일본어, 중국어, 스페인어 등)`n- [ ] 시스템 언어 자동 감지`n- [ ] 번역 누락 체크`n- [ ] RTL 언어 지원 (아랍어 등)`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 숏컷/빠른 액션"; body="## 설명`n앱 아이콘 롱프레스 메뉴와 알림에서 직접 관리를 추가합니다.`n`n## 요구사항`n- [ ] 앱 아이콘 롱프레스 메뉴 (Android 7.1+)`n- [ ] 알림에서 직접 완료/미루기`n- [ ] 앱바 단축 아이콘`n- [ ] 실시간 배지 업데이트`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 리스트 뷰 옵션"; body="## 설명`n그리드 뷰와 컴팩트 모드 등 다양한 뷰 옵션을 추가합니다.`n`n## 요구사항`n- [ ] 그리드 뷰 / 리스트 뷰 전환`n- [ ] 썸네일 표시 (첨부파일 있을 경우)`n- [ ] 컴팩트 모드 / 편안 모드`n- [ ] 정렬 옵션 (이름, 날짜, 우선순위)`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 태그/라벨 UI 개선"; body="## 설명`n태그 색상 커스터마이징과 태그 클라우드 뷰를 추가합니다.`n`n## 요구사항`n- [ ] 태그 색상 커스터마이징`n- [ ] 태그 클라우드 뷰`n- [ ] 태그 자동완성`n- [ ] 태그별 필터링 개선`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 알림 UI 개선"; body="## 설명`n알림 센터와 알림 채널 설정을 개선합니다.`n`n## 요구사항`n- [ ] 알림 센터에서 할 일 관리`n- [ ] 알림 그룹핑 (Android 7.0+)`n- [ ] 알림 채널 설정 (Android 8.0+)`n- [ ] 알림 사운드/진동 커스터마이징`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 통계 대시보드"; body="## 설명`n완료율 그래프와 생산성 트렌드를 시각화합니다.`n`n## 요구사항`n- [ ] 완료율 그래프 (원형/막대)`n- [ ] 주간/월간 생산성 트렌드`n- [ ] 태그별 통계`n- [ ] 시간대별 생산성 히트맵`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 개인화 홈"; body="## 설명`n오늘의 할 일 포커스와 AI 기반 추천을 추가합니다.`n`n## 요구사항`n- [ ] 오늘의 할 일 포커스 뷰`n- [ ] 추천 작업 (AI 기반)`n- [ ] 날씨 정보 연동`n- [ ] 인사말 (Good morning 등)`n`n## 라벨`nenhancement, ux,ai"; labels="enhancement,ux,ai"},
    @{title="[UI/UX] 드래그 앤 드롭"; body="## 설명`n할 일 순서 변경과 리스트 간 이동을 드래그로 지원합니다.`n`n## 요구사항`n- [ ] 할 일 순서 변경`n- [ ] 리스트 간 이동`n- [ ] 캘린더로 드래그`n- [ ] 폴더/프로젝트로 이동`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    @{title="[UI/UX] 음성 입력 UI"; body="## 설명`n음성 입력 버튼 애니메이션과 실시간 표시를 개선합니다.`n`n## 요구사항`n- [ ] 음성 입력 버튼 애니메이션`n- [ ] 음성 인식 결과 실시간 표시`n- [ ] 명령어 힌트 표시`n- [ ] 음성 프로필 설정`n`n## 라벨`nenhancement, ux,ai"; labels="enhancement,ux,ai"},
    @{title="[UI/UX] 공유/익스포트 UI"; body="## 설명`n공유 시트와 내보내기 옵션을 개선합니다.`n`n## 요구사항`n- [ ] 공유 시트 개선`n- [ ] 내보내기 옵션 (PDF, CSV, JSON)`n- [ ] 인쇄 레이아웃 개선`n- [ ] QR 코드로 공유`n`n## 라벨`nenhancement, ux"; labels="enhancement,ux"},
    
    # Features (21-50)
    @{title="[Feature] 하위 작업 (Subtasks) 지원"; body="## 설명`n무제한 하위 작업 생성과 진행률 표시를 추가합니다.`n`n## 요구사항`n- [ ] 무제한 하위 작업 생성`n- [ ] 하위 작업 진행률 표시`n- [ ] 하위 작업 마감일 설정`n- [ ] 하위 작업 완료 시 부모 업데이트`n`n## 참고`nTop 10 앱(Todoist, TickTick)의 핵심 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 습관 추적 (Habit Tracker)"; body="## 설명`n습관 생성과 통계, 알림을 추가합니다.`n`n## 요구사항`n- [ ] 습관 생성 (매일/매주/매월)`n- [ ] 습관 통계 (연속일, 성공률)`n- [ ] 습관 캘린더 뷰`n- [ ] 습관 알림 및 리마인더`n`n## 참고`nTickTick의 핵심 차별화 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 뽀모도로 타이머 (Pomodoro Timer)"; body="## 설명`n25분 집중 / 5분 휴식 타이머와 위젯을 추가합니다.`n`n## 요구사항`n- [ ] 25분 집중 / 5분 휴식 타이머`n- [ ] 사용자 정의 시간 설정`n- [ ] 타이머 위젯 (홈 화면)`n- [ ] 세션 통계 및 기록`n`n## 참고`nTickTick, Any.do 등의 주요 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 아이젠하워 매트릭스 (Eisenhower Matrix)"; body="## 설명`n4분면 뷰으로 우선순위를 자동 분류합니다.`n`n## 요구사항`n- [ ] 4분면 뷰 (긴급/중요)`n- [ ] 드래그로 사분면 이동`n- [ ] 우선순위 자동 분류`n- [ ] 매트릭스 통계`n`n## 참고`nTickTick의 차별화 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 자연어 처리 (NLP) 개선"; body="## 설명`n\"내일 오전 10시 회의\" 등의 자연어를 자동 파싱합니다.`n`n## 요구사항`n- [ ] \"내일 오전 10시 회의\" → 자동 파싱`n- [ ] \"매주 월요일마다\" → 반복 설정`n- [ ] 우선순위 자동 감지 (\"긴급한\" 등)`n- [ ] 태그 자동 추출`n`n## 참고`nTodoist, TickTick의 핵심 기능입니다.`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[Feature] 반복 작업 개선"; body="## 설명`n복잡한 반복 규칙과 예외 처리를 추가합니다.`n`n## 요구사항`n- [ ] 복잡한 반복 규칙 (매월 첫째 주 등)`n- [ ] 반복 작업 예외 처리`n- [ ] 반복 작업 일시 중지`n- [ ] 반복 패턴 템플릿`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 위치 기반 알림"; body="## 설명`n특정 장소 도착 시 알림과 지오펜싱을 추가합니다.`n`n## 요구사항`n- [ ] 특정 장소 도착 시 알림`n- [ ] 지오펜싱 (Geofencing)`n- [ ] 장소별 할 일 리스트`n- [ ] 위치 히스토리 기반 추천`n`n## 참고`nTodoist, Any.do의 프리미엄 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 첨부파일 지원"; body="## 설명`n이미지, 파일, 음성 녹음 첨부를 추가합니다.`n`n## 요구사항`n- [ ] 이미지 첨부 (갤러리/카메라)`n- [ ] 파일 첨부 (PDF, DOC 등)`n- [ ] 음성 녹음 첨부`n- [ ] 클라우드 파일 링크 (Google Drive 등)`n`n## 참고`nMicrosoft To Do, Any.do 등의 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 협업/공유"; body="## 설명`n할 일 공유와 실시간 동기화, 댓글을 추가합니다.`n`n## 요구사항`n- [ ] 할 일 공유 (가족/팀)`n- [ ] 공유 목록 실시간 동기화`n- [ ] 댓글 / @멘션`n- [ ] 권한 관리 (보기/편집/관리자)`n`n## 참고`nTodoist, Any.do의 핵심 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 프로젝트/폴더"; body="## 설명`n무제한 프로젝트 생성과 템플릿을 추가합니다.`n`n## 요구사항`n- [ ] 무제한 프로젝트 생성`n- [ ] 프로젝트 색상/아이콘`n- [ ] 프로젝트 템플릿`n- [ ] 프로젝트 간 이동`n`n## 참고`nTodoist, TickTick의 핵심 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 시간 추적 (Time Tracking)"; body="## 설명`n할 일에 소요 시간 기록과 통계를 추가합니다.`n`n## 요구사항`n- [ ] 할 일에 소요 시간 기록`n- [ ] 시작/중지 타이머`n- [ ] 시간대별 리포트`n- [ ] 시간 기반 생산성 분석`n`n## 참고`n고급 생산성 앱의 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 태그 시스템 고도화"; body="## 설명`n중첩 태그와 AI 기반 자동 생성을 추가합니다.`n`n## 요구사항`n- [ ] 중첩 태그 (parent/child)`n- [ ] 태그 자동 생성 (AI)`n- [ ] 태그 필터링 고급 검색`n- [ ] 태그별 통계 대시보드`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[Feature] 캘린더 통합 고도화"; body="## 설명`nGoogle Calendar 양방향 동기화와 Outlook/Apple 연동을 추가합니다.`n`n## 요구사항`n- [ ] Google Calendar 양방향 동기화`n- [ ] Outlook Calendar 연동`n- [ ] Apple Calendar 연동 (iOS)`n- [ ] 캘린더 구독 (iCal)`n`n## 참고`nBrioDo는 이미 기본 연동이 있지만 고도화가 필요합니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 이메일 연동"; body="## 설명`nGmail에서 할 일 생성과 이메일 알림을 추가합니다.`n`n## 요구사항`n- [ ] Gmail에서 할 일 생성`n- [ ] 이메일 첨부/링크 저장`n- [ ] 이메일 알림`n- [ ] 이메일로 할 일 전송`n`n## 참고`nMicrosoft To Do의 핵심 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 스마트 리스트/필터"; body="## 설명`n사용자 정의 스마트 리스트와 복합 조건 필터를 추가합니다.`n`n## 요구사항`n- [ ] 사용자 정의 스마트 리스트`n- [ ] 복합 조건 필터 (AND/OR)`n- [ ] 저장된 필터 즐겨찾기`n- [ ] 필터 공유`n`n## 참고`nTodoist의 핵심 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 템플릿 시스템"; body="## 설명`n할 일/프로젝트 템플릿과 마켓플레이스를 추가합니다.`n`n## 요구사항`n- [ ] 할 일 템플릿 (장보기 등)`n- [ ] 프로젝트 템플릿`n- [ ] 템플릿 마켓플레이스`n- [ ] 템플릿 공유`n`n## 참고`nTodoist, Asana의 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 백업/복원"; body="## 설명`n자동 클라우드 백업과 선택적 복원을 추가합니다.`n`n## 요구사항`n- [ ] 자동 클라우드 백업 (Firebase)`n- [ ] 로컬 백업 (JSON)`n- [ ] 백업 스케줄링`n- [ ] 선택적 복원`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 가져오기/내보내기"; body="## 설명`nTodoist, Google Tasks 가져오기와 CSV/Excel 내보내기를 추가합니다.`n`n## 요구사항`n- [ ] Todoist 가져오기`n- [ ] Google Tasks 가져오기`n- [ ] CSV/Excel 내보내기`n- [ ] PDF 리포트 생성`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 음성 비서 연동"; body="## 설명`nGoogle Assistant, Bixby, Siri 숏컷 연동을 추가합니다.`n`n## 요구사항`n- [ ] Google Assistant 연동`n- [ ] Bixby 연동 (Samsung)`n- [ ] Siri 숏컷 (iOS)`n- [ ] 음성 명령어 커스터마이징`n`n## 참고`nAny.do, Todoist의 기능입니다.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 위젯 개선"; body="## 설명`n투두위젯/캘린더 위젯 통합과 커스터마이징을 추가합니다.`n`n## 요구사항`n- [ ] 투두위젯/캘린더 위젯 통합`n- [ ] 위젯 색상 테마`n- [ ] 위젯 투명도 조절`n- [ ] 위젯 새로고침 주기`n`n## 라벨`nenhancement, ux, roadmap"; labels="enhancement,ux,roadmap"},
    @{title="[Feature] 알림 스마트화"; body="## 설명`n알림 스누즈와 스마트 알림을 추가합니다.`n`n## 요구사항`n- [ ] 알림 스누즈 (5분, 10분, 1시간)`n- [ ] 알림 시간대 설정 (방해 금지 모드)`n- [ ] 할 일 기반 스마트 알림`n- [ ] 알림 히스토리`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 빠른 추가 (Quick Add)"; body="## 설명`n글로벌 플로팅 버튼과 알림창에서 빠른 추가를 추가합니다.`n`n## 요구사항`n- [ ] 글로벌 플로팅 버튼`n- [ ] 알림창에서 빠른 추가`n- [ ] 위젯에서 빠른 추가`n- [ ] 음성으로 빠른 추가`n`n## 라벨`nenhancement, ux, roadmap"; labels="enhancement,ux,roadmap"},
    @{title="[Feature] 할 일 우선순위 고도화"; body="## 설명`n4단계 우선순위와 자동 조정(AI)을 추가합니다.`n`n## 요구사항`n- [ ] 4단계 우선순위 (낮음/보통/높음/긴급)`n- [ ] 우선순위별 색상/아이콘`n- [ ] 우선순위 자동 조정 (AI)`n- [ ] 우선순위별 필터`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 마감일 관리"; body="## 설명`n마감일 카운트다운과 임박 알림을 추가합니다.`n`n## 요구사항`n- [ ] 마감일 카운트다운`n- [ ] 마감일 임박 알림 (1일 전, 1시간 전)`n- [ ] 지연된 할 일 표시`n- [ ] 마감일 일괄 변경`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 검색 엔진 고도화"; body="## 설명`n전문 검색과 최근 검색 기록을 추가합니다.`n`n## 요구사항`n- [ ] 전문 검색 (Full-text search)`n- [ ] 검색 결과 하이라이트`n- [ ] 검색 필터 (날짜, 태그, 우선순위)`n- [ ] 최근 검색 기록`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 북마크/즐겨찾기"; body="## 설명`n중요한 할 일 북마크와 폴더를 추가합니다.`n`n## 요구사항`n- [ ] 중요한 할 일 북마크`n- [ ] 북마크 폴더`n- [ ] 북마크 동기화`n- [ ] 북마크 공유`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 메모/노트"; body="## 설명`n할 일에 리치 텍스트 메모와 첨부파일을 추가합니다.`n`n## 요구사항`n- [ ] 할 일에 리치 텍스트 메모`n- [ ] 첨부파일 포함 메모`n- [ ] 메모 검색`n- [ ] 메모 내보내기`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 리마인더 고도화"; body="## 설명`n위치 기반 리마인더와 특정 앱 실행 시 리마인더를 추가합니다.`n`n## 요구사항`n- [ ] 위치 기반 리마인더`n- [ ] 특정 앱 실행 시 리마인더`n- [ ] 반복 리마인더 패턴`n- [ ] 리마인더 히스토리`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Feature] 대시보드 위젯"; body="## 설명`n오늘의 생산성 위젯과 완료율 원형 차트 위젯을 추가합니다.`n`n## 요구사항`n- [ ] 오늘의 생산성 위젯`n- [ ] 완료율 원형 차트 위젯`n- [ ] 태그 클라우드 위젯`n- [ ] 캘린더 미니 위젯`n`n## 라벨`nenhancement, ux, roadmap"; labels="enhancement,ux,roadmap"},
    @{title="[Feature] 오프라인 큐 개선"; body="## 설명`n오프라인 작업 큐와 충돌 해결을 개선합니다.`n`n## 요구사항`n- [ ] 오프라인 작업 큐잉`n- [ ] 충돌 해결 (Conflict resolution)`n- [ ] 동기화 진행률 표시`n- [ ] 오프라인 모드 표시`n`n## 라벨`nenhancement, stability, roadmap"; labels="enhancement,stability,roadmap"},
    
    # Performance (51-65)
    @{title="[Performance] 가상화/지연 로딩"; body="## 설명`n긴 리스트 가상화와 이미지 지연 로딩을 추가합니다.`n`n## 요구사항`n- [ ] 긴 리스트 가상화 (VirtualizedList)`n- [ ] 이미지 지연 로딩 (Lazy loading)`n- [ ] 무한 스크롤 (Infinite scroll)`n- [ ] 페이지네이션`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 캐싱 전략"; body="## 설명`n메모리 캐시와 디스크 캐시를 구현합니다.`n`n## 요구사항`n- [ ] 메모리 캐시 (LRU)`n- [ ] 디스크 캐시 (IndexedDB)`n- [ ] API 응답 캐싱`n- [ ] 이미지 캐싱`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] Firebase 최적화"; body="## 설명`nFirestore 쿼리 최적화와 배치 쓰기를 개선합니다.`n`n## 요구사항`n- [ ] Firestore 쿼리 최적화 (인덱스)`n- [ ] 배치 쓰기 (Batch writes)`n- [ ] 트랜잭션 최적화`n- [ ] 읽기/쓰기 비용 절감`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] IndexedDB 최적화"; body="## 설명`n인덱스 생성과 대량 데이터 청크 단위 처리를 개선합니다.`n`n## 요구사항`n- [ ] 인덱스 생성`n- [ ] 대량 데이터 청크 단위 처리`n- [ ] 커서 기반 쿼리`n- [ ] 저장소 한도 관리`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 번들 크기 최적화"; body="## 설명`n코드 스플리팅과 트리 쉐이킹을 적용합니다.`n`n## 요구사항`n- [ ] 코드 스플리팅 (Code splitting)`n- [ ] 트리 쉐이킹 (Tree shaking)`n- [ ] 사용하지 않는 코드 제거`n- [ ] 라이브러리 최적화 (lodash → 개별 함수)`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 이미지 최적화"; body="## 설명`n이미지 압축과 썸네일 생성을 추가합니다.`n`n## 요구사항`n- [ ] 이미지 압축 (WebP)`n- [ ] 썸네일 생성`n- [ ] 이미지 리사이징`n- [ ] CDN 연동`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 렌더링 최적화"; body="## 설명`nReact.memo 적용과 불필요한 리렌더링 방지를 추가합니다.`n`n## 요구사항`n- [ ] React.memo 적용`n- [ ] useMemo/useCallback 활용`n- [ ] 불필요한 리렌더링 방지`n- [ ] 가상 DOM 최적화`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 네트워크 최적화"; body="## 설명`n요청 병합과 중복 요청 방지를 추가합니다.`n`n## 요구사항`n- [ ] 요청 병합 (Request batching)`n- [ ] 중복 요청 방지 (Deduplication)`n- [ ] 오프라인 큐 관리`n- [ ] 재시도 로직 (Exponential backoff)`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 시작 시간 단축"; body="## 설명`n초기 번들 크기 감소와 서비스 워커 프리캐시를 추가합니다.`n`n## 요구사항`n- [ ] 초기 번들 크기 감소`n- [ ] 지연 로딩 (Lazy loading)`n- [ ] 서비스 워커 프리캐시`n- [ ] 스플래시 스크린 최적화`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 메모리 관리"; body="## 설명`n메모리 누수 탐지와 큰 객체 해제를 추가합니다.`n`n## 요구사항`n- [ ] 메모리 누수 탐지`n- [ ] 큰 객체 해제`n- [ ] 이벤트 리스너 정리`n- [ ] 가비지 컬렉션 힌트`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 배터리 최적화"; body="## 설명`n백그라운드 작업 최적화와 Doze 모드 대응을 추가합니다.`n`n## 요구사항`n- [ ] 백그라운드 작업 최적화`n- [ ] 위치 업데이트 빈도 조절`n- [ ] 동기화 주기 조정`n- [ ] Doze 모드 대응`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 데이터베이스 마이그레이션"; body="## 설명`n버전 관리 마이그레이션과 롤백 스크립트를 추가합니다.`n`n## 요구사항`n- [ ] 버전 관리 마이그레이션`n- [ ] 롤백 스크립트`n- [ ] 데이터 무결성 검증`n- [ ] 마이그레이션 로깅`n`n## 라벨`nenhancement, performance, stability, roadmap"; labels="enhancement,performance,stability,roadmap"},
    @{title="[Performance] 에러 핸들링"; body="## 설명`n전역 에러 바운더리와 에러 리포팅을 추가합니다.`n`n## 요구사항`n- [ ] 전역 에러 바운더리`n- [ ] 에러 리포팅 (Firebase Crashlytics)`n- [ ] 사용자 친화적 에러 메시지`n- [ ] 에러 복구 로직`n`n## 라벨`nenhancement, stability, roadmap"; labels="enhancement,stability,roadmap"},
    @{title="[Performance] 로깅/모니터링"; body="## 설명`n성능 로깅과 사용자 행동 추적을 추가합니다.`n`n## 요구사항`n- [ ] 성능 로깅 (Performance API)`n- [ ] 사용자 행동 추적 (Analytics)`n- [ ] 네트워크 요청 로깅`n- [ ] 디버그 모드`n`n## 라벨`nenhancement, performance, roadmap"; labels="enhancement,performance,roadmap"},
    @{title="[Performance] 테스트 커버리지"; body="## 설명`n단위 테스트, 통합 테스트, E2E 테스트를 추가합니다.`n`n## 요구사항`n- [ ] 단위 테스트 (Jest)`n- [ ] 통합 테스트 (React Testing Library)`n- [ ] E2E 테스트 (Playwright)`n- [ ] 성능 테스트 (Lighthouse CI)`n`n## 라벨`nenhancement, stability, roadmap"; labels="enhancement,stability,roadmap"},
    
    # Security (66-75)
    @{title="[Security] 인증 보안 강화"; body="## 설명`n생체 인식 인증과 PIN/패턴 잠금을 추가합니다.`n`n## 요구사항`n- [ ] 생체 인식 인증 (Fingerprint/FaceID)`n- [ ] PIN/패턴 잠금`n- [ ] 자동 로그아웃 (세션 타임아웃)`n- [ ] 다중 인증 (2FA)`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 데이터 암호화"; body="## 설명`n로컬 데이터 암호화와 전송 계층 보안을 강화합니다.`n`n## 요구사항`n- [ ] 로컬 데이터 암호화 (AES-256)`n- [ ] 전송 계층 보안 (TLS 1.3)`n- [ ] 키 관리 (Android Keystore)`n- [ ] 암호화된 백업`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 권한 관리"; body="## 설명`n최소 권한 원칙과 런타임 권한 요청을 개선합니다.`n`n## 요구사항`n- [ ] 최소 권한 원칙`n- [ ] 런타임 권한 요청`n- [ ] 권한 사용 투명성`n- [ ] 권한 거부 대응`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 개인정보 보호"; body="## 설명`nGDPR 준수와 데이터 삭제 요청 처리를 추가합니다.`n`n## 요구사항`n- [ ] GDPR 준수`n- [ ] 데이터 삭제 요청 처리`n- [ ] 개인정보 취급 방침`n- [ ] 데이터 내보내기 (GDPR)`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] Firebase 보안"; body="## 설명`nFirestore 보안 규칙 강화와 Firebase App Check을 추가합니다.`n`n## 요구사항`n- [ ] Firestore 보안 규칙 강화`n- [ ] Firebase App Check`n- [ ] API 키 제한`n- [ ] 앱 무단 복제 방지`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 네트워크 보안"; body="## 설명`n인증서 고정과 SSL 핀닝을 추가합니다.`n`n## 요구사항`n- [ ] 인증서 고정 (Certificate pinning)`n- [ ] SSL 핀닝`n- [ ] MITM 방지`n- [ ] VPN 탐지`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 데이터 백업 보안"; body="## 설명`n백업 암호화와 안전한 전송을 추가합니다.`n`n## 요구사항`n- [ ] 백업 암호화`n- [ ] 안전한 전송 (HTTPS)`n- [ ] 백업 무결성 검증`n- [ ] 기기 간 보안 전송`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 세션 관리"; body="## 설명`n보안 쿠키와 CSRF 방지를 추가합니다.`n`n## 요구사항`n- [ ] 보안 쿠키 (HttpOnly, Secure)`n- [ ] CSRF 방지`n- [ ] 세션 하이재킹 방지`n- [ ] 동시 로그인 제한`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 콘텐츠 보안 정책"; body="## 설명`nCSP 헤더 설정과 XSS 방지를 추가합니다.`n`n## 요구사항`n- [ ] CSP 헤더 설정`n- [ ] XSS 방지`n- [ ] 인젝션 공격 방어`n- [ ] 입력값 검증/삭제`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    @{title="[Security] 보안 감사"; body="## 설명`n정기적인 보안 검사와 취약점 스캔을 추가합니다.`n`n## 요구사항`n- [ ] 정기적인 보안 검사`n- [ ] 의존성 취약점 스캔 (npm audit)`n- [ ] 침투 테스트`n- [ ] 보안 로깅`n`n## 라벨`nenhancement, security, roadmap"; labels="enhancement,security,roadmap"},
    
    # Platform (76-85)
    @{title="[Platform] Wear OS 지원"; body="## 설명`nWear OS 앱 개발과 시계에서 할 일 관리를 추가합니다.`n`n## 요구사항`n- [ ] Wear OS 앱 개발`n- [ ] 시계에서 할 일 확인/완료`n- [ ] 음성 입력 (Wear OS)`n- [ ] 시계 전용 위젯`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] iOS 버전"; body="## 설명`nCapacitor iOS 빌드와 Siri 숏컷 연동을 추가합니다.`n`n## 요구사항`n- [ ] Capacitor iOS 빌드`n- [ ] iOS 디자인 가이드 준수`n- [ ] Siri 숏컷 연동`n- [ ] Apple Watch 지원`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] 웹 버전 (PWA)"; body="## 설명`n프로그레시브 웹 앱과 홈 화면 추가를 추가합니다.`n`n## 요구사항`n- [ ] 프로그레시브 웹 앱`n- [ ] 오프라인 지원 (Service Worker)`n- [ ] 홈 화면 추가`n- [ ] 웹 푸시 알림`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] 태블릿 최적화"; body="## 설명`n태블릿 전용 레이아웃과 마스터/디테일 뷰를 추가합니다.`n`n## 요구사항`n- [ ] 태블릿 전용 레이아웃`n- [ ] 마스터/디테일 뷰`n- [ ] 멀티윈도우 지원`n- [ ] S 펜 지원 (Samsung)`n`n## 라벨`nenhancement, ux, roadmap"; labels="enhancement,ux,roadmap"},
    @{title="[Platform] 폴더블 디스플레이"; body="## 설명`n갤럭시 Z Fold/Flip 대응과 힌지 각도 감지를 추가합니다.`n`n## 요구사항`n- [ ] 갤럭시 Z Fold/Flip 대응`n- [ ] 힌지 각도 감지`n- [ ] 연속 모드/플립 모드`n- [ ] 멀티 윈도우`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] Android Automotive"; body="## 설명`n차량용 인터페이스와 음성 제어를 추가합니다.`n`n## 요구사항`n- [ ] 차량용 인터페이스`n- [ ] 음성 제어`n- [ ] 운전 모드`n- [ ] 크고 쉬운 터치`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] Android TV"; body="## 설명`nTV용 인터페이스와 리모컨 네비게이션을 추가합니다.`n`n## 요구사항`n- [ ] TV용 인터페이스`n- [ ] 리모컨 네비게이션`n- [ ] TV 전용 위젯`n- [ ] 10피트 UI`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] 크롬 확장프로그램"; body="## 설명`nChrome Extension과 브라우저에서 빠른 추가를 추가합니다.`n`n## 요구사항`n- [ ] Chrome Extension`n- [ ] 브라우저에서 빠른 추가`n- [ ] 웹페이지 저장`n- [ ] 알림 동기화`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] 데스크톱 앱"; body="## 설명`nElectron 래퍼와 시스템 트레이 아이콘을 추가합니다.`n`n## 요구사항`n- [ ] Electron 래퍼`n- [ ] 시스템 트레이 아이콘`n- [ ] 바로가기 키 (Global shortcut)`n- [ ] 데스크톱 알림`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Platform] 스마트 홈 연동"; body="## 설명`nGoogle Home 연동과 스마트 스피커 알림을 추가합니다.`n`n## 요구사항`n- [ ] Google Home 연동`n- [ ] Alexa 스킬`n- [ ] 스마트 스피커 알림`n- [ ] 홈 오토메이션 트리거`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    
    # Monetization (86-90)
    @{title="[Monetization] 구독 모델 (Pro)"; body="## 설명`n월간/연간 구독과 Google Play Billing 연동을 추가합니다.`n`n## 요구사항`n- [ ] 월간/연간 구독`n- [ ] Google Play Billing 연동`n- [ ] 구독 혜택 (무제한, 고급 기능)`n- [ ] 무료 체험 기간`n`n## 라벨`nenhancement, monetization, roadmap"; labels="enhancement,monetization,roadmap"},
    @{title="[Monetization] 인앱 구매"; body="## 설명`n테마 팩과 고급 위젯, 내보내기 옵션을 추가합니다.`n`n## 요구사항`n- [ ] 테마 팩`n- [ ] 고급 위젯`n- [ ] 내보내기 옵션`n- [ ] 백업 스토리지`n`n## 라벨`nenhancement, monetization, roadmap"; labels="enhancement,monetization,roadmap"},
    @{title="[Monetization] 광고 통합"; body="## 설명`n배너 광고와 보상형 광고를 추가합니다.`n`n## 요구사항`n- [ ] 배너 광고 (AdMob)`n- [ ] 보상형 광고 (추가 기능 잠금 해제)`n- [ ] 광고 제거 옵션`n- [ ] 광고 개인정보 보호`n`n## 라벨`nenhancement, monetization, roadmap"; labels="enhancement,monetization,roadmap"},
    @{title="[Monetization] 추천 프로그램"; body="## 설명`n친구 초대 보상과 추천 코드 생성을 추가합니다.`n`n## 요구사항`n- [ ] 친구 초대 보상`n- [ ] 추천 코드 생성`n- [ ] 보상 포인트 시스템`n- [ ] 리더보드`n`n## 라벨`nenhancement, monetization, roadmap"; labels="enhancement,monetization,roadmap"},
    @{title="[Monetization] 엔터프라이즈 플랜"; body="## 설명`n팀 관리 기능과 관리자 대시보드를 추가합니다.`n`n## 요구사항`n- [ ] 팀 관리 기능`n- [ ] 관리자 대시보드`n- [ ] 고급 통계/리포트`n- [ ] 우선 지원`n`n## 라벨`nenhancement, monetization, roadmap"; labels="enhancement,monetization,roadmap"},
    
    # AI (91-95)
    @{title="[AI] AI 일정 추천"; body="## 설명`n과거 패턴 분석으로 최적 시간 추천과 스마트 스케줄링을 추가합니다.`n`n## 요구사항`n- [ ] 과거 패턴 분석으로 최적 시간 추천`n- [ ] AI 기반 작업 우선순위`n- [ ] 스마트 스케줄링`n- [ ] 충돌 감지 및 해결`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[AI] AI 태그 추출 고도화"; body="## 설명`n콘텐츠 기반 자동 태그와 의미론적 유사도 분석을 추가합니다.`n`n## 요구사항`n- [ ] 콘텐츠 기반 자동 태그`n- [ ] 의미론적 유사도 분석`n- [ ] 태그 제안 (ML 모델)`n- [ ] 태그 클러스터링`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[AI] AI 생산성 코치"; body="## 설명`n개인화된 생산성 팁과 작업 습관 분석을 추가합니다.`n`n## 요구사항`n- [ ] 개인화된 생산성 팁`n- [ ] 작업 습관 분석`n- [ ] 개선 제안`n- [ ] 동기부여 메시지`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[AI] AI 음성 비서 고도화"; body="## 설명`n자연어 처리 고도화와 대화형 할 일 관리를 추가합니다.`n`n## 요구사항`n- [ ] 자연어 처리 고도화`n- [ ] 대화형 할 일 관리`n- [ ] 컨텍스트 기억`n- [ ] 다국어 지원`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    @{title="[AI] AI 요약/리포트"; body="## 설명`n일일/주간/월간 요약과 AI 생성 생산성 리포트를 추가합니다.`n`n## 요구사항`n- [ ] 일일/주간/월간 요약`n- [ ] AI 생성 생산성 리포트`n- [ ] 트렌드 분석`n- [ ] 이상 탐지 (Anomaly detection)`n`n## 라벨`nenhancement, ai, roadmap"; labels="enhancement,ai,roadmap"},
    
    # Other (96-100)
    @{title="[Other] 게임화 (Gamification)"; body="## 설명`n경험치(XP) 시스템과 레벨업/배지 획득을 추가합니다.`n`n## 요구사항`n- [ ] 경험치 (XP) 시스템`n- [ ] 레벨업 / 배지 획득`n- [ ] 리더보드 (친구/전체)`n- [ ] 연속 달성 (Streak) 보상`n`n## 참고`nTodoist Karma 시스템의 벤치마킹.`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Other] 접근성 (Accessibility) 향상"; body="## 설명`nWCAG 2.1 AA 준수와 스크린 리더 최적화를 추가합니다.`n`n## 요구사항`n- [ ] WCAG 2.1 AA 준수`n- [ ] 스크린 리더 최적화`n- [ ] 키보드 전용 네비게이션`n- [ ] 고대비/큰 글씨 모드`n`n## 라벨`nenhancement, accessibility, roadmap"; labels="enhancement,accessibility,roadmap"},
    @{title="[Other] 현지화 (Localization) 확장"; body="## 설명`n10개 언어 지원과 문화적 맞춤을 추가합니다.`n`n## 요구사항`n- [ ] 10개 언어 지원`n- [ ] 문화적 맞춤 (날짜/시간 형식)`n- [ ] 현지 휴일/캘린더`n- [ ] 통화/단위 변환`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Other] 데이터 시각화"; body="## 설명`n인터랙티브 차트와 히트맵을 추가합니다.`n`n## 요구사항`n- [ ] 인터랙티브 차트 (Recharts)`n- [ ] 히트맵 (Heatmap)`n- [ ] 산포도 (Scatter plot)`n- [ ] 타임라인 뷰`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"},
    @{title="[Other] 소셜 기능"; body="## 설명`n친구 추가/팔로우와 피드 공유를 추가합니다.`n`n## 요구사항`n- [ ] 친구 추가/팔로우`n- [ ] 피드 공유 (완료한 할 일)`n- [ ] 댓글/좋아요`n- [ ] 소셜 리더보드`n`n## 라벨`nenhancement, roadmap"; labels="enhancement,roadmap"}
)

Write-Host "Creating 100 GitHub Issues for BrioDo..." -ForegroundColor Green
Write-Host "Total issues to create: $($issues.Count)" -ForegroundColor Yellow

$created = 0
$failed = 0

foreach ($issue in $issues) {
    $created++
    Write-Host "Creating issue $created/100`: $($issue.title)" -ForegroundColor Cyan
    
    # Create the issue using gh CLI
    $title = $issue.title
    $body = $issue.body
    $labels = $issue.labels
    
    $command = "gh issue create --title `"$title`" --body `"$body`" --label `"$labels`""
    
    try {
        Invoke-Expression $command 2>&1 | Out-Null
        Write-Host "  ✓ Created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed: $_" -ForegroundColor Red
        $failed++
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "Created: $($created - $failed)" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "=================" -ForegroundColor Green
