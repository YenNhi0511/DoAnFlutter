import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/error/failures.dart';

class MagicLinkScreen extends ConsumerStatefulWidget {
  final String email;
  
  const MagicLinkScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<MagicLinkScreen> createState() => _MagicLinkScreenState();
}

class _MagicLinkScreenState extends ConsumerState<MagicLinkScreen> {
  bool _isLoading = false;
  bool _linkSent = false;

  @override
  void initState() {
    super.initState();
    _sendMagicLink();
    // Listen for auth state changes (when user clicks magic link)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
        next.whenData((user) {
          if (user != null && mounted) {
            // User authenticated via magic link
            context.go('/home');
          }
        });
      });
    });
  }

  Future<void> _sendMagicLink() async {
    setState(() => _isLoading = true);
    
    final success = await ref.read(authNotifierProvider.notifier).signInWithMagicLink(
      widget.email,
    );
    
    setState(() {
      _isLoading = false;
      _linkSent = success;
    });
    
    if (!success && mounted) {
      final errorObj = ref.read(authNotifierProvider).error;
      String message = 'Không thể gửi magic link';
      if (errorObj is Failure) {
        message = errorObj.message;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceDark]
                : [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Title
                Text(
                  'Magic Link',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Chúng tôi đã gửi link đăng nhập đến email của bạn',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSizes.xl),

                // Email display
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.sms,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          widget.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSizes.xl),

                if (_linkSent) ...[
                  // Success message
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.tick_circle,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Magic link đã được gửi! Kiểm tra email và click vào link để đăng nhập.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.success,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppSizes.xl),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.surfaceDark.withOpacity(0.5)
                          : AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Hướng dẫn:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '1. Kiểm tra hộp thư email của bạn\n'
                          '2. Click vào link "Confirm your signup" trong email\n'
                          '3. Bạn sẽ được đăng nhập tự động',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ] else ...[
                  // Loading state
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],

                const SizedBox(height: AppSizes.xl),

                // Resend link
                if (_linkSent)
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _sendMagicLink,
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Gửi lại magic link'),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
