import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Model đơn giản cho Comment (Nếu bạn chưa có file model riêng)
class CommentModel {
  final String id;
  final String taskId;
  final String userId;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      taskId: json['task_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Repository
class CommentRepository {
  final SupabaseClient _client;
  CommentRepository(this._client);

  Stream<List<CommentModel>> watchTaskComments(String taskId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('task_id', taskId)
        .order('created_at')
        .map(
            (data) => data.map((json) => CommentModel.fromJson(json)).toList());
  }

  Future<void> addComment(String taskId, String userId, String content) async {
    await _client.from('comments').insert({
      'task_id': taskId,
      'user_id': userId,
      'content': content,
    });
  }
}

final commentRepositoryProvider =
    Provider((ref) => CommentRepository(Supabase.instance.client));

// Provider lấy danh sách comment
final commentsStreamProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, taskId) {
  return ref.watch(commentRepositoryProvider).watchTaskComments(taskId);
});

// Notifier xử lý thêm comment
class CommentNotifier extends StateNotifier<AsyncValue<void>> {
  final CommentRepository _repo;
  final String _taskId;
  final String? _userId;

  CommentNotifier(this._repo, this._taskId, this._userId)
      : super(const AsyncValue.data(null));

  Future<void> addComment(String content) async {
    if (_userId == null) return;
    try {
      await _repo.addComment(_taskId, _userId!, content);
    } catch (e) {
      // Handle error
    }
  }
}

final commentNotifierProvider =
    StateNotifierProvider.family<CommentNotifier, AsyncValue<void>, String>(
        (ref, taskId) {
  final user = ref.watch(authStateProvider).value;
  return CommentNotifier(
      ref.watch(commentRepositoryProvider), taskId, user?.id);
});
