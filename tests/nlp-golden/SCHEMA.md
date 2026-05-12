# NLP 골든셋 스키마 + 작성 가이드

**관련 이슈**: [#221](https://github.com/jeiel85/BrioDo/issues/221)
**목적**: AI 자연어 파싱 정확도 회귀 측정 — Top 10 차별점 KPI

## 디렉토리

```
tests/nlp-golden/
├── SCHEMA.md       # 이 문서
├── ko.json         # 한국어 (1차 목표: 200 케이스, 정확도 99%)
├── en.json         # 영어 (목표: 200 케이스, 95%)
├── ja.json         # 일본어 (목표: 200 케이스, 90%)
└── zh.json         # 중국어 (목표: 200 케이스, 90%)
```

## 측정 대상 KPI

| 항목 | 정의 | 한국어 목표 |
|------|------|------------|
| **date_accuracy** | `expected.date == ai.date` 비율 (null 포함) | 99% |
| **time_accuracy** | `expected.time == ai.time` 비율 (null 포함) | 99% |
| **tag_overlap** | `expected.categories ∩ ai.categories ≥ 1` 비율 | 95% |
| **overall** | 위 셋 모두 통과한 비율 | 95% |

## 케이스 스키마

```json
{
  "id": "ko-001",
  "input": "내일 오후 3시 팀 회의",
  "today": "2026-05-12",
  "expected": {
    "date": "2026-05-13",
    "time": "15:00",
    "categories": ["업무"]
  },
  "tags": ["relative-date", "afternoon-time", "team-meeting"],
  "difficulty": "easy"
}
```

### 필드 설명

| 필드 | 타입 | 필수 | 설명 |
|------|------|-----|------|
| `id` | string | ✅ | `{lang}-{3-digit}` 형식, 영구 식별자 |
| `input` | string | ✅ | 사용자가 입력하는 자연어 (PII 포함 금지) |
| `today` | YYYY-MM-DD | ✅ | 측정 시 "오늘"로 사용할 기준일. 상대 표현 계산용 |
| `expected.date` | YYYY-MM-DD \| null | ✅ | 정답 날짜. 종일 일정/날짜 없음은 today, 미지정은 null |
| `expected.time` | HH:MM \| null | ✅ | 정답 시간. 종일이거나 시간 미지정은 null |
| `expected.categories` | string[] | ✅ | 정답 태그 1~2개. 순서 무관. 빈 배열 가능 |
| `tags` | string[] | 선택 | 디버깅용 메타 태그 (relative-date, time-format-variant 등) |
| `difficulty` | enum | 선택 | `easy` / `medium` / `hard` |

### 정답 작성 원칙

1. **"오늘"은 항상 `today` 필드 기준**으로 계산. 측정 스크립트가 Gemini에게 동일 today를 주입함.
2. **시간이 명시 안 되면 `time: null`** — Gemini가 임의로 09:00 등으로 채우면 오답.
3. **모호한 표현은 "관용적 해석" 따름**:
   - "내일 점심" → `time: "12:00"` (점심 = 정오)
   - "내일 저녁" → `time: "19:00"` (저녁 = 7시)
   - "다음주" → 다음 주 월요일 (한국 기준)
4. **태그는 broad 카테고리**: 업무 / 개인 / 건강 / 학습 / 운동 / 가족 / 쇼핑 / 약속 등
5. **PII 절대 포함 금지**: 실명, 전화번호, 이메일, 주소

## 난이도 가이드

- **easy** (60%): 표준 자연어, 단일 시간/날짜 표현
- **medium** (30%): 변형 시간 형식, 복합 표현, 상대 표현 중첩
- **hard** (10%): 모호한 표현, 컨텍스트 의존, edge case

## 커버해야 할 케이스 카테고리

1. **절대 날짜**: "5월 15일", "12/25", "2026년 6월 1일"
2. **상대 날짜**: 오늘, 내일, 모레, 어제, 다음주 X요일, 이번주 X요일, 다다음주
3. **시간 형식**: 오후 3시, 15시, 15:00, 3시 30분, 오전 9시 반
4. **상대 시간**: 1시간 후, 30분 뒤, 2시간 전
5. **종일 일정**: "내일 회의" (시간 없음 → time: null)
6. **시간 범위**: "오후 2시부터 4시까지" → 시작 시각만 추출
7. **요일**: 월/화/수/.../일, 평일, 주말
8. **이벤트 유형별**: 회의/약속/운동/병원/공부/식사/여행/마감
9. **edge case**:
   - "방금 끝남" → 시간 있음, 과거
   - "조만간" → 모호, null
   - "다음달 1일 새벽 2시" → 자정 넘는 시간

## 새 케이스 추가 방법

1. 적절한 언어 JSON에 객체 추가
2. `id`는 마지막 번호 + 1 (절대 재사용 금지)
3. `npm run test:nlp -- --lang=ko --id=ko-031`로 단건 검증
4. PR/커밋 메시지에 추가한 케이스 ID 명시

## 측정 실행

```bash
# 전체
npm run test:nlp

# 언어별
npm run test:nlp -- --lang=ko

# 단건
npm run test:nlp -- --id=ko-005

# Dry run (API 호출 없이 스키마 검증만)
npm run test:nlp -- --dry-run
```

## 결과 출력

`tests/nlp-golden/reports/YYYY-MM-DD_HH-mm.json` 형식으로 저장.

```json
{
  "timestamp": "2026-05-12T14:30:00Z",
  "model": "gemini-2.5-flash-lite",
  "summary": {
    "ko": { "total": 30, "passed": 28, "date_accuracy": 0.97, "time_accuracy": 0.93, "tag_overlap": 1.0, "overall": 0.93 }
  },
  "failures": [
    { "id": "ko-017", "input": "...", "expected": {...}, "actual": {...}, "reason": "time mismatch" }
  ]
}
```

## 운영 정책

- **버전 단위 회귀 측정**: v1.X 릴리즈 직전 전체 골든셋 실행, 정확도 저하 시 릴리즈 보류
- **분기별 골든셋 확장**: 사용자 실제 입력 로그(개인정보 마스킹 후)에서 패턴 추출 → 새 케이스 추가
- **마케팅 자산화**: 분기별 정확도 리포트 → Disquiet/블로그 콘텐츠
