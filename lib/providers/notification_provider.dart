import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

// Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

// Notifications List Provider
final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final result = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(user.id);
      return result.fold((l) => [], (r) => r);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Notifications Stream Provider (Real-time)
final notificationsStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .read(notificationRepositoryProvider)
          .watchNotifications(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Unread Count Provider
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return 0;
      final result = await ref
          .read(notificationRepositoryProvider)
          .getUnreadCount(user.id);
      return result.fold((l) => 0, (r) => r);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Unread Count Stream Provider
final unreadNotificationsCountStreamProvider = StreamProvider<int>((ref) {
  final notificationsStream = ref.watch(notificationsStreamProvider);

  return notificationsStream.when(
    data: (notifications) =>
        Stream.value(notifications.where((n) => !n.isRead).length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// Notification Notifier
class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final String? _userId;

  NotificationNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadNotifications();
    }
  }

  Future<void> loadNotifications() async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    final result = await _repository.getNotifications(_userId!);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (notifications) => AsyncValue.data(notifications),
    );
  }

  Future<bool> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    await loadNotifications(); // Refresh list
    return result.isRight();
  }

  Future<bool> markAllAsRead() async {
    if (_userId == null) return false;

    final result = await _repository.markAllAsRead(_userId!);
    await loadNotifications(); // Refresh list
    return result.isRight();
  }

  Future<bool> deleteNotification(String notificationId) async {
    final result = await _repository.deleteNotification(notificationId);
    if (result.isRight()) {
      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.where((n) => n.id != notificationId).toList(),
        );
      });
    }
    return result.isRight();
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<NotificationModel>>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.id;
  return NotificationNotifier(
      ref.watch(notificationRepositoryProvider), userId);
});
