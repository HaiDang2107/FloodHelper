import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostAnnouncementDialog extends StatelessWidget {
  const PostAnnouncementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController captionController = TextEditingController();

    return AlertDialog(
      title: const Text('Post Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              hintText: 'Enter announcement details...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image selected: ${image.name}')),
                );
              }
            },
            icon: const Icon(Icons.image),
            label: const Text('Attach Image'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, captionController.text),
          child: const Text('Post'),
        ),
      ],
    );
  }
}
