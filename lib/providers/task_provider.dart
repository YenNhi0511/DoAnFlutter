import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/task_model.dart';
import 'auth_provider.dart';

class TaskRepository {
  final SupabaseClient _client;
  TaskRepository(this._client);

  // Lấy task trong 1 bảng (Kanban)
  Stream<List<TaskModel>> watchBoardTasks(String boardId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .order('position')
        .map((data) => data.map((json) => TaskModel.fromJson(json)).toList());
  }

  // Lấy "Task của tôi" (Task do mình tạo hoặc được giao)
  Future<List<TaskModel>> getMyTasks(String userId) async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('created_by_id', userId)
        .order('due_date', ascending: true);
    return data.map((json) => TaskModel.fromJson(json)).toList();
  }

  // Lấy Task sắp đến hạn (cho Calendar/Home)
  Future<List<TaskModel>> getUpcomingTasks(String userId, int days) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    final data = await _client
        .from('tasks')
        .select()
        .eq('created_by_id', userId)
        .gte('due_date', now.toIso8601String())
        .lte('due_date', future.toIso8601String())
        .order('due_date');
    return data.map((json) => TaskModel.fromJson(json)).toList();
  }

  // Lấy TẤT CẢ Task của user (cho Calendar)
  Future<List<TaskModel>> getAllTasks(String userId) async {
    final data =
        await _client.from('tasks').select().eq('created_by_id', userId);
    return data.map((json) => TaskModel.fromJson(json)).toList();
  }

  // Lấy Task QUÁ HẠN (cho My Tasks)
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    final now = DateTime.now();
    final data = await _client
        .from('tasks')
        .select()
        .eq('created_by_id', userId)
        .lt('due_date',
            now.toIso8601String()) // lt = less than (nhỏ hơn ngày hiện tại)
        .order('due_date');
    return data.map((json) => TaskModel.fromJson(json)).toList();
  }

  // Lấy CHI TIẾT 1 Task
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final data =
          await _client.from('tasks').select().eq('id', taskId).single();
      return TaskModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Tạo Task mới
  Future<TaskModel> createTask(TaskModel task) async {
    final data =
        await _client.from('tasks').insert(task.toJson()).select().single();
    return TaskModel.fromJson(data);
  }

  // Cập nhật Task
  Future<void> updateTask(TaskModel task) async {
    await _client.from('tasks').update(task.toJson()).eq('id', task.id);
  }

  // Xóa Task
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  Future<void> updateTaskPosition(
      String taskId, String columnId, int newIndex) async {
    await _client.from('tasks').update({
      'column_id': columnId,
      'position': newIndex,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }
}

// --- PROVIDERS ---

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Supabase.instance.client);
});

final boardTasksStreamProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, boardId) {
  return ref.watch(taskRepositoryProvider).watchBoardTasks(boardId);
});

final assignedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(taskRepositoryProvider).getMyTasks(user.id);
});

final upcomingTasksProvider =
    FutureProvider.family<List<TaskModel>, int>((ref, days) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(taskRepositoryProvider).getUpcomingTasks(user.id, days);
});

// Provider lấy chi tiết task (dùng cho TaskDetailScreen)
final taskProvider =
    FutureProvider.family<TaskModel?, String>((ref, taskId) async {
  return ref.watch(taskRepositoryProvider).getTask(taskId);
});

// Provider lấy tất cả task (dùng cho CalendarScreen)
final allTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(taskRepositoryProvider).getAllTasks(user.id);
});

// Provider lấy task quá hạn (dùng cho MyTasksScreen)
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(taskRepositoryProvider).getOverdueTasks(user.id);
});

// --- NOTIFIER ---

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repo;
  final String _boardId;

  TaskNotifier(this._repo, this._boardId) : super(const AsyncValue.data(null));

  Future<TaskModel?> createTask({
    required String columnId,
    required String projectId,
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? dueDate,
    List<String>? attachmentUrls,
    required String createdById,
  }) async {
    try {
      final newTask = TaskModel(
        id: '',
        columnId: columnId,
        boardId: _boardId,
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        attachmentUrls: attachmentUrls ?? [],
        createdById: createdById,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        position: 0,
      );
      return await _repo.createTask(newTask);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> moveTask(
      String taskId, String newColumnId, int newPosition) async {
    await _repo.updateTaskPosition(taskId, newColumnId, newPosition);
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repo.updateTask(task);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repo.deleteTask(taskId);
    } catch (e) {
      // Handle error
    }
  }
}

final taskNotifierProvider =
    StateNotifierProvider.family<TaskNotifier, AsyncValue<void>, String>(
        (ref, boardId) {
  return TaskNotifier(ref.watch(taskRepositoryProvider), boardId);
});
