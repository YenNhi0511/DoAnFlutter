import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/task_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
// Tạm thời comment các widget custom để tránh lỗi Null check bên trong chúng
// import '../../widgets/common/user_avatar.dart';
// import 'widgets/project_card.dart';
import 'widgets/create_project_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Thêm chức năng kéo để refresh dữ liệu
                  ref.invalidate(projectNotifierProvider);
                  ref.invalidate(currentUserProvider);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // --- APP BAR ---
                    SliverAppBar(
                      floating: true,
                      pinned: false,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: const Icon(Iconsax.task_square,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          const Text(
                            'ProjectFlow',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(isDark ? Iconsax.sun_1 : Iconsax.moon),
                          onPressed: () =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.notification),
                          onPressed: () => context.push('/notifications'),
                        ),
                        const SizedBox(width: 8),
                        // Thay UserAvatar bằng CircleAvatar cơ bản để tránh lỗi
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                currentUserAsync.value?.avatarUrl != null
                                    ? NetworkImage(
                                        currentUserAsync.value!.avatarUrl!)
                                    : null,
                            child: currentUserAsync.value?.avatarUrl == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),

                    // --- WELCOME SECTION ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${currentUserAsync.value?.name ?? 'Friend'}! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your projects efficiently',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- STATS CARDS ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSimpleStat(
                                  context,
                                  'Projects',
                                  '${projectsAsync.valueOrNull?.length ?? 0}',
                                  Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSimpleStat(
                                  context,
                                  'Tasks',
                                  '${ref.watch(assignedTasksProvider).valueOrNull?.length ?? 0}',
                                  Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // --- PROJECTS HEADER ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Projects',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () => _showCreateProjectSheet(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- PROJECTS LIST ---
                    projectsAsync.when(
                      data: (projects) {
                        if (projects.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Iconsax.folder_2,
                                        size: 48, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text("No projects yet"),
                                    TextButton(
                                      onPressed: () =>
                                          _showCreateProjectSheet(context),
                                      child: const Text("Create one"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final project = projects[index];
                              // Sử dụng màu mặc định thay vì truy cập project.color nếu model thiếu trường này
                              // Nếu model có trường colorHex thì dùng:
                              // final color = Color(int.parse(project.colorHex.replaceFirst('#', '0xFF')));
                              // Ở đây dùng màu ngẫu nhiên cho an toàn:
                              final color = Colors
                                  .primaries[index % Colors.primaries.length];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.folder,
                                        color: Colors.white),
                                  ),
                                  title: Text(project.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  // Kiểm tra an toàn cho description
                                  subtitle: Text(
                                      project.description ?? 'No description'),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                  onTap: () =>
                                      context.push('/project/${project.id}'),
                                ),
                              );
                            },
                            childCount: projects.length,
                          ),
                        );
                      },
                      loading: () => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppLoadingWidget(message: 'Loading projects...'),
                      ),
                      error: (err, stack) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppErrorWidget(
                          message: err.toString(),
                          onRetry: () => ref.refresh(projectNotifierProvider),
                        ),
                      ),
                    ),

                    // Padding bottom để không bị che bởi FAB
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectSheet(context),
        icon: const Icon(Iconsax.add),
        label: const Text('New Project'),
      ),

      // Giữ nguyên Bottom Navigation Bar của bạn
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.push('/tasks');
          if (index == 2) context.push('/calendar');
          if (index == 3) context.push('/settings');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          NavigationDestination(icon: Icon(Iconsax.task), label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Iconsax.calendar), label: 'Calendar'),
          NavigationDestination(
              icon: Icon(Iconsax.setting_2), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ĐÃ XÓA const ở đây để sửa lỗi "Not a constant expression"
      builder: (context) => CreateProjectSheet(),
    );
  }
}
