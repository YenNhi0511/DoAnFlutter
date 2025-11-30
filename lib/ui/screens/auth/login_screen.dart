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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? AppStrings.errorAuth),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.08),
                  
                  // Logo & Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.textTertiary.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.textTertiary.withOpacity(0.3))),
                    ],
                  ).animate().fadeIn(delay: 1000.ms),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Google Sign In
                  AppButton(
                    text: 'Continue with Google',
                    variant: AppButtonVariant.outline,
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                      // TODO: Implement Google Sign In
                    },
                  ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1),
                  
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
    );
  }
}

