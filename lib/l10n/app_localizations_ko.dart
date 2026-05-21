// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'BrioDo';

  @override
  String get today => '오늘';

  @override
  String get settings => '설정';

  @override
  String get account => '계정';

  @override
  String get storage => '저장 방식';

  @override
  String get notSignedIn => '로그인 안 됨';

  @override
  String get notSignedInSubtitle => '일정은 이 기기에만 저장됩니다. Google 로그인 시 동기화 가능.';

  @override
  String get signInWithGoogle => 'Google 계정으로 로그인';

  @override
  String get linkGoogle => 'Google 계정 연결';

  @override
  String get anonymousAccount => '익명 계정 (v1.1.17 이전 사용자)';

  @override
  String get anonymousSubtitle => 'Google 계정으로 연결하면 다른 기기에서도 사용할 수 있어요.';

  @override
  String get signOut => '로그아웃';

  @override
  String get syncedToCloud => 'Google 계정에 동기화 중';

  @override
  String get syncedSubtitle => '여러 기기에서 같은 일정을 볼 수 있어요.';

  @override
  String get deviceOnly => '이 기기에만 저장';

  @override
  String get deviceOnlySubtitle => '로그인하지 않아도 일정 추가/편집이 가능합니다.';

  @override
  String get notifications => '알림';

  @override
  String get allDayReminderTime => '종일 일정 알림 시각';

  @override
  String get allDayReminderTimeSubtitle => '시간이 지정되지 않은 일정의 알림이 발송될 시각';

  @override
  String get calendarSync => 'Google Calendar 동기화';

  @override
  String get calendarSyncSubtitle =>
      '할 일을 Google Calendar에 BrioDo 캘린더로 양방향 동기화';

  @override
  String get calendarNoTimePolicy => '시간 없는 일정';

  @override
  String get calendarNoTimeAllday => '종일 일정으로 동기화';

  @override
  String get calendarNoTimeSkip => '동기화 안 함';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템 기본';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get noTodosToday => '오늘 할 일이 없어요\n+ 버튼으로 추가하세요';

  @override
  String get noTodosOnDate => '이 날짜에 할 일이 없어요';

  @override
  String errorPrefix(String detail) {
    return '오류: $detail';
  }

  @override
  String get addTodo => '할 일 추가';

  @override
  String get editTodo => '할 일 편집';

  @override
  String get fieldText => '내용';

  @override
  String get fieldTextHint => '예: 운동 30분';

  @override
  String get fieldNote => '메모 (선택)';

  @override
  String get fieldAllDay => '종일';

  @override
  String get fieldClearTime => '시간 지우기';

  @override
  String get fieldPriority => '우선순위';

  @override
  String get fieldReminder => '알림';

  @override
  String get fieldTags => '태그 (쉼표 구분)';

  @override
  String get fieldTagsHint => '예: 운동, 건강';

  @override
  String get noTimeNoReminderHint => '시간 미지정 시 일정 시각이 없어 알림이 예약되지 않을 수 있어요.';

  @override
  String get priorityLow => '낮음';

  @override
  String get priorityMedium => '보통';

  @override
  String get priorityHigh => '높음';

  @override
  String get priorityUrgent => '긴급';

  @override
  String get reminderNone => '없음';

  @override
  String get reminderAtTime => '정각';

  @override
  String get reminder10min => '10분 전';

  @override
  String get reminder30min => '30분 전';

  @override
  String get reminder1hour => '1시간 전';

  @override
  String get fieldSubtasks => '하위 작업';

  @override
  String get addSubtask => '하위 작업 추가';

  @override
  String get subtaskHint => '내용 입력 후 Enter';

  @override
  String get fieldRecurrence => '반복';

  @override
  String get recurrenceNone => '반복 안 함';

  @override
  String get recurrenceDaily => '매일';

  @override
  String get recurrenceWeekly => '매주';

  @override
  String get recurrenceMonthly => '매월';

  @override
  String get recurrenceEnd => '반복 종료일';

  @override
  String get recurrenceEndNone => '무기한';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get search => '검색';

  @override
  String get searchHint => '내용, 메모, 태그';

  @override
  String get searchEmpty => '결과가 없어요';

  @override
  String get actionCancel => '취소';

  @override
  String get actionAdd => '추가';

  @override
  String get actionSave => '저장';

  @override
  String get migrateDialogTitle => '기기 일정을 옮길까요?';

  @override
  String migrateDialogBody(int count) {
    return '현재 기기에 저장된 일정 $count개가 있어요.\nGoogle 계정으로 옮기면 다른 기기에서도 같은 일정을 볼 수 있습니다.';
  }

  @override
  String get migrateDeclineButton => '아니요, 그냥 로그인';

  @override
  String get migrateAcceptButton => '옮기기';

  @override
  String get snackLoginSuccess => '로그인됐어요.';

  @override
  String snackLoginMigrated(int count) {
    return '로그인됐어요. 일정 $count개를 Google 계정으로 옮겼습니다.';
  }

  @override
  String snackLoginFailed(String detail) {
    return '로그인 실패: $detail';
  }

  @override
  String get snackLogoutSuccess => '로그아웃됐어요. 다시 로컬 저장으로 돌아갑니다.';

  @override
  String snackLogoutFailed(String detail) {
    return '로그아웃 실패: $detail';
  }

  @override
  String get webNoGoogleLogin =>
      '웹에서는 아직 Google 로그인이 지원되지 않습니다. 모바일 앱에서 사용해 주세요.';
}
