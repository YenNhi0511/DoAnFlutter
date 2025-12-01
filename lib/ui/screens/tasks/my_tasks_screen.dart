import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/empty_state.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All', icon: Icon(Iconsax.task_square)),
            Tab(text: 'Assigned', icon: Icon(Iconsax.user)),
            Tab(text: 'Due Soon', icon: Icon(Iconsax.clock)),
            Tab(text: 'Overdue', icon: Icon(Iconsax.danger)),
          ],
        ),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please login'));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: All Tasks (Dùng assignedTasksProvider làm mặc định)
              _buildTasksList(
                ref.watch(assignedTasksProvider),
                'All Tasks',
                isDark,
              ),
              // Tab 2: Assigned (Tạm thời dùng chung với All)
              _buildTasksList(
                ref.watch(assignedTasksProvider),
                'Assigned to Me',
                isDark,
              ),
              // Tab 3: Due Soon (7 days)
              _buildTasksList(
                ref.watch(upcomingTasksProvider(7)),
                'Due in 7 Days',
                isDark,
              ),
              // Tab 4: Overdue
              _buildTasksList(
                ref.watch(overdueTasksProvider),
                'Overdue Tasks',
                isDark,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildTasksList(
    AsyncValue<List<TaskModel>> tasksAsync,
    String title,
    bool isDark,
  ) {
    return tasksAsync.when(
      data: (tasks) {
        // Filter by search query if exists
        final filteredTasks = _searchQuery.isEmpty
            ? tasks
            : tasks.where((task) {
                final query = _searchQuery.toLowerCase();
                return task.title.toLowerCase().contains(query) ||
                    (task.description?.toLowerCase().contains(query) ?? false);
              }).toList();

        if (filteredTasks.isEmpty) {
          return EmptyState(
            icon: Iconsax.task_square,
            title: 'No tasks found',
            subtitle: _searchQuery.isEmpty
                ? 'You don\'t have any tasks here yet'
                : 'No tasks match your search',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh lại các provider liên quan
            ref.invalidate(assignedTasksProvider);
            ref.invalidate(overdueTasksProvider);
            ref.invalidate(upcomingTasksProvider(7));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(filteredTasks[index], isDark);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: EmptyState(
          icon: Iconsax.danger,
          title: 'Error loading tasks',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isDark) {
    final priorityColor = _getPriorityColor(task.priority);
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: isOverdue
              ? AppColors.error
              : isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/task/${task.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPriorityLabel(task.priority),
                            style: TextStyle(
                              fontSize: 10,
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Date Badge
                        if (task.dueDate != null) ...[
                          Icon(
                            Iconsax.calendar_1,
                            size: 14,
                            color: isOverdue ? AppColors.error : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, HH:mm').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? AppColors.error : Colors.grey,
                              fontWeight: isOverdue ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    _searchController.text = _searchQuery;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title...',
            prefixIcon: Icon(Iconsax.search_normal),
          ),
          autofocus: true,
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = _searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    return priority.name.toUpperCase();
  }
}
