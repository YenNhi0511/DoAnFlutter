import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/user_avatar.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _commentController = TextEditingController();
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskProvider(widget.taskId));
    final comments = ref.watch(commentsStreamProvider(widget.taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('Task Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Iconsax.edit),
              onPressed: () {
                final t = task.valueOrNull;
                if (t != null) {
                  _titleController.text = t.title;
                  _descriptionController.text = t.description ?? '';
                  setState(() => _isEditing = true);
                }
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed == true && mounted) {
                  // TODO: Delete task
                  context.pop();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: task.when(
        data: (t) {
          if (t == null) {
            return const Center(child: Text('Task not found'));
          }

          final priorityColor = _getPriorityColor(t.priority);
          final isOverdue =
              t.dueDate != null && t.dueDate!.isOverdue && !t.isCompleted;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority & Status Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: AppSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusFull),
                              border: Border.all(color: priorityColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPriorityIcon(t.priority),
                                  size: 14,
                                  color: priorityColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getPriorityLabel(t.priority),
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          if (t.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusFull),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.tick_circle,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Title
                      if (_isEditing)
                        AppTextField(
                          controller: _titleController,
                          hint: 'Task title',
                        )
                      else
                        Text(
                          t.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: t.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),

                      const SizedBox(height: AppSizes.lg),

                      // Due Date
                      if (t.dueDate != null) ...[
                        _buildInfoRow(
                          context,
                          icon: Iconsax.calendar,
                          label: 'Due Date',
                          value: DateFormat('EEEE, MMM dd, yyyy - HH:mm')
                              .format(t.dueDate!),
                          valueColor: isOverdue ? AppColors.error : null,
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],

                      // Assignee
                      _buildInfoRow(
                        context,
                        icon: Iconsax.user,
                        label: 'Assignee',
                        value: t.assigneeId ?? 'Unassigned',
                        isDark: isDark,
                        trailing: t.assigneeId != null
                            ? const UserAvatar(name: 'User', size: 28)
                            : TextButton(
                                onPressed: () {
                                  // TODO: Assign user
                                },
                                child: const Text('Assign'),
                              ),
                      ),

                      const SizedBox(height: AppSizes.lg),
                      const Divider(),
                      const SizedBox(height: AppSizes.lg),

                      // Description
                      Text(
                        'Description',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      if (_isEditing)
                        AppTextField(
                          controller: _descriptionController,
                          hint: 'Add description...',
                          maxLines: 5,
                        )
                      else
                        Text(
                          t.description?.isNotEmpty == true
                              ? t.description!
                              : 'No description',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: t.description?.isNotEmpty != true
                                        ? isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textTertiary
                                        : null,
                                  ),
                        ),

                      if (_isEditing) ...[
                        const SizedBox(height: AppSizes.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _isEditing = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Save changes
                                  setState(() => _isEditing = false);
                                },
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSizes.lg),
                      const Divider(),
                      const SizedBox(height: AppSizes.lg),

                      // Comments Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Comments',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          comments.when(
                            data: (list) => Text(
                              '${list.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Comments List
                      comments.when(
                        data: (commentList) {
                          if (commentList.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.lg),
                              child: Center(
                                child: Text(
                                  'No comments yet',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: commentList.map((comment) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSizes.md),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const UserAvatar(name: 'User', size: 36),
                                    const SizedBox(width: AppSizes.sm),
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(AppSizes.sm),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.surfaceVariantDark
                                              : AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusMd,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'User',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  comment.createdAt.relative,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSizes.xs),
                                            Text(comment.content),
                                            if (comment
                                                .attachmentUrls.isNotEmpty) ...[
                                              const SizedBox(
                                                  height: AppSizes.sm),
                                              Wrap(
                                                spacing: 8,
                                                children: comment.attachmentUrls
                                                    .map((url) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => Dialog(
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height: 400,
                                                            child: Image.network(
                                                                url,
                                                                fit: BoxFit
                                                                    .contain),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      width: 120,
                                                      height: 120,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                AppSizes
                                                                    .radiusMd),
                                                        child: Image.network(
                                                            url,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_,
                                                                    __, ___) =>
                                                                Icon(Icons
                                                                    .attach_file)),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, _) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Input
              Container(
                padding: EdgeInsets.only(
                  left: AppSizes.md,
                  right: AppSizes.md,
                  top: AppSizes.sm,
                  bottom: MediaQuery.of(context).padding.bottom + AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: AppStrings.addComment,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    IconButton.filled(
                      onPressed: () async {
                        if (_commentController.text.isEmpty) return;

                        final user = ref.read(authStateProvider).valueOrNull;
                        if (user == null) return;

                        await ref
                            .read(
                                commentNotifierProvider(widget.taskId).notifier)
                            .addComment(
                              userId: user.id,
                              content: _commentController.text,
                            );

                        _commentController.clear();
                      },
                      icon: const Icon(Iconsax.send_1),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSizes.xs),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: valueColor)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
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

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Iconsax.arrow_down;
      case TaskPriority.medium:
        return Iconsax.minus;
      case TaskPriority.high:
        return Iconsax.arrow_up;
      case TaskPriority.urgent:
        return Iconsax.danger;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppStrings.low;
      case TaskPriority.medium:
        return AppStrings.medium;
      case TaskPriority.high:
        return AppStrings.high;
      case TaskPriority.urgent:
        return AppStrings.urgent;
    }
  }
}
