import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Advanced SliverAppBar with parallax, gradient, and custom effects
class AdvancedSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? elevation;
  final Widget? bottom;

  const AdvancedSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expandedHeight = 200,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? AppColors.surfaceDark : AppColors.surface);
    final fgColor = foregroundColor ?? 
        (isDark ? Colors.white : AppColors.textPrimary);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      elevation: elevation,
      backgroundColor: gradient == null ? bgColor : Colors.transparent,
      foregroundColor: fgColor,
      leading: leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        title: subtitle != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: fgColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(
          left: AppSizes.lg,
          bottom: AppSizes.md,
        ),
        background: gradient != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
                child: flexibleSpace,
              )
            : flexibleSpace,
      ),
    );
  }
}

/// SliverAppBar with parallax effect
class ParallaxSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? background;
  final double parallaxSpeed;
  final List<Widget>? actions;

  const ParallaxSliverAppBar({
    super.key,
    required this.title,
    this.background,
    this.parallaxSpeed = 0.5,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final expandRatio = (constraints.maxHeight - 
              MediaQuery.of(context).padding.top - kToolbarHeight) / 
              (250 - MediaQuery.of(context).padding.top - kToolbarHeight);
          
          return FlexibleSpaceBar(
            title: Text(
              title,
              style: TextStyle(
                color: expandRatio > 0.5 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Transform.translate(
              offset: Offset(0, -constraints.maxHeight * parallaxSpeed * (1 - expandRatio)),
              child: background ?? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.darken(0.2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: actions,
    );
  }
}

