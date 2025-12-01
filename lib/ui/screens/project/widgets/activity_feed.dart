import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/user_model.dart';
import '../../../../providers/project_provider.dart';
import '../../../../providers/activity_provider.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/user_avatar.dart';

class ActivityFeed extends ConsumerWidget {
  final String projectId;

  const ActivityFeed({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return EmptyState(
            icon: Iconsax.activity,
            title: 'No activity yet',
            subtitle: 'Activity will appear here as team members work on the project',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityItem(
              activity: activity,
              isDark: isDark,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: EmptyState(
          icon: Iconsax.danger,
          title: 'Error loading activity',
          subtitle: error.toString(),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool isDark;

  const _ActivityItem({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final action = activity['action'] as String? ?? '';
    final user = activity['user'] as Map<String, dynamic>?;
    final userName = user?['name'] as String? ?? 'Unknown';
    final timestamp = activity['created_at'] != null
        ? DateTime.parse(activity['created_at'] as String)
        : DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: userName,
            size: 40,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $_getActionText(action)'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  timestamp.relative,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'task_created':
        return 'created a task';
      case 'task_updated':
        return 'updated a task';
      case 'task_completed':
        return 'completed a task';
      case 'task_moved':
        return 'moved a task';
      case 'comment_added':
        return 'added a comment';
      case 'member_added':
        return 'added a member';
      case 'board_created':
        return 'created a board';
      default:
        return action.replaceAll('_', ' ');
    }
  }
}


