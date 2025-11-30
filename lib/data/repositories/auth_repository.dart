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
  Future<Either<Failure, void>> resendConfirmation(String email);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
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
      final res = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      final sbUser = res.user;
      if (sbUser == null) {
        // Map known error payloads from Supabase response
        final dynError = (res as dynamic).error;
        final errMsg = (dynError?.message ?? '').toString();
        final errCode = (dynError?.statusCode?.toString() ?? '');
        final lowerErr = errMsg.toLowerCase();

        if (errMsg.isNotEmpty) {
          // detect email not confirmed case from res.error message or status code
          if (errMsg.contains('EMAIL_NOT_CONFIRMED') ||
              lowerErr.contains('email not confirmed') ||
              lowerErr.contains('email is not confirmed') ||
              (errCode == '400' && lowerErr.contains('confirm'))) {
            return const Left(AuthFailure(
                message: 'Email not confirmed. Please check your inbox.',
                code: 'email-not-confirmed'));
          }

          // Pass the raw error message
          return Left(AuthFailure(message: errMsg));
        }

        return const Left(AuthFailure(message: 'Sign in failed'));
      }

      final userData = await _getOrCreateSupabaseUserFromUser(sbUser);
      return Right(userData);
    } catch (e, st) {
      final msg = e.toString();
      // Print some helpful debug details for developers while keeping secrets out
      // Avoid printing the entire anon key; print base URL and error details.
      // Show supabase debug info (if available) without printing the full keys
      // ignore: avoid_print
      print(
          'Supabase debug -> url: ${SupabaseService.baseUrl}, anonPreview: ${SupabaseService.anonKeyPreview}');
      // Print error type and stack (for dev only); it helps diagnose 401/invalid keys
      // ignore: avoid_print
      print('SignIn error: ${e.runtimeType}: $msg');
      // ignore: avoid_print
      print(st);
      if (msg.contains('401') ||
          msg.toLowerCase().contains('invalid api key')) {
        return const Left(AuthFailure(
            message:
                'Invalid Supabase API key (401). Check SUPABASE_ANON_KEY in .env or Supabase project settings.'));
      }
      // If supabase returns an explicit 'email not confirmed' message, return a distinct failure code
      final lower = msg.toLowerCase();
      if (lower.contains('email not confirmed') ||
          lower.contains('email is not confirmed') ||
          lower.contains('email not verified') ||
          lower.contains('email is not verified') ||
          lower.contains('user not confirmed') ||
          lower.contains('not confirmed') ||
          lower.contains('verify your email')) {
        return const Left(AuthFailure(
            message: 'Email not confirmed. Please check your inbox.',
            code: 'email-not-confirmed'));
      }
      return Left(AuthFailure(message: msg));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      final sbUser = res.user;
      if (sbUser == null) {
        // Inspect dynamic response for detailed error
        final dynError = (res as dynamic).error;
        final errMsg = (dynError?.message ?? '').toString();
        final errCodeStr = (dynError?.statusCode?.toString() ?? '');
        final lower = errMsg.toLowerCase();
        if (errCodeStr == '429' ||
            lower.contains('over_email_send_rate_limit') ||
            lower.contains('rate limit')) {
          return const Left(AuthFailure(
              message: 'Bạn gửi quá nhiều yêu cầu. Vui lòng chờ vài giây.',
              code: 'over_email_send_rate_limit'));
        }
        if (lower.contains('email not confirmed') ||
            lower.contains('confirm')) {
          return const Left(AuthFailure(
              message: 'Email not confirmed. Please check your inbox.',
              code: 'email-not-confirmed'));
        }
        if (errMsg.isNotEmpty) return Left(AuthFailure(message: errMsg));
        return const Left(AuthFailure(message: 'Sign up failed'));
      }

      final userData = await _createSupabaseUserFromUser(sbUser, name);
      return Right(userData);
    } catch (e, st) {
      final msg = e.toString();
      // ignore: avoid_print
      print(
          'Supabase debug -> url: ${SupabaseService.baseUrl}, anonPreview: ${SupabaseService.anonKeyPreview}');
      // ignore: avoid_print
      print('SignUp error: ${e.runtimeType}: $msg');
      // ignore: avoid_print
      print(st);
      if (msg.contains('401') ||
          msg.toLowerCase().contains('invalid api key')) {
        return const Left(AuthFailure(
            message:
                'Invalid Supabase API key (401). Check SUPABASE_ANON_KEY in .env or Supabase project settings.'));
      }
      return Left(AuthFailure(message: msg));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmation(String email) async {
    try {
      final res = await _supabase.auth.signInWithOtp(email: email);
      final dynError = (res as dynamic).error;
      final errMsg = (dynError?.message ?? '').toString();
      final errCodeStr = (dynError?.statusCode?.toString() ?? '');
      final lower = errMsg.toLowerCase();
      if (errCodeStr == '429' ||
          lower.contains('over_email_send_rate_limit') ||
          lower.contains('rate limit')) {
        return const Left(AuthFailure(
            message:
                'Bạn gửi quá nhiều yêu cầu. Vui lòng chờ vài giây trước khi thử lại.',
            code: 'over_email_send_rate_limit'));
      }
      if (errMsg.isNotEmpty) {
        return Left(
            AuthFailure(message: 'Could not resend confirmation: $errMsg'));
      }
      return const Right(null);
    } catch (e) {
      final msg = e.toString();
      return Left(AuthFailure(message: 'Could not resend confirmation: $msg'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final user = currentUser;
      if (user != null) {
        await _supabase.from(SupabaseService.usersTable).update({
          'is_online': false,
          'last_seen_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }

      await _supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'Not authenticated'));
      }

      final response = await _supabase
          .from(SupabaseService.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
        return const Left(AuthFailure(message: 'Not authenticated'));
      }
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updates['name'] = name;
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<UserModel> _getOrCreateSupabaseUserFromUser(sb.User sbUser) async {
    try {
      final response = await _supabase
          .from(SupabaseService.usersTable)
          .select()
          .eq('id', sbUser.id)
          .maybeSingle();

      if (response != null) {
        // Update online status
        await _supabase.from(SupabaseService.usersTable).update({
          'is_online': true,
          'last_seen_at': DateTime.now().toIso8601String(),
        }).eq('id', sbUser.id);

        return UserModel.fromJson(response);
      }
      return await _createSupabaseUserFromUser(
        sbUser,
        sbUser.userMetadata?['name'] ?? sbUser.email?.split('@')[0] ?? 'User',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> _createSupabaseUserFromUser(
      sb.User sbUser, String name) async {
    final userData = {
      'id': sbUser.id,
      'email': sbUser.email,
      'name': name,
      'avatar_url': sbUser.userMetadata?['avatar_url'],
      'is_online': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(SupabaseService.usersTable)
        .insert(userData)
        .select()
        .single();

    return UserModel.fromJson(response);
  }
}
