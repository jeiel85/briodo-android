// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BrioDo';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get storage => 'Storage';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get notSignedInSubtitle =>
      'Items are stored on this device only. Sign in with Google to sync.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get linkGoogle => 'Link Google account';

  @override
  String get anonymousAccount => 'Anonymous account (pre-v1.1.17 user)';

  @override
  String get anonymousSubtitle =>
      'Link a Google account to use BrioDo on other devices.';

  @override
  String get signOut => 'Sign out';

  @override
  String get syncedToCloud => 'Syncing to Google account';

  @override
  String get syncedSubtitle => 'Your items are available on all your devices.';

  @override
  String get deviceOnly => 'Saved on this device only';

  @override
  String get deviceOnlySubtitle =>
      'You can add and edit items without signing in.';

  @override
  String get notifications => 'Notifications';

  @override
  String get allDayReminderTime => 'All-day reminder time';

  @override
  String get allDayReminderTimeSubtitle =>
      'When to send reminders for items without a set time';

  @override
  String get calendarSync => 'Google Calendar sync';

  @override
  String get calendarSyncSubtitle =>
      'Two-way sync of items with the BrioDo calendar in Google';

  @override
  String get calendarNoTimePolicy => 'Items without a time';

  @override
  String get calendarNoTimeAllday => 'Sync as all-day events';

  @override
  String get calendarNoTimeSkip => 'Don\'t sync';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get noTodosToday => 'Nothing to do today\nTap + to add';

  @override
  String get noTodosOnDate => 'Nothing on this date';

  @override
  String errorPrefix(String detail) {
    return 'Error: $detail';
  }

  @override
  String get addTodo => 'New item';

  @override
  String get editTodo => 'Edit item';

  @override
  String get fieldText => 'Title';

  @override
  String get fieldTextHint => 'e.g. 30 min workout';

  @override
  String get fieldNote => 'Note (optional)';

  @override
  String get fieldAllDay => 'All-day';

  @override
  String get fieldClearTime => 'Clear time';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldReminder => 'Reminder';

  @override
  String get fieldTags => 'Tags (comma-separated)';

  @override
  String get fieldTagsHint => 'e.g. workout, health';

  @override
  String get noTimeNoReminderHint =>
      'Without a specific time, the reminder may not be scheduled.';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get reminderNone => 'Off';

  @override
  String get reminderAtTime => 'At time';

  @override
  String get reminder10min => '10 min before';

  @override
  String get reminder30min => '30 min before';

  @override
  String get reminder1hour => '1 hour before';

  @override
  String get fieldSubtasks => 'Subtasks';

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get subtaskHint => 'Type and press Enter';

  @override
  String get fieldRecurrence => 'Repeat';

  @override
  String get recurrenceNone => 'Doesn\'t repeat';

  @override
  String get recurrenceDaily => 'Daily';

  @override
  String get recurrenceWeekly => 'Weekly';

  @override
  String get recurrenceMonthly => 'Monthly';

  @override
  String get recurrenceEnd => 'Repeat until';

  @override
  String get recurrenceEndNone => 'Forever';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'title, note, tag';

  @override
  String get searchEmpty => 'No results';

  @override
  String get allView => 'All';

  @override
  String get lists => 'Tags';

  @override
  String get stats => 'Stats';

  @override
  String get filterAll => 'All';

  @override
  String get filterMonth => 'This month';

  @override
  String get filterWeek => 'This week';

  @override
  String get noTodos => 'Nothing here';

  @override
  String get noTags => 'No tags yet';

  @override
  String todosCount(int count) {
    return '$count items';
  }

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsThisMonth => 'This month';

  @override
  String get statsStreak => 'Streak';

  @override
  String get statsTotal => 'Total done';

  @override
  String get statsContribution => 'Recent activity';

  @override
  String get statsCompleted => 'completed';

  @override
  String streakDays(int days) {
    return '$days days';
  }

  @override
  String get onboardTitle1 => 'Welcome to BrioDo';

  @override
  String get onboardBody1 =>
      'A light, fast to-do app that lives right on your calendar.';

  @override
  String get onboardTitle2 => 'Calendar IS the list';

  @override
  String get onboardBody2 =>
      'See at a glance — dots on dates show your flow across weeks.';

  @override
  String get onboardTitle3 => 'Sync only when you want';

  @override
  String get onboardBody3 =>
      'Use it without signing in. Add a Google account later and it picks up where you left off.';

  @override
  String get onboardTitle4 => 'Reminders & stats';

  @override
  String get onboardBody4 =>
      'Due-time reminders, streaks, achievements — tools for people who stick with it.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardNext => 'Next';

  @override
  String get onboardStart => 'Get started';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Default';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeXLarge => 'Extra large';

  @override
  String get defaultView => 'Default view';

  @override
  String get viewDate => 'Calendar';

  @override
  String get viewAll => 'All';

  @override
  String get viewLists => 'Tags';

  @override
  String get completeMode => 'On complete';

  @override
  String get completeToggle => 'Toggle state';

  @override
  String get completeDelete => 'Delete immediately';

  @override
  String get statusBarOngoing => 'Status-bar ongoing';

  @override
  String get statusBarOngoingSubtitle =>
      'Keep today\'s count pinned to the status bar';

  @override
  String get achievements => 'Achievements';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSave => 'Save';

  @override
  String get migrateDialogTitle => 'Move items to the cloud?';

  @override
  String migrateDialogBody(int count) {
    return 'There are $count items saved on this device.\nMove them to your Google account to view them on other devices.';
  }

  @override
  String get migrateDeclineButton => 'No, just sign in';

  @override
  String get migrateAcceptButton => 'Move them';

  @override
  String get snackLoginSuccess => 'Signed in.';

  @override
  String snackLoginMigrated(int count) {
    return 'Signed in. Moved $count items to your Google account.';
  }

  @override
  String snackLoginFailed(String detail) {
    return 'Sign-in failed: $detail';
  }

  @override
  String get snackLogoutSuccess => 'Signed out. Back to local storage.';

  @override
  String snackLogoutFailed(String detail) {
    return 'Sign-out failed: $detail';
  }

  @override
  String get webNoGoogleLogin =>
      'Google sign-in is not supported on web yet. Please use the mobile app.';

  @override
  String get smartInputSettings => 'Smart Input Settings (Offline)';

  @override
  String get smartInputEngine => 'Parsing Engine';

  @override
  String get smartInputEngineLocal => 'Local Regex/Keywords';

  @override
  String get smartInputEngineOndevice => 'On-device LLM (Fully Offline)';

  @override
  String get modelStatus => 'Model Status';

  @override
  String get modelStatusNotDownloaded => 'Download Required (~1.35 GB)';

  @override
  String modelStatusDownloading(String progress, String speed) {
    return 'Downloading... $progress% ($speed MB/s)';
  }

  @override
  String get modelStatusReady => 'Ready (Available)';

  @override
  String get modelDownloadUrl => 'Model Download URL';

  @override
  String get modelDownloadUrlHint => 'Enter model download URL';

  @override
  String get modelDownloadButton => 'Start Download';

  @override
  String get modelDeleteButton => 'Delete Model';

  @override
  String get modelDownloadCancelButton => 'Cancel Download';

  @override
  String get modelHardwareWarning =>
      '⚠️ On-device LLM might be slow or terminate the app due to RAM limits (at least 4GB RAM recommended) depending on device specs.';

  @override
  String get modelNotDownloadedWarning =>
      'On-device LLM model is not on this device. Please download the model in Settings first.';

  @override
  String smartParsingError(String detail) {
    return 'Smart parsing error: $detail';
  }
}
