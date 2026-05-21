import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/achievements.dart';
import '../models/achievement.dart';
import '../models/todo.dart';
import 'todos_provider.dart';

/// 잠금 해제된 업적 ID 집합 + 임의 플래그 (검색 사용 등).
class AchievementState {
  const AchievementState({
    required this.unlocked,
    required this.flags,
  });

  /// 잠금 해제된 ID 집합
  final Set<String> unlocked;

  /// searchUsed / collectionVisited / calendarUsed 등 명시 플래그
  final Map<String, bool> flags;

  AchievementState copyWith({Set<String>? unlocked, Map<String, bool>? flags}) =>
      AchievementState(
        unlocked: unlocked ?? this.unlocked,
        flags: flags ?? this.flags,
      );
}

class AchievementsNotifier extends Notifier<AchievementState> {
  static const _keyUnlocked = 'achievements.unlocked';
  static const _keyFlags = 'achievements.flags';

  late SharedPreferences _prefs;

  /// 새로 잠금 해제된 정의 알림용 — UI가 listen해서 스낵바 + 축하 애니메이션.
  final _unlockController = StreamController<AchievementDef>.broadcast();
  Stream<AchievementDef> get unlockStream => _unlockController.stream;

  @override
  AchievementState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final raw = _prefs.getStringList(_keyUnlocked) ?? <String>[];
    final flagsRaw = _prefs.getStringList(_keyFlags) ?? <String>[];
    final flags = <String, bool>{};
    for (final f in flagsRaw) {
      flags[f] = true;
    }
    return AchievementState(unlocked: raw.toSet(), flags: flags);
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_keyUnlocked, state.unlocked.toList());
    await _prefs.setStringList(
      _keyFlags,
      state.flags.entries.where((e) => e.value).map((e) => e.key).toList(),
    );
  }

  Future<void> setFlag(String key) async {
    if (state.flags[key] == true) return;
    state = state.copyWith(flags: {...state.flags, key: true});
    await _persist();
    // 플래그 기반 업적도 즉시 체크.
    final list = ref.read(todosStreamProvider).asData?.value ?? const <Todo>[];
    await checkAgainst(list);
  }

  /// 현재 todos로 stats 계산 후 새로 잠금 해제될 업적이 있으면 추가.
  Future<List<AchievementDef>> checkAgainst(List<Todo> todos) async {
    final stats = _computeStats(todos, state);
    final newlyUnlocked = <AchievementDef>[];
    final next = {...state.unlocked};
    for (final def in kAchievementDefs) {
      if (next.contains(def.id)) continue;
      if (def.check(stats)) {
        next.add(def.id);
        newlyUnlocked.add(def);
      }
    }
    if (newlyUnlocked.isNotEmpty) {
      state = state.copyWith(unlocked: next);
      await _persist();
      // E1/E4/E5 같은 "unlockedCount" 기반 업적이 새 잠금 후 다시 만족할 수 있음.
      // 한 번 더 재귀 체크 (간단히 1회만).
      final stats2 = _computeStats(todos, state);
      for (final def in kAchievementDefs) {
        if (state.unlocked.contains(def.id)) continue;
        if (def.check(stats2)) {
          state = state.copyWith(unlocked: {...state.unlocked, def.id});
          newlyUnlocked.add(def);
        }
      }
      if (newlyUnlocked.isNotEmpty &&
          state.unlocked.length != next.length) {
        await _persist();
      }
      for (final def in newlyUnlocked) {
        _unlockController.add(def);
      }
    }
    return newlyUnlocked;
  }

  AchievementStats _computeStats(List<Todo> todos, AchievementState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = dateKey(today);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    int totalCompleted = 0;
    int weekCompleted = 0;
    int monthCompleted = 0;
    int mondayCompletions = 0;
    int todayCompleted = 0;
    int todayActive = 0;
    int todayTotal = 0;
    int completedRecurringCount = 0;
    int totalSubtasksCompleted = 0;
    int completedWithDescription = 0;
    final completedByPriority = <String, int>{};
    final uniqueTags = <String>{};
    final todayTags = <String>{};
    bool hasRecurrence = false;
    int activeRecurrences = 0;
    final perfectWeekDays = <String>{};

    for (final t in todos) {
      uniqueTags.addAll(t.tags);
      if (t.recurrence != 'none') {
        hasRecurrence = true;
        if (!t.completed) activeRecurrences += 1;
      }
      if (t.date == todayKey) {
        todayTotal += 1;
        if (!t.completed) {
          todayActive += 1;
        }
      }

      if (t.completed) {
        totalCompleted += 1;
        if (t.description.isNotEmpty) completedWithDescription += 1;
        totalSubtasksCompleted +=
            t.subtasks.where((s) => s.completed).length;
        completedByPriority[t.priority] =
            (completedByPriority[t.priority] ?? 0) + 1;
        if (t.recurrence != 'none') completedRecurringCount += 1;

        final d = parseDateKey(t.date);
        if (d.year == today.year && d.month == today.month) {
          monthCompleted += 1;
        }
        if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
          weekCompleted += 1;
          perfectWeekDays.add(t.date);
        }
        if (d.weekday == DateTime.monday) {
          mondayCompletions += 1;
        }
        if (t.date == todayKey) {
          todayCompleted += 1;
          todayTags.addAll(t.tags);
        }
      }
    }

    // streak — 오늘부터 거꾸로 완료 todo가 있는 날 연속.
    final dailyHas = <String, bool>{};
    for (final t in todos) {
      if (t.completed) dailyHas[t.date] = true;
    }
    int streak = 0;
    for (var i = 0; i < 400; i++) {
      final d = today.subtract(Duration(days: i));
      if (dailyHas[dateKey(d)] == true) {
        streak += 1;
      } else if (i == 0) {
        break;
      } else {
        break;
      }
    }

    final perfectWeek = perfectWeekDays.length >= 7;

    final special = <String, bool>{
      'newYear': today.month == 1 && today.day == 1 && todayCompleted > 0,
      'christmas':
          today.month == 12 && today.day == 25 && todayCompleted > 0,
      'spring': today.month == 3 && today.day == 1 && todayCompleted > 0,
    };

    return AchievementStats(
      streak: streak,
      totalCompleted: totalCompleted,
      todayCompleted: todayCompleted,
      todayActive: todayActive,
      todayTotal: todayTotal,
      weekCompleted: weekCompleted,
      monthCompleted: monthCompleted,
      mondayCompletions: mondayCompletions,
      uniqueTagCount: uniqueTags.length,
      todayTagVariety: todayTags.length,
      totalSubtasksCompleted: totalSubtasksCompleted,
      completedByPriority: completedByPriority,
      completedWithDescription: completedWithDescription,
      hasRecurrence: hasRecurrence,
      activeRecurrences: activeRecurrences,
      completedRecurringCount: completedRecurringCount,
      perfectWeek: perfectWeek,
      special: special,
      unlockedCount: state.unlocked.length,
      flags: state.flags,
    );
  }
}

final achievementsProvider =
    NotifierProvider<AchievementsNotifier, AchievementState>(
        AchievementsNotifier.new);
