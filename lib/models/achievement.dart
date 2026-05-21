/// 4언어 이름/설명 묶음.
class LocalizedText {
  const LocalizedText(this.ko, this.en, this.ja, this.zh);
  final String ko;
  final String en;
  final String ja;
  final String zh;

  String forLocale(String code) {
    switch (code) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'zh':
        return zh;
      case 'ko':
      default:
        return ko;
    }
  }
}

class AchievementCategory {
  static const streak = 'streak';
  static const completion = 'completion';
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const recurrence = 'recurrence';
  static const tag = 'tag';
  static const subtask = 'subtask';
  static const priority = 'priority';
  static const calendar = 'calendar';
  static const notes = 'notes';
  static const special = 'special';
  static const engagement = 'engagement';

  static const all = [
    streak,
    completion,
    daily,
    weekly,
    recurrence,
    tag,
    subtask,
    priority,
    calendar,
    notes,
    special,
    engagement,
  ];
}

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.icon,
    required this.difficulty,
    required this.category,
    required this.name,
    required this.desc,
    required this.check,
  });

  final String id;
  final String icon;
  final int difficulty; // 1-10
  final String category;
  final LocalizedText name;
  final LocalizedText desc;

  /// AchievementStats를 받아 잠금 해제 조건 체크.
  final bool Function(AchievementStats) check;
}

/// todos 리스트에서 계산된 누적 통계. AchievementDef.check 가 이걸 본다.
class AchievementStats {
  const AchievementStats({
    required this.streak,
    required this.totalCompleted,
    required this.todayCompleted,
    required this.todayActive,
    required this.todayTotal,
    required this.weekCompleted,
    required this.monthCompleted,
    required this.mondayCompletions,
    required this.uniqueTagCount,
    required this.todayTagVariety,
    required this.totalSubtasksCompleted,
    required this.completedByPriority,
    required this.completedWithDescription,
    required this.hasRecurrence,
    required this.activeRecurrences,
    required this.completedRecurringCount,
    required this.perfectWeek,
    required this.special,
    required this.unlockedCount,
    required this.flags,
  });

  final int streak;
  final int totalCompleted;
  final int todayCompleted;
  final int todayActive;
  final int todayTotal;
  final int weekCompleted;
  final int monthCompleted;
  final int mondayCompletions;
  final int uniqueTagCount;
  final int todayTagVariety;
  final int totalSubtasksCompleted;
  final Map<String, int> completedByPriority;
  final int completedWithDescription;
  final bool hasRecurrence;
  final int activeRecurrences;
  final int completedRecurringCount;
  final bool perfectWeek;

  /// newYear / christmas / spring 등 today-based 플래그
  final Map<String, bool> special;

  final int unlockedCount;

  /// searchUsed / collectionVisited / calendarUsed 등 명시 플래그
  final Map<String, bool> flags;
}
