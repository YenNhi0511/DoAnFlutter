import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/task_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/task_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  final String projectId;
  final String boardId;
  final String columnId;

  const CreateTaskSheet({
    super.key,
    required this.projectId,
    required this.boardId,
    required this.columnId,
  });

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;
  final List<String> _attachmentUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);

    final task = await ref
        .read(taskNotifierProvider(widget.boardId).notifier)
        .createTask(
          columnId: widget.columnId,
          projectId: widget.projectId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          attachmentUrls: _attachmentUrls,
          createdById: user.id,
        );

    setState(() => _isLoading = false);

    if (task != null && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create task'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      setState(() {
        _dueDate = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 23,
          time?.minute ?? 59,
        );
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      setState(() => _isLoading = true);
      final file = File(picked.path);
      final url = await StorageService.uploadAttachment(file);
      setState(() => _attachmentUrls.add(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload attachment')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Title
              Text(
                AppStrings.createTask,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Task Title
              AppTextField(
                label: AppStrings.taskTitle,
                hint: 'Enter task title',
                controller: _titleController,
                prefixIcon: Iconsax.task,
                validator: (value) => Validators.required(value, 'Task title'),
                autofocus: true,
              ),

              const SizedBox(height: AppSizes.md),

              // Attachments
              Row(
                children: [
                  IconButton(
                    onPressed: _pickAttachment,
                    icon: const Icon(Iconsax.attach_circle),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  if (_attachmentUrls.isNotEmpty)
                    Text('${_attachmentUrls.length} attachments'),
                ],
              ),

              // Description
              AppTextField(
                label: AppStrings.taskDescription,
                hint: 'Enter task description (optional)',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: Iconsax.document_text,
              ),

              const SizedBox(height: AppSizes.lg),

              // Priority
              Text(
                AppStrings.priority,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _priority == priority;
                  final color = _getPriorityColor(priority);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = priority),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSizes.sm),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                          border: isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              color: isSelected ? color : null,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getPriorityLabel(priority),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isSelected ? color : null,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.lg),

              // Due Date
              Text(
                AppStrings.dueDate,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              InkWell(
                onTap: _selectDueDate,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _dueDate != null
                            ? DateFormat('MMM dd, yyyy - HH:mm')
                                .format(_dueDate!)
                            : 'Select due date (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _dueDate != null
                                  ? null
                                  : isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary,
                            ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 20),
                          onPressed: () => setState(() => _dueDate = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: AppStrings.cancel,
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppButton(
                      text: AppStrings.create,
                      onPressed: _createTask,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),
            ],
          ),
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
