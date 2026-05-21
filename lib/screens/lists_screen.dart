import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 태그별 그룹 뷰. 각 태그 카드 → 그 태그의 todos.
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  /// 태그 문자열 해시로 안정적인 색상 (Material 톤).
  Color _tagColor(String tag, ColorScheme cs) {
    final h = tag.hashCode.abs() % 360;
    return HSLColor.fromAHSL(1, h.toDouble(), 0.45, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.lists)),
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
            return Center(child: Text(l.noTags));
          }
          final entries = tagMap.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              final color = _tagColor(e.key, theme.colorScheme);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _TagDetailScreen(tag: e.key, todos: e.value),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '#${e.key}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          l.todosCount(e.value.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TagDetailScreen extends StatelessWidget {
  const _TagDetailScreen({required this.tag, required this.todos});

  final String tag;
  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...todos]
      ..sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        return b.date.compareTo(a.date);
      });
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: ListView.separated(
        itemCount: sorted.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final t = sorted[i];
          return ListTile(
            title: Text(
              t.text,
              style: t.completed
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.outline,
                    )
                  : null,
            ),
            subtitle: Text(
              [
                t.date,
                if (t.time.isNotEmpty) t.time,
              ].join('  '),
              style: theme.textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }
}
