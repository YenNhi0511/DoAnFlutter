import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wrapper widget for pull-to-refresh functionality
class PullToRefreshWrapper extends ConsumerWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final List<ProviderBase>? providersToRefresh;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.providersToRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
        if (providersToRefresh != null) {
          for (final provider in providersToRefresh!) {
            ref.invalidate(provider);
          }
        }
      },
      child: child,
    );
  }
}

