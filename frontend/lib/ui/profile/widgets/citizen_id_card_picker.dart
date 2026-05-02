import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for selecting and previewing CCCD (Citizen ID Card) images
class CitizenIdCardPicker extends StatelessWidget {
  final String? currentFrontUrl;
  final String? currentBackUrl;
  final XFile? selectedFrontImage;
  final XFile? selectedBackImage;
  final ValueChanged<XFile?>? onFrontImageSelected;
  final ValueChanged<XFile?>? onBackImageSelected;
  final VoidCallback? onViewFront;
  final VoidCallback? onViewBack;
  final bool isEditing;

  const CitizenIdCardPicker({
    super.key,
    this.currentFrontUrl,
    this.currentBackUrl,
    this.selectedFrontImage,
    this.selectedBackImage,
    this.onFrontImageSelected,
    this.onBackImageSelected,
    this.onViewFront,
    this.onViewBack,
    this.isEditing = false,
  });

  Future<void> _pickImage(ValueChanged<XFile?>? onImageSelected) async {
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

  Widget _buildCardImage({
    required String? currentUrl,
    required XFile? selectedImage,
    required String label,
    required VoidCallback? onTap,
    required ValueChanged<XFile?>? onImageSelected,
  }) {
    final imageProvider = _resolveImageProvider(
      currentUrl: currentUrl,
      selectedImage: selectedImage,
    );
    final hasImage = imageProvider != null;

    return GestureDetector(
      onTap: isEditing ? () => _pickImage(onImageSelected) : onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300] ?? Colors.grey,
                width: 2,
              ),
              color: Colors.grey[100],
            ),
            child: Stack(
              children: [
                // Card image
                if (hasImage)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.credit_card,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  ),
                // Overlay for edit mode
                if (isEditing)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black54,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveImageProvider({
    required String? currentUrl,
    required XFile? selectedImage,
  }) {
    if (selectedImage != null) {
      final file = File(selectedImage.path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final safeUrl = currentUrl?.trim();
    if (safeUrl != null && safeUrl.isNotEmpty) {
      return NetworkImage(safeUrl);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Card Images',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCardImage(
                currentUrl: currentFrontUrl,
                selectedImage: selectedFrontImage,
                label: 'Front Side',
                onTap: onViewFront,
                onImageSelected: onFrontImageSelected,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardImage(
                currentUrl: currentBackUrl,
                selectedImage: selectedBackImage,
                label: 'Back Side',
                onTap: onViewBack,
                onImageSelected: onBackImageSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
