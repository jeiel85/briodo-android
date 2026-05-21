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
}
