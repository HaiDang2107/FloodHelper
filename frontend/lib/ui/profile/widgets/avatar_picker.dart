import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for selecting and previewing avatar image
class AvatarPicker extends StatelessWidget {
  final String? currentAvatarUrl;
  final XFile? selectedImage;
  final ValueChanged<XFile?>? onImageSelected;
  final VoidCallback? onViewImage;
  final bool isEditing;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.selectedImage,
    this.onImageSelected,
    this.onViewImage,
    this.isEditing = false,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImageSelected?.call(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null || currentAvatarUrl != null;

    return GestureDetector(
      onTap: isEditing ? _pickImage : onViewImage,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300] ?? Colors.grey,
            width: 2,
          ),
          color: Colors.grey[100],
        ),
        child: Stack(
          children: [
            // Avatar image
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: selectedImage != null
                        ? FileImage(File(selectedImage!.path)) as ImageProvider
                        : NetworkImage(currentAvatarUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.grey[400],
                ),
              ),
            // Overlay for edit mode
            if (isEditing)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
