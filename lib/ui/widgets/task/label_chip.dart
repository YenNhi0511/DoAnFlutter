import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/label_model.dart';

class LabelChip extends StatelessWidget {
  final LabelModel label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showClose;

  const LabelChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.showClose = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = Color(
      int.parse(label.colorHex.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? labelColor.withOpacity(0.2)
              : labelColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isSelected ? labelColor : labelColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: labelColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xs),
            Text(
              label.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: labelColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            if (showClose) ...[
              const SizedBox(width: AppSizes.xs),
              Icon(
                Icons.close,
                size: 14,
                color: labelColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

