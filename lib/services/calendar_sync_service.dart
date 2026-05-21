import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;
import 'package:http/http.dart' as http;

import '../models/todo.dart';

/// Google Calendar 양방향 동기화.
///
/// 캘린더 컨벤션:
/// - 우리 앱이 만든 캘린더 이름은 'BrioDo'.
/// - 기존 'Blendo' 사용자는 자동 감지해 그 캘린더를 재사용 (이름은 그대로 둠).
/// - todos ↔ events 매핑은 event.extendedProperties.private.briodoTodoId 에 저장.
class CalendarSyncService {
  CalendarSyncService._();
  static final instance = CalendarSyncService._();

  static const _calendarPrimary = 'BrioDo';
  static const _calendarLegacy = 'Blendo';
  static const _todoIdKey = 'briodoTodoId';
  static const List<String> _scopes = <String>[gcal.CalendarApi.calendarScope];

  String? _cachedCalendarId;

  /// 사용자가 calendar 권한을 부여했는지 확인하고, 안 됐으면 요청.
  /// 거부하거나 미로그인이면 null 반환.
  Future<gcal.CalendarApi?> _api() async {
    try {
      // 7.x: lightweight 시도 → 없으면 사용자 측에서 이미 sign-in 한 상태가 아님.
      // 호출 측이 settings_screen에서 Google 로그인 후에만 sync를 켜기 때문에
      // 여기서 이미 인증된 세션이 있다고 가정 가능.
      final user =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (user == null) return null;

      final auth = await user.authorizationClient
          .authorizationForScopes(_scopes);
      gauth.AccessToken token;
      if (auth != null) {
        token = _toAccessToken(auth.accessToken);
      } else {
        final granted =
            await user.authorizationClient.authorizeScopes(_scopes);
        token = _toAccessToken(granted.accessToken);
      }

      final credentials = gauth.AccessCredentials(token, null, _scopes);
      final client = gauth.authenticatedClient(http.Client(), credentials);
      return gcal.CalendarApi(client);
    } catch (e) {
      debugPrint('CalendarSyncService._api 실패: $e');
      return null;
    }
  }

  /// google_sign_in 토큰을 googleapis_auth AccessToken으로 변환.
  /// 만료 시간은 보수적으로 50분 (Capacitor 룰과 동일) 잡음.
  gauth.AccessToken _toAccessToken(String raw) => gauth.AccessToken(
        'Bearer',
        raw,
        DateTime.now().toUtc().add(const Duration(minutes: 50)),
      );

  /// BrioDo 캘린더 ID 찾기/생성.
  /// 1) cachedCalendarId 있으면 그대로 사용
  /// 2) 캘린더 목록에서 'BrioDo' 찾기
  /// 3) 없으면 'Blendo' 찾기 (마이그레이션)
  /// 4) 둘 다 없으면 새로 'BrioDo' 생성
  Future<String?> findOrCreateBrioDoCalendar() async {
    if (_cachedCalendarId != null) return _cachedCalendarId;
    final api = await _api();
    if (api == null) return null;

    final list = await api.calendarList.list();
    String? brioDo;
    String? blendo;
    for (final c in list.items ?? const <gcal.CalendarListEntry>[]) {
      if (c.summary == _calendarPrimary) {
        brioDo = c.id;
      } else if (c.summary == _calendarLegacy) {
        blendo = c.id;
      }
    }
    final found = brioDo ?? blendo;
    if (found != null) {
      _cachedCalendarId = found;
      return found;
    }

    final created = await api.calendars.insert(
      gcal.Calendar()..summary = _calendarPrimary,
    );
    _cachedCalendarId = created.id;
    return created.id;
  }

  /// todo 하나를 캘린더에 push (생성 or 업데이트).
  /// 시간 없음(종일) todo 처리:
  ///   - syncNoTimePolicy == 'allday' → all-day event로 push
  ///   - syncNoTimePolicy == 'skip' → 아무것도 안 함
  Future<void> pushTodo(Todo todo, {String syncNoTimePolicy = 'allday'}) async {
    if (todo.time.isEmpty && syncNoTimePolicy == 'skip') return;

    final api = await _api();
    if (api == null) return;
    final calId = await findOrCreateBrioDoCalendar();
    if (calId == null) return;

    final existingId = await _findEventIdForTodo(api, calId, todo.id);
    final event = _toEvent(todo);

    if (existingId == null) {
      await api.events.insert(event, calId);
    } else {
      await api.events.update(event, calId, existingId);
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final api = await _api();
    if (api == null) return;
    final calId = await findOrCreateBrioDoCalendar();
    if (calId == null) return;
    final eventId = await _findEventIdForTodo(api, calId, todoId);
    if (eventId == null) return;
    await api.events.delete(calId, eventId);
  }

  /// 캘린더에서 events를 한 번 pull. 각 event 마다 작업을 위임 (호출 측 fold).
  Future<List<gcal.Event>> pullEvents({DateTime? since}) async {
    final api = await _api();
    if (api == null) return const [];
    final calId = await findOrCreateBrioDoCalendar();
    if (calId == null) return const [];
    final events = await api.events.list(
      calId,
      timeMin: since?.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
      maxResults: 500,
    );
    return events.items ?? const [];
  }

  Future<String?> _findEventIdForTodo(
    gcal.CalendarApi api,
    String calId,
    String todoId,
  ) async {
    final events = await api.events.list(
      calId,
      privateExtendedProperty: ['$_todoIdKey=$todoId'],
      maxResults: 1,
    );
    final items = events.items;
    if (items == null || items.isEmpty) return null;
    return items.first.id;
  }

  gcal.Event _toEvent(Todo todo) {
    final ev = gcal.Event()
      ..summary = todo.text
      ..description = todo.description.isEmpty ? null : todo.description
      ..extendedProperties = (gcal.EventExtendedProperties()
        ..private = {_todoIdKey: todo.id});

    final dateParts = todo.date.split('-');
    if (dateParts.length != 3) return ev;
    final y = int.tryParse(dateParts[0]) ?? 2026;
    final m = int.tryParse(dateParts[1]) ?? 1;
    final d = int.tryParse(dateParts[2]) ?? 1;

    if (todo.time.isEmpty) {
      // all-day event
      final start = DateTime(y, m, d);
      final end = start.add(const Duration(days: 1));
      ev.start = gcal.EventDateTime()..date = start;
      ev.end = gcal.EventDateTime()..date = end;
    } else {
      final tp = todo.time.split(':');
      final hh = int.tryParse(tp[0]) ?? 9;
      final mm = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;
      final start = DateTime(y, m, d, hh, mm);
      final end = start.add(const Duration(hours: 1));
      ev.start = gcal.EventDateTime()..dateTime = start;
      ev.end = gcal.EventDateTime()..dateTime = end;
    }
    return ev;
  }
}
