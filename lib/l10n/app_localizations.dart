import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'BrioDo'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// No description provided for @storage.
  ///
  /// In ko, this message translates to:
  /// **'저장 방식'**
  String get storage;

  /// No description provided for @notSignedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인 안 됨'**
  String get notSignedIn;

  /// No description provided for @notSignedInSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'일정은 이 기기에만 저장됩니다. Google 로그인 시 동기화 가능.'**
  String get notSignedInSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정으로 로그인'**
  String get signInWithGoogle;

  /// No description provided for @linkGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정 연결'**
  String get linkGoogle;

  /// No description provided for @anonymousAccount.
  ///
  /// In ko, this message translates to:
  /// **'익명 계정 (v1.1.17 이전 사용자)'**
  String get anonymousAccount;

  /// No description provided for @anonymousSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정으로 연결하면 다른 기기에서도 사용할 수 있어요.'**
  String get anonymousSubtitle;

  /// No description provided for @signOut.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get signOut;

  /// No description provided for @syncedToCloud.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정에 동기화 중'**
  String get syncedToCloud;

  /// No description provided for @syncedSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'여러 기기에서 같은 일정을 볼 수 있어요.'**
  String get syncedSubtitle;

  /// No description provided for @deviceOnly.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에만 저장'**
  String get deviceOnly;

  /// No description provided for @deviceOnlySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인하지 않아도 일정 추가/편집이 가능합니다.'**
  String get deviceOnlySubtitle;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @allDayReminderTime.
  ///
  /// In ko, this message translates to:
  /// **'종일 일정 알림 시각'**
  String get allDayReminderTime;

  /// No description provided for @allDayReminderTimeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'시간이 지정되지 않은 일정의 알림이 발송될 시각'**
  String get allDayReminderTimeSubtitle;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기본'**
  String get languageSystem;

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageChinese.
  ///
  /// In ko, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @noTodosToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘 할 일이 없어요\n+ 버튼으로 추가하세요'**
  String get noTodosToday;

  /// No description provided for @noTodosOnDate.
  ///
  /// In ko, this message translates to:
  /// **'이 날짜에 할 일이 없어요'**
  String get noTodosOnDate;

  /// No description provided for @errorPrefix.
  ///
  /// In ko, this message translates to:
  /// **'오류: {detail}'**
  String errorPrefix(String detail);

  /// No description provided for @addTodo.
  ///
  /// In ko, this message translates to:
  /// **'할 일 추가'**
  String get addTodo;

  /// No description provided for @editTodo.
  ///
  /// In ko, this message translates to:
  /// **'할 일 편집'**
  String get editTodo;

  /// No description provided for @fieldText.
  ///
  /// In ko, this message translates to:
  /// **'내용'**
  String get fieldText;

  /// No description provided for @fieldTextHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 운동 30분'**
  String get fieldTextHint;

  /// No description provided for @fieldNote.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get fieldNote;

  /// No description provided for @fieldAllDay.
  ///
  /// In ko, this message translates to:
  /// **'종일'**
  String get fieldAllDay;

  /// No description provided for @fieldClearTime.
  ///
  /// In ko, this message translates to:
  /// **'시간 지우기'**
  String get fieldClearTime;

  /// No description provided for @fieldPriority.
  ///
  /// In ko, this message translates to:
  /// **'우선순위'**
  String get fieldPriority;

  /// No description provided for @fieldReminder.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get fieldReminder;

  /// No description provided for @fieldTags.
  ///
  /// In ko, this message translates to:
  /// **'태그 (쉼표 구분)'**
  String get fieldTags;

  /// No description provided for @fieldTagsHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 운동, 건강'**
  String get fieldTagsHint;

  /// No description provided for @noTimeNoReminderHint.
  ///
  /// In ko, this message translates to:
  /// **'시간 미지정 시 일정 시각이 없어 알림이 예약되지 않을 수 있어요.'**
  String get noTimeNoReminderHint;

  /// No description provided for @priorityLow.
  ///
  /// In ko, this message translates to:
  /// **'낮음'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In ko, this message translates to:
  /// **'높음'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In ko, this message translates to:
  /// **'긴급'**
  String get priorityUrgent;

  /// No description provided for @reminderNone.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get reminderNone;

  /// No description provided for @reminderAtTime.
  ///
  /// In ko, this message translates to:
  /// **'정각'**
  String get reminderAtTime;

  /// No description provided for @reminder10min.
  ///
  /// In ko, this message translates to:
  /// **'10분 전'**
  String get reminder10min;

  /// No description provided for @reminder30min.
  ///
  /// In ko, this message translates to:
  /// **'30분 전'**
  String get reminder30min;

  /// No description provided for @reminder1hour.
  ///
  /// In ko, this message translates to:
  /// **'1시간 전'**
  String get reminder1hour;

  /// No description provided for @actionCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get actionCancel;

  /// No description provided for @actionAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get actionAdd;

  /// No description provided for @actionSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get actionSave;

  /// No description provided for @migrateDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'기기 일정을 옮길까요?'**
  String get migrateDialogTitle;

  /// No description provided for @migrateDialogBody.
  ///
  /// In ko, this message translates to:
  /// **'현재 기기에 저장된 일정 {count}개가 있어요.\nGoogle 계정으로 옮기면 다른 기기에서도 같은 일정을 볼 수 있습니다.'**
  String migrateDialogBody(int count);

  /// No description provided for @migrateDeclineButton.
  ///
  /// In ko, this message translates to:
  /// **'아니요, 그냥 로그인'**
  String get migrateDeclineButton;

  /// No description provided for @migrateAcceptButton.
  ///
  /// In ko, this message translates to:
  /// **'옮기기'**
  String get migrateAcceptButton;

  /// No description provided for @snackLoginSuccess.
  ///
  /// In ko, this message translates to:
  /// **'로그인됐어요.'**
  String get snackLoginSuccess;

  /// No description provided for @snackLoginMigrated.
  ///
  /// In ko, this message translates to:
  /// **'로그인됐어요. 일정 {count}개를 Google 계정으로 옮겼습니다.'**
  String snackLoginMigrated(int count);

  /// No description provided for @snackLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인 실패: {detail}'**
  String snackLoginFailed(String detail);

  /// No description provided for @snackLogoutSuccess.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃됐어요. 다시 로컬 저장으로 돌아갑니다.'**
  String get snackLogoutSuccess;

  /// No description provided for @snackLogoutFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 실패: {detail}'**
  String snackLogoutFailed(String detail);

  /// No description provided for @webNoGoogleLogin.
  ///
  /// In ko, this message translates to:
  /// **'웹에서는 아직 Google 로그인이 지원되지 않습니다. 모바일 앱에서 사용해 주세요.'**
  String get webNoGoogleLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
