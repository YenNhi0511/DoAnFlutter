import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../core/error/failures.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth State Provider - theo dõi trạng thái đăng nhập
final authStateProvider = StreamProvider<sb.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Current User Provider - lấy thông tin user hiện tại
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

// Auth Notifier - quản lý state đăng nhập/đăng ký
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Đăng nhập
  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.signIn(email, password);
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
    } catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: 'Lỗi đăng nhập: ${e.toString()}'),
        StackTrace.current,
      );
      return false;
    }
  }

  /// Đăng ký
  Future<bool> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
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
    } catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: 'Lỗi đăng ký: ${e.toString()}'),
        StackTrace.current,
      );
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      // Vẫn set state về null dù có lỗi
      state = const AsyncValue.data(null);
    }
  }

  /// Đặt lại mật khẩu
  Future<bool> resetPassword(String email) async {
    try {
      final result = await _repository.resetPassword(email);
      return result.isRight();
    } catch (e) {
      return false;
    }
  }

  /// Cập nhật profile
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    try {
      final result = await _repository.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      result.fold(
        (failure) => null,
        (user) => state = AsyncValue.data(user),
      );
    } catch (e) {
      // Bỏ qua lỗi
    }
  }

  /// Đăng nhập bằng magic link (OTP qua email)
  Future<bool> signInWithMagicLink(String email) async {
    try {
      final result = await _repository.signInWithMagicLink(email);
      return result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          return false;
        },
        (_) {
          // Magic link đã gửi thành công
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: 'Lỗi gửi magic link: ${e.toString()}'),
        StackTrace.current,
      );
      return false;
    }
  }

  /// Gửi mã OTP để đặt lại mật khẩu
  Future<bool> sendPasswordResetOtp(String email) async {
    try {
      final result = await _repository.sendPasswordResetOtp(email);
      return result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: 'Lỗi gửi mã OTP: ${e.toString()}'),
        StackTrace.current,
      );
      return false;
    }
  }

  /// Xác thực OTP và đặt lại mật khẩu mới
  Future<bool> verifyOtpAndResetPassword(
      String email, String token, String newPassword) async {
    try {
      final result = await _repository.verifyOtpAndResetPassword(
          email, token, newPassword);
      return result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: 'Lỗi đặt lại mật khẩu: ${e.toString()}'),
        StackTrace.current,
      );
      return false;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
