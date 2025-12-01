import 'dart:async';

/// Utility class for performance optimization
class PerformanceUtils {
  /// Debounce function calls
  static Timer? _debounceTimer;

  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleCall;
  static const Duration _throttleDelay = Duration(milliseconds: 500);

  static bool throttle(VoidCallback callback) {
    final now = DateTime.now();
    if (_lastThrottleCall == null ||
        now.difference(_lastThrottleCall!) > _throttleDelay) {
      _lastThrottleCall = now;
      callback();
      return true;
    }
    return false;
  }

  /// Cancel debounce
  static void cancelDebounce() {
    _debounceTimer?.cancel();
  }
}

/// Extension for List pagination
extension ListPagination<T> on List<T> {
  List<T> paginate({required int page, required int pageSize}) {
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    if (start >= length) return [];
    if (end > length) return sublist(start);
    return sublist(start, end);
  }

  int getTotalPages(int pageSize) {
    if (isEmpty) return 1;
    return (length / pageSize).ceil();
  }
}

