import 'package:flutter/material.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/app_sizes.dart';

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = AppSizes.md,
    this.childAspectRatio = 1.5,
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
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

