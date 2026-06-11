import 'package:flutter_test/flutter_test.dart';
import 'package:briodo/services/todo_parser.dart';

void main() {
  group('TodoParser Tests - 기준일: 2026-05-26 (화요일)', () {
    // 2026년 5월 26일 (화요일) 기준
    final baseDate = DateTime(2026, 5, 26);

    test('1. 오늘/내일/모레/글피 등 상대 날짜 파싱', () {
      // 오늘
      final rToday = TodoParser.parse('오늘 헬스장 가기', baseDate: baseDate);
      expect(rToday.date, DateTime(2026, 5, 26));
      expect(rToday.cleanedText, '헬스장 가기');

      // 내일
      final rTomorrow = TodoParser.parse('내일 마트 가기', baseDate: baseDate);
      expect(rTomorrow.date, DateTime(2026, 5, 27));
      expect(rTomorrow.cleanedText, '마트 가기');

      // 모레
      final rDayAfter = TodoParser.parse('내일 모레 약속 잡기', baseDate: baseDate);
      expect(rDayAfter.date, DateTime(2026, 5, 28));
      expect(rDayAfter.cleanedText, '약속 잡기');

      // 글피
      final rGlpi = TodoParser.parse('글피 영화 보기', baseDate: baseDate);
      expect(rGlpi.date, DateTime(2026, 5, 29));
      expect(rGlpi.cleanedText, '영화 보기');
    });

    test('2. 요일 파싱 (이번주, 다음주, 다다음주)', () {
      // 이번주 목요일 (2026-05-26 화요일 기준 ➡️ 목요일은 2026-05-28)
      final rThisThur = TodoParser.parse('이번주 목요일 세미나 참석', baseDate: baseDate);
      expect(rThisThur.date, DateTime(2026, 5, 28));
      expect(rThisThur.cleanedText, '세미나 참석');

      // 접두사 없는 요일 (목요일 ➡️ 화요일보다 이후이므로 이번주 목요일인 2026-05-28)
      final rThur = TodoParser.parse('목요일 세미나 참석', baseDate: baseDate);
      expect(rThur.date, DateTime(2026, 5, 28));

      // 접두사 없는 요일 (월요일 ➡️ 화요일보다 이전이므로 다음주 월요일인 2026-06-01)
      final rMon = TodoParser.parse('월요일 회의 준비', baseDate: baseDate);
      expect(rMon.date, DateTime(2026, 6, 1));
      expect(rMon.cleanedText, '회의 준비');

      // 다음주 금요일 (2026-05-26 기준 다음주 금요일 ➡️ 2026-06-05)
      final rNextFri = TodoParser.parse('다음주 금요일 치과 가기', baseDate: baseDate);
      expect(rNextFri.date, DateTime(2026, 6, 5));
      expect(rNextFri.cleanedText, '치과 가기');

      // 다다음주 월요일 (2026-05-26 기준 다다음주 월요일 ➡️ 2026-06-08)
      final rDadaMon = TodoParser.parse('다다음주 월요일 출장', baseDate: baseDate);
      expect(rDadaMon.date, DateTime(2026, 6, 8));
      expect(rDadaMon.cleanedText, '출장');
    });

    test('3. 특정 날짜 파싱 (MM월 DD일, MM/DD)', () {
      // 5월 30일
      final rMay30 = TodoParser.parse('5월 30일 친구 생일', baseDate: baseDate);
      expect(rMay30.date, DateTime(2026, 5, 30));
      expect(rMay30.cleanedText, '친구 생일');

      // 06.15 (도트 형식)
      final rJune15 = TodoParser.parse('06.15 보고서 마감', baseDate: baseDate);
      expect(rJune15.date, DateTime(2026, 6, 15));
      expect(rJune15.cleanedText, '보고서 마감');

      // 10/24 (슬래시 형식)
      final rOct24 = TodoParser.parse('10/24 해외 배송 도착', baseDate: baseDate);
      expect(rOct24.date, DateTime(2026, 10, 24));
      expect(rOct24.cleanedText, '해외 배송 도착');
    });

    test('4. 시간 파싱 (오전/오후/저녁/밤 및 시/분/반)', () {
      // 오후 2시 30분
      final r1 = TodoParser.parse('내일 오후 2시 30분 회의', baseDate: baseDate);
      expect(r1.date, DateTime(2026, 5, 27));
      expect(r1.time, '14:30');
      expect(r1.cleanedText, '회의');

      // 저녁 7시반
      final r2 = TodoParser.parse('저녁 7시반 헬스장', baseDate: baseDate);
      expect(r2.time, '19:30');
      expect(r2.cleanedText, '헬스장');

      // 아침 9시
      final r3 = TodoParser.parse('아침 9시 출근', baseDate: baseDate);
      expect(r3.time, '09:00');
      expect(r3.cleanedText, '출근');

      // 디지털 타임 (13:15)
      final r4 = TodoParser.parse('오늘 13:15 우체국 방문', baseDate: baseDate);
      expect(r4.date, DateTime(2026, 5, 26));
      expect(r4.time, '13:15');
      expect(r4.cleanedText, '우체국 방문');

      // 모디파이어 단독 (저녁에 마트가기 ➡️ 기본값 19:00 할당)
      final r5 = TodoParser.parse('저녁에 마트 가기', baseDate: baseDate);
      expect(r5.time, '19:00');
      // 조사 정제 처리 ➡️ '저녁에 마트 가기' 에서 '저녁'과 '에'가 잘 지워져서 '마트 가기'가 남음
      expect(r5.cleanedText, '마트 가기');
    });

    test('5. 우선순위 파싱 (!긴급, !!, !!! 등)', () {
      // !긴급
      final r1 = TodoParser.parse('내일 회의 준비 !긴급', baseDate: baseDate);
      expect(r1.priority, 'urgent');
      expect(r1.cleanedText, '회의 준비');

      // !! (high)
      final r2 = TodoParser.parse('!! 마트 우유 사기', baseDate: baseDate);
      expect(r2.priority, 'high');
      expect(r2.cleanedText, '마트 우유 사기');

      // !!! (urgent)
      final r3 = TodoParser.parse('방 청소하기 !!!', baseDate: baseDate);
      expect(r3.priority, 'urgent');
      expect(r3.cleanedText, '방 청소하기');
    });

    test('6. 태그 자동 분류 (쇼핑, 업무, 운동 등)', () {
      final r1 = TodoParser.parse('이마트에서 우유랑 시리얼 사기', baseDate: baseDate);
      expect(r1.tags, contains('쇼핑'));

      final r2 = TodoParser.parse('팀 미팅 보고서 작성', baseDate: baseDate);
      expect(r2.tags, contains('업무'));

      final r2Academic = TodoParser.parse('기말 시험 공부하기', baseDate: baseDate);
      expect(r2Academic.tags, contains('학업'));

      final r3 = TodoParser.parse('헬스장 가서 스쿼트하기', baseDate: baseDate);
      expect(r3.tags, contains('운동'));

      final r4 = TodoParser.parse('친구 생일 파티 준비', baseDate: baseDate);
      expect(r4.tags, contains('약속'));
    });

    test('7. 조사 및 공백 정제 (Cleaning) 검증', () {
      final r1 = TodoParser.parse('내일 오후 2시에 마트에서 우유 사기', baseDate: baseDate);
      expect(r1.date, DateTime(2026, 5, 27));
      expect(r1.time, '14:00'); // '오후 2시' -> 14:00
      // '내일', '오후 2시에'가 날아가고 남는 조사 정제되어 '마트에서 우유 사기'가 되어야 함
      expect(r1.cleanedText, '마트에서 우유 사기');
    });
  });
}
