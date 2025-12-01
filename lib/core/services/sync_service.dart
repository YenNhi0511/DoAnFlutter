import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';

/// Service to sync offline operations when connection is restored
class SyncService {
  final ConnectivityService _connectivityService;
  Timer? _syncTimer;

  SyncService(this._connectivityService);

  /// Start auto-sync when online
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final isConnected = await _connectivityService.isConnected;
      if (isConnected && OfflineQueueService.queueSize > 0) {
        await _syncQueuedOperations();
      }
    });
  }

  /// Stop auto-sync
  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  /// Sync all queued operations
  Future<void> _syncQueuedOperations() async {
    final operations = OfflineQueueService.getQueuedOperations();
    
    for (final operation in operations) {
      try {
        // Process operation based on type
        // This would call appropriate repository methods
        // For now, just remove from queue after processing
        await OfflineQueueService.removeOperation(operation['id'] as String);
      } catch (e) {
        // If sync fails, keep operation in queue for retry
        print('Failed to sync operation ${operation['id']}: $e');
      }
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      await _syncQueuedOperations();
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref.watch(connectivityServiceProvider));
  service.startAutoSync();
  return service;
});

