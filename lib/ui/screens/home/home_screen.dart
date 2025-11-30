import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/user_avatar.dart';
import 'widgets/project_card.dart';
import 'widgets/create_project_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final projects = ref.watch(projectNotifierProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Iconsax.task_square,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(isDark ? Iconsax.sun_1 : Iconsax.moon),
                  onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Iconsax.notification),
                  onPressed: () => context.push('/notifications'),
                ),
                const SizedBox(width: AppSizes.xs),
                currentUser.when(
                  data: (user) => GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSizes.md),
                      child: UserAvatar(
                        name: user?.name ?? 'User',
                        imageUrl: user?.avatarUrl,
                        size: 36,
                      ),
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(right: AppSizes.md),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),

            // Welcome Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    currentUser.when(
                      data: (user) => Text(
                        'Hello, ${user?.name.split(' ').first ?? 'there'}! 👋',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn().slideX(begin: -0.05),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Manage your projects efficiently',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
                  ],
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Iconsax.folder_2,
                        label: 'Projects',
                        value: projects.valueOrNull?.length.toString() ?? '0',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Iconsax.task,
                        label: 'Tasks',
                        value: '12', // TODO: Calculate from tasks
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Iconsax.timer_1,
                        label: 'Due Soon',
                        value: '3', // TODO: Calculate from tasks
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.myProjects,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCreateProjectSheet(context),
                      icon: const Icon(Iconsax.add, size: 18),
                      label: const Text('New'),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),

            // Filter Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 0),
                      const SizedBox(width: AppSizes.sm),
                      _buildFilterChip('Active', 1),
                      const SizedBox(width: AppSizes.sm),
                      _buildFilterChip('Shared', 2),
                      const SizedBox(width: AppSizes.sm),
                      _buildFilterChip('Archived', 3),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ),
            ),

            // Projects Grid
            projects.when(
              data: (projectList) {
                if (projectList.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Iconsax.folder_2,
                      title: AppStrings.noProjects,
                      subtitle: AppStrings.startFirstProject,
                      actionText: AppStrings.createProject,
                      onAction: () => _showCreateProjectSheet(context),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.isMobile ? 1 : 2,
                      mainAxisSpacing: AppSizes.md,
                      crossAxisSpacing: AppSizes.md,
                      childAspectRatio: context.isMobile ? 1.8 : 1.5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projectList[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => context.push('/project/${project.id}'),
                        ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.1);
                      },
                      childCount: projectList.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectSheet(context),
        icon: const Icon(Iconsax.add),
        label: const Text('New Project'),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) context.push('/tasks');
          if (index == 2) context.push('/calendar');
          if (index == 3) context.push('/settings');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.home),
            selectedIcon: Icon(Iconsax.home_15),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.task),
            selectedIcon: Icon(Iconsax.task5),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.calendar),
            selectedIcon: Icon(Iconsax.calendar_15),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.setting_2),
            selectedIcon: Icon(Iconsax.setting_25),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filtering
      },
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
      ),
    );
  }

  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateProjectSheet(),
    );
  }
}

