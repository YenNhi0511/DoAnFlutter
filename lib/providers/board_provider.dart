import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/board_model.dart';
import '../data/models/board_column_model.dart';
import '../data/repositories/board_repository.dart';

// Repository Provider
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  return BoardRepositoryImpl();
});

// Boards List Provider
final boardsProvider = FutureProvider.family<List<BoardModel>, String>((ref, projectId) async {
  final result = await ref.read(boardRepositoryProvider).getBoards(projectId);
  return result.fold((l) => [], (r) => r);
});

// Boards Stream Provider (Real-time)
final boardsStreamProvider = StreamProvider.family<List<BoardModel>, String>((ref, projectId) {
  return ref.read(boardRepositoryProvider).watchBoards(projectId);
});

// Single Board Provider
final boardProvider = FutureProvider.family<BoardModel?, String>((ref, boardId) async {
  final result = await ref.read(boardRepositoryProvider).getBoard(boardId);
  return result.fold((l) => null, (r) => r);
});

// Columns Provider
final columnsProvider = FutureProvider.family<List<BoardColumnModel>, String>((ref, boardId) async {
  final result = await ref.read(boardRepositoryProvider).getColumns(boardId);
  return result.fold((l) => [], (r) => r);
});

// Columns Stream Provider (Real-time)
final columnsStreamProvider = StreamProvider.family<List<BoardColumnModel>, String>((ref, boardId) {
  return ref.read(boardRepositoryProvider).watchColumns(boardId);
});

// Selected Board Provider
final selectedBoardProvider = StateProvider<BoardModel?>((ref) => null);

// Board Notifier
class BoardNotifier extends StateNotifier<AsyncValue<List<BoardModel>>> {
  final BoardRepository _repository;
  final String _projectId;

  BoardNotifier(this._repository, this._projectId) : super(const AsyncValue.loading()) {
    loadBoards();
  }

  Future<void> loadBoards() async {
    state = const AsyncValue.loading();
    final result = await _repository.getBoards(_projectId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (boards) => AsyncValue.data(boards),
    );
  }

  Future<BoardModel?> createBoard(String name) async {
    final existingBoards = state.valueOrNull ?? [];
    final board = BoardModel(
      id: '',
      projectId: _projectId,
      name: name,
      position: existingBoards.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createBoard(board);
    return result.fold(
      (failure) => null,
      (createdBoard) {
        state.whenData((boards) {
          state = AsyncValue.data([...boards, createdBoard]);
        });
        return createdBoard;
      },
    );
  }

  Future<bool> updateBoard(BoardModel board) async {
    final result = await _repository.updateBoard(board);
    return result.fold(
      (failure) => false,
      (updatedBoard) {
        state.whenData((boards) {
          final index = boards.indexWhere((b) => b.id == board.id);
          if (index != -1) {
            final updatedList = [...boards];
            updatedList[index] = updatedBoard;
            state = AsyncValue.data(updatedList);
          }
        });
        return true;
      },
    );
  }

  Future<bool> deleteBoard(String boardId) async {
    final result = await _repository.deleteBoard(boardId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((boards) {
          state = AsyncValue.data(
            boards.where((b) => b.id != boardId).toList(),
          );
        });
        return true;
      },
    );
  }
}

final boardNotifierProvider =
    StateNotifierProvider.family<BoardNotifier, AsyncValue<List<BoardModel>>, String>(
  (ref, projectId) {
    return BoardNotifier(ref.watch(boardRepositoryProvider), projectId);
  },
);

// Column Notifier
class ColumnNotifier extends StateNotifier<AsyncValue<List<BoardColumnModel>>> {
  final BoardRepository _repository;
  final String _boardId;

  ColumnNotifier(this._repository, this._boardId) : super(const AsyncValue.loading()) {
    loadColumns();
  }

  Future<void> loadColumns() async {
    state = const AsyncValue.loading();
    final result = await _repository.getColumns(_boardId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (columns) => AsyncValue.data(columns),
    );
  }

  Future<BoardColumnModel?> createColumn({
    required String name,
    required String colorHex,
    int? taskLimit,
  }) async {
    final existingColumns = state.valueOrNull ?? [];
    final column = BoardColumnModel(
      id: '',
      boardId: _boardId,
      name: name,
      position: existingColumns.length,
      colorHex: colorHex,
      taskLimit: taskLimit,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createColumn(column);
    return result.fold(
      (failure) => null,
      (createdColumn) {
        state.whenData((columns) {
          state = AsyncValue.data([...columns, createdColumn]);
        });
        return createdColumn;
      },
    );
  }

  Future<bool> updateColumn(BoardColumnModel column) async {
    final result = await _repository.updateColumn(column);
    return result.fold(
      (failure) => false,
      (updatedColumn) {
        state.whenData((columns) {
          final index = columns.indexWhere((c) => c.id == column.id);
          if (index != -1) {
            final updatedList = [...columns];
            updatedList[index] = updatedColumn;
            state = AsyncValue.data(updatedList);
          }
        });
        return true;
      },
    );
  }

  Future<bool> deleteColumn(String columnId) async {
    final result = await _repository.deleteColumn(columnId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((columns) {
          state = AsyncValue.data(
            columns.where((c) => c.id != columnId).toList(),
          );
        });
        return true;
      },
    );
  }

  Future<void> reorderColumns(List<String> columnIds) async {
    await _repository.reorderColumns(_boardId, columnIds);
    await loadColumns();
  }
}

final columnNotifierProvider =
    StateNotifierProvider.family<ColumnNotifier, AsyncValue<List<BoardColumnModel>>, String>(
  (ref, boardId) {
    return ColumnNotifier(ref.watch(boardRepositoryProvider), boardId);
  },
);

