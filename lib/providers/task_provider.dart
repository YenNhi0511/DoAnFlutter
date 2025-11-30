import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task_model.dart';
import '../data/models/comment_model.dart';
import '../data/repositories/task_repository.dart';
import 'auth_provider.dart';

// Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

// Tasks by Column Provider
final tasksProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, columnId) async {
  final result = await ref.read(taskRepositoryProvider).getTasks(columnId);
  return result.fold((l) => [], (r) => r);
});

// Tasks Stream Provider (Real-time)
final tasksStreamProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, columnId) {
  return ref.read(taskRepositoryProvider).watchTasks(columnId);
});

// Board Tasks Stream Provider
final boardTasksStreamProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, boardId) {
  return ref.read(taskRepositoryProvider).watchBoardTasks(boardId);
});

// Single Task Provider
final taskProvider =
    FutureProvider.family<TaskModel?, String>((ref, taskId) async {
  final result = await ref.read(taskRepositoryProvider).getTask(taskId);
  return result.fold((l) => null, (r) => r);
});

// Comments Provider
final commentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, taskId) async {
  final result = await ref.read(taskRepositoryProvider).getComments(taskId);
  return result.fold((l) => [], (r) => r);
});

// Comments Stream Provider
final commentsStreamProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, taskId) {
  return ref.read(taskRepositoryProvider).watchComments(taskId);
});

// Assigned Tasks Provider
final assignedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final result =
          await ref.read(taskRepositoryProvider).getAssignedTasks(user.id);
      return result.fold((l) => [], (r) => r);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Overdue Tasks Provider
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final result =
          await ref.read(taskRepositoryProvider).getOverdueTasks(user.id);
      return result.fold((l) => [], (r) => r);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Upcoming Tasks Provider
final upcomingTasksProvider =
    FutureProvider.family<List<TaskModel>, int>((ref, days) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final result = await ref
          .read(taskRepositoryProvider)
          .getUpcomingTasks(user.id, days);
      return result.fold((l) => [], (r) => r);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Selected Task Provider
final selectedTaskProvider = StateProvider<TaskModel?>((ref) => null);

// Task Notifier
class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final String _boardId;

  TaskNotifier(this._repository, this._boardId)
      : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    final result = await _repository.getTasksByBoard(_boardId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (tasks) => AsyncValue.data(tasks),
    );
  }

  Future<TaskModel?> createTask({
    required String columnId,
    required String projectId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? assigneeId,
    List<String> attachmentUrls = const [],
    required String createdById,
  }) async {
    final existingTasks =
        state.valueOrNull?.where((t) => t.columnId == columnId).toList() ?? [];

    final task = TaskModel(
      id: '',
      columnId: columnId,
      boardId: _boardId,
      projectId: projectId,
      title: title,
      description: description,
      position: existingTasks.length,
      priority: priority,
      dueDate: dueDate,
      assigneeId: assigneeId,
      createdById: createdById,
      attachmentUrls: attachmentUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createTask(task);
    return result.fold(
      (failure) => null,
      (createdTask) {
        state.whenData((tasks) {
          state = AsyncValue.data([...tasks, createdTask]);
        });
        return createdTask;
      },
    );
  }

  Future<bool> updateTask(TaskModel task) async {
    final result = await _repository.updateTask(task);
    return result.fold(
      (failure) => false,
      (updatedTask) {
        state.whenData((tasks) {
          final index = tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            final updatedList = [...tasks];
            updatedList[index] = updatedTask;
            state = AsyncValue.data(updatedList);
          }
        });
        return true;
      },
    );
  }

  Future<bool> deleteTask(String taskId) async {
    final result = await _repository.deleteTask(taskId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((tasks) {
          state = AsyncValue.data(
            tasks.where((t) => t.id != taskId).toList(),
          );
        });
        return true;
      },
    );
  }

  Future<bool> moveTask(
      String taskId, String newColumnId, int newPosition) async {
    // Optimistic update
    state.whenData((tasks) {
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final updatedTask = tasks[taskIndex].copyWith(
          columnId: newColumnId,
          position: newPosition,
        );
        final updatedList = [...tasks];
        updatedList[taskIndex] = updatedTask;
        state = AsyncValue.data(updatedList);
      }
    });

    final result = await _repository.moveTask(taskId, newColumnId, newPosition);
    if (result.isLeft()) {
      await loadTasks(); // Revert on failure
      return false;
    }
    return true;
  }

  Future<void> reorderTasks(String columnId, List<String> taskIds) async {
    await _repository.reorderTasks(columnId, taskIds);
  }
}

final taskNotifierProvider = StateNotifierProvider.family<TaskNotifier,
    AsyncValue<List<TaskModel>>, String>(
  (ref, boardId) {
    return TaskNotifier(ref.watch(taskRepositoryProvider), boardId);
  },
);

// Comment Notifier
class CommentNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final TaskRepository _repository;
  final String _taskId;

  CommentNotifier(this._repository, this._taskId)
      : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    final result = await _repository.getComments(_taskId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (comments) => AsyncValue.data(comments),
    );
  }

  Future<CommentModel?> addComment({
    required String userId,
    required String content,
    List<String> attachmentUrls = const [],
  }) async {
    final comment = CommentModel(
      id: '',
      taskId: _taskId,
      userId: userId,
      content: content,
      attachmentUrls: attachmentUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.addComment(comment);
    return result.fold(
      (failure) => null,
      (createdComment) {
        state.whenData((comments) {
          state = AsyncValue.data([...comments, createdComment]);
        });
        return createdComment;
      },
    );
  }

  Future<bool> updateComment(CommentModel comment) async {
    final result = await _repository.updateComment(comment);
    return result.fold(
      (failure) => false,
      (updatedComment) {
        state.whenData((comments) {
          final index = comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            final updatedList = [...comments];
            updatedList[index] = updatedComment;
            state = AsyncValue.data(updatedList);
          }
        });
        return true;
      },
    );
  }

  Future<bool> deleteComment(String commentId) async {
    final result = await _repository.deleteComment(commentId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((comments) {
          state = AsyncValue.data(
            comments.where((c) => c.id != commentId).toList(),
          );
        });
        return true;
      },
    );
  }
}

final commentNotifierProvider = StateNotifierProvider.family<CommentNotifier,
    AsyncValue<List<CommentModel>>, String>(
  (ref, taskId) {
    return CommentNotifier(ref.watch(taskRepositoryProvider), taskId);
  },
);
