import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget to show user online/offline status
class PresenceIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const PresenceIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );
  }
}

