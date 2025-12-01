import 'package:flutter/material.dart';
import '../../../core/utils/extensions.dart';

/// Wrapper widget for responsive layouts
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double? maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? 1200,
          ),
          child: desktop!,
        ),
      );
    }

    if (context.isTablet && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

/// Responsive grid that adapts to screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    int columns = mobileColumns;
    if (context.isDesktop) {
      columns = desktopColumns;
    } else if (context.isTablet) {
      columns = tabletColumns;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.5,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

