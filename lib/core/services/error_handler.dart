import 'package:flutter/material.dart';
import '../error/failures.dart';
import '../constants/app_colors.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
  }) {
    String message = 'An error occurred';
    String? actionLabel;

    if (error is Failure) {
      message = error.message;
    } else {
      message = error.toString();
    }

    // Determine action based on error type
    if (error is NetworkFailure) {
      actionLabel = 'Retry';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            if (onRetry != null && actionLabel != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: Text(
                  actionLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Widget buildErrorWidget(
    Object error, {
    VoidCallback? onRetry,
  }) {
    String message = 'An error occurred';
    IconData icon = Icons.error_outline;

    if (error is Failure) {
      message = error.message;
      if (error is NetworkFailure) {
        icon = Icons.wifi_off;
      } else if (error is AuthFailure) {
        icon = Icons.lock_outline;
      }
    } else {
      message = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

