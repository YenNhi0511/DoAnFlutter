import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/label_model.dart';
import '../../../data/models/task_model.dart';
import 'label_chip.dart';

class LabelSelector extends ConsumerStatefulWidget {
  final String projectId;
  final List<String> selectedLabelIds;
  final Function(List<String>) onLabelsChanged;

  const LabelSelector({
    super.key,
    required this.projectId,
    required this.selectedLabelIds,
    required this.onLabelsChanged,
  });

  @override
  ConsumerState<LabelSelector> createState() => _LabelSelectorState();
}

class _LabelSelectorState extends ConsumerState<LabelSelector> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement labels provider
    final labels = <LabelModel>[]; // Placeholder

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        ...labels.map((label) {
          final isSelected = widget.selectedLabelIds.contains(label.id);
          return LabelChip(
            label: label,
            isSelected: isSelected,
            onTap: () {
              final newIds = List<String>.from(widget.selectedLabelIds);
              if (isSelected) {
                newIds.remove(label.id);
              } else {
                newIds.add(label.id);
              }
              widget.onLabelsChanged(newIds);
            },
          );
        }),
        // Add label button
        GestureDetector(
          onTap: () => _showCreateLabelDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.add,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Add Label',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateLabelDialog(BuildContext context) {
    // TODO: Implement create label dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Label'),
        content: const Text('Label creation coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

