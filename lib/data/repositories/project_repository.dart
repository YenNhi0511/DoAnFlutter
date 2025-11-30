import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/failures.dart';
import '../../core/services/supabase_service.dart';
import '../models/project_model.dart';
import '../models/project_member_model.dart';
import '../models/user_model.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<ProjectModel>>> getProjects(String userId);
  Future<Either<Failure, ProjectModel>> getProject(String projectId);
  Future<Either<Failure, ProjectModel>> createProject(ProjectModel project);
  Future<Either<Failure, ProjectModel>> updateProject(ProjectModel project);
  Future<Either<Failure, void>> deleteProject(String projectId);
  Future<Either<Failure, void>> archiveProject(String projectId);
  Stream<List<ProjectModel>> watchProjects(String userId);
  Future<Either<Failure, List<UserModel>>> getProjectMembers(String projectId);
  Future<Either<Failure, void>> addMember(String projectId, String email, MemberRole role);
  Future<Either<Failure, void>> removeMember(String projectId, String userId);
  Future<Either<Failure, void>> updateMemberRole(String projectId, String userId, MemberRole role);
}

class ProjectRepositoryImpl implements ProjectRepository {
  final SupabaseClient _supabase;

  ProjectRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<Either<Failure, List<ProjectModel>>> getProjects(String userId) async {
    try {
      // Get projects where user is owner
      final ownedProjects = await _supabase
          .from(SupabaseService.projectsTable)
          .select()
          .eq('owner_id', userId)
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      // Get projects where user is member
      final memberProjectIds = await _supabase
          .from(SupabaseService.projectMembersTable)
          .select('project_id')
          .eq('user_id', userId);

      final memberIds = (memberProjectIds as List)
          .map((e) => e['project_id'] as String)
          .toList();

      List<dynamic> memberProjects = [];
      if (memberIds.isNotEmpty) {
        memberProjects = await _supabase
            .from(SupabaseService.projectsTable)
            .select()
            .inFilter('id', memberIds)
            .eq('is_archived', false)
            .order('updated_at', ascending: false);
      }

      final allProjects = [
        ...ownedProjects.map((e) => ProjectModel.fromJson(e)),
        ...memberProjects.map((e) => ProjectModel.fromJson(e)),
      ];

      // Remove duplicates
      final uniqueProjects = {for (var p in allProjects) p.id: p}.values.toList();

      return Right(uniqueProjects);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> getProject(String projectId) async {
    try {
      final response = await _supabase
          .from(SupabaseService.projectsTable)
          .select()
          .eq('id', projectId)
          .single();

      return Right(ProjectModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> createProject(ProjectModel project) async {
    try {
      final response = await _supabase
          .from(SupabaseService.projectsTable)
          .insert(project.toInsertJson())
          .select()
          .single();

      final createdProject = ProjectModel.fromJson(response);

      // Add owner as member
      await _supabase.from(SupabaseService.projectMembersTable).insert({
        'project_id': createdProject.id,
        'user_id': project.ownerId,
        'role': 'owner',
      });

      return Right(createdProject);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> updateProject(ProjectModel project) async {
    try {
      final response = await _supabase
          .from(SupabaseService.projectsTable)
          .update({
            'name': project.name,
            'description': project.description,
            'color_hex': project.colorHex,
            'icon_name': project.iconName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', project.id)
          .select()
          .single();

      return Right(ProjectModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      await _supabase
          .from(SupabaseService.projectsTable)
          .delete()
          .eq('id', projectId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveProject(String projectId) async {
    try {
      await _supabase
          .from(SupabaseService.projectsTable)
          .update({
            'is_archived': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ProjectModel>> watchProjects(String userId) {
    return _supabase
        .from(SupabaseService.projectsTable)
        .stream(primaryKey: ['id'])
        .eq('owner_id', userId)
        .order('updated_at', ascending: false)
        .map((data) => data.map((e) => ProjectModel.fromJson(e)).toList());
  }

  @override
  Future<Either<Failure, List<UserModel>>> getProjectMembers(String projectId) async {
    try {
      final memberData = await _supabase
          .from(SupabaseService.projectMembersTable)
          .select('user_id')
          .eq('project_id', projectId);

      final userIds = (memberData as List)
          .map((e) => e['user_id'] as String)
          .toList();

      if (userIds.isEmpty) {
        return const Right([]);
      }

      final users = await _supabase
          .from(SupabaseService.usersTable)
          .select()
          .inFilter('id', userIds);

      return Right(
        (users as List).map((e) => UserModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMember(
    String projectId,
    String email,
    MemberRole role,
  ) async {
    try {
      // Find user by email
      final userResponse = await _supabase
          .from(SupabaseService.usersTable)
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        return const Left(NotFoundFailure(message: 'User not found'));
      }

      final userId = userResponse['id'] as String;

      // Check if already member
      final existing = await _supabase
          .from(SupabaseService.projectMembersTable)
          .select()
          .eq('project_id', projectId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return const Left(ValidationFailure(message: 'User is already a member'));
      }

      await _supabase.from(SupabaseService.projectMembersTable).insert({
        'project_id': projectId,
        'user_id': userId,
        'role': role == MemberRole.admin
            ? 'admin'
            : role == MemberRole.viewer
                ? 'viewer'
                : 'member',
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
    String projectId,
    String userId,
  ) async {
    try {
      await _supabase
          .from(SupabaseService.projectMembersTable)
          .delete()
          .eq('project_id', projectId)
          .eq('user_id', userId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
    String projectId,
    String userId,
    MemberRole role,
  ) async {
    try {
      await _supabase
          .from(SupabaseService.projectMembersTable)
          .update({
            'role': role == MemberRole.admin
                ? 'admin'
                : role == MemberRole.viewer
                    ? 'viewer'
                    : 'member',
          })
          .eq('project_id', projectId)
          .eq('user_id', userId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

