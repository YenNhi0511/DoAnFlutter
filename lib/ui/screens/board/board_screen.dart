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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) {
              // TODO: Handle menu actions
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
              // Group tasks by column
              final tasksByColumn = <String, List<TaskModel>>{};
              for (final column in columnList) {
                tasksByColumn[column.id] = taskList
                    .where((t) => t.columnId == column.id)
                    .toList()
                  ..sort((a, b) => a.position.compareTo(b.position));
              }

              return Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...columnList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final column = entry.value;
                        return KanbanColumn(
                          column: column,
                          tasks: tasksByColumn[column.id] ?? [],
                          onAddTask: () => _showCreateTaskSheet(context, column),
                          onTaskMoved: (taskId, newColumnId, newPosition) {
                            ref
                                .read(taskNotifierProvider(widget.boardId).notifier)
                                .moveTask(taskId, newColumnId, newPosition);
                          },
                          onTaskTap: (task) => _showTaskDetails(context, task),
                        ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1);
                      }),
                      // Add Column Button
                      _buildAddColumnButton(context, isDark),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final columnList = columns.valueOrNull;
          if (columnList != null && columnList.isNotEmpty) {
            _showCreateTaskSheet(context, columnList.first);
          }
        },
        child: const Icon(Iconsax.add),
      ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildAddColumnButton(BuildContext context, bool isDark) {
    return Container(
      width: AppSizes.kanbanColumnWidth,
      margin: const EdgeInsets.only(left: AppSizes.md),
      child: InkWell(
        onTap: () => _showAddColumnDialog(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant)
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.add,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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

  void _showAddColumnDialog(BuildContext context) {
    final controller = TextEditingController();
    String selectedColor = '#E2E8F0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Column'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Column Name',
                hintText: 'Enter column name',
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
                    selectedColor = color;
                    (context as Element).markNeedsBuild();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
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
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(columnNotifierProvider(widget.boardId).notifier)
                    .createColumn(
                      name: controller.text,
                      colorHex: selectedColor,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
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
}

