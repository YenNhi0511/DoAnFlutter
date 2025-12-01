import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl();
});

final activitiesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  final result = await ref
      .read(activityRepositoryProvider)
      .getActivities(projectId);
  return result.fold((l) => [], (r) => r);
});

