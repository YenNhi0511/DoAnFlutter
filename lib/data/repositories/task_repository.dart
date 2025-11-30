import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/failures.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskModel>>> getTasks(String columnId);
  Future<Either<Failure, List<TaskModel>>> getTasksByBoard(String boardId);
  Future<Either<Failure, List<TaskModel>>> getTasksByProject(String projectId);
  Future<Either<Failure, TaskModel>> getTask(String taskId);
  Future<Either<Failure, TaskModel>> createTask(TaskModel task);
  Future<Either<Failure, TaskModel>> updateTask(TaskModel task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> moveTask(
      String taskId, String newColumnId, int newPosition);
  Future<Either<Failure, void>> reorderTasks(
      String columnId, List<String> taskIds);
  Stream<List<TaskModel>> watchTasks(String columnId);
  Stream<List<TaskModel>> watchBoardTasks(String boardId);
  // Attachments
  Future<Either<Failure, String>> uploadAttachment(dynamic file);
  Future<Either<Failure, void>> addAttachmentToTask(String taskId, String url);

  // Comments
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId);
  Future<Either<Failure, CommentModel>> addComment(CommentModel comment);
  Future<Either<Failure, CommentModel>> updateComment(CommentModel comment);
  Future<Either<Failure, void>> deleteComment(String commentId);
  Stream<List<CommentModel>> watchComments(String taskId);

  // Search & Filter
  Future<Either<Failure, List<TaskModel>>> searchTasks(
      String projectId, String query);
  Future<Either<Failure, List<TaskModel>>> getOverdueTasks(String userId);
  Future<Either<Failure, List<TaskModel>>> getUpcomingTasks(
      String userId, int days);
  Future<Either<Failure, List<TaskModel>>> getAssignedTasks(String userId);
}

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseClient _supabase;

  TaskRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(String columnId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('column_id', columnId)
          .order('position');

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasksByBoard(
      String boardId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('board_id', boardId)
          .order('position');

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasksByProject(
      String projectId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> getTask(String taskId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('id', taskId)
          .single();

      return Right(TaskModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .insert(task.toInsertJson())
          .select()
          .single();

      return Right(TaskModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> updateTask(TaskModel task) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .update({
            'title': task.title,
            'description': task.description,
            'priority': task.priorityString,
            'due_date': task.dueDate?.toIso8601String(),
            'assignee_id': task.assigneeId,
            'label_ids': task.labelIds,
            'attachment_urls': task.attachmentUrls,
            'is_completed': task.isCompleted,
            'completed_at': task.completedAt?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', task.id)
          .select()
          .single();

      return Right(TaskModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _supabase
          .from(SupabaseService.tasksTable)
          .delete()
          .eq('id', taskId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> moveTask(
    String taskId,
    String newColumnId,
    int newPosition,
  ) async {
    try {
      // Call server-side RPC to handle atomic reordering
      final res = await _supabase.rpc('move_task_atomic', params: {
        'task_uuid': taskId,
        'new_column': newColumnId,
        'new_pos': newPosition,
      });
      // Some supabase client versions return a response object from rpc; if so, handle res.error
      // If rpc doesn't return a response, this will still succeed.

      // Note: If your supabase client returns data directly, you can ignore 'res'

      if (res.error != null) {
        return Left(ServerFailure(message: res.error!.message));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderTasks(
    String columnId,
    List<String> taskIds,
  ) async {
    try {
      for (int i = 0; i < taskIds.length; i++) {
        await _supabase
            .from(SupabaseService.tasksTable)
            .update({'position': i}).eq('id', taskIds[i]);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAttachment(dynamic file) async {
    try {
      // Delegate to StorageService
      // StorageService.uploadAttachment expects a File instance on mobile
      // We accept dynamic to support different file representations (File, XFile etc.)
      final f = file as File;
      final url = await StorageService.uploadAttachment(f);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAttachmentToTask(
      String taskId, String url) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select('attachment_urls')
          .eq('id', taskId)
          .single();

      List<String> urls = [];
      if (response['attachment_urls'] != null) {
        urls = (response['attachment_urls'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }

      urls.add(url);

      await _supabase
          .from(SupabaseService.tasksTable)
          .update({'attachment_urls': urls}).eq('id', taskId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<TaskModel>> watchTasks(String columnId) {
    return _supabase
        .from(SupabaseService.tasksTable)
        .stream(primaryKey: ['id'])
        .eq('column_id', columnId)
        .order('position')
        .map((data) => data.map((e) => TaskModel.fromJson(e)).toList());
  }

  @override
  Stream<List<TaskModel>> watchBoardTasks(String boardId) {
    return _supabase
        .from(SupabaseService.tasksTable)
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .order('position')
        .map((data) => data.map((e) => TaskModel.fromJson(e)).toList());
  }

  // Comments
  @override
  Future<Either<Failure, List<CommentModel>>> getComments(String taskId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.commentsTable)
          .select()
          .eq('task_id', taskId)
          .order('created_at');

      return Right(
        (response as List).map((e) => CommentModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addComment(CommentModel comment) async {
    try {
      final response = await _supabase
          .from(SupabaseService.commentsTable)
          .insert(comment.toInsertJson())
          .select()
          .single();

      return Right(CommentModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> updateComment(
      CommentModel comment) async {
    try {
      final response = await _supabase
          .from(SupabaseService.commentsTable)
          .update({
            'content': comment.content,
            'is_edited': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', comment.id)
          .select()
          .single();

      return Right(CommentModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await _supabase
          .from(SupabaseService.commentsTable)
          .delete()
          .eq('id', commentId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<CommentModel>> watchComments(String taskId) {
    return _supabase
        .from(SupabaseService.commentsTable)
        .stream(primaryKey: ['id'])
        .eq('task_id', taskId)
        .order('created_at')
        .map((data) => data.map((e) => CommentModel.fromJson(e)).toList());
  }

  // Search & Filter
  @override
  Future<Either<Failure, List<TaskModel>>> searchTasks(
    String projectId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('project_id', projectId)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('updated_at', ascending: false);

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getOverdueTasks(
      String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('assignee_id', userId)
          .eq('is_completed', false)
          .lt('due_date', now)
          .order('due_date');

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getUpcomingTasks(
    String userId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final future = now.add(Duration(days: days));

      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('assignee_id', userId)
          .eq('is_completed', false)
          .gte('due_date', now.toIso8601String())
          .lte('due_date', future.toIso8601String())
          .order('due_date');

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getAssignedTasks(
      String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.tasksTable)
          .select()
          .eq('assignee_id', userId)
          .eq('is_completed', false)
          .order('due_date');

      return Right(
        (response as List).map((e) => TaskModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
