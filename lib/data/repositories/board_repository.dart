import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/failures.dart';
import '../../core/services/supabase_service.dart';
import '../models/board_model.dart';
import '../models/board_column_model.dart';

abstract class BoardRepository {
  Future<Either<Failure, List<BoardModel>>> getBoards(String projectId);
  Future<Either<Failure, BoardModel>> getBoard(String boardId);
  Future<Either<Failure, BoardModel>> createBoard(BoardModel board);
  Future<Either<Failure, BoardModel>> updateBoard(BoardModel board);
  Future<Either<Failure, void>> deleteBoard(String boardId);
  Stream<List<BoardModel>> watchBoards(String projectId);
  
  // Columns
  Future<Either<Failure, List<BoardColumnModel>>> getColumns(String boardId);
  Future<Either<Failure, BoardColumnModel>> createColumn(BoardColumnModel column);
  Future<Either<Failure, BoardColumnModel>> updateColumn(BoardColumnModel column);
  Future<Either<Failure, void>> deleteColumn(String columnId);
  Future<Either<Failure, void>> reorderColumns(String boardId, List<String> columnIds);
  Stream<List<BoardColumnModel>> watchColumns(String boardId);
}

class BoardRepositoryImpl implements BoardRepository {
  final SupabaseClient _supabase;

  BoardRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<Either<Failure, List<BoardModel>>> getBoards(String projectId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.boardsTable)
          .select()
          .eq('project_id', projectId)
          .order('position');

      return Right(
        (response as List).map((e) => BoardModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BoardModel>> getBoard(String boardId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.boardsTable)
          .select()
          .eq('id', boardId)
          .single();

      return Right(BoardModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BoardModel>> createBoard(BoardModel board) async {
    try {
      final response = await _supabase
          .from(SupabaseService.boardsTable)
          .insert(board.toInsertJson())
          .select()
          .single();

      final createdBoard = BoardModel.fromJson(response);

      // Create default columns
      await _createDefaultColumns(createdBoard.id);

      return Right(createdBoard);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<void> _createDefaultColumns(String boardId) async {
    final defaultColumns = [
      {'name': 'To Do', 'position': 0, 'color_hex': '#E2E8F0', 'type': 'todo'},
      {'name': 'In Progress', 'position': 1, 'color_hex': '#DDD6FE', 'type': 'in_progress'},
      {'name': 'Review', 'position': 2, 'color_hex': '#FED7AA', 'type': 'review'},
      {'name': 'Done', 'position': 3, 'color_hex': '#BBF7D0', 'type': 'done'},
    ];

    for (final column in defaultColumns) {
      await _supabase.from(SupabaseService.columnsTable).insert({
        'board_id': boardId,
        ...column,
      });
    }
  }

  @override
  Future<Either<Failure, BoardModel>> updateBoard(BoardModel board) async {
    try {
      final response = await _supabase
          .from(SupabaseService.boardsTable)
          .update({
            'name': board.name,
            'position': board.position,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', board.id)
          .select()
          .single();

      return Right(BoardModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoard(String boardId) async {
    try {
      await _supabase
          .from(SupabaseService.boardsTable)
          .delete()
          .eq('id', boardId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<BoardModel>> watchBoards(String projectId) {
    return _supabase
        .from(SupabaseService.boardsTable)
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('position')
        .map((data) => data.map((e) => BoardModel.fromJson(e)).toList());
  }

  // Columns
  @override
  Future<Either<Failure, List<BoardColumnModel>>> getColumns(String boardId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.columnsTable)
          .select()
          .eq('board_id', boardId)
          .order('position');

      return Right(
        (response as List).map((e) => BoardColumnModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BoardColumnModel>> createColumn(BoardColumnModel column) async {
    try {
      final response = await _supabase
          .from(SupabaseService.columnsTable)
          .insert(column.toInsertJson())
          .select()
          .single();

      return Right(BoardColumnModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BoardColumnModel>> updateColumn(BoardColumnModel column) async {
    try {
      final response = await _supabase
          .from(SupabaseService.columnsTable)
          .update({
            'name': column.name,
            'color_hex': column.colorHex,
            'task_limit': column.taskLimit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', column.id)
          .select()
          .single();

      return Right(BoardColumnModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteColumn(String columnId) async {
    try {
      await _supabase
          .from(SupabaseService.columnsTable)
          .delete()
          .eq('id', columnId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderColumns(
    String boardId,
    List<String> columnIds,
  ) async {
    try {
      for (int i = 0; i < columnIds.length; i++) {
        await _supabase
            .from(SupabaseService.columnsTable)
            .update({'position': i})
            .eq('id', columnIds[i]);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<BoardColumnModel>> watchColumns(String boardId) {
    return _supabase
        .from(SupabaseService.columnsTable)
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .order('position')
        .map((data) => data.map((e) => BoardColumnModel.fromJson(e)).toList());
  }
}

