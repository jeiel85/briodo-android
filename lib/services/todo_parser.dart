import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import '../providers/app_settings_provider.dart';

class ParsedTodoResult {
  final String originalText;
  final String cleanedText;
  final DateTime? date;
  final String? time; // "HH:mm"
  final List<String> tags;
  final String? priority; // "low", "medium", "high", "urgent"

  ParsedTodoResult({
    required this.originalText,
    required this.cleanedText,
    this.date,
    this.time,
    required this.tags,
    this.priority,
  });

  @override
  String toString() {
    return 'ParsedTodoResult(originalText: $originalText, cleanedText: $cleanedText, date: $date, time: $time, tags: $tags, priority: $priority)';
  }
}

class TodoParser {
  static const _channel = MethodChannel('app.briodo/ondevice_llm');

  static Future<ParsedTodoResult> parseSmart(
    String text,
    AppSettings settings, {
    DateTime? baseDate,
  }) async {
    if (settings.smartInputEngine == 'local') {
      return parse(text, baseDate: baseDate);
    }

    if (settings.onDeviceModelPath.isEmpty) {
      dev.log("On-device model path is empty, falling back to local regex");
      return parse(text, baseDate: baseDate);
    }

    final now = baseDate ?? DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final weekdayNamesEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdayStrEn = weekdayNamesEn[now.weekday - 1];

    final systemPromptEn = """Today's date is $todayStr ($weekdayStrEn).
Analyze the user's input task/schedule and convert it into a structured JSON object.
You must return only a valid JSON object matching the format below, without any other text or markdown code block markers.

JSON Format:
{
  "refinedText": "core title of the schedule without date/time/priority details",
  "date": "YYYY-MM-DD format date (calculate relative dates based on today's date $todayStr)",
  "time": "HH:MM format time (null if not specified)",
  "categories": ["tag1", "tag2"],
  "priority": "low, medium, high, urgent (default is medium)"
}

Rules:
1. categories is a list of max 2 tags representing the task category (e.g. Shopping, Work, Exercise, Appointment, Health, Household, Study, etc.).
2. refinedText must be clean and not contain date/time keywords or priority marks.
3. Return ONLY the JSON object starting with { and ending with }.""";

    final gemmaPrompt = """$systemPromptEn

Input: "$text"
Output:
""";

    try {
      print("TodoParser.parseSmart: Starting on-device LLM parsing for text: '$text'...");
      print("TodoParser.parseSmart: initModel called with modelPath = '${settings.onDeviceModelPath}'...");
      await _channel.invokeMethod('initModel', {
        'modelPath': settings.onDeviceModelPath,
      });
      print("TodoParser.parseSmart: initModel completed successfully.");

      print("TodoParser.parseSmart: generateResponse calling with prompt length: ${gemmaPrompt.length}...");
      final responseText = await _channel.invokeMethod<String>('generateResponse', {
        'prompt': gemmaPrompt,
      });
      print("TodoParser.parseSmart: generateResponse returned: '$responseText'");

      if (responseText != null && responseText.trim().isNotEmpty) {
        String cleanJson = responseText.trim();
        if (cleanJson.contains('```')) {
          final firstIndex = cleanJson.indexOf('{');
          final lastIndex = cleanJson.lastIndexOf('}');
          if (firstIndex != -1 && lastIndex != -1 && lastIndex > firstIndex) {
            cleanJson = cleanJson.substring(firstIndex, lastIndex + 1);
          }
        }
        print("TodoParser.parseSmart: cleanJson to parse: '$cleanJson'");

        final parsedMap = jsonDecode(cleanJson) as Map<String, dynamic>;
        
        final refinedText = parsedMap['refinedText'] as String? ?? text;
        final dateStr = parsedMap['date'] as String?;
        final timeStr = parsedMap['time'] as String?;
        final categories = (parsedMap['categories'] as List?)?.map((e) {
          final s = e.toString().trim().toLowerCase();
          if (s == 'work' || s == 'job') return '업무';
          if (s == 'shopping') return '쇼핑';
          if (s == 'exercise' || s == 'workout') return '운동';
          if (s == 'appointment' || s == 'meeting') return '약속';
          if (s == 'health' || s == 'medical') return '건강';
          if (s == 'household' || s == 'home') return '집안일';
          if (s == 'study' || s == 'school') return '학업';
          return e.toString();
        }).toList() ?? [];
        final priorityStr = parsedMap['priority'] as String?;

        DateTime? parsedDate;
        if (dateStr != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
          parsedDate = DateTime.tryParse(dateStr);
        }

        final result = ParsedTodoResult(
          originalText: text,
          cleanedText: refinedText,
          date: parsedDate,
          time: timeStr,
          tags: categories,
          priority: priorityStr,
        );
        print("TodoParser.parseSmart: Successfully parsed result: $result");
        return result;
      }
    } catch (e, stackTrace) {
      print("TodoParser.parseSmart error: $e\n$stackTrace");
      dev.log("On-device LLM Parsing error, falling back to local regex", error: e);
    }

    // Fallback to local regex/keyword parser
    return parse(text, baseDate: baseDate);
  }

