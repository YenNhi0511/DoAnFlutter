import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/failures.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
    _cooldownTimer?.cancel();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final errorObj = ref.read(authNotifierProvider).error;
      String message = AppStrings.errorAuth;
      String? code;
      if (errorObj is Failure) {
        message = errorObj.message;
        code = errorObj.code;
      } else if (errorObj != null) {
        message = errorObj.toString();
      }

      // If over_email_send_rate_limit, disable the register button for 5 seconds
      if (code == 'over_email_send_rate_limit') {
        setState(() {
          _isCooldown = true;
          _cooldownSeconds = 5;
        });
        _cooldownTimer?.cancel();
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _cooldownSeconds -= 1;
            if (_cooldownSeconds <= 0) {
              _isCooldown = false;
              _cooldownTimer?.cancel();
            }
          });
        });
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Join ProjectFlow and start managing your projects',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSizes.xl),

                  // Name Field
                  AppTextField(
                    label: AppStrings.fullName,
                    hint: 'Enter your full name',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Iconsax.user,
                    validator: Validators.name,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Email Field
                  AppTextField(
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Iconsax.sms,
                    validator: Validators.email,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Password Field
                  AppTextField(
                    label: AppStrings.password,
                    hint: 'Create a password',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Iconsax.lock,
                    validator: Validators.password,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Confirm Password Field
                  AppTextField(
                    label: AppStrings.confirmPassword,
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Iconsax.lock,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    onSubmitted: (_) => _register(),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.xl),

                  // Register Button
                  AppButton(
                    text: _isCooldown
                        ? 'Vui lòng chờ ($_cooldownSeconds)s'
                        : AppStrings.signUp,
                    onPressed: (_isLoading || _isCooldown) ? null : _register,
                    isLoading: _isLoading || _isCooldown,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.lg),

                  // Terms
                  Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: AppSizes.lg),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(AppStrings.login),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
