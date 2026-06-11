// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'BrioDo';

  @override
  String get today => '今日';

  @override
  String get settings => '設定';

  @override
  String get account => 'アカウント';

  @override
  String get storage => '保存方法';

  @override
  String get notSignedIn => '未ログイン';

  @override
  String get notSignedInSubtitle => '予定はこの端末にのみ保存されます。Googleでログインすると同期できます。';

  @override
  String get signInWithGoogle => 'Googleアカウントでログイン';

  @override
  String get linkGoogle => 'Googleアカウントを連携';

  @override
  String get anonymousAccount => '匿名アカウント (v1.1.17以前のユーザー)';

  @override
  String get anonymousSubtitle => 'Googleアカウントを連携すると他の端末でも使えます。';

  @override
  String get signOut => 'ログアウト';

  @override
  String get syncedToCloud => 'Googleアカウントに同期中';

  @override
  String get syncedSubtitle => '複数の端末で同じ予定を見ることができます。';

  @override
  String get deviceOnly => 'この端末にのみ保存';

  @override
  String get deviceOnlySubtitle => 'ログインしなくても予定の追加・編集ができます。';

  @override
  String get notifications => '通知';

  @override
  String get allDayReminderTime => '終日予定の通知時刻';

  @override
  String get allDayReminderTimeSubtitle => '時刻が指定されていない予定の通知を送る時刻';

  @override
  String get calendarSync => 'Googleカレンダー同期';

  @override
  String get calendarSyncSubtitle => '予定をGoogleカレンダーのBrioDoカレンダーと双方向同期';

  @override
  String get calendarNoTimePolicy => '時刻のない予定';

  @override
  String get calendarNoTimeAllday => '終日予定として同期';

  @override
  String get calendarNoTimeSkip => '同期しない';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム設定';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get noTodosToday => '今日の予定はありません\n+ ボタンで追加できます';

  @override
  String get noTodosOnDate => 'この日付の予定はありません';

  @override
  String errorPrefix(String detail) {
    return 'エラー: $detail';
  }

  @override
  String get addTodo => '予定を追加';

  @override
  String get editTodo => '予定を編集';

  @override
  String get fieldText => '内容';

  @override
  String get fieldTextHint => '例: 運動30分';

  @override
  String get fieldNote => 'メモ (任意)';

  @override
  String get fieldAllDay => '終日';

  @override
  String get fieldClearTime => '時間を消す';

  @override
  String get fieldPriority => '優先度';

  @override
  String get fieldReminder => '通知';

  @override
  String get fieldTags => 'タグ (カンマ区切り)';

  @override
  String get fieldTagsHint => '例: 運動, 健康';

  @override
  String get noTimeNoReminderHint => '時間が指定されていないと通知がスケジュールされない場合があります。';

  @override
  String get priorityLow => '低';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityUrgent => '緊急';

  @override
  String get reminderNone => 'なし';

  @override
  String get reminderAtTime => '時刻ちょうど';

  @override
  String get reminder10min => '10分前';

  @override
  String get reminder30min => '30分前';

  @override
  String get reminder1hour => '1時間前';

  @override
  String get fieldSubtasks => 'サブタスク';

  @override
  String get addSubtask => 'サブタスクを追加';

  @override
  String get subtaskHint => '入力してEnter';

  @override
  String get fieldRecurrence => '繰り返し';

  @override
  String get recurrenceNone => '繰り返さない';

  @override
  String get recurrenceDaily => '毎日';

  @override
  String get recurrenceWeekly => '毎週';

  @override
  String get recurrenceMonthly => '毎月';

  @override
  String get recurrenceEnd => '終了日';

  @override
  String get recurrenceEndNone => '無期限';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get search => '検索';

  @override
  String get searchHint => '内容, メモ, タグ';

  @override
  String get searchEmpty => '結果がありません';

  @override
  String get allView => 'すべて';

  @override
  String get lists => 'タグ';

  @override
  String get stats => '統計';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterMonth => '今月';

  @override
  String get filterWeek => '今週';

  @override
  String get noTodos => '予定がありません';

  @override
  String get noTags => 'タグがありません';

  @override
  String todosCount(int count) {
    return '$count件';
  }

  @override
  String get statsThisWeek => '今週';

  @override
  String get statsThisMonth => '今月';

  @override
  String get statsStreak => '連続';

  @override
  String get statsTotal => '総完了数';

  @override
  String get statsContribution => '最近の活動';

  @override
  String get statsCompleted => '完了';

  @override
  String streakDays(int days) {
    return '$days日';
  }

  @override
  String get onboardTitle1 => 'BrioDoへようこそ';

  @override
  String get onboardBody1 => 'カレンダーに沿って広がる、軽くて速いタスクアプリ。';

  @override
  String get onboardTitle2 => 'カレンダーがリスト';

  @override
  String get onboardBody2 => '日付の横のドットで全体の流れを一目で。';

  @override
  String get onboardTitle3 => '必要なときだけ同期';

  @override
  String get onboardBody3 => 'ログイン不要でOK。後でGoogle連携すれば自動で他端末と同期。';

  @override
  String get onboardTitle4 => '通知と統計';

  @override
  String get onboardBody4 => '締切通知、連続日数、実績 — 続ける人のためのツール。';

  @override
  String get onboardSkip => 'スキップ';

  @override
  String get onboardNext => '次へ';

  @override
  String get onboardStart => 'はじめる';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get fontSize => '文字サイズ';

  @override
  String get fontSizeSmall => '小';

  @override
  String get fontSizeMedium => '標準';

  @override
  String get fontSizeLarge => '大';

  @override
  String get fontSizeXLarge => '特大';

  @override
  String get defaultView => 'デフォルトビュー';

  @override
  String get viewDate => 'カレンダー';

  @override
  String get viewAll => 'すべて';

  @override
  String get viewLists => 'タグ';

  @override
  String get completeMode => '完了処理';

  @override
  String get completeToggle => '状態切替';

  @override
  String get completeDelete => '即削除';

  @override
  String get statusBarOngoing => 'ステータスバー常時表示';

  @override
  String get statusBarOngoingSubtitle => '今日のタスク数をステータスバーに常時表示';

  @override
  String get achievements => '実績';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionAdd => '追加';

  @override
  String get actionSave => '保存';

  @override
  String get migrateDialogTitle => '端末の予定を移動しますか?';

  @override
  String migrateDialogBody(int count) {
    return 'この端末に保存されている予定が $count 件あります。\nGoogleアカウントに移動すると他の端末でも同じ予定を見られます。';
  }

  @override
  String get migrateDeclineButton => 'いいえ、ログインのみ';

  @override
  String get migrateAcceptButton => '移動する';

  @override
  String get snackLoginSuccess => 'ログインしました。';

  @override
  String snackLoginMigrated(int count) {
    return 'ログインしました。予定 $count 件をGoogleアカウントに移動しました。';
  }

  @override
  String snackLoginFailed(String detail) {
    return 'ログイン失敗: $detail';
  }

  @override
  String get snackLogoutSuccess => 'ログアウトしました。ローカル保存に戻ります。';

  @override
  String snackLogoutFailed(String detail) {
    return 'ログアウト失敗: $detail';
  }

  @override
  String get webNoGoogleLogin => 'ウェブではまだGoogleログインに対応していません。モバイルアプリをご利用ください。';

  @override
  String get smartInputSettings => '스마트 입력 설정 (오프라인)';

  @override
  String get smartInputEngine => '분석 엔진';

  @override
  String get smartInputEngineLocal => '로컬 정규식/키워드';

  @override
  String get smartInputEngineOndevice => '온디바이스 LLM (완전 오프라인)';

  @override
  String get modelStatus => '모델 상태';

  @override
  String get modelStatusNotDownloaded => '다운로드 필요 (약 1.35 GB)';

  @override
  String modelStatusDownloading(String progress, String speed) {
    return '다운로드 중... $progress% ($speed MB/s)';
  }

  @override
  String get modelStatusReady => '준비 완료 (사용 가능)';

  @override
  String get modelDownloadUrl => '모델 다운로드 URL';

  @override
  String get modelDownloadUrlHint => '모델 다운로드 주소를 입력하세요';

  @override
  String get modelDownloadButton => '다운로드 시작';

  @override
  String get modelDeleteButton => '모델 삭제';

  @override
  String get modelDownloadCancelButton => '다운로드 취소';

  @override
  String get modelHardwareWarning =>
      '⚠️ 온디바이스 LLM은 기기 성능에 따라 작동 속도가 느리거나 가용 RAM 부족(최소 4GB 권장)으로 인해 앱이 종료될 수 있습니다.';

  @override
  String get modelNotDownloadedWarning =>
      '온디바이스 LLM 모델이 기기에 없습니다. 설정에서 모델을 먼저 다운로드해야 사용할 수 있습니다.';

  @override
  String smartParsingError(String detail) {
    return '스마트 분석 오류: $detail';
  }
}
