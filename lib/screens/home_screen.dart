import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';

/// 오늘 할 일 리스트 + FAB.
/// 패턴 예시 — 다른 화면도 ConsumerWidget + ref.watch(provider) 형태로 작성.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _todayStr() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(todosRepositoryProvider);
    if (repo == null) return;

    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('할 일 추가'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '내용을 입력하세요'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (text == null || text.isEmpty) return;
    await repo.add(text: text, date: _todayStr());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosStreamProvider);
    final repo = ref.read(todosRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrioDo'),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout),
            onPressed: () => signOutCompletely(),
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('오류: $err')),
        data: (todos) {
          // 오늘 + 미완료 우선
          final today = _todayStr();
          final filtered = todos.where((t) => t.date == today).toList()
            ..sort((a, b) {
              if (a.completed != b.completed) return a.completed ? 1 : -1;
              return a.time.compareTo(b.time);
            });

          if (filtered.isEmpty) {
            return const Center(
              child: Text('오늘 할 일이 없어요\n+ 버튼으로 추가하세요',
                  textAlign: TextAlign.center),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final t = filtered[i];
              return Dismissible(
                key: ValueKey(t.id),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => repo?.delete(t.id),
                child: CheckboxListTile(
                  value: t.completed,
                  onChanged: (_) => repo?.toggleComplete(t),
                  title: Text(
                    t.text,
                    style: t.completed
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  subtitle: t.time.isEmpty ? null : Text(t.time),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
