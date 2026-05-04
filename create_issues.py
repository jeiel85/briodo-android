import subprocess
import time

issues = [
    # UI/UX & Visual Polish
    {"title": "[UI/UX] 햅틱 피드백 강화", "body": "할 일 완료, 버튼 클릭, 업적 달성 시 세밀한 진동 피드백 추가", "labels": "ui/ux,enhancement"},
    {"title": "[UI/UX] Lottie 애니메이션 도입", "body": "성공 상태, 빈 목록 등에 정적인 아이콘 대신 Lottie 애니메이션 적용", "labels": "ui/ux,enhancement"},
    {"title": "[UI/UX] 스켈레톤 스크린 적용", "body": "데이터 로딩 시 화면 깜빡임을 줄이기 위한 스켈레톤 UI 구현", "labels": "ui/ux,performance"},
    {"title": "[UI/UX] 다크 모드 자동 전환 고도화", "body": "시스템 설정 외에 일출/일몰 시간에 맞춘 자동 전환 기능", "labels": "ui/ux"},
    {"title": "[UI/UX] 안드로이드 홈 화면 위젯 고도화", "body": "앱을 열지 않고 위젯에서 바로 할 일을 체크할 수 있는 상호작용 추가", "labels": "ui/ux,android"},
    {"title": "[UI/UX] 커스텀 폰트 지원", "body": "사용자가 선호하는 현대적인 폰트 선택 기능 제공", "labels": "ui/ux"},
    {"title": "[UI/UX] 안드로이드 13+ 테마 아이콘 지원", "body": "시스템 테마에 맞춘 모노크롬 앱 아이콘 지원", "labels": "ui/ux,android"},
    {"title": "[UI/UX] 부드러운 화면 전환 애니메이션", "body": "Framer Motion 등을 활용한 탭 간 이동 및 모달 전환 고도화", "labels": "ui/ux"},
    {"title": "[UI/UX] 업적 달성 컨페티 효과 다양화", "body": "업적 난이도에 따른 다양한 파티클 효과 및 성능 최적화", "labels": "ui/ux"},
    {"title": "[UI/UX] 리스트 드래그 앤 드롭 정렬", "body": "할 일 순서 변경 및 날짜 간 이동을 위한 드래그 앤 드롭 UI", "labels": "ui/ux"},
    {"title": "[UI/UX] 스타일리시한 Pull-to-Refresh", "body": "Brio 브랜드 아이덴티티가 담긴 고유의 새로고침 애니메이션", "labels": "ui/ux"},
    {"title": "[UI/UX] 체크박스 마이크로 인터랙션", "body": "체크 시 터지는 듯한 시각 효과 추가", "labels": "ui/ux"},
    {"title": "[UI/UX] 단계적 기능 노출 (Progressive Disclosure)", "body": "초보자에게는 단순하게, 숙련자에게는 고급 기능을 노출하는 UI 설계", "labels": "ui/ux"},
    {"title": "[UI/UX] 인터랙티브 온보딩 가이드", "body": "정적 카드 대신 실제 앱 기능을 따라해보는 튜토리얼 구현", "labels": "ui/ux"},
    {"title": "[UI/UX] 집중 모드 테마 비주얼 강화", "body": "집중 모드 시 마음을 차분하게 하는 그라데이션 또는 배경 영상 적용", "labels": "ui/ux"},

    # AI & Smart Features
    {"title": "[AI] 다중 할 일 음성 인식", "body": "'우유 사고 엄마한테 전화해'와 같이 한 문장에서 여러 할 일을 분리 추출", "labels": "ai,enhancement"},
    {"title": "[AI] 생산성 패턴 분석 인사이트", "body": "사용자의 완료 패턴을 분석하여 최적의 집중 시간 추천", "labels": "ai"},
    {"title": "[AI] 지오펜싱 기반 스마트 알림", "body": "장소에 도착했을 때 관련 할 일을 알려주는 위치 기반 알림", "labels": "ai,android"},
    {"title": "[AI] 할 일 우선순위 자동 제안", "body": "내용과 기한을 바탕으로 중요도(Low/High) 자동 추천", "labels": "ai"},
    {"title": "[AI] 문맥 인식 브리핑 고도화", "body": "날씨와 캘린더 일정을 더 자연스럽게 통합한 AI 브리핑", "labels": "ai"},
    {"title": "[AI] 사용자 맞춤형 자동 태그 정교화", "body": "사용자의 기존 태그 습관을 학습하여 더 정확한 태그 추천", "labels": "ai"},
    {"title": "[AI] AI 목표 세분화 (Sub-task Generator)", "body": "큰 목표를 입력하면 실행 가능한 세부 단계로 쪼개주는 기능", "labels": "ai"},
    {"title": "[AI] 자연어 기반 검색 지원", "body": "'지난주 화요일에 끝낸 일 보여줘'와 같은 자연어 쿼리 처리", "labels": "ai"},
    {"title": "[AI] OCR 영수증/메모 인식", "body": "사진을 찍어 손글씨 메모나 영수증을 할 일로 자동 변환", "labels": "ai"},
    {"title": "[AI] AI 생산성 코치 챗봇", "body": "오늘 무엇에 집중해야 할지 물어볼 수 있는 전용 채팅 탭", "labels": "ai"},

    # Gamification & Retention
    {"title": "[Gamification] 글로벌 생산성 리더보드", "body": "익명으로 진행되는 전 세계 사용자 간의 생산성 점수 경쟁", "labels": "gamification"},
    {"title": "[Gamification] 생산성 길드/그룹 기능", "body": "친구들과 그룹을 만들어 함께 할 일을 달성하고 응원", "labels": "gamification"},
    {"title": "[Gamification] 개인화된 마일스톤 축하", "body": "100번째 할 일 완료, 가입 1주년 등 특별한 순간 기념", "labels": "gamification"},
    {"title": "[Gamification] 성장형 아바타 시스템", "body": "생산성 점수에 따라 레벨업하고 꾸밀 수 있는 캐릭터 도입", "labels": "gamification"},
    {"title": "[Gamification] 데일리 퀘스트 도입", "body": "'오전 10시 전 할 일 3개 끝내기' 등 보너스 브리오 획득 퀘스트", "labels": "gamification"},
    {"title": "[Gamification] 알림 페르소나 설정", "body": "격려하는 말투, 엄격한 말투 등 알림의 톤앤매너 선택", "labels": "gamification"},
    {"title": "[Gamification] 시즌별 이벤트 및 업적", "body": "공휴일이나 특정 시즌에만 획득 가능한 한정판 테마/업적", "labels": "gamification"},
    {"title": "[Gamification] 스트릭 보험 (Streak Insurance)", "body": "브리오를 사용하여 실수로 놓친 스트릭을 유지하는 기능", "labels": "gamification"},

    # Security & Stability
    {"title": "[Security] 생체 인식 잠금", "body": "지문이나 얼굴 인식을 통한 앱 잠금 기능 옵션", "labels": "security"},
    {"title": "[Security] 데이터 내보내기/백업 강화", "body": "JSON, CSV 형식으로 데이터 백업 및 외부 보관 지원", "labels": "security"},
    {"title": "[Security] PII 마스킹 고도화", "body": "더 다양한 국가 및 형식의 개인정보 자동 감지 및 마스킹", "labels": "security"},
    {"title": "[Security] 보안 감사 로그 제공", "body": "데이터 동기화 및 접근 이력을 사용자가 직접 확인", "labels": "security"},
    {"title": "[Stability] 오프라인 신뢰성 극대화", "body": "극도의 저대역폭 환경에서도 동기화 충돌을 최소화하는 로직", "labels": "stability"},

    # Monetization & Pro
    {"title": "[Monetization] Pro 구독 모델 도입", "body": "무제한 AI, 커스텀 테마, 광고 제거를 포함한 구독 서비스", "labels": "monetization"},
    {"title": "[Monetization] 일회성 테마/아이템 구매", "body": "특별한 테마 팩이나 할 일 스티커 등 소액 결제 아이템", "labels": "monetization"},
    {"title": "[Monetization] 브리오 직접 구매 상점", "body": "광고 시청 대신 유료 결제로 브리오를 즉시 충전", "labels": "monetization"},
    {"title": "[Monetization] 친구 초대 보상 프로그램", "body": "친구 초대 시 초대자와 피초대자 모두에게 Pro 혜택 제공", "labels": "monetization"},
    {"title": "[Monetization] 패밀리 플랜 지원", "body": "가족 그룹과 Pro 기능을 공유할 수 있는 요금제", "labels": "monetization"},

    # ASO & Marketing
    {"title": "[ASO] 스토어 등록 정보 현지화 완성", "body": "주요 20개국 언어로 앱 설명 및 스크린샷 텍스트 번역", "labels": "marketing"},
    {"title": "[ASO] 고퀄리티 앱 프리뷰 영상", "body": "BrioDo의 매력을 담은 30초 내외의 홍보 영상 제작", "labels": "marketing"},
    {"title": "[ASO] 사용자 리뷰 유도 시스템 최적화", "body": "업적 달성 등 긍정적인 경험 직후 리뷰 요청 로직 구현", "labels": "marketing"},
    {"title": "[ASO] 소셜 미디어 리포트 공유 기능", "body": "주간/월간 생산성 리포트를 인스타그램 등에 최적화된 포맷으로 공유", "labels": "marketing"},
    {"title": "[Marketing] 생산성 블로그/콘텐츠 연동", "body": "앱 내에서 생산성 팁을 읽고 바로 실천해볼 수 있는 콘텐츠 제공", "labels": "marketing"},
    {"title": "[ASO] 웹 페이지 SEO 최적화", "body": "GitHub Pages 사이트를 생산성 관련 키워드로 검색 엔진 최적화", "labels": "marketing"},
    {"title": "[Marketing] 인플루언서 협업 키트 준비", "body": "생산성 유튜버/블로거 리뷰를 위한 프레스 키트 및 체험 계정 준비", "labels": "marketing"}
]

for issue in issues:
    cmd = [
        "gh", "issue", "create",
        "--title", issue["title"],
        "--body", issue["body"],
        "--label", issue["labels"]
    ]
    print(f"Creating issue: {issue['title']}...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        print(f"Successfully created: {result.stdout.strip()}")
    else:
        print(f"Failed: {result.stderr.strip()}")
    
    # Rate limiting 방지를 위해 약간의 대기
    time.sleep(1)
