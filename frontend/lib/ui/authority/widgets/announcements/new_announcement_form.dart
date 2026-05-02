import 'package:flutter/material.dart';

import '../../theme/authority_theme.dart';

class NewAnnouncementForm extends StatelessWidget {
  const NewAnnouncementForm({
    super.key,
    required this.titleController,
    required this.captionController,
    required this.fileName,
    required this.isPickingFile,
    required this.fileUploadProgress,
    required this.isPublishing,
    required this.onPickFile,
    required this.onClearFile,
    required this.onPublish,
  });

  final TextEditingController titleController;
  final TextEditingController captionController;
  final String? fileName;
  final bool isPickingFile;
  final double fileUploadProgress;
  final bool isPublishing;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Announcement',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AuthorityTheme.textDark,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: captionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isPublishing || isPickingFile ? null : onPickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('Upload document'),
          ),
          if (fileName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: isPublishing ? null : onClearFile,
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove file',
                  ),
                ],
              ),
            ),
          ],
          if (isPublishing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: fileUploadProgress),
            const SizedBox(height: 8),
            Text(
              'Publishing ${(100 * fileUploadProgress).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPublishing ? null : onPublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthorityTheme.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
    );
  }
}
