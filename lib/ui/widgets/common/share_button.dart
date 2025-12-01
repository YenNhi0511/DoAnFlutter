import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ShareButton extends StatelessWidget {
  final String text;
  final String? subject;
  final List<String>? files;

  const ShareButton({
    super.key,
    required this.text,
    this.subject,
    this.files,
  });

  Future<void> _share(BuildContext context) async {
    try {
      if (files != null && files!.isNotEmpty) {
        final xFiles = files!.map((path) => XFile(path)).toList();
        await Share.shareXFiles(
          xFiles,
          text: text,
          subject: subject,
        );
      } else {
        await Share.share(
          text,
          subject: subject,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Iconsax.share),
      tooltip: 'Share',
      onPressed: () => _share(context),
    );
  }
}

