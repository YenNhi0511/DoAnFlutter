import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/board_column_model.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/board_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/project_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/kanban_column.dart';
import 'widgets/create_task_sheet.dart';

class BoardScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String boardId;

  const BoardScreen({
    super.key,
    required this.projectId,
    required this.boardId,
  });

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  bool _showCompleted = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- HÀM TẠO CỘT MỚI (ĐÃ SỬA LỖI) ---
  void _showAddColumnDialog(BuildContext context) {
    final controller = TextEditingController();
    String selectedColor = '#E2E8F0'; // Màu mặc định

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Column Name',
                  hintText: 'Enter column name (e.g. Pending)',
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.md),
              Wrap(
                spacing: AppSizes.sm,
                children: [
                  '#E2E8F0',
                  '#DDD6FE',
                  '#FED7AA',
                  '#BBF7D0',
                  '#FECACA',
                  '#BAE6FD',
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedColor = color);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              // Thêm async để chờ kết quả
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    await ref
                        .read(columnNotifierProvider(widget.boardId).notifier)
                        .createColumn(
                          name: controller.text,
                          colorHex: selectedColor,
                        );

                    // Refresh danh sách cột
                    ref.invalidate(columnsStreamProvider(widget.boardId));

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Created column successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create column: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(boardProvider(widget.boardId));
    final columns = ref.watch(columnsStreamProvider(widget.boardId));
    final tasks = ref.watch(boardTasksStreamProvider(widget.boardId));
    final project = ref.watch(projectProvider(widget.projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        title: board.when(
          data: (b) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b?.name ?? 'Board',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              project.when(
                data: (p) => Text(
                  p?.name ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) {
              if (value == 'add_column') _showAddColumnDialog(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_column',
                child: Row(
                  children: [
                    Icon(Iconsax.add, size: 18),
                    SizedBox(width: 8),
                    Text('Add Column'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Iconsax.setting_2, size: 18),
                    SizedBox(width: 8),
                    Text('Board Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: columns.when(
        data: (columnList) {
          if (columnList.isEmpty) {
            return EmptyState(
              icon: Iconsax.element_3,
              title: 'No columns yet',
              subtitle: 'Add columns to organize your tasks',
              actionText: 'Add Column',
              onAction: () => _showAddColumnDialog(context),
            );
          }

          return tasks.when(
            data: (taskList) {
              // Filter tasks
              final filteredTasks = taskList.where((task) {
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  if (!task.title.toLowerCase().contains(query) &&
                      (task.description?.toLowerCase().contains(query) !=
                          true)) {
                    return false;
                  }
                }
                if (_selectedPriority != null &&
                    task.priority != _selectedPriority) {
                  return false;
                }
                if (!_showCompleted && task.isCompleted) {
                  return false;
                }
                return true;
              }).toList();

              // Group tasks by column
              final tasksByColumn = <String, List<TaskModel>>{};
              for (final column in columnList) {
                tasksByColumn[column.id] = filteredTasks
                    .where((t) => t.columnId == column.id)
                    .toList()
                  ..sort((a, b) => a.position.compareTo(b.position));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxHeight: constraints.maxHeight,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...columnList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final column = entry.value;
                              return SizedBox(
                                width: AppSizes.kanbanColumnWidth,
                                child: KanbanColumn(
                                  key: ValueKey(column.id),
                                  column: column,
                                  tasks: tasksByColumn[column.id] ?? [],
                                  onAddTask: () =>
                                      _showCreateTaskSheet(context, column),
                                  onTaskMoved:
                                      (taskId, newColumnId, newPosition) {
                                    ref
                                        .read(
                                            taskNotifierProvider(widget.boardId)
                                                .notifier)
                                        .moveTask(
                                            taskId, newColumnId, newPosition);
                                  },
                                  onTaskTap: (task) =>
                                      _showTaskDetails(context, task),
                                )
                                    .animate(delay: (100 * index).ms)
                                    .fadeIn()
                                    .slideX(begin: 0.1),
                              );
                            }),
                            _buildAddColumnButton(context, isDark),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const AppLoadingWidget(message: 'Loading tasks...'),
            error: (error, _) => AppErrorWidget(
              message: error.toString(),
              onRetry: () =>
                  ref.refresh(boardTasksStreamProvider(widget.boardId)),
            ),
          );
        },
        loading: () => const AppLoadingWidget(message: 'Loading columns...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(columnsStreamProvider(widget.boardId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final columnList = columns.valueOrNull;
          if (columnList != null && columnList.isNotEmpty) {
            _showCreateTaskSheet(context, columnList.first);
          } else {
            // Nếu chưa có cột thì hiện dialog tạo cột
            _showAddColumnDialog(context);
          }
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _buildAddColumnButton(BuildContext context, bool isDark) {
    return Container(
      width: AppSizes.kanbanColumnWidth,
      margin: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.md),
      height: 60,
      child: InkWell(
        onTap: () => _showAddColumnDialog(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant)
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.add,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Add Column',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTaskSheet(BuildContext context, BoardColumnModel column) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTaskSheet(
        projectId: widget.projectId,
        boardId: widget.boardId,
        columnId: column.id,
      ),
    );
  }

  void _showTaskDetails(BuildContext context, TaskModel task) {
    context.push('/task/${task.id}');
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
            hintText: 'Search by title or description...',
            prefixIcon: Icon(Iconsax.search_normal),
          ),
          autofocus: true,
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = '');
                _searchController.clear();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Tasks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Priority:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                children: [
                  null,
                  TaskPriority.low,
                  TaskPriority.medium,
                  TaskPriority.high,
                  TaskPriority.urgent,
                ].map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return FilterChip(
                    label: Text(priority == null
                        ? 'All'
                        : priority.toString().split('.').last),
                    selected: isSelected,
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedPriority = selected ? priority : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  const Text('Show Completed:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Switch(
                    value: _showCompleted,
                    onChanged: (value) {
                      setDialogState(() => _showCompleted = value);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedPriority = null;
                  _showCompleted = true;
                });
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
