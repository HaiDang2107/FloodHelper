import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Full-screen image viewer for network URLs and local files
class FullscreenImageViewer extends StatelessWidget {
  final String? networkUrl;
  final String? localFilePath;
  final String title;

  const FullscreenImageViewer({
    super.key,
    this.networkUrl,
    this.localFilePath,
    this.title = 'Image',
  }) : assert(networkUrl != null || localFilePath != null,
      'Either networkUrl or localFilePath must be provided');

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PhotoView(
            imageProvider: _getImageProvider(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return NetworkImage(networkUrl!);
    } else if (localFilePath != null && localFilePath!.isNotEmpty) {
      return FileImage(File(localFilePath!));
    } else {
      throw Exception('No valid image source provided');
    }
  }
}

/// Helper function to show fullscreen image viewer
void showFullscreenImageViewer({
  required BuildContext context,
  required String? networkUrl,
  required String? localFilePath,
  required String title,
}) {
  showDialog(
    context: context,
    builder: (context) => FullscreenImageViewer(
      networkUrl: networkUrl,
      localFilePath: localFilePath,
      title: title,
    ),
  );
}
