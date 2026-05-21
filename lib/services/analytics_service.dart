import 'package:firebase_analytics/firebase_analytics.dart';

/// Capacitor v1.1.17과 일관성 유지하기 위한 이벤트 키.
/// app_open, session_start, first_open, login, sign_up은 Firebase Analytics가 자동 수집.
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _fa);

  Future<void> logTodoCreate({String? priority, int? tagCount}) {
    return _fa.logEvent(
      name: 'todo_create',
      parameters: {
        'priority': ?priority,
        'tag_count': ?tagCount,
      },
    );
  }

  Future<void> logTodoComplete({String? priority}) {
    return _fa.logEvent(
      name: 'todo_complete',
      parameters: {
        'priority': ?priority,
      },
    );
  }

  Future<void> logTodoDelete() {
    return _fa.logEvent(name: 'todo_delete');
  }

  Future<void> logLogin({String method = 'google'}) {
    return _fa.logLogin(loginMethod: method);
  }

  Future<void> setUserId(String? uid) {
    return _fa.setUserId(id: uid);
  }
}
