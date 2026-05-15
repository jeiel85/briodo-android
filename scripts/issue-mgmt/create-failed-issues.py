#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Create the 34 failed GitHub Issues that had missing labels.
Now that labels 'ai', 'performance', 'security', 'accessibility' exist.
"""

import sys
import subprocess
import time
import os

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

# These are the EXACT same issues that failed, in order
failed_issues = [
    # Issue 5 (index 4 in original list)
    {
        "title": "[UI/UX] 폰트/접근성 개선",
        "body": "## 설명\n시스템 폰트 크기 연동과 접근성을 향상시킵니다.\n\n## 요구사항\n- [ ] 시스템 폰트 크기 연동\n- [ ] 접근성 향상 (TalkBack 완벽 지원)\n- [ ] 키보드 네비게이션 최적화\n- [ ] 고대비 모드 준수\n\n## 라벨\nenhancement, ux,accessibility",
        "labels": "enhancement,ux,accessibility"
    },
    # Issue 17 (index 16)
    {
        "title": "[UI/UX] 개인화 홈",
        "body": "## 설명\n오늘의 할 일 포커스와 AI 기반 추천을 추가합니다.\n\n## 요구사항\n- [ ] 오늘의 할 일 포커스 뷰\n- [ ] 추천 작업 (AI 기반)\n- [ ] 날씨 정보 연동\n- [ ] 인사말 (Good morning 등)\n\n## 라벨\nenhancement, ux,ai",
        "labels": "enhancement,ux,ai"
    },
    # Issue 19 (index 18)
    {
        "title": "[UI/UX] 음성 입력 UI",
        "body": "## 설명\n음성 입력 버튼 애니메이션과 실시간 표시를 개선합니다.\n\n## 요구사항\n- [ ] 음성 입력 버튼 애니메이션\n- [ ] 음성 인식 결과 실시간 표시\n- [ ] 명령어 힌트 표시\n- [ ] 음성 프로필 설정\n\n## 라벨\nenhancement, ux,ai",
        "labels": "enhancement,ux,ai"
    },
    # Issue 25 (index 24)
    {
        "title": "[Feature] 자연어 처리 (NLP) 개선",
        "body": "## 설명\n\"내일 오전 10시 회의\" 등의 자연어를 자동 파싱합니다.\n\n## 요구사항\n- [ ] \"내일 오전 10시 회의\" → 자동 파싱\n- [ ] \"매주 월요일마다\" → 반복 설정\n- [ ] 우선순위 자동 감지 (\"긴급한\" 등)\n- [ ] 태그 자동 추출\n\n## 참고\nTodoist, TickTick의 핵심 기능입니다.\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    # Issue 32 (index 31)
    {
        "title": "[Feature] 태그 시스템 고도화",
        "body": "## 설명\n중첩 태그와 AI 기반 자동 생성을 추가합니다.\n\n## 요구사항\n- [ ] 중첩 태그 (parent/child)\n- [ ] 태그 자동 생성 (AI)\n- [ ] 태그 필터링 고급 검색\n- [ ] 태그별 통계 대시보드\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    # Issues 51-65: Performance (14 issues)
    {
        "title": "[Performance] 가상화/지연 로딩",
        "body": "## 설명\n긴 리스트 가상화와 이미지 지연 로딩을 추가합니다.\n\n## 요구사항\n- [ ] 긴 리스트 가상화 (VirtualizedList)\n- [ ] 이미지 지연 로딩 (Lazy loading)\n- [ ] 무한 스크롤 (Infinite scroll)\n- [ ] 페이지네이션\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 캐싱 전략",
        "body": "## 설명\n메모리 캐시와 디스크 캐시를 구현합니다.\n\n## 요구사항\n- [ ] 메모리 캐시 (LRU)\n- [ ] 디스크 캐시 (IndexedDB)\n- [ ] API 응답 캐싱\n- [ ] 이미지 캐싱\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] Firebase 최적화",
        "body": "## 설명\nFirestore 쿼리 최적화와 배치 쓰기를 개선합니다.\n\n## 요구사항\n- [ ] Firestore 쿼리 최적화 (인덱스)\n- [ ] 배치 쓰기 (Batch writes)\n- [ ] 트랜잭션 최적화\n- [ ] 읽기/쓰기 비용 절감\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] IndexedDB 최적화",
        "body": "## 설명\n인덱스 생성과 대량 데이터 청크 단위 처리를 개선합니다.\n\n## 요구사항\n- [ ] 인덱스 생성\n- [ ] 대량 데이터 청크 단위 처리\n- [ ] 커서 기반 쿼리\n- [ ] 저장소 한도 관리\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 번들 크기 최적화",
        "body": "## 설명\n코드 스플리팅과 트리 쉐이킹을 적용합니다.\n\n## 요구사항\n- [ ] 코드 스플리팅 (Code splitting)\n- [ ] 트리 쉐이킹 (Tree shaking)\n- [ ] 사용하지 않는 코드 제거\n- [ ] 라이브러리 최적화 (lodash → 개별 함수)\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 이미지 최적화",
        "body": "## 설명\n이미지 압축과 썸네일 생성을 추가합니다.\n\n## 요구사항\n- [ ] 이미지 압축 (WebP)\n- [ ] 썸네일 생성\n- [ ] 이미지 리사이징\n- [ ] CDN 연동\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 렌더링 최적화",
        "body": "## 설명\nReact.memo 적용과 불필요한 리렌더링 방지를 추가합니다.\n\n## 요구사항\n- [ ] React.memo 적용\n- [ ] useMemo/useCallback 활용\n- [ ] 불필요한 리렌더링 방지\n- [ ] 가상 DOM 최적화\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 네트워크 최적화",
        "body": "## 설명\n요청 병합과 중복 요청 방지를 추가합니다.\n\n## 요구사항\n- [ ] 요청 병합 (Request batching)\n- [ ] 중복 요청 방지 (Deduplication)\n- [ ] 오프라인 큐 관리\n- [ ] 재시도 로직 (Exponential backoff)\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 시작 시간 단축",
        "body": "## 설명\n초기 번들 크기 감소와 서비스 워커 프리캐시를 추가합니다.\n\n## 요구사항\n- [ ] 초기 번들 크기 감소\n- [ ] 지연 로딩 (Lazy loading)\n- [ ] 서비스 워커 프리캐시\n- [ ] 스플래시 스크린 최적화\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 메모리 관리",
        "body": "## 설명\n메모리 누수 탐지와 큰 객체 해제를 추가합니다.\n\n## 요구사항\n- [ ] 메모리 누수 탐지\n- [ ] 큰 객체 해제\n- [ ] 이벤트 리스너 정리\n- [ ] 가비지 컬렉션 힌트\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 배터리 최적화",
        "body": "## 설명\n백그라운드 작업 최적화와 Doze 모드 대응을 추가합니다.\n\n## 요구사항\n- [ ] 백그라운드 작업 최적화\n- [ ] 위치 업데이트 빈도 조절\n- [ ] 동기화 주기 조정\n- [ ] Doze 모드 대응\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    {
        "title": "[Performance] 데이터베이스 마이그레이션",
        "body": "## 설명\n버전 관리 마이그레이션과 롤백 스크립트를 추가합니다.\n\n## 요구사항\n- [ ] 버전 관리 마이그레이션\n- [ ] 롤백 스크립트\n- [ ] 데이터 무결성 검증\n- [ ] 마이그레이션 로깅\n\n## 라벨\nenhancement, performance, stability, roadmap",
        "labels": "enhancement,performance,stability,roadmap"
    },
    {
        "title": "[Performance] 로깅/모니터링",
        "body": "## 설명\n성능 로깅과 사용자 행동 추적을 추가합니다.\n\n## 요구사항\n- [ ] 성능 로깅 (Performance API)\n- [ ] 사용자 행동 추적 (Analytics)\n- [ ] 네트워크 요청 로깅\n- [ ] 디버그 모드\n\n## 라벨\nenhancement, performance, roadmap",
        "labels": "enhancement,performance,roadmap"
    },
    # Issues 66-75: Security (10 issues)
    {
        "title": "[Security] 인증 보안 강화",
        "body": "## 설명\n생체 인식 인증과 PIN/패턴 잠금을 추가합니다.\n\n## 요구사항\n- [ ] 생체 인식 인증 (Fingerprint/FaceID)\n- [ ] PIN/패턴 잠금\n- [ ] 자동 로그아웃 (세션 타임아웃)\n- [ ] 다중 인증 (2FA)\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 데이터 암호화",
        "body": "## 설명\n로컬 데이터 암호화와 전송 계층 보안을 강화합니다.\n\n## 요구사항\n- [ ] 로컬 데이터 암호화 (AES-256)\n- [ ] 전송 계층 보안 (TLS 1.3)\n- [ ] 키 관리 (Android Keystore)\n- [ ] 암호화된 백업\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 권한 관리",
        "body": "## 설명\n최소 권한 원칙과 런타임 권한 요청을 개선합니다.\n\n## 요구사항\n- [ ] 최소 권한 원칙\n- [ ] 런타임 권한 요청\n- [ ] 권한 사용 투명성\n- [ ] 권한 거부 대응\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 개인정보 보호",
        "body": "## 설명\nGDPR 준수와 데이터 삭제 요청 처리를 추가합니다.\n\n## 요구사항\n- [ ] GDPR 준수\n- [ ] 데이터 삭제 요청 처리\n- [ ] 개인정보 취급 방침\n- [ ] 데이터 내보내기 (GDPR)\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] Firebase 보안",
        "body": "## 설명\nFirestore 보안 규칙 강화와 Firebase App Check을 추가합니다.\n\n## 요구사항\n- [ ] Firestore 보안 규칙 강화\n- [ ] Firebase App Check\n- [ ] API 키 제한\n- [ ] 앱 무단 복제 방지\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 네트워크 보안",
        "body": "## 설명\n인증서 고정과 SSL 핀닝을 추가합니다.\n\n## 요구사항\n- [ ] 인증서 고정 (Certificate pinning)\n- [ ] SSL 핀닝\n- [ ] MITM 방지\n- [ ] VPN 탐지\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 데이터 백업 보안",
        "body": "## 설명\n백업 암호화와 안전한 전송을 추가합니다.\n\n## 요구사항\n- [ ] 백업 암호화\n- [ ] 안전한 전송 (HTTPS)\n- [ ] 백업 무결성 검증\n- [ ] 기기 간 보안 전송\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 세션 관리",
        "body": "## 설명\n보안 쿠키와 CSRF 방지를 추가합니다.\n\n## 요구사항\n- [ ] 보안 쿠키 (HttpOnly, Secure)\n- [ ] CSRF 방지\n- [ ] 세션 하이재킹 방지\n- [ ] 동시 로그인 제한\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 콘텐츠 보안 정책",
        "body": "## 설명\nCSP 헤더 설정과 XSS 방지를 추가합니다.\n\n## 요구사항\n- [ ] CSP 헤더 설정\n- [ ] XSS 방지\n- [ ] 인젝션 공격 방어\n- [ ] 입력값 검증/삭제\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    {
        "title": "[Security] 보안 감사",
        "body": "## 설명\n정기적인 보안 검사와 취약점 스캔을 추가합니다.\n\n## 요구사항\n- [ ] 정기적인 보안 검사\n- [ ] 의존성 취약점 스캔 (npm audit)\n- [ ] 침투 테스트\n- [ ] 보안 로깅\n\n## 라벨\nenhancement, security, roadmap",
        "labels": "enhancement,security,roadmap"
    },
    # Issues 91-95: AI (5 issues)
    {
        "title": "[AI] AI 일정 추천",
        "body": "## 설명\n과거 패턴 분석으로 최적 시간 추천과 스마트 스케줄링을 추가합니다.\n\n## 요구사항\n- [ ] 과거 패턴 분석으로 최적 시간 추천\n- [ ] AI 기반 작업 우선순위\n- [ ] 스마트 스케줄링\n- [ ] 충돌 감지 및 해결\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    {
        "title": "[AI] AI 태그 추출 고도화",
        "body": "## 설명\n콘텐츠 기반 자동 태그와 의미론적 유사도 분석을 추가합니다.\n\n## 요구사항\n- [ ] 콘텐츠 기반 자동 태그\n- [ ] 의미론적 유사도 분석\n- [ ] 태그 제안 (ML 모델)\n- [ ] 태그 클러스터링\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    {
        "title": "[AI] AI 생산성 코치",
        "body": "## 설명\n개인화된 생산성 팁과 작업 습관 분석을 추가합니다.\n\n## 요구사항\n- [ ] 개인화된 생산성 팁\n- [ ] 작업 습관 분석\n- [ ] 개선 제안\n- [ ] 동기부여 메시지\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    {
        "title": "[AI] AI 음성 비서 고도화",
        "body": "## 설명\n자연어 처리 고도화와 대화형 할 일 관리를 추가합니다.\n\n## 요구사항\n- [ ] 자연어 처리 고도화\n- [ ] 대화형 할 일 관리\n- [ ] 컨텍스트 기억\n- [ ] 다국어 지원\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    {
        "title": "[AI] AI 요약/리포트",
        "body": "## 설명\n일일/주간/월간 요약과 AI 생성 생산성 리포트를 추가합니다.\n\n## 요구사항\n- [ ] 일일/주간/월간 요약\n- [ ] AI 생성 생산성 리포트\n- [ ] 트렌드 분석\n- [ ] 이상 탐지 (Anomaly detection)\n\n## 라벨\nenhancement, ai, roadmap",
        "labels": "enhancement,ai,roadmap"
    },
    # Issue 97 (index 96)
    {
        "title": "[Other] 접근성 (Accessibility) 향상",
        "body": "## 설명\nWCAG 2.1 AA 준수와 스크린 리더 최적화를 추가합니다.\n\n## 요구사항\n- [ ] WCAG 2.1 AA 준수\n- [ ] 스크린 리더 최적화\n- [ ] 키보드 전용 네비게이션\n- [ ] 고대비/큰 글씨 모드\n\n## 라벨\nenhancement, accessibility, roadmap",
        "labels": "enhancement,accessibility,roadmap"
    }
]

def create_issue(issue, index):
    title = issue["title"]
    body = issue["body"]
    labels = issue["labels"]
    
    print(f"Creating failed issue {index}/35: {title}")
    
    temp_file = f"temp_body_{index}.txt"
    with open(temp_file, "w", encoding="utf-8") as f:
        f.write(body)
    
    cmd = [
        "gh", "issue", "create",
        "--title", title,
        "--body-file", temp_file,
        "--label", labels
    ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=30
        )
        if result.returncode == 0:
            print(f"  Success: {result.stdout.strip()}")
            return True
        else:
            print(f"  Failed: {result.stderr.strip()}")
            return False
    except Exception as e:
        print(f"  Error: {e}")
        return False
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)
        time.sleep(0.5)

def main():
    print("Creating 34 failed GitHub Issues (retries)...")
    print(f"Total issues to create: {len(failed_issues)}\n")
    
    created = 0
    failed = 0
    
    for i, issue in enumerate(failed_issues, 1):
        success = create_issue(issue, i)
        if success:
            created += 1
        else:
            failed += 1
    
    print(f"\n=== Summary ===")
    print(f"Created: {created}")
    print(f"Failed: {failed}")
    print("=================")

if __name__ == "__main__":
    import sys
    main()
