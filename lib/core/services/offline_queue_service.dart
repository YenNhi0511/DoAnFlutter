import 'package:hive_flutter/hive_flutter.dart';

/// Service to queue operations when offline and sync when online
class OfflineQueueService {
  static const String _queueBox = 'offline_queue';
  static Box? _queueBoxInstance;

  static Future<void> initialize() async {
    _queueBoxInstance = await Hive.openBox(_queueBox);
  }

  /// Add operation to queue
  static Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> data,
    String? id,
  }) async {
    if (_queueBoxInstance == null) await initialize();

    final operation = {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    };

    await _queueBoxInstance!.put(operation['id'], operation);
  }

  /// Get all queued operations
  static List<Map<String, dynamic>> getQueuedOperations() {
    if (_queueBoxInstance == null) return [];

    return _queueBoxInstance!.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (a['timestamp'] as String)
          .compareTo(b['timestamp'] as String));
  }

  /// Remove operation from queue
  static Future<void> removeOperation(String id) async {
    if (_queueBoxInstance == null) await initialize();
    await _queueBoxInstance!.delete(id);
  }

  /// Clear all queued operations
  static Future<void> clearQueue() async {
    if (_queueBoxInstance == null) await initialize();
    await _queueBoxInstance!.clear();
  }

  /// Get queue size
  static int get queueSize {
    if (_queueBoxInstance == null) return 0;
    return _queueBoxInstance!.length;
  }
}

