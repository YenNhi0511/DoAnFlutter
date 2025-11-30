import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectColor = _parseColor(project.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: AppColors.cardShadow,
          border: Border.all(
            color: projectColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      projectColor.withOpacity(0.2),
                      projectColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon & Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: projectColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Icon(
                          _getProjectIcon(project.iconName),
                          color: projectColor,
                          size: 24,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Iconsax.more,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        onSelected: (value) {
                          // TODO: Handle menu actions
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Iconsax.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Iconsax.archive, size: 18),
                                SizedBox(width: 8),
                                Text('Archive'),
                              ],
                            ),
                          ),
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
                  
                  const Spacer(),
                  
                  // Project Name
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (project.description != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      project.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: AppSizes.sm),
                  
                  // Progress & Members
                  Row(
                    children: [
                      // Progress indicator
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '65%', // TODO: Calculate actual progress
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: projectColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                              child: LinearProgressIndicator(
                                value: 0.65, // TODO: Calculate actual progress
                                backgroundColor: projectColor.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: AppSizes.md),
                      
                      // Members
                      SizedBox(
                        width: 60,
                        child: Stack(
                          children: [
                            for (int i = 0; i < 3; i++)
                              Positioned(
                                left: i * 18.0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.tagColors[i % AppColors.tagColors.length],
                                    border: Border.all(
                                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.sm),
                  
                  // Updated date
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        'Updated ${project.updatedAt.relative}',
                        style: Theme.of(context).textTheme.bodySmall,
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

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getProjectIcon(String? iconName) {
    switch (iconName) {
      case 'folder':
        return Iconsax.folder_2;
      case 'code':
        return Iconsax.code;
      case 'design':
        return Iconsax.brush;
      case 'marketing':
        return Iconsax.chart;
      case 'personal':
        return Iconsax.user;
      default:
        return Iconsax.folder_2;
    }
  }
}

