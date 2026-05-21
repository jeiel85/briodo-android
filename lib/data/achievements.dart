import '../models/achievement.dart';

/// Capacitor v1.1.17의 78개 업적 중 핵심 38개를 옮긴 정의.
/// AI 카테고리는 v1.3.0에서 드롭. 나머지는 점진 확장 가능.
const _n = LocalizedText.new;

final List<AchievementDef> kAchievementDefs = [
  // ───────── Streak (5) ─────────
  AchievementDef(
    id: 'S1', icon: '🔥', difficulty: 3, category: AchievementCategory.streak,
    name: _n('불꽃 시작', 'Hot Start', '炎の始まり', '燃烧开始'),
    desc: _n('3일 연속 최소 1개 완료', '3-day streak', '3日連続1タスク完了', '连续3天完成1件'),
    check: (s) => s.streak >= 3,
  ),
  AchievementDef(
    id: 'S2', icon: '🔥🔥', difficulty: 5, category: AchievementCategory.streak,
    name: _n('일주일 챔피언', 'Week Champion', '一週間チャンプ', '周冠军'),
    desc: _n('7일 연속 최소 1개 완료', '7-day streak', '7日連続完了', '连续7天完成'),
    check: (s) => s.streak >= 7,
  ),
  AchievementDef(
    id: 'S3', icon: '💪', difficulty: 6, category: AchievementCategory.streak,
    name: _n('2주 돌파', '2-Week Run', '2週間突破', '两周突破'),
    desc: _n('14일 연속 최소 1개 완료', '14-day streak', '14日連続完了', '连续14天完成'),
    check: (s) => s.streak >= 14,
  ),
  AchievementDef(
    id: 'S4', icon: '🏆', difficulty: 8, category: AchievementCategory.streak,
    name: _n('한달 챔피언', 'Month Champion', '月間チャンプ', '月冠军'),
    desc: _n('30일 연속 최소 1개 완료', '30-day streak', '30日連続完了', '连续30天完成'),
    check: (s) => s.streak >= 30,
  ),
  AchievementDef(
    id: 'S5', icon: '👑', difficulty: 10, category: AchievementCategory.streak,
    name: _n('100일의 기적', '100-Day Miracle', '100日の奇跡', '百日奇迹'),
    desc: _n('100일 연속 최소 1개 완료', '100-day streak', '100日連続完了', '连续100天完成'),
    check: (s) => s.streak >= 100,
  ),

  // ───────── Completion (5) ─────────
  AchievementDef(
    id: 'C1', icon: '🎉', difficulty: 1,
    category: AchievementCategory.completion,
    name: _n('첫 발걸음', 'First Step', '第一歩', '第一步'),
    desc: _n('첫 번째 할 일 완료', 'Complete your first task', '初めてタスクを完了', '完成第一件任务'),
    check: (s) => s.totalCompleted >= 1,
  ),
  AchievementDef(
    id: 'C2', icon: '⚡', difficulty: 3,
    category: AchievementCategory.completion,
    name: _n('가속 중', 'Speeding Up', '加速中', '加速中'),
    desc: _n('누적 10개 완료', '10 total completions', '累計10件完了', '累计完成10件'),
    check: (s) => s.totalCompleted >= 10,
  ),
  AchievementDef(
    id: 'C3', icon: '🎯', difficulty: 5,
    category: AchievementCategory.completion,
    name: _n('집중 모드', 'Focus Mode', '集中モード', '专注模式'),
    desc: _n('누적 50개 완료', '50 total completions', '累計50件完了', '累计完成50件'),
    check: (s) => s.totalCompleted >= 50,
  ),
  AchievementDef(
    id: 'C4', icon: '💯', difficulty: 7,
    category: AchievementCategory.completion,
    name: _n('백 개 돌파', 'Century', '百個突破', '百件突破'),
    desc: _n('누적 100개 완료', '100 total completions', '累計100件完了', '累计完成100件'),
    check: (s) => s.totalCompleted >= 100,
  ),
  AchievementDef(
    id: 'C5', icon: '🌟', difficulty: 10,
    category: AchievementCategory.completion,
    name: _n('전설의 완료자', 'Legendary Achiever', '伝説の達成者', '传奇完成者'),
    desc: _n('누적 1000개 완료', '1000 total completions', '累計1000件完了', '累计完成1000件'),
    check: (s) => s.totalCompleted >= 1000,
  ),

  // ───────── Daily (4) ─────────
  AchievementDef(
    id: 'D1', icon: '📥', difficulty: 2, category: AchievementCategory.daily,
    name: _n('인박스 제로', 'Inbox Zero', 'インボックスゼロ', '收件箱清零'),
    desc: _n('오늘 할 일 전부 완료', 'Complete all of today\'s tasks',
        '今日のタスクを全完了', '完成今天所有任务'),
    check: (s) => s.todayActive == 0 && s.todayTotal > 0,
  ),
  AchievementDef(
    id: 'D2', icon: '🎯', difficulty: 4, category: AchievementCategory.daily,
    name: _n('하루 5개', 'High Five Day', '1日5件', '一天5件'),
    desc: _n('하루에 5개 이상 완료', 'Complete 5+ tasks in one day',
        '1日に5件以上完了', '一天完成5件以上'),
    check: (s) => s.todayCompleted >= 5,
  ),
  AchievementDef(
    id: 'D3', icon: '🔟', difficulty: 6, category: AchievementCategory.daily,
    name: _n('풀가동', 'Full Power', 'フル稼働', '全力运转'),
    desc: _n('하루에 10개 이상 완료', 'Complete 10+ tasks in one day',
        '1日に10件以上完了', '一天完成10件以上'),
    check: (s) => s.todayCompleted >= 10,
  ),
  AchievementDef(
    id: 'D4', icon: '🦁', difficulty: 9, category: AchievementCategory.daily,
    name: _n('하루의 왕', 'Day King', 'その日の王', '当日之王'),
    desc: _n('하루에 20개 이상 완료', 'Complete 20+ tasks in one day',
        '1日に20件以上完了', '一天完成20件以上'),
    check: (s) => s.todayCompleted >= 20,
  ),

  // ───────── Weekly (3) ─────────
  AchievementDef(
    id: 'W1', icon: '📊', difficulty: 6, category: AchievementCategory.weekly,
    name: _n('주간 달성자', 'Weekly Achiever', '週間達成者', '周成就者'),
    desc: _n('한 주에 20개 이상 완료', '20+ completions in a week',
        '1週間に20件以上完了', '一周内完成20件以上'),
    check: (s) => s.weekCompleted >= 20,
  ),
  AchievementDef(
    id: 'W2', icon: '✨', difficulty: 9, category: AchievementCategory.weekly,
    name: _n('완벽한 일주일', 'Perfect Week', '完璧な一週間', '完美一周'),
    desc: _n('7일 모두 최소 1개 이상 완료',
        'Complete at least 1 task every day for a week', '7日全て1件以上完了',
        '一周7天每天至少完成1件'),
    check: (s) => s.perfectWeek,
  ),
  AchievementDef(
    id: 'W3', icon: '📅', difficulty: 8, category: AchievementCategory.weekly,
    name: _n('한달 꽉 채우기', 'Month Full', '月間フル', '月度满载'),
    desc: _n('한 달에 100개 이상 완료', '100+ completions in a month',
        '1ヶ月に100件以上完了', '一个月内完成100件以上'),
    check: (s) => s.monthCompleted >= 100,
  ),

  // ───────── Recurrence (2) ─────────
  AchievementDef(
    id: 'R1', icon: '🔄', difficulty: 2,
    category: AchievementCategory.recurrence,
    name: _n('루틴 시작', 'Routine Start', 'ルーティン開始', '开始例行任务'),
    desc: _n('첫 반복 일정 생성', 'Create your first recurring task',
        '初めての繰り返しタスク作成', '创建第一个重复任务'),
    check: (s) => s.hasRecurrence,
  ),
  AchievementDef(
    id: 'R2', icon: '💎', difficulty: 9,
    category: AchievementCategory.recurrence,
    name: _n('100번 반복', '100 Reps', '100回繰り返し', '100次重复'),
    desc: _n('반복 일정 누적 100회 완료', '100 total recurring completions',
        '繰り返しタスク累計100回完了', '累计完成100次重复任务'),
    check: (s) => s.completedRecurringCount >= 100,
  ),

  // ───────── Tag (3) ─────────
  AchievementDef(
    id: 'T1', icon: '🏷️', difficulty: 1, category: AchievementCategory.tag,
    name: _n('태그 입문', 'Tag Explorer', 'タグ入門', '标签入门'),
    desc: _n('첫 태그 사용', 'Use your first tag', '初めてタグを使用', '使用第一个标签'),
    check: (s) => s.uniqueTagCount >= 1,
  ),
  AchievementDef(
    id: 'T2', icon: '🗂️', difficulty: 4, category: AchievementCategory.tag,
    name: _n('분류 전문가', 'Category Pro', '分類のプロ', '分类专家'),
    desc: _n('서로 다른 태그 5가지 사용', 'Use 5 different tags',
        '5種類のタグを使用', '使用5种不同标签'),
    check: (s) => s.uniqueTagCount >= 5,
  ),
  AchievementDef(
    id: 'T3', icon: '🌈', difficulty: 6, category: AchievementCategory.tag,
    name: _n('카테고리 컬렉터', 'Category Collector', 'カテゴリコレクター', '分类收藏家'),
    desc: _n('서로 다른 태그 10가지 사용', 'Use 10 different tags',
        '10種類のタグを使用', '使用10种不同标签'),
    check: (s) => s.uniqueTagCount >= 10,
  ),

  // ───────── Subtask (2) ─────────
  AchievementDef(
    id: 'ST1', icon: '✅', difficulty: 2,
    category: AchievementCategory.subtask,
    name: _n('체크리스트 시작', 'Checklist Start', 'チェックリスト開始', '清单开始'),
    desc: _n('첫 하위 태스크 완료', 'Complete your first subtask',
        '初めてサブタスクを完了', '完成第一个子任务'),
    check: (s) => s.totalSubtasksCompleted >= 1,
  ),
  AchievementDef(
    id: 'ST2', icon: '🔍', difficulty: 7,
    category: AchievementCategory.subtask,
    name: _n('세부사항 전문가', 'Detail Expert', '細部のプロ', '细节专家'),
    desc: _n('하위 태스크 누적 50개 완료', '50 total subtask completions',
        'サブタスク累計50件完了', '累计完成50个子任务'),
    check: (s) => s.totalSubtasksCompleted >= 50,
  ),

  // ───────── Priority (3) ─────────
  AchievementDef(
    id: 'P1', icon: '🚨', difficulty: 5,
    category: AchievementCategory.priority,
    name: _n('긴급 처리반', 'Urgent Response', '緊急処理班', '紧急处理'),
    desc: _n('긴급 우선순위 5개 완료', 'Complete 5 urgent tasks',
        '緊急優先度タスクを5件完了', '完成5件紧急优先任务'),
    check: (s) => (s.completedByPriority['urgent'] ?? 0) >= 5,
  ),
  AchievementDef(
    id: 'P2', icon: '🎯', difficulty: 6,
    category: AchievementCategory.priority,
    name: _n('집중 집중', 'High Focus', '高集中', '高度专注'),
    desc: _n('높음 우선순위 10개 완료', 'Complete 10 high-priority tasks',
        '高優先度タスクを10件完了', '完成10件高优先级任务'),
    check: (s) => (s.completedByPriority['high'] ?? 0) >= 10,
  ),
  AchievementDef(
    id: 'P3', icon: '⚖️', difficulty: 3,
    category: AchievementCategory.priority,
    name: _n('균형 잡기', 'Balanced', 'バランスを保つ', '保持平衡'),
    desc: _n('4가지 우선순위 각 1개씩 완료',
        'Complete 1 task at each priority level', '4種類の優先度を各1件完了',
        '完成每种优先级各1件'),
    check: (s) =>
        (s.completedByPriority['low'] ?? 0) >= 1 &&
        (s.completedByPriority['medium'] ?? 0) >= 1 &&
        (s.completedByPriority['high'] ?? 0) >= 1 &&
        (s.completedByPriority['urgent'] ?? 0) >= 1,
  ),

  // ───────── Calendar (2) ─────────
  AchievementDef(
    id: 'CAL1', icon: '📆', difficulty: 2,
    category: AchievementCategory.calendar,
    name: _n('캘린더 연동', 'Calendar Sync', 'カレンダー連携', '日历同步'),
    desc: _n('Google Calendar 첫 연동', 'Sync with Google Calendar',
        'Googleカレンダーと初めて連携', '首次与Google日历同步'),
    check: (s) => s.flags['calendarUsed'] ?? false,
  ),
  AchievementDef(
    id: 'CAL2', icon: '🔗', difficulty: 6,
    category: AchievementCategory.calendar,
    name: _n('동기화 유지', 'Sync Maintained', '同期維持', '保持同步'),
    desc: _n('캘린더 연동으로 7일 이상 사용', 'Use with calendar sync for 7+ days',
        'カレンダー連携で7日以上使用', '保持日历同步使用7天以上'),
    check: (s) => s.flags['calendarMaintained'] ?? false,
  ),

  // ───────── Notes (2) ─────────
  AchievementDef(
    id: 'N1', icon: '📖', difficulty: 4, category: AchievementCategory.notes,
    name: _n('스토리텔러', 'Storyteller', 'ストーリーテラー', '故事讲述者'),
    desc: _n('설명이 있는 할 일 10개 완료',
        'Complete 10 tasks with descriptions', '説明付きタスクを10件完了',
        '完成10件带描述的任务'),
    check: (s) => s.completedWithDescription >= 10,
  ),
  AchievementDef(
    id: 'N2', icon: '🖊️', difficulty: 7, category: AchievementCategory.notes,
    name: _n('기록의 달인', 'Note Master', '記録の達人', '记录达人'),
    desc: _n('설명 포함 할 일 50개 완료',
        'Complete 50 tasks with descriptions', '説明付きタスクを50件完了',
        '完成50件带描述的任务'),
    check: (s) => s.completedWithDescription >= 50,
  ),

  // ───────── Special (3) ─────────
  AchievementDef(
    id: 'SP1', icon: '🎆', difficulty: 4,
    category: AchievementCategory.special,
    name: _n('새해 결심', 'New Year Resolution', '新年の決意', '新年决心'),
    desc: _n('1월 1일에 할 일 완료', 'Complete a task on January 1st',
        '1月1日にタスクを完了', '在1月1日完成任务'),
    check: (s) => s.special['newYear'] ?? false,
  ),
  AchievementDef(
    id: 'SP2', icon: '🎄', difficulty: 4,
    category: AchievementCategory.special,
    name: _n('크리스마스 달성', 'Christmas Done', 'クリスマス達成', '圣诞节完成'),
    desc: _n('12월 25일에 할 일 완료', 'Complete a task on December 25th',
        '12月25日にタスクを完了', '在12月25日完成任务'),
    check: (s) => s.special['christmas'] ?? false,
  ),
  AchievementDef(
    id: 'SP3', icon: '🌸', difficulty: 4,
    category: AchievementCategory.special,
    name: _n('봄의 시작', 'Spring Start', '春の始まり', '春天开始'),
    desc: _n('3월 1일에 할 일 완료', 'Complete a task on March 1st',
        '3月1日にタスクを完了', '在3月1日完成任务'),
    check: (s) => s.special['spring'] ?? false,
  ),

  // ───────── Engagement (5) ─────────
  AchievementDef(
    id: 'E1', icon: '🎖️', difficulty: 1,
    category: AchievementCategory.engagement,
    name: _n('첫 업적', 'First Badge', '最初の実績', '第一个成就'),
    desc: _n('첫 번째 업적 달성', 'Unlock your first achievement',
        '初めての実績解除', '解锁第一个成就'),
    check: (s) => s.unlockedCount >= 1,
  ),
  AchievementDef(
    id: 'E2', icon: '🔎', difficulty: 2,
    category: AchievementCategory.engagement,
    name: _n('탐색자', 'Explorer', '探検者', '探索者'),
    desc: _n('검색 기능 첫 사용', 'Use the search feature first time',
        '検索機能を初めて使用', '首次使用搜索功能'),
    check: (s) => s.flags['searchUsed'] ?? false,
  ),
  AchievementDef(
    id: 'E3', icon: '⭐', difficulty: 3,
    category: AchievementCategory.engagement,
    name: _n('컬렉션 탐험가', 'Collection Explorer', 'コレクション探検家',
        '收藏探险家'),
    desc: _n('컬렉션 뷰 처음 방문', 'Visit the collections view',
        'コレクションビューを初めて訪問', '首次访问收藏视图'),
    check: (s) => s.flags['collectionVisited'] ?? false,
  ),
  AchievementDef(
    id: 'E4', icon: '🏅', difficulty: 7,
    category: AchievementCategory.engagement,
    name: _n('업적 수집가', 'Achievement Collector', '実績コレクター',
        '成就收集家'),
    desc: _n('10개 이상 업적 달성', 'Unlock 10 or more achievements',
        '10個以上の実績を解除', '解锁10个以上成就'),
    check: (s) => s.unlockedCount >= 10,
  ),
  AchievementDef(
    id: 'E5', icon: '🌟', difficulty: 9,
    category: AchievementCategory.engagement,
    name: _n('업적 마스터', 'Achievement Master', '実績マスター', '成就大师'),
    desc: _n('30개 이상 업적 달성', 'Unlock 30 or more achievements',
        '30個以上の実績を解除', '解锁30个以上成就'),
    check: (s) => s.unlockedCount >= 30,
  ),
];
