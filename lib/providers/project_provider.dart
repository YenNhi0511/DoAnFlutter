import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/project_model.dart';
import '../data/models/project_member_model.dart';
import 'auth_provider.dart';

// --- REPOSITORY ---
class ProjectRepository {
  final SupabaseClient _client;
  ProjectRepository(this._client);

  Future<List<ProjectModel>> getProjects(String userId) async {
    try {
      final data = await _client
          .from('projects')
          .select()
          .eq('is_archived', false)
          .order('created_at', ascending: false);
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final data =
          await _client.from('projects').select().eq('id', projectId).single();
      return ProjectModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProjectMemberModel>> getProjectMembers(String projectId) async {
    try {
      final List<dynamic> data = await _client
          .from('project_members')
          .select()
          .eq('project_id', projectId);

      // Sửa lỗi: Không dùng 'const' ở đây vì name là giá trị động
      return data.map((json) {
        return ProjectMemberModel(
          id: json['id'] ?? '',
          projectId: json['project_id'] ?? '',
          userId: json['user_id'] ?? '',
          role: ProjectMemberModel.fromJson(json)
              .role, // Sử dụng logic parse role từ model
          name: 'User ' +
              (json['user_id'] as String).substring(0, 4), // Giá trị động
          email: 'user@example.com',
          // avatarUrl để null hoặc giá trị mặc định
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProjectModel?> createProject(ProjectModel project) async {
    try {
      final data = await _client.rpc('create_project_with_owner', params: {
        'p_name': project.name,
        'p_description': project.description,
        'p_color_hex': project.colorHex,
        'p_icon_name': project.iconName,
        'p_owner_id': project.ownerId,
      });
      return ProjectModel.fromJson(data);
    } catch (e) {
      debugPrint('Error creating project: $e');
      return null;
    }
  }

  Future<String> addMember(
      String projectId, String email, MemberRole role) async {
    try {
      final response = await _client.rpc('add_member_by_email', params: {
        'p_project_id': projectId,
        'p_email': email,
        'p_role': role.name,
      });
      return response as String;
    } catch (e) {
      return 'error';
    }
  }

  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }
}

// --- PROVIDERS ---

final projectRepositoryProvider = Provider((ref) {
  return ProjectRepository(Supabase.instance.client);
});

final projectNotifierProvider =
    StateNotifierProvider<ProjectNotifier, AsyncValue<List<ProjectModel>>>(
        (ref) {
  final authState = ref.watch(authStateProvider);
  return ProjectNotifier(
      ref.watch(projectRepositoryProvider), authState.value?.id);
});

final projectProvider = FutureProvider.family<ProjectModel?, String>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProject(id);
});

final projectMembersProvider =
    FutureProvider.family<List<ProjectMemberModel>, String>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectMembers(id);
});

// --- NOTIFIER ---

class ProjectNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository _repo;
  final String? _userId;

  ProjectNotifier(this._repo, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) loadProjects();
  }

  Future<void> loadProjects() async {
    if (_userId == null) return;
    try {
      final projects = await _repo.getProjects(_userId!);
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ProjectModel?> createProject({
    required String name,
    String? description,
    required String colorHex,
    String? iconName,
  }) async {
    if (_userId == null) return null;

    final newProject = ProjectModel(
      id: '',
      name: name,
      description: description,
      colorHex: colorHex,
      iconName: iconName,
      ownerId: _userId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repo.createProject(newProject);
    if (result != null) {
      loadProjects();
    }
    return result;
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await _repo.deleteProject(projectId);
      loadProjects();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addMember(
      String projectId, String email, MemberRole role) async {
    final result = await _repo.addMember(projectId, email, role);
    return result == 'success';
  }
}
