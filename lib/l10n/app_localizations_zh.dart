// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BrioDo';

  @override
  String get today => '今天';

  @override
  String get settings => '设置';

  @override
  String get account => '账户';

  @override
  String get storage => '保存方式';

  @override
  String get notSignedIn => '未登录';

  @override
  String get notSignedInSubtitle => '事项仅保存在本机。使用 Google 登录可同步到云端。';

  @override
  String get signInWithGoogle => '使用 Google 登录';

  @override
  String get linkGoogle => '关联 Google 账户';

  @override
  String get anonymousAccount => '匿名账户 (v1.1.17 之前的用户)';

  @override
  String get anonymousSubtitle => '关联 Google 账户后可在其他设备使用。';

  @override
  String get signOut => '退出登录';

  @override
  String get syncedToCloud => '正在同步到 Google 账户';

  @override
  String get syncedSubtitle => '在多台设备上查看相同的事项。';

  @override
  String get deviceOnly => '仅保存在本机';

  @override
  String get deviceOnlySubtitle => '不登录也可以添加和编辑事项。';

  @override
  String get notifications => '通知';

  @override
  String get allDayReminderTime => '全天事项提醒时间';

  @override
  String get allDayReminderTimeSubtitle => '未设置时间的事项的提醒发送时刻';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get noTodosToday => '今天没有事项\n点击 + 添加';

  @override
  String get noTodosOnDate => '这一天没有事项';

  @override
  String errorPrefix(String detail) {
    return '错误: $detail';
  }

  @override
  String get addTodo => '新建事项';

  @override
  String get editTodo => '编辑事项';

  @override
  String get fieldText => '内容';

  @override
  String get fieldTextHint => '例如: 运动 30 分钟';

  @override
  String get fieldNote => '备注 (可选)';

  @override
  String get fieldAllDay => '全天';

  @override
  String get fieldClearTime => '清除时间';

  @override
  String get fieldPriority => '优先级';

  @override
  String get fieldReminder => '提醒';

  @override
  String get fieldTags => '标签 (逗号分隔)';

  @override
  String get fieldTagsHint => '例如: 运动, 健康';

  @override
  String get noTimeNoReminderHint => '未指定时间时,提醒可能无法被安排。';

  @override
  String get priorityLow => '低';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityUrgent => '紧急';

  @override
  String get reminderNone => '关闭';

  @override
  String get reminderAtTime => '准点';

  @override
  String get reminder10min => '提前 10 分钟';

  @override
  String get reminder30min => '提前 30 分钟';

  @override
  String get reminder1hour => '提前 1 小时';

  @override
  String get fieldSubtasks => '子任务';

  @override
  String get addSubtask => '添加子任务';

  @override
  String get subtaskHint => '输入后按 Enter';

  @override
  String get fieldRecurrence => '重复';

  @override
  String get recurrenceNone => '不重复';

  @override
  String get recurrenceDaily => '每天';

  @override
  String get recurrenceWeekly => '每周';

  @override
  String get recurrenceMonthly => '每月';

  @override
  String get recurrenceEnd => '重复结束日';

  @override
  String get recurrenceEndNone => '无限期';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get search => '搜索';

  @override
  String get searchHint => '内容, 备注, 标签';

  @override
  String get searchEmpty => '没有结果';

  @override
  String get actionCancel => '取消';

  @override
  String get actionAdd => '添加';

  @override
  String get actionSave => '保存';

  @override
  String get migrateDialogTitle => '将本机事项迁移到云端?';

  @override
  String migrateDialogBody(int count) {
    return '本机当前保存了 $count 个事项。\n迁移到 Google 账户后可在其他设备查看。';
  }

  @override
  String get migrateDeclineButton => '否, 仅登录';

  @override
  String get migrateAcceptButton => '迁移';

  @override
  String get snackLoginSuccess => '已登录。';

  @override
  String snackLoginMigrated(int count) {
    return '已登录。已将 $count 个事项迁移到 Google 账户。';
  }

  @override
  String snackLoginFailed(String detail) {
    return '登录失败: $detail';
  }

  @override
  String get snackLogoutSuccess => '已退出登录。回到本地存储。';

  @override
  String snackLogoutFailed(String detail) {
    return '退出登录失败: $detail';
  }

  @override
  String get webNoGoogleLogin => '网页端尚不支持 Google 登录,请使用移动 App。';
}
