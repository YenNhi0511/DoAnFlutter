import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/common/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: currentUser.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // User Profile Card
            Card(
              elevation: 0,
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Row(
                  children: [
                    UserAvatar(
                      name: user?.name ?? 'User',
                      imageUrl: user?.avatarUrl,
                      size: 60,
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.edit),
                      onPressed: () {
                        // TODO: Navigate to edit profile
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Appearance Section
            _buildSectionHeader(context, 'Giao diện', Iconsax.brush),
            _buildSettingsTile(
              context: context,
              icon: themeMode == ThemeMode.dark ? Iconsax.moon : Iconsax.sun_1,
              title: 'Chế độ tối',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Notifications Section
            _buildSectionHeader(context, 'Thông báo', Iconsax.notification),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.notification_bing,
              title: 'Thông báo Push',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Handle notification settings
                },
                activeColor: AppColors.primary,
              ),
            ),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.message_notif,
              title: 'Thông báo Task',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Handle task notification settings
                },
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Account Section
            _buildSectionHeader(context, 'Tài khoản', Iconsax.user),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.lock,
              title: 'Đổi mật khẩu',
              onTap: () {
                context.push('/forgot-password');
              },
            ),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.security,
              title: 'Bảo mật & Quyền riêng tư',
              onTap: () {
                // TODO: Navigate to security settings
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // About Section
            _buildSectionHeader(context, 'Về ứng dụng', Iconsax.info_circle),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.document,
              title: 'Điều khoản sử dụng',
              onTap: () {
                _showDialog(
                  context,
                  'Điều khoản sử dụng',
                  'Đây là ứng dụng quản lý dự án cá nhân. '
                      'Vui lòng sử dụng có trách nhiệm.',
                );
              },
            ),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.shield_security,
              title: 'Chính sách bảo mật',
              onTap: () {
                _showDialog(
                  context,
                  'Chính sách bảo mật',
                  'Chúng tôi bảo vệ thông tin cá nhân của bạn. '
                      'Dữ liệu được lưu trữ an toàn trên Supabase.',
                );
              },
            ),
            _buildSettingsTile(
              context: context,
              icon: Iconsax.information,
              title: 'Phiên bản',
              trailing: const Text('1.0.0'),
            ),

            const SizedBox(height: AppSizes.xl),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    'Đăng xuất',
                    'Bạn có chắc muốn đăng xuất?',
                  );

                  if (confirm == true) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                icon: const Icon(Iconsax.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Lỗi tải thông tin')),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.md,
        bottom: AppSizes.sm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(title),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Iconsax.arrow_right_3,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
