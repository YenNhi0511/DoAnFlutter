import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/failures.dart';
import '../../core/services/supabase_service.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getActivities(
      String projectId);
  Future<Either<Failure, void>> logActivity({
    required String projectId,
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  });
}

class ActivityRepositoryImpl implements ActivityRepository {
  final SupabaseClient _supabase;

  ActivityRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getActivities(
      String projectId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.activitiesTable)
          .select('''
            *,
            users:user_id (
              id,
              name,
              email,
              avatar_url
            )
          ''')
          .eq('project_id', projectId)
          .order('created_at', ascending: false)
          .limit(50);

      final activities = (response as List).map((e) {
        final activity = Map<String, dynamic>.from(e);
        if (activity['users'] != null) {
          activity['user'] = activity['users'];
          activity.remove('users');
        }
        return activity;
      }).toList();

      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logActivity({
    required String projectId,
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.from(SupabaseService.activitiesTable).insert({
        'project_id': projectId,
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'metadata': metadata ?? {},
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

