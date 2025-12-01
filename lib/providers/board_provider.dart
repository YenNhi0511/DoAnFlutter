import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/board_model.dart';
import '../data/models/board_column_model.dart';

// --- REPOSITORY (Xử lý gọi Database) ---
class BoardRepository {
  final SupabaseClient _client;
  BoardRepository(this._client);

  // Lấy danh sách Bảng theo Dự án (Realtime)
  Stream<List<BoardModel>> watchBoards(String projectId) {
    return _client
        .from('boards')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at')
        .map((data) => data.map((json) => BoardModel.fromJson(json)).toList());
  }

  // Lấy danh sách Cột theo Bảng (Realtime)
  Stream<List<BoardColumnModel>> watchColumns(String boardId) {
    return _client
        .from('board_columns')
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .order('position')
        .map((data) =>
            data.map((json) => BoardColumnModel.fromJson(json)).toList());
  }

  // Lấy chi tiết 1 Bảng
  Future<BoardModel?> getBoard(String boardId) async {
    try {
      final data =
          await _client.from('boards').select().eq('id', boardId).single();
      return BoardModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Tạo Bảng mới
  Future<void> createBoard(String projectId, String name) async {
    await _client.from('boards').insert({
      'project_id': projectId,
      'name': name,
    });
  }

  // Xóa Bảng
  Future<void> deleteBoard(String boardId) async {
    await _client.from('boards').delete().eq('id', boardId);
  }

  // Tạo Cột mới
  Future<void> createColumn(String boardId, String name, String color) async {
    // Lấy position lớn nhất hiện tại để xếp cột mới vào cuối
    final res = await _client
        .from('board_columns')
        .select('position')
        .eq('board_id', boardId)
        .order('position', ascending: false)
        .limit(1)
        .maybeSingle();

    final int newPos =
        (res != null && res['position'] != null) ? res['position'] + 1 : 0;

    await _client.from('board_columns').insert({
      'board_id': boardId,
      'name': name,
      'color': color,
      'position': newPos,
    });
  }
}

// --- PROVIDERS ---

// 1. Repository Provider
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  return BoardRepository(Supabase.instance.client);
});

// 2. Stream Boards (Danh sách bảng trong Project Screen)
final boardsStreamProvider =
    StreamProvider.family<List<BoardModel>, String>((ref, projectId) {
  return ref.watch(boardRepositoryProvider).watchBoards(projectId);
});

// 3. Stream Columns (Danh sách cột trong Board Screen - QUAN TRỌNG CHO LỖI CỦA BẠN)
final columnsStreamProvider =
    StreamProvider.family<List<BoardColumnModel>, String>((ref, boardId) {
  return ref.watch(boardRepositoryProvider).watchColumns(boardId);
});

// 4. Single Board Provider
final boardProvider =
    FutureProvider.family<BoardModel?, String>((ref, boardId) {
  return ref.watch(boardRepositoryProvider).getBoard(boardId);
});

// --- NOTIFIERS (Xử lý logic thêm/sửa/xóa) ---

// Board Notifier
class BoardNotifier extends StateNotifier<AsyncValue<void>> {
  final BoardRepository _repo;
  final String _projectId;

  BoardNotifier(this._repo, this._projectId)
      : super(const AsyncValue.data(null));

  Future<void> createBoard(String name) async {
    try {
      state = const AsyncValue.loading();
      await _repo.createBoard(_projectId, name);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBoard(String boardId) async {
    try {
      await _repo.deleteBoard(boardId);
    } catch (e) {
      // Handle error silently or log it
    }
  }
}

final boardNotifierProvider =
    StateNotifierProvider.family<BoardNotifier, AsyncValue<void>, String>(
        (ref, projectId) {
  return BoardNotifier(ref.watch(boardRepositoryProvider), projectId);
});

// Column Notifier (Logic tạo cột)
class ColumnNotifier extends StateNotifier<AsyncValue<void>> {
  final BoardRepository _repo;
  final String _boardId;

  ColumnNotifier(this._repo, this._boardId)
      : super(const AsyncValue.data(null));

  Future<void> createColumn(
      {required String name, required String colorHex}) async {
    // Không try-catch ở đây để UI bắt lỗi và hiện SnackBar
    await _repo.createColumn(_boardId, name, colorHex);
  }
}

final columnNotifierProvider =
    StateNotifierProvider.family<ColumnNotifier, AsyncValue<void>, String>(
        (ref, boardId) {
  return ColumnNotifier(ref.watch(boardRepositoryProvider), boardId);
});