  /// 자연어 텍스트를 파싱하여 결과를 반환합니다.
  static ParsedTodoResult parse(String text, {DateTime? baseDate}) {
    final original = text;
    final now = baseDate ?? DateTime.now();
    
    DateTime? parsedDate;
    String? parsedTime;
    String? parsedPriority;
    final parsedTags = <String>[];

    // 파싱된 부분들을 제거하여 깨끗한 텍스트로 만들기 위해 사용할 작업용 문자열
    String workingText = text;

    // 1. 우선순위 (Priority) 파싱
    // 느낌표 기호 개수(기호는 긴 것부터 매칭하여 오동작 방지) 및 키워드 매칭
    if (workingText.contains('!!!')) {
      parsedPriority = 'urgent';
      workingText = workingText.replaceAll('!!!', '');
    } else if (workingText.contains('!!')) {
      parsedPriority = 'high';
      workingText = workingText.replaceAll('!!', '');
    } else if (workingText.contains('!긴급') || workingText.contains('!urgent')) {
      parsedPriority = 'urgent';
      workingText = workingText.replaceAll('!긴급', '').replaceAll('!urgent', '');
    } else if (workingText.contains('!높음') || workingText.contains('!high')) {
      parsedPriority = 'high';
      workingText = workingText.replaceAll('!높음', '').replaceAll('!high', '');
    } else if (workingText.contains('!낮음') || workingText.contains('!low')) {
      parsedPriority = 'low';
      workingText = workingText.replaceAll('!낮음', '').replaceAll('!low', '');
    } else if (workingText.contains('!보통') || workingText.contains('!medium')) {
      parsedPriority = 'medium';
      workingText = workingText.replaceAll('!보통', '').replaceAll('!medium', '');
    } else {
      // 단독 느낌표 ! 매칭 (공백과 함께 있거나 문장 맨 끝의 느낌표)
      final singleExclReg = RegExp(r'\s!$|\s!\s|^!\s');
      if (singleExclReg.hasMatch(workingText) || workingText.endsWith('!')) {
        parsedPriority = 'medium';
        workingText = workingText.replaceAll(RegExp(r'\s!$|\s!\s|^!\s|!'), '');
      }
    }

    // 2. 날짜 (Date) 파싱
    // 2-1. 오늘, 내일, 모레, 글피 매칭
    final relativeDateReg = RegExp(r'(내일\s*모레|내일모레|오늘|금일|내일|명일|모레|글피)');
    final relativeMatch = relativeDateReg.firstMatch(workingText);
    if (relativeMatch != null) {
      final keyword = relativeMatch.group(1)!;
      if (keyword == '오늘' || keyword == '금일') {
        parsedDate = DateTime(now.year, now.month, now.day);
      } else if (keyword == '내일' || keyword == '명일') {
        parsedDate = now.add(const Duration(days: 1));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      } else if (keyword == '모레' || keyword == '내일 모레' || keyword == '내일모레') {
        parsedDate = now.add(const Duration(days: 2));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      } else if (keyword == '글피') {
        parsedDate = now.add(const Duration(days: 3));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      }
      workingText = workingText.replaceFirst(relativeDateReg, '');
    }

    // 2-2. 주말 및 요일 파싱
    // 예: "이번주 금요일", "다음주 월요일", "다다음주 화요일", "금요일에", "수요일"
    if (parsedDate == null) {
      final weekdayReg = RegExp(
        r'(이번주|다음주|다다음주)?\s*([월화수목금토일])요일?(?:에)?',
      );
      final weekdayMatch = weekdayReg.firstMatch(workingText);
      if (weekdayMatch != null) {
        final prefix = weekdayMatch.group(1); // 이번주/다음주/다다음주
        final dayStr = weekdayMatch.group(2)!; // 월~일
        
        final targetWeekday = _mapWeekday(dayStr);
        final currentWeekday = now.weekday; // 1 = 월요일, 7 = 일요일

        int daysToAdd = targetWeekday - currentWeekday;
        
        if (prefix == '다음주') {
          daysToAdd += 7;
        } else if (prefix == '다다음주') {
          daysToAdd += 14;
        } else {
          // 접두사 없음 또는 "이번주"
          if (daysToAdd < 0) {
            // 이미 지난 요일이면 다음주 해당 요일로 계산 (예: 목요일인데 월요일이라 하면 다음주 월요일)
            daysToAdd += 7;
          }
        }
        
        parsedDate = now.add(Duration(days: daysToAdd));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        workingText = workingText.replaceFirst(weekdayReg, '');
      }
    }

    // 2-3. 주말 파싱
    if (parsedDate == null) {
      final weekendReg = RegExp(r'(이번주|다음주|다다음주)?\s*주말(?:에)?');
      final weekendMatch = weekendReg.firstMatch(workingText);
      if (weekendMatch != null) {
        final prefix = weekendMatch.group(1);
        final currentWeekday = now.weekday;
        
        // 토요일(6) 기준으로 계산
        int daysToAdd = 6 - currentWeekday;
        if (prefix == '다음주') {
          daysToAdd += 7;
        } else if (prefix == '다다음주') {
          daysToAdd += 14;
        } else {
          if (daysToAdd < 0) {
            // 이미 토요일이 지났으면(일요일) 다음주 주말로 계산
            daysToAdd += 7;
          }
        }
        parsedDate = now.add(Duration(days: daysToAdd));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        workingText = workingText.replaceFirst(weekendReg, '');
      }
    }

    // 2-4. 특정 날짜 파싱 (MM/DD, MM월 DD일, YYYY-MM-DD 등)
    if (parsedDate == null) {
      // 패턴: YYYY년 MM월 DD일, MM월 DD일, YYYY/MM/DD, MM/DD, MM.DD
      final specificDateReg = RegExp(
        r'(?:(\d{4})년\s*)?(\d{1,2})월\s*(\d{1,2})일?',
      );
      final specificDateMatch = specificDateReg.firstMatch(workingText);
      if (specificDateMatch != null) {
        final yearStr = specificDateMatch.group(1);
        final monthStr = specificDateMatch.group(2)!;
        final dayStr = specificDateMatch.group(3)!;

        final year = yearStr != null ? int.parse(yearStr) : now.year;
        final month = int.parse(monthStr);
        final day = int.parse(dayStr);

        // 유효한 날짜인지 검증 후 객체 생성
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          parsedDate = DateTime(year, month, day);
          workingText = workingText.replaceFirst(specificDateReg, '');
        }
      }
    }

