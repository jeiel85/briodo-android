import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../providers/achievements_provider.dart';
import '../providers/todos_provider.dart';
import '../services/todo_actions.dart';
import '../widgets/brio_components.dart';
import '../widgets/todo_editor_sheet.dart';

/// 전문 검색 화면 — 새 BrioTodoTile 디자인.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  late final TodoActions _actions = TodoActions(ref);
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
    final cs = Theme.of(context).colorScheme;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: l.searchHint,
            hintStyle: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          onChanged: (v) {
            setState(() => _query = v.trim());
            if (_query.isNotEmpty) {
              ref.read(achievementsProvider.notifier).setFlag('searchUsed');
            }
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorPrefix(e.toString()))),
        data: (todos) {
          if (_query.isEmpty) {
            return BrioEmptyState(
              title: '검색창이 대기 중입니다',
              subtitle: '찾고 싶은 할 일, 태그, 메모의 일부 검색어를 입력해 보세요!',
              icon: Icon(
                Icons.manage_search,
                size: 54,
                color: cs.primary.withValues(alpha: 0.35),
              ),
            );
          }
          final results = todos.where((t) => _match(t, _query)).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          if (results.isEmpty) {
            return BrioEmptyState(
              title: "'$_query' 결과 없음",
              subtitle: '검색어를 잘못 입력했거나 없는 할 일입니다. 다른 키워드를 기입해 보세요!',
              icon: Icon(
                Icons.find_in_page,
                size: 54,
                color: cs.error.withValues(alpha: 0.35),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '검색된 결과 ${results.length}개',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              for (final t in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BrioTodoTile(
                    todo: t,
                    onToggle: () => _actions.toggle(t),
                    onTap: () => openTodoEditorSheet(context,
                        ref: ref, initial: t),
                    onDelete: () => _actions.delete(t),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
