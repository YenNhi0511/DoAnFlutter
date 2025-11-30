import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/project_model.dart';
import '../data/models/project_member_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/project_repository.dart';
import 'auth_provider.dart';

// Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl();
});

// Projects List Provider
final projectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final result =
          await ref.read(projectRepositoryProvider).getProjects(user.id);
      return result.fold((l) => [], (r) => r);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Projects Stream Provider (Real-time)
final projectsStreamProvider = StreamProvider<List<ProjectModel>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(projectRepositoryProvider).watchProjects(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Single Project Provider
final projectProvider =
    FutureProvider.family<ProjectModel?, String>((ref, projectId) async {
  final result =
      await ref.read(projectRepositoryProvider).getProject(projectId);
  return result.fold((l) => null, (r) => r);
});

// Project Members Provider
final projectMembersProvider =
    FutureProvider.family<List<UserModel>, String>((ref, projectId) async {
  final result =
      await ref.read(projectRepositoryProvider).getProjectMembers(projectId);
  return result.fold((l) => [], (r) => r);
});

// Selected Project Provider
final selectedProjectProvider = StateProvider<ProjectModel?>((ref) => null);

// Project Notifier
class ProjectNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository _repository;
  final String? _userId;

  ProjectNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadProjects();
    }
  }

  Future<void> loadProjects() async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    final result = await _repository.getProjects(_userId!);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (projects) => AsyncValue.data(projects),
    );
  }

  Future<ProjectModel?> createProject({
    required String name,
    String? description,
    required String colorHex,
    String? iconName,
  }) async {
    if (_userId == null) return null;

    final project = ProjectModel(
      id: '',
      name: name,
      description: description,
      ownerId: _userId!,
      colorHex: colorHex,
      iconName: iconName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createProject(project);
    return result.fold(
      (failure) => null,
      (createdProject) {
        state.whenData((projects) {
          state = AsyncValue.data([createdProject, ...projects]);
        });
        return createdProject;
      },
    );
  }

  Future<bool> updateProject(ProjectModel project) async {
    final result = await _repository.updateProject(project);
    return result.fold(
      (failure) => false,
      (updatedProject) {
        state.whenData((projects) {
          final index = projects.indexWhere((p) => p.id == project.id);
          if (index != -1) {
            final updatedList = [...projects];
            updatedList[index] = updatedProject;
            state = AsyncValue.data(updatedList);
          }
        });
        return true;
      },
    );
  }

  Future<bool> deleteProject(String projectId) async {
    final result = await _repository.deleteProject(projectId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((projects) {
          state = AsyncValue.data(
            projects.where((p) => p.id != projectId).toList(),
          );
        });
        return true;
      },
    );
  }

  Future<bool> archiveProject(String projectId) async {
    final result = await _repository.archiveProject(projectId);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((projects) {
          state = AsyncValue.data(
            projects.where((p) => p.id != projectId).toList(),
          );
        });
        return true;
      },
    );
  }

  Future<bool> addMember(
      String projectId, String email, MemberRole role) async {
    final result = await _repository.addMember(projectId, email, role);
    return result.isRight();
  }

  Future<bool> removeMember(String projectId, String userId) async {
    final result = await _repository.removeMember(projectId, userId);
    return result.isRight();
  }
}

final projectNotifierProvider =
    StateNotifierProvider<ProjectNotifier, AsyncValue<List<ProjectModel>>>(
        (ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.id;
  return ProjectNotifier(ref.watch(projectRepositoryProvider), userId);
});
