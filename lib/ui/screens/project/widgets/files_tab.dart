import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/task_model.dart';
import '../../../../providers/task_provider.dart';
import '../../../widgets/common/empty_state.dart';

class FilesTab extends ConsumerWidget {
  final String projectId;

  const FilesTab({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tasksAsync.when(
      data: (tasks) {
        // Collect all attachments from tasks
        final attachments = <Map<String, String>>[];
        for (final task in tasks) {
          for (final url in task.attachmentUrls) {
            attachments.add({
              'url': url,
              'taskId': task.id,
              'taskTitle': task.title,
            });
          }
        }

        if (attachments.isEmpty) {
          return EmptyState(
            icon: Iconsax.document,
            title: 'No files yet',
            subtitle: 'Files attached to tasks will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final attachment = attachments[index];
            final url = attachment['url']!;
            final taskTitle = attachment['taskTitle']!;
            final fileName = url.split('/').last;

            return Card(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    _getFileIcon(fileName),
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('From: $taskTitle'),
                trailing: IconButton(
                  icon: const Icon(Iconsax.arrow_right_3),
                  onPressed: () {
                    // TODO: Open file or navigate to task
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: EmptyState(
          icon: Iconsax.danger,
          title: 'Error loading files',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Iconsax.document;
      case 'doc':
      case 'docx':
        return Iconsax.document_text;
      case 'xls':
      case 'xlsx':
        return Iconsax.document_download;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Iconsax.gallery;
      case 'zip':
      case 'rar':
        return Iconsax.archive;
      default:
        return Iconsax.document;
    }
  }
}

