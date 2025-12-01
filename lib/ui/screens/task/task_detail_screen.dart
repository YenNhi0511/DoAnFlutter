import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/comment_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _commentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin task từ Provider
    final taskAsync = ref.watch(taskProvider(widget.taskId));
    // Lấy danh sách comment từ Provider (đã import comment_provider.dart)
    final commentsAsync = ref.watch(commentsStreamProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null)
            return const Center(child: Text('Không tìm thấy công việc'));

          // Cập nhật giá trị vào controller nếu chưa ở chế độ chỉnh sửa
          if (!_isEditing) {
            _titleController.text = task.title;
            _descController.text = task.description ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tiêu đề Task
                TextFormField(
                  controller: _titleController,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Tiêu đề công việc',
                  ),
                  onChanged: (val) {
                    // Đánh dấu là đang chỉnh sửa để không bị ghi đè khi rebuild
                    _isEditing = true;
                    // Bạn có thể gọi setState để hiển thị nút Lưu nếu muốn
                    setState(() {});
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // 2. Ngày hết hạn & Priority (Chip)
                Row(
                  children: [
                    if (task.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.calendar_1,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(task.dueDate!),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _getPriorityColor(task.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _getPriorityColor(task.priority)
                                .withOpacity(0.5)),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getPriorityColor(task.priority),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // 3. Mô tả
                const Text('Mô tả',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Thêm mô tả chi tiết...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  onChanged: (val) {
                    _isEditing = true;
                    setState(() {});
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // Nút Lưu thay đổi (chỉ hiện khi có chỉnh sửa)
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateTask(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lưu thay đổi',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                const Divider(height: 40),

                // 4. Bình luận (Comments)
                const Text('Bình luận',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                // Danh sách bình luận
                commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                            child: Text('Chưa có bình luận nào',
                                style: TextStyle(color: Colors.grey))),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue.shade100,
                                    child: const Icon(Icons.person,
                                        size: 16, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'User', // Tên người dùng (cần join bảng users nếu muốn hiện tên thật)
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('dd/MM HH:mm')
                                        .format(comment.createdAt),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(comment.content,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Lỗi tải bình luận: $e'),
                ),

                const SizedBox(height: 20),

                // Input bình luận
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _addComment(task.id),
                      icon: const Icon(Iconsax.send_2),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary),
                    ),
                  ],
                ),

                // Khoảng trắng dưới cùng để không bị che bởi bàn phím
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Lỗi: $e')),
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

  Future<void> _updateTask(TaskModel task) async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final updatedTask = task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(taskRepositoryProvider).updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã cập nhật công việc'),
              backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
        // Làm mới dữ liệu
        ref.invalidate(taskProvider(widget.taskId));
        ref.invalidate(assignedTasksProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addComment(String taskId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // Gọi Provider tạo comment
    await ref
        .read(commentNotifierProvider(taskId).notifier)
        .addComment(content);

    if (mounted) {
      _commentController.clear();
      // Không cần invalidate vì stream sẽ tự update
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Gọi repository trực tiếp để xóa task
      await ref.read(taskRepositoryProvider).deleteTask(widget.taskId);
      if (mounted) {
        context.pop(); // Quay lại màn hình trước
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Đã xóa công việc'), backgroundColor: Colors.green));
        // Refresh danh sách ở các màn hình khác
        ref.invalidate(assignedTasksProvider);
      }
    }
  }
}
