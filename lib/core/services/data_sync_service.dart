import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';
import '../services/supabase_service.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/board_repository.dart';

/// Service to sync offline operations with Supabase
class DataSyncService {
  final ConnectivityService _connectivityService;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final BoardRepository _boardRepository;
  Timer? _syncTimer;
  bool _isSyncing = false;

  DataSyncService(
    this._connectivityService,
    this._projectRepository,
    this._taskRepository,
    this._boardRepository,
  );

  /// Start auto-sync when online
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final isConnected = await _connectivityService.isConnected;
      if (isConnected && OfflineQueueService.queueSize > 0 && !_isSyncing) {
        await syncQueuedOperations();
      }
    });
  }

  /// Stop auto-sync
  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  /// Sync all queued operations with Supabase
  Future<void> syncQueuedOperations() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      final operations = OfflineQueueService.getQueuedOperations();
      
      for (final operation in operations) {
        try {
          await _processOperation(operation);
          await OfflineQueueService.removeOperation(operation['id'] as String);
        } catch (e) {
          // Increment retry count
          final retries = (operation['retries'] as int? ?? 0) + 1;
          if (retries >= 3) {
            // Max retries reached, remove from queue
            await OfflineQueueService.removeOperation(operation['id'] as String);
          } else {
            // Update retry count
            await OfflineQueueService.queueOperation(
              type: operation['type'] as String,
              data: operation['data'] as Map<String, dynamic>,
              id: operation['id'] as String,
            );
          }
          print('Failed to sync operation ${operation['id']}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single operation
  Future<void> _processOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final data = operation['data'] as Map<String, dynamic>;

    switch (type) {
      case 'create_project':
        await _projectRepository.createProject(
          name: data['name'] as String,
          description: data['description'] as String?,
          colorHex: data['colorHex'] as String? ?? '#1E3A5F',
          iconName: data['iconName'] as String? ?? 'folder',
        );
        break;

      case 'update_project':
        await _projectRepository.updateProject(
          projectId: data['projectId'] as String,
          name: data['name'] as String?,
          description: data['description'] as String?,
          colorHex: data['colorHex'] as String?,
          iconName: data['iconName'] as String?,
        );
        break;

      case 'create_task':
        await _taskRepository.createTask(
          columnId: data['columnId'] as String,
          boardId: data['boardId'] as String?,
          projectId: data['projectId'] as String,
          title: data['title'] as String,
          description: data['description'] as String?,
          priority: data['priority'] as String,
          dueDate: data['dueDate'] != null
              ? DateTime.parse(data['dueDate'] as String)
              : null,
        );
        break;

      case 'update_task':
        await _taskRepository.updateTask(
          taskId: data['taskId'] as String,
          title: data['title'] as String?,
          description: data['description'] as String?,
          priority: data['priority'] as String?,
          dueDate: data['dueDate'] != null
              ? DateTime.parse(data['dueDate'] as String)
              : null,
          isCompleted: data['isCompleted'] as bool?,
        );
        break;

      case 'move_task':
        await _taskRepository.moveTask(
          taskId: data['taskId'] as String,
          newColumnId: data['newColumnId'] as String,
          newPosition: data['newPosition'] as int,
        );
        break;

      case 'create_board':
        await _boardRepository.createBoard(
          projectId: data['projectId'] as String,
          name: data['name'] as String,
        );
        break;

      case 'add_comment':
        await _taskRepository.addComment(
          taskId: data['taskId'] as String,
          content: data['content'] as String,
        );
        break;

      default:
        print('Unknown operation type: $type');
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      await syncQueuedOperations();
    }
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;
  int get pendingOperations => OfflineQueueService.queueSize;
}

final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService(
    ref.watch(connectivityServiceProvider),
    ref.watch(projectRepositoryProvider),
    ref.watch(taskRepositoryProvider),
    ref.watch(boardRepositoryProvider),
  )..startAutoSync();
});

