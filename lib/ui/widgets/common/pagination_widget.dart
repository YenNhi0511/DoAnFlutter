import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 && !isLoading
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          ...List.generate(
            totalPages > 5 ? 5 : totalPages,
            (index) {
              int page;
              if (totalPages <= 5) {
                page = index + 1;
              } else if (currentPage <= 3) {
                page = index + 1;
              } else if (currentPage >= totalPages - 2) {
                page = totalPages - 4 + index;
              } else {
                page = currentPage - 2 + index;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: page == currentPage
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: InkWell(
                    onTap: isLoading ? null : () => onPageChanged(page),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$page',
                        style: TextStyle(
                          color: page == currentPage
                              ? Colors.white
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                          fontWeight: page == currentPage
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages && !isLoading
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

