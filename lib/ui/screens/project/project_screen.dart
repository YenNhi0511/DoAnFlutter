import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/board_model.dart';
import '../../../data/models/project_member_model.dart';
import '../../../providers/board_provider.dart';
import '../../../providers/project_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/user_avatar.dart';
import 'widgets/activity_feed.dart';
import 'widgets/files_tab.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- HÀM XÓA DỰ ÁN ---
  Future<void> _deleteProject(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dự án?'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa dự án này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(projectNotifierProvider.notifier)
          .deleteProject(widget.projectId);

      if (success && mounted) {
        context.pop(); // Quay về màn hình Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa dự án thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- HÀM XÓA BẢNG (BOARD) ---
  Future<void> _deleteBoard(BuildContext context, String boardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bảng này?'),
        content: const Text(
            'Tất cả công việc trong bảng này sẽ bị xóa. Bạn có chắc chắn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(boardNotifierProvider(widget.projectId).notifier)
          .deleteBoard(boardId);

      // Refresh danh sách bảng
      ref.invalidate(boardsStreamProvider(widget.projectId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bảng thành công')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId));
    final boards = ref.watch(boardsStreamProvider(widget.projectId));
    final members = ref.watch(projectMembersProvider(widget.projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: project.when(
        data: (proj) {
          if (proj == null) {
            return const Center(child: Text('Project not found'));
          }

          final projectColor = _parseColor(proj.colorHex);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Iconsax.search_normal),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.notification),
                    onPressed: () {},
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.more),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteProject(context);
                      } else if (value == 'members') {
                        _showMembersSheet(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'members',
                        child: Row(
                          children: [
                            Icon(Iconsax.people, size: 18),
                            SizedBox(width: 8),
                            Text('Members'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Iconsax.setting_2, size: 18),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Project',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          projectColor,
                          projectColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.lg, AppSizes.lg, AppSizes.lg, 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Icon(
                                _getProjectIcon(proj.iconName),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              proj.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (proj.description != null) ...[
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                proj.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: AppSizes.md),
                            // Members row
                            members.when(
                              data: (memberList) => Row(
                                children: [
                                  ...memberList.take(4).map((member) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: UserAvatar(
                                        name: member.name,
                                        imageUrl: member.avatarUrl,
                                        size: 32,
                                      ),
                                    );
                                  }),
                                  if (memberList.length > 4)
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${memberList.length - 4}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () => _showMembersSheet(context),
                                    icon: const Icon(
                                      Iconsax.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Invite',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: projectColor,
                  labelColor: isDark ? Colors.white : AppColors.textPrimary,
                  tabs: const [
                    Tab(text: 'Boards'),
                    Tab(text: 'Activity'),
                    Tab(text: 'Files'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Boards Tab
                boards.when(
                  data: (boardList) {
                    if (boardList.isEmpty) {
                      return EmptyState(
                        icon: Iconsax.element_3,
                        title: 'No boards yet',
                        subtitle: 'Create your first board to get started',
                        actionText: 'Create Board',
                        onAction: () => _showCreateBoardDialog(context),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: boardList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == boardList.length) {
                          return _buildCreateBoardCard(context, isDark);
                        }

                        final board = boardList[index];
                        return _buildBoardCard(
                                context, board, projectColor, isDark)
                            .animate(delay: (100 * index).ms)
                            .fadeIn()
                            .slideY(begin: 0.1);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),

                ActivityFeed(projectId: widget.projectId),
                FilesTab(projectId: widget.projectId),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBoardDialog(context),
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _buildBoardCard(
    BuildContext context,
    BoardModel board,
    Color projectColor,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        onTap: () =>
            context.push('/project/${widget.projectId}/board/${board.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: projectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Iconsax.element_3,
                  color: projectColor,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Updated ${board.updatedAt.relative}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                  if (value == 'delete') {
                    _deleteBoard(context, board.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBoardCard(BuildContext context, bool isDark) {
    return Card(
      color: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant)
          .withOpacity(0.5),
      child: InkWell(
        onTap: () => _showCreateBoardDialog(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
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
                'Create New Board',
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

  void _showCreateBoardDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Board'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Board Name',
            hintText: 'Enter board name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            // --- SỬA LỖI Ở ĐÂY: Thêm async để chờ tạo xong rồi mới refresh ---
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                // Gọi API tạo bảng
                await ref
                    .read(boardNotifierProvider(widget.projectId).notifier)
                    .createBoard(controller.text);

                // Refresh ngay lập tức để hiện bảng mới
                ref.invalidate(boardsStreamProvider(widget.projectId));

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMembersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final members = ref.watch(projectMembersProvider(widget.projectId));

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Team Members',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showInviteMemberDialog(context),
                        icon: const Icon(Iconsax.add),
                        label: const Text('Invite'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: members.when(
                    data: (memberList) => ListView.builder(
                      controller: scrollController,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      itemCount: memberList.length,
                      itemBuilder: (context, index) {
                        final member = memberList[index];
                        return ListTile(
                          leading: UserAvatar(
                            name: member.name,
                            imageUrl: member.avatarUrl,
                            showOnlineIndicator: true,
                            isOnline: member.isOnline,
                          ),
                          title: Text(member.name),
                          subtitle: Text(member.email),
                          trailing: const Chip(label: Text('Member')),
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
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

  void _showInviteMemberDialog(BuildContext context) {
    final emailController = TextEditingController();
    MemberRole selectedRole = MemberRole.member;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Invite Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter member email',
                  prefixIcon: Icon(Iconsax.sms),
                ),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.md),
              const Text('Role:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              ...MemberRole.values.map((role) {
                if (role == MemberRole.owner) return const SizedBox.shrink();
                return RadioListTile<MemberRole>(
                  title: Text(role.toString().split('.').last.toUpperCase()),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                  dense: true,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  final success = await ref
                      .read(projectNotifierProvider.notifier)
                      .addMember(
                        widget.projectId,
                        emailController.text.trim(),
                        selectedRole,
                      );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Member invited successfully')),
                    );
                    ref.invalidate(projectMembersProvider(widget.projectId));
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Failed to invite member. User may not exist.')),
                    );
                  }
                }
              },
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }
}
