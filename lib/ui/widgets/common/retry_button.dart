import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_sizes.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  final String? label;

  const RetryButton({
    super.key,
    required this.onRetry,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Iconsax.refresh, size: 18),
      label: Text(label ?? 'Thử lại'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
    );
  }
}

