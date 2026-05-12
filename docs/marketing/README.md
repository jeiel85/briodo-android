# BrioDo 마케팅 자산 디렉토리

**관련 이슈**: [#256](https://github.com/jeiel85/BrioDo/issues/256)

본 디렉토리는 Play Store 등록 정보, 인플루언서 시드(#255), 메이커 커뮤니티 콘텐츠(#136), 리뷰 응답(#252)에서 공통으로 사용하는 마케팅 자산을 모읍니다.

## 디렉토리 구조

```
docs/marketing/
├── README.md                       # 이 문서
├── COPY_GUIDE.md                   # 카피 라이팅 가이드 (1줄 가치 제안, 30초 피치, FAQ)
├── screenshots/                    # Play Store 스크린샷 4종 + 4개 언어
│   ├── ko/                         # 한국어 (1차 시장)
│   ├── en/
│   ├── ja/
│   └── zh/
├── featured-graphic/               # Play Store featured graphic (1024x500)
├── video/                          # 30초 데모 영상 + 15초 쇼츠
│   ├── 30s-demo.mp4
│   ├── 15s-shorts.mp4
│   └── scenario.md                 # 시나리오 / 컷리스트
├── cards/                          # 정사각 카드 (1080x1080)
│   ├── feature-lockscreen.png
│   ├── feature-ai-nlp.png
│   ├── feature-briefing.png
│   ├── feature-widget.png
│   └── feature-subscription.png
├── gifs/                           # 블로그/Disquiet 첨부용 GIF
│   ├── lockscreen-edit.gif
│   ├── ai-parse.gif
│   └── share-card.gif
└── review-templates/               # Play Store 리뷰 응답 템플릿
    ├── bug.md
    ├── feature-request.md
    ├── misunderstanding.md
    └── positive.md
```

## 스크린샷 가이드 (Play Store)

| 순서 | 주제 | 핵심 메시지 | 디바이스 | 비고 |
|------|------|-----------|---------|------|
| #1 | **잠금화면 위젯** | "잠금 해제 없이 할 일 추가" | Galaxy S24 | **차별점 1순위** — 첫 인상 |
| #2 | **AI 자연어** | "내일 오후 3시 팀 회의" → 자동 파싱 | Galaxy S24 | 결과 강조 |
| #3 | **AI 브리핑** | "오늘 가장 중요한 일정 한눈에" | Galaxy S24 | 페르소나형 카피 |
| #4 | **홈 화면** | "할 일 + Pro 구독" | Galaxy S24 | 전체 UX 노출 |

**규격**:
- 권장 1080 × 1920 (Portrait)
- 최대 8장 슬롯 사용 가능. 4장 미만이어도 무방
- 파일명: `01_lockscreen.png`, `02_ai_nlp.png` … (정렬 보장)

**제작 도구**:
- 실제 디바이스 캡처 → Figma에서 카피 오버레이 → PNG export
- 베젤/상단바 깨끗하게 정리 (배터리/시간 표시 일관)

## 30초 영상 시나리오

[`video/scenario.md`](video/scenario.md)에 상세 컷리스트.

대략적 흐름:
- 0~5s: 잠금화면에서 위젯으로 할 일 추가
- 5~15s: 잠금 해제 → 스마트 입력 → AI 자연어 파싱
- 15~25s: 캘린더 동기화 + 알림 등장
- 25~30s: 로고 + 1줄 가치 제안

## 자산 갱신 정책

1. **버전 단위 갱신**: 메이저 업데이트 (v1.2, v1.3) 시 스크린샷 검토
2. **번역**: 한국어 마스터본 → 영/일/중 순으로 번역. 카피는 직역 X, 시장별 톤 조정
3. **저작권**: 모든 폰트/음악/이미지는 상업 사용 가능 라이선스만 사용
4. **GitHub LFS 고려**: 영상 파일이 10MB를 넘으면 LFS 등록 또는 외부 저장소 (Google Drive 링크) 활용

## 사용처별 자산 매핑

| 사용처 | 필요 자산 |
|--------|----------|
| Play Store 등록 | screenshots/, featured-graphic/, video/30s-demo.mp4 |
| #255 인플루언서 시드 | video/30s-demo.mp4, cards/, COPY_GUIDE.md (30초 피치) |
| #136 Disquiet/PH | gifs/, cards/, COPY_GUIDE.md (1줄 가치 제안) |
| #135 바이럴 공유 카드 | cards/feature-* (사용자 공유시 base layout) |
| #252 리뷰 응답 | review-templates/, COPY_GUIDE.md (FAQ) |