    if (parsedDate == null) {
      final slashDateReg = RegExp(
        r'(?:(\d{4})[./\-])?(\d{1,2})[./\-](\d{1,2})',
      );
      final slashDateMatch = slashDateReg.firstMatch(workingText);
      if (slashDateMatch != null) {
        final yearStr = slashDateMatch.group(1);
        final monthStr = slashDateMatch.group(2)!;
        final dayStr = slashDateMatch.group(3)!;

        final year = yearStr != null ? int.parse(yearStr) : now.year;
        final month = int.parse(monthStr);
        final day = int.parse(dayStr);

        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          parsedDate = DateTime(year, month, day);
          workingText = workingText.replaceFirst(slashDateReg, '');
        }
      }
    }

    // 3. 시간 (Time) 파싱
    // 3-1. 오전/오후 + 시/분 매칭
    // 예: "오후 2시 30분", "오전 9시", "저녁 7시반", "새벽 2시", "14:30"
    final timeModifierReg = RegExp(r'(오전|오후|아침|점심|저녁|새벽|낮|밤)');
    final timeModifierMatch = timeModifierReg.firstMatch(workingText);
    String? modifier = timeModifierMatch?.group(1);
    
    // 시/분 정보 추출
    final timeClockReg = RegExp(
      r'(\d{1,2})\s*시\s*(?:(?:(\d{1,2})\s*분)|(반))?',
    );
    final timeClockMatch = timeClockReg.firstMatch(workingText);

    final digitalTimeReg = RegExp(r'(\d{1,2})\s*:\s*(\d{2})');
    final digitalTimeMatch = digitalTimeReg.firstMatch(workingText);

    int? hour;
    int? minute;
    bool timeMatched = false;

    if (timeClockMatch != null) {
      timeMatched = true;
      final hourStr = timeClockMatch.group(1)!;
      final minuteStr = timeClockMatch.group(2);
      final halfStr = timeClockMatch.group(3);

      hour = int.tryParse(hourStr);
      if (halfStr == '반') {
        minute = 30;
      } else {
        minute = minuteStr != null ? int.tryParse(minuteStr) : 0;
      }
      workingText = workingText.replaceFirst(timeClockReg, '');
    } else if (digitalTimeMatch != null) {
      timeMatched = true;
      hour = int.tryParse(digitalTimeMatch.group(1)!);
      minute = int.tryParse(digitalTimeMatch.group(2)!);
      workingText = workingText.replaceFirst(digitalTimeReg, '');
    }

    // 오전/오후 단독 키워드도 텍스트에서 제거
    if (modifier != null) {
      workingText = workingText.replaceFirst(timeModifierReg, '');
    }

    // 시간 계산
    if (timeMatched && hour != null && minute != null) {
      if (modifier != null) {
        if (modifier == '오후' || modifier == '저녁' || modifier == '밤' || modifier == '점심') {
          if (hour < 12) {
            hour += 12;
          } else if (hour == 12 && modifier == '밤') {
            hour = 0; // 밤 12시 -> 00시
          }
        } else if (modifier == '오전' || modifier == '새벽' || modifier == '아침') {
          if (hour == 12) {
            hour = 0; // 오전 12시 -> 00시
          }
        }
      } else {
        // 모디파이어가 없고 시간이 1~8시 사이이면 현실적으로 오후 시간(13~20)일 가능성이 높음 (보통 2시는 오후 2시 의미)
        // 단, 24시간 표기법인 9~24시는 그대로 유지
        if (hour >= 1 && hour <= 8) {
          hour += 12; // 디폴트로 오후 시간으로 보정
        }
      }

      parsedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (modifier != null) {
      // 시간 수치 없이 "아침에 마트 가기" 와 같이 모디파이어만 있는 경우, 합리적인 기본 시간 할당
      int defHour = 9;
      switch (modifier) {
        case '새벽':
          defHour = 6;
          break;
        case '아침':
        case '오전':
          defHour = 9;
          break;
        case '점심':
        case '낮':
          defHour = 12;
          break;
        case '오후':
          defHour = 14;
          break;
        case '저녁':
          defHour = 19;
          break;
        case '밤':
          defHour = 22;
          break;
      }
      parsedTime = '${defHour.toString().padLeft(2, '0')}:00';
    }

    // 4. 태그 (Tags) 자동 분류
    final tagKeywords = {
      '쇼핑': ['쇼핑', '장보기', '사기', '구매', '주문', '택배', '마트', '백화점', '쿠팡', '다이소', '올리브영', '지름', '결제', '장바구니'],
      '업무': ['회의', '미팅', '업무', '보고', '회사', '프로젝트', '출근', '퇴근', '일하기', '바이어', '기획', '이메일', '메일', '계약', '세미나', '협의'],
      '운동': ['헬스', '운동', '러닝', '수영', '요가', '필라테스', '산책', '자전거', '조깅', '피트니스', '짐', '등산', '스쿼트', '스트레칭'],
      '약속': ['약속', '친구', '생일', '데이트', '만남', '가족', '부모님', '식사', '저녁약속', '점심약속', '생신', '외식', '모임', '동창', '파티'],
      '건강': ['병원', '치과', '약', '진료', '검진', '영양제', '치료', '처방', '내과', '피부과', '한의원', '비타민', '안과'],
      '집안일': ['청소', '빨래', '설거지', '정리', '분리수거', '가사', '빨래감', '이불빨래', '먼지털기', '환기', '분리 수거'],
      '학업': ['공부', '독서', '강의', '시험', '과제', '학원', '세미나', '공부하기', '인강', '수업', '과외', '숙제', '복습', '예습', '영어'],
    };

    tagKeywords.forEach((tag, keywords) {
      for (final keyword in keywords) {
        if (original.contains(keyword)) {
          parsedTags.add(tag);
          break; // 해당 태그에 대해 하나라도 매칭되면 중복 추가 방지를 위해 루프 탈출
        }
      }
    });

    // 5. 텍스트 정제 (Clean Text)
    // 파싱 과정에서 남은 조사('에', '에서', '을', '를', '은', '는')가 단독으로 남거나 연속된 공백 정제
    String cleaned = workingText;
    
    // "에", "에서", "까지", "은/는"이 단어 앞이나 뒤에 덩그러니 남는 경우 정제
    cleaned = cleaned.replaceAll(RegExp(r'\s+에\s+|\s+에서\s+|\s+을\s+|\s+를\s+|\s+은\s+|\s+는\s+'), ' ');
    // 텍스트 앞의 "에 " 또는 "에서 " 제거
    cleaned = cleaned.replaceFirst(RegExp(r'^(?:에|에서|을|를|은|는)\s+'), '');
    // 텍스트 뒤의 "에", "에서" 등 제거
    cleaned = cleaned.replaceFirst(RegExp(r'\s+(?:에|에서|을|를|은|는)$'), '');
    
    // 연속된 공백 하나로 치환 및 양끝 공백 정제
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 만약 파싱 키워드를 지우고 났더니 남은 텍스트가 완전히 비었거나 단순 기호만 남았다면, 원본 텍스트를 제목으로 유지하여 최소한의 제목 보장
    if (cleaned.isEmpty || RegExp(r'^[!@#$%^&*(),.?":{}|<>]*$').hasMatch(cleaned)) {
      cleaned = original.trim();
    }

    return ParsedTodoResult(
      originalText: original,
      cleanedText: cleaned,
      date: parsedDate,
      time: parsedTime,
      tags: parsedTags,
      priority: parsedPriority,
    );
  }

  static int _mapWeekday(String w) {
    switch (w) {
      case '월': return 1;
      case '화': return 2;
      case '수': return 3;
      case '목': return 4;
      case '금': return 5;
      case '토': return 6;
      case '일': return 7;
      default: return 1;
    }
  }
}
