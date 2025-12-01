import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/error/failures.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1. Ẩn bàn phím ngay khi bấm Login để tránh lỗi layout
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    // 2. QUAN TRỌNG: Kiểm tra mounted trước khi setState hoặc dùng context sau await
    // Nếu màn hình đã bị đóng (người dùng back ra), dừng lại để tránh crash.
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      // Xử lý hiển thị lỗi
      final errorObj = ref.read(authNotifierProvider).error;
      String message = AppStrings.errorAuth;

      // Không cần biến code nếu không dùng đến
      if (errorObj is Failure) {
        message = errorObj.message;
      } else if (errorObj != null) {
        message = errorObj.toString();
      }

      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating, // Hiển thị snackbar nổi đẹp hơn
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // 3. Bọc GestureDetector để ẩn bàn phím khi chạm ra ngoài
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusLg),
                                boxShadow: AppColors.elevatedShadow,
                              ),
                              child: const Icon(
                                Iconsax.task_square,
                                size: 48,
                                color: Colors.white,
                              ),
                            ).animate().scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              AppStrings.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              AppStrings.appTagline,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 300.ms),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Welcome Text
                      Text(
                        'Welcome Back',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Sign in to continue managing your projects',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                      const SizedBox(height: AppSizes.xl),

                      // Email Field
                      AppTextField(
                        label: AppStrings.email,
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Iconsax.sms,
                        validator: Validators.email,
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSizes.md),

                      // Password Field
                      AppTextField(
                        label: AppStrings.password,
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Iconsax.lock,
                        validator: Validators.password,
                        onSubmitted: (_) => _login(),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSizes.sm),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: AppSizes.lg),

                      // Login Button
                      AppButton(
                        text: AppStrings.login,
                        onPressed: _login,
                        isLoading: _isLoading,
                      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSizes.xl),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text(AppStrings.signUp),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
