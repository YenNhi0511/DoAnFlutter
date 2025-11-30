import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth State Provider
final authStateProvider = StreamProvider<sb.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// NOTE: Firebase Messaging removed. Device token registration is not active.

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final result =
          await ref.read(authRepositoryProvider).getCurrentUserData();
      return result.fold((l) => null, (r) => r);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signIn(email, password);
    return result.fold(
      (failure) {
        // Preserve the failure object in the AsyncValue error for richer UI handling
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUp(email, password, name);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  Future<bool> resendConfirmation(String email) async {
    final result = await _repository.resendConfirmation(email);
    return result.fold((failure) {
      state = AsyncValue.error(failure, StackTrace.current);
      return false;
    }, (r) {
      // Keep previous state; not signing user in
      return true;
    });
  }

  Future<void> signOut() async {
    // No push token unregister (Firebase Messaging removed)
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<bool> resetPassword(String email) async {
    final result = await _repository.resetPassword(email);
    return result.isRight();
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    final result = await _repository.updateProfile(
      name: name,
      avatarUrl: avatarUrl,
    );
    result.fold(
      (failure) => null,
      (user) => state = AsyncValue.data(user),
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Watch auth state - token registration is removed with Firebase.
