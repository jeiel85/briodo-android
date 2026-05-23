import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';
import '../theme.dart';
import '../widgets/brio_components.dart';

/// 태그별 그룹 뷰 — BrioCard로 각 태그의 진행률 + 미리보기를 보여준다.
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key, this.onSelectTagDate});

  /// 미리보기 카드를 누르면 해당 날짜를 selectedDate로 잡고 홈 탭으로 점프하기 위한 콜백.
  final void Function(String date)? onSelectTagDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.lists,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
        data: (todos) {
          final tagMap = <String, List<Todo>>{};
          for (final t in todos) {
            for (final tag in t.tags) {
              tagMap.putIfAbsent(tag, () => []).add(t);
            }
          }
          if (tagMap.isEmpty) {
            return BrioEmptyState(
              title: '등록된 태그가 없습니다',
              subtitle: '할 일을 생성할 때 태그를 기입하시면 여기에 자동으로 분류됩니다!',
              icon: Icon(
                Icons.label_off_outlined,
                size: 54,
                color: cs.primary.withValues(alpha: 0.35),
              ),
            );
          }
          final entries = tagMap.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              final completed = e.value.where((t) => t.completed).length;
              final rate = e.value.isEmpty ? 0.0 : completed / e.value.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TagCard(
                  tag: e.key,
                  todos: e.value,
                  progress: rate,
                  onPick: (date) {
                    ref.read(selectedDateProvider.notifier).set(date);
                    onSelectTagDate?.call(date);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  const _TagCard({
    required this.tag,
    required this.todos,
    required this.progress,
    required this.onPick,
  });

  final String tag;
  final List<Todo> todos;
  final double progress;
  final void Function(String date) onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preview = todos.take(8).toList();
    return BrioCard(
      backgroundColor: cs.surface,
      elevation: 0.5,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.label, color: BrioColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '일정 ${todos.length}개',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        BrioColors.secondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '완료율 ${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '최근 일정 미리보기',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = preview[i];
                return GestureDetector(
                  onTap: () => onPick(t.date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            t.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              decoration: t.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: t.completed
                                  ? cs.onSurface.withValues(alpha: 0.5)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.date,
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
