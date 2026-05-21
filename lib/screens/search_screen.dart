import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todos_provider.dart';

/// 전문 검색 화면. text/description/tags에서 substring 매치.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _match(Todo t, String q) {
    if (q.isEmpty) return false;
    final ql = q.toLowerCase();
    if (t.text.toLowerCase().contains(ql)) return true;
    if (t.description.toLowerCase().contains(ql)) return true;
    if (t.tags.any((tag) => tag.toLowerCase().contains(ql))) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l.searchHint,
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
        data: (todos) {
          if (_query.isEmpty) {
            return Center(
              child: Text(
                l.searchHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            );
          }
          final results = todos.where((t) => _match(t, _query)).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          if (results.isEmpty) {
            return Center(child: Text(l.searchEmpty));
          }
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final t = results[i];
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
                    ...t.tags.map((x) => '#$x'),
                  ].join('  '),
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
