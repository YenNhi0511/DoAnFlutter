import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/board_column_model.dart';
import '../../../../data/models/task_model.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final BoardColumnModel column;
  final List<TaskModel> tasks;
  final VoidCallback onAddTask;
  final Function(String taskId, String newColumnId, int newPosition) onTaskMoved;
  final Function(TaskModel task) onTaskTap;

  const KanbanColumn({
    super.key,
    required this.column,
    required this.tasks,
    required this.onAddTask,
    required this.onTaskMoved,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final columnColor = _parseColor(column.colorHex);

    return Container(
      width: AppSizes.kanbanColumnWidth,
      margin: const EdgeInsets.only(right: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: columnColor.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: columnColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    column.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: columnColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                PopupMenuButton<String>(
                  icon: Icon(
                    Iconsax.more,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    // TODO: Handle column actions
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: DragTarget<TaskModel>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final task = details.data;
                if (task.columnId != column.id) {
                  onTaskMoved(task.id, column.id, tasks.length);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark.withOpacity(0.5)
                        : AppColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppSizes.radiusMd),
                    ),
                    border: candidateData.isNotEmpty
                        ? Border.all(
                            color: AppColors.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: tasks.isEmpty
                      ? _buildEmptyState(context, isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          itemCount: tasks.length + 1,
                          itemBuilder: (context, index) {
                            if (index == tasks.length) {
                              return _buildAddTaskButton(context, isDark);
                            }

                            final task = tasks[index];
                            return Draggable<TaskModel>(
                              data: task,
                              feedback: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                child: SizedBox(
                                  width: AppSizes.kanbanColumnWidth - 32,
                                  child: TaskCard(
                                    task: task,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: TaskCard(
                                  task: task,
                                  onTap: () {},
                                ),
                              ),
                              child: TaskCard(
                                task: task,
                                onTap: () => onTaskTap(task),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.task,
              size: 40,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'No tasks',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.md),
            _buildAddTaskButton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onAddTask,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.sm,
          horizontal: AppSizes.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.add,
              size: 18,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.xs),
            Text(
              'Add Task',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.columnTodo;
    }
  }
}

