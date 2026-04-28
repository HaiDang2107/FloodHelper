import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostAnnouncementPayload {
  final String caption;
  final XFile image;

  const PostAnnouncementPayload({
    required this.caption,
    required this.image,
  });
}

class PostAnnouncementDialog extends StatefulWidget {
  const PostAnnouncementDialog({super.key});

  @override
  State<PostAnnouncementDialog> createState() => _PostAnnouncementDialogState();
}

class _PostAnnouncementDialogState extends State<PostAnnouncementDialog> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedImage;

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty && _selectedImage != null;
  }

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async { // Chọn ảnh trong thư viện
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) {
      return;
    }

    final lowerName = image.name.toLowerCase();
    if (!(lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a JPG or PNG image.')),
      );
      return;
    }

    final fileSize = await image.length();
    if (fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size must be under 5MB.')),
      );
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Post Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              hintText: 'Enter announcement details...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Attach Image'),
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Selected: ${_selectedImage!.name}'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSubmit
              ? () => Navigator.pop(
                    context,
                    PostAnnouncementPayload(
                      caption: _captionController.text.trim(),
                      image: _selectedImage!,
                    ),
                  )
              : null,
          child: const Text('Post'),
        ),
      ],
    );
  }
}
