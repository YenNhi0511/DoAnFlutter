import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/project_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class CreateProjectSheet extends ConsumerStatefulWidget {
  const CreateProjectSheet({super.key});

  @override
  ConsumerState<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends ConsumerState<CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedColor = '#1E3A5F';
  String _selectedIcon = 'folder';
  bool _isLoading = false;

  final List<String> _colors = [
    '#1E3A5F', // Primary
    '#4ECDC4', // Teal
    '#FF6B6B', // Coral
    '#6366F1', // Indigo
    '#22C55E', // Green
    '#F59E0B', // Amber
    '#EC4899', // Pink
    '#8B5CF6', // Purple
  ];

  final List<Map<String, dynamic>> _icons = [
    {'name': 'folder', 'icon': Iconsax.folder_2},
    {'name': 'code', 'icon': Iconsax.code},
    {'name': 'design', 'icon': Iconsax.brush},
    {'name': 'marketing', 'icon': Iconsax.chart},
    {'name': 'personal', 'icon': Iconsax.user},
    {'name': 'team', 'icon': Iconsax.people},
    {'name': 'finance', 'icon': Iconsax.dollar_circle},
    {'name': 'education', 'icon': Iconsax.book},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final project = await ref.read(projectNotifierProvider.notifier).createProject(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          colorHex: _selectedColor,
          iconName: _selectedIcon,
        );

    setState(() => _isLoading = false);

    if (project != null && mounted) {
      context.pop();
      context.push('/project/${project.id}');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create project'),
          backgroundColor: AppColors.error,
        ),
      );
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
                AppStrings.createProject,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              const SizedBox(height: AppSizes.lg),
              
              // Project Name
              AppTextField(
                label: AppStrings.projectName,
                hint: 'Enter project name',
                controller: _nameController,
                prefixIcon: Iconsax.folder_2,
                validator: (value) => Validators.required(value, 'Project name'),
                autofocus: true,
              ),
              
              const SizedBox(height: AppSizes.md),
              
              // Description
              AppTextField(
                label: AppStrings.projectDescription,
                hint: 'Enter project description (optional)',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: Iconsax.document_text,
              ),
              
              const SizedBox(height: AppSizes.lg),
              
              // Color Selection
              Text(
                AppStrings.projectColor,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: AppSizes.lg),
              
              // Icon Selection
              Text(
                'Project Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _icons.map((item) {
                  final isSelected = _selectedIcon == item['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = item['name']),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')))
                                .withOpacity(0.2)
                            : isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: isSelected
                            ? Border.all(
                                color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        item['icon'],
                        color: isSelected
                            ? Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')))
                            : isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
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
                      onPressed: _createProject,
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
}

