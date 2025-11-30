import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(task.priority);
    final isOverdue =
        task.dueDate != null && task.dueDate!.isOverdue && !task.isCompleted;
    final isDueSoon =
        task.dueDate != null && task.dueDate!.isDueSoon && !task.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: AppColors.cardShadow,
          border: Border.all(
            color: isOverdue
                ? AppColors.error.withOpacity(0.5)
                : isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority indicator
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMd),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Labels
                  if (task.labelIds.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: AppSizes.xs,
                      children: task.labelIds.take(3).map((labelId) {
                        // TODO: Get actual label color
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tagColors[
                                labelId.hashCode % AppColors.tagColors.length],
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: const SizedBox(height: 6),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.xs),
                  ],

                  // Title
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiary
                              : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSizes.sm),

                  // Footer
                  Row(
                    children: [
                      // Due date
                      if (task.dueDate != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? AppColors.error.withOpacity(0.1)
                                : isDueSoon
                                    ? AppColors.warning.withOpacity(0.1)
                                    : (isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 12,
                                color: isOverdue
                                    ? AppColors.error
                                    : isDueSoon
                                        ? AppColors.warning
                                        : isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate!.dayMonth,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color: isOverdue
                                          ? AppColors.error
                                          : isDueSoon
                                              ? AppColors.warning
                                              : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                      ],

                      const Spacer(),

                      // Attachments indicator (show up to 3 thumbnails)
                      if (task.attachmentUrls.isNotEmpty) ...[
                        Row(
                          children: task.attachmentUrls.take(3).map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Iconsax.attach_circle,
                                        size: 14),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: AppSizes.sm),
                      ],

                      // Assignee avatar
                      if (task.assigneeId != null)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}
