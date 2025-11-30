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
        return const Left(AuthFailure(message: 'Sign in failed'));
      }

      final userData = await _getOrCreateSupabaseUserFromUser(sbUser);
      return Right(userData);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
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
        return const Left(AuthFailure(message: 'Sign up failed'));
      }

      final userData = await _createSupabaseUserFromUser(sbUser, name);
      return Right(userData);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
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
