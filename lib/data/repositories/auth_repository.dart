import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../core/error/failures.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<sb.User?> get authStateChanges;
  sb.User? get currentUser;
  Future<Either<Failure, UserModel>> signIn(String email, String password);
  Future<Either<Failure, UserModel>> signUp(
      String email, String password, String name);
  Future<Either<Failure, void>> signInWithMagicLink(String email);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> sendPasswordResetOtp(String email);
  Future<Either<Failure, void>> verifyOtpAndResetPassword(
      String email, String token, String newPassword);
  Future<Either<Failure, UserModel>> getCurrentUserData();
  Future<Either<Failure, UserModel>> updateProfile(
      {String? name, String? avatarUrl});
}

class AuthRepositoryImpl implements AuthRepository {
  final sb.SupabaseClient _supabase;

  AuthRepositoryImpl({
    sb.SupabaseClient? supabase,
  }) : _supabase = supabase ?? SupabaseService.client;

  Stream<sb.AuthState> get _authChangeStream =>
      _supabase.auth.onAuthStateChange;

  @override
  Stream<sb.User?> get authStateChanges =>
      _authChangeStream.map((state) => state.session?.user);

  @override
  sb.User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<Either<Failure, UserModel>> signIn(
      String email, String password) async {
    try {
      // Đăng nhập với Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // Kiểm tra user
      if (response.user == null) {
        return const Left(AuthFailure(
            message: 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.'));
      }

      // Lấy hoặc tạo user data trong bảng users
      final userData = await _getOrCreateSupabaseUserFromUser(response.user!);
      return Right(userData);
    } on sb.AuthException catch (e) {
      // Xử lý lỗi từ Supabase Auth
      String errorMessage = 'Đăng nhập thất bại';

      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('Invalid email or password')) {
        errorMessage = 'Email hoặc mật khẩu không đúng';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Email chưa được xác thực. Vui lòng kiểm tra email.';
      } else {
        errorMessage = e.message;
      }

      return Left(AuthFailure(message: errorMessage));
    } catch (e) {
      // Xử lý lỗi khác
      final errorMsg = e.toString();

      if (errorMsg.contains('401') || errorMsg.contains('Invalid API key')) {
        return const Left(AuthFailure(
            message:
                'Lỗi cấu hình. Vui lòng kiểm tra SUPABASE_ANON_KEY trong file .env'));
      }

      return Left(AuthFailure(message: 'Đăng nhập thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Đăng ký với Supabase (email confirmation đã tắt)
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
        },
      );

      // Kiểm tra user
      if (response.user == null) {
        // Kiểm tra lỗi từ response
        final error = response.session == null ? 'Đăng ký thất bại' : null;
        if (error != null) {
          return Left(AuthFailure(message: error));
        }
        return const Left(
            AuthFailure(message: 'Đăng ký thất bại. Vui lòng thử lại.'));
      }

      // Tạo user data trong bảng users
      try {
        final userData =
            await _createSupabaseUserFromUser(response.user!, name.trim());
        return Right(userData);
      } catch (e) {
        // Nếu user đã tồn tại, lấy lại
        if (e.toString().contains('duplicate') ||
            e.toString().contains('unique')) {
          final existingUser =
              await _getOrCreateSupabaseUserFromUser(response.user!);
          return Right(existingUser);
        }
        rethrow;
      }
    } on sb.AuthException catch (e) {
      // Xử lý lỗi từ Supabase Auth
      String errorMessage = 'Đăng ký thất bại';

      if (e.message.contains('User already registered') ||
          e.message.contains('already exists')) {
        errorMessage = 'Email này đã được sử dụng. Vui lòng đăng nhập.';
      } else if (e.message.contains('Password')) {
        errorMessage =
            'Mật khẩu không hợp lệ. Mật khẩu phải có ít nhất 6 ký tự.';
      } else if (e.message.contains('Email')) {
        errorMessage = 'Email không hợp lệ.';
      } else {
        errorMessage = e.message;
      }

      return Left(AuthFailure(message: errorMessage));
    } catch (e) {
      // Xử lý lỗi khác
      final errorMsg = e.toString();

      if (errorMsg.contains('401') || errorMsg.contains('Invalid API key')) {
        return const Left(AuthFailure(
            message:
                'Lỗi cấu hình. Vui lòng kiểm tra SUPABASE_ANON_KEY trong file .env'));
      }

      if (errorMsg.contains('duplicate') || errorMsg.contains('unique')) {
        return const Left(AuthFailure(
            message: 'Email này đã được sử dụng. Vui lòng đăng nhập.'));
      }

      return Left(AuthFailure(message: 'Đăng ký thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email.trim());
      return const Right(null);
    } on sb.AuthException catch (e) {
      return Left(
          AuthFailure(message: 'Không thể gửi magic link: ${e.message}'));
    } catch (e) {
      return Left(
          AuthFailure(message: 'Không thể gửi magic link: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Cập nhật trạng thái offline
        try {
          await _supabase.from(SupabaseService.usersTable).update({
            'is_online': false,
            'last_seen_at': DateTime.now().toIso8601String(),
          }).eq('id', user.id);
        } catch (e) {
          // Bỏ qua lỗi nếu không update được
        }
      }

      await _supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Đăng xuất thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(
          message: 'Không thể gửi email đặt lại mật khẩu: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false,
      );
      return const Right(null);
    } on sb.AuthException catch (e) {
      String errorMessage = 'Không thể gửi mã OTP';
      if (e.message.contains('User not found') ||
          e.message.contains('not found')) {
        errorMessage = 'Email không tồn tại trong hệ thống';
      } else if (e.message.contains('over_email_send_rate_limit')) {
        errorMessage = 'Vui lòng đợi 60 giây trước khi gửi lại';
      } else {
        errorMessage = e.message;
      }
      return Left(AuthFailure(message: errorMessage, code: 'otp-send-failed'));
    } catch (e) {
      return Left(AuthFailure(
          message: 'Không thể gửi mã OTP: ${e.toString()}',
          code: 'otp-send-failed'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtpAndResetPassword(
      String email, String token, String newPassword) async {
    try {
      // Xác thực OTP
      final response = await _supabase.auth.verifyOTP(
        type: sb.OtpType.email,
        email: email.trim(),
        token: token.trim(),
      );

      if (response.user == null) {
        return const Left(AuthFailure(
            message: 'Mã OTP không hợp lệ hoặc đã hết hạn',
            code: 'invalid-otp'));
      }

      // Đổi mật khẩu
      await _supabase.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );

      return const Right(null);
    } on sb.AuthException catch (e) {
      String errorMessage = 'Không thể đặt lại mật khẩu';
      if (e.message.contains('Invalid token') ||
          e.message.contains('expired') ||
          e.message.contains('otp_expired')) {
        errorMessage = 'Mã OTP không hợp lệ hoặc đã hết hạn';
      } else if (e.message.contains('Password')) {
        errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      } else {
        errorMessage = e.message;
      }
      return Left(AuthFailure(message: errorMessage, code: 'reset-failed'));
    } catch (e) {
      return Left(AuthFailure(
          message: 'Không thể đặt lại mật khẩu: ${e.toString()}',
          code: 'reset-failed'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'Chưa đăng nhập'));
      }

      final response = await _supabase
          .from(SupabaseService.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        // Nếu không tìm thấy, tạo mới
        return Right(await _getOrCreateSupabaseUserFromUser(user));
      }

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Không thể lấy thông tin user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'Chưa đăng nhập'));
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updates['name'] = name.trim();
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      final response = await _supabase
          .from(SupabaseService.usersTable)
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Không thể cập nhật thông tin: ${e.toString()}'));
    }
  }

  /// Lấy hoặc tạo user trong bảng users từ Supabase auth user
  Future<UserModel> _getOrCreateSupabaseUserFromUser(sb.User sbUser) async {
    try {
      // Thử lấy user từ bảng users
      final response = await _supabase
          .from(SupabaseService.usersTable)
          .select()
          .eq('id', sbUser.id)
          .maybeSingle();

      if (response != null) {
        // Cập nhật trạng thái online
        try {
          await _supabase.from(SupabaseService.usersTable).update({
            'is_online': true,
            'last_seen_at': DateTime.now().toIso8601String(),
          }).eq('id', sbUser.id);
        } catch (e) {
          // Bỏ qua lỗi update
        }

        return UserModel.fromJson(response);
      }

      // Nếu không tìm thấy, tạo mới
      final name = sbUser.userMetadata?['name'] as String? ??
          sbUser.email?.split('@')[0] ??
          'User';
      return await _createSupabaseUserFromUser(sbUser, name);
    } catch (e) {
      // Nếu có lỗi, thử tạo lại
      final name = sbUser.userMetadata?['name'] as String? ??
          sbUser.email?.split('@')[0] ??
          'User';
      return await _createSupabaseUserFromUser(sbUser, name);
    }
  }

  /// Tạo user mới trong bảng users
  Future<UserModel> _createSupabaseUserFromUser(
      sb.User sbUser, String name) async {
    final now = DateTime.now().toIso8601String();
    final userData = {
      'id': sbUser.id,
      'email': sbUser.email ?? '',
      'name': name,
      'avatar_url': sbUser.userMetadata?['avatar_url'],
      'is_online': true,
      'created_at': now,
      'updated_at': now,
    };

    try {
      // Insert user data vào database
      await _supabase.from(SupabaseService.usersTable).insert(userData);

      // Trả về UserModel từ dữ liệu vừa insert
      return UserModel.fromJson(userData);
    } catch (e) {
      // Nếu insert thất bại (có thể do duplicate), thử select lại
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique')) {
        final existing = await _supabase
            .from(SupabaseService.usersTable)
            .select()
            .eq('id', sbUser.id)
            .maybeSingle();

        if (existing != null) {
          return UserModel.fromJson(existing);
        }
      }
      rethrow;
    }
  }
}
