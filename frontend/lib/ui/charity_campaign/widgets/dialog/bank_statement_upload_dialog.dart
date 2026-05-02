import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

typedef BankStatementUploadHandler = Future<void> Function(
  String campaignId, {
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  required void Function(double progress) onProgress,
});

class BankStatementUploadDialog extends StatefulWidget {
  final String campaignId;
  final BankStatementUploadHandler onUpload;

  const BankStatementUploadDialog({
    super.key,
    required this.campaignId,
    required this.onUpload,
  });

  @override
  State<BankStatementUploadDialog> createState() => _BankStatementUploadDialogState();
}

class _BankStatementUploadDialogState extends State<BankStatementUploadDialog> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _progress = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'xlsx', 'docx'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    if (file.bytes == null || file.bytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot read the selected file.')),
      );
      return;
    }

    final lowerName = file.name.toLowerCase();
    if (!(lowerName.endsWith('.pdf') ||
        lowerName.endsWith('.xlsx') ||
        lowerName.endsWith('.docx'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF, XLSX, or DOCX file.')),
      );
      return;
    }

    if (file.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be under 10MB.')),
      );
      return;
    }

    setState(() {
      _selectedFile = file;
      _progress = 0;
    });
  }

  Future<void> _upload() async {
    final file = _selectedFile;
    if (file == null || file.bytes == null || file.bytes!.isEmpty) {
      return;
    }

    final mimeType = _inferMimeType(file.name);
    setState(() {
      _isUploading = true;
      _progress = 0;
    });

    try {
      await widget.onUpload(
        widget.campaignId,
        bytes: file.bytes!,
        fileName: file.name,
        mimeType: mimeType,
        onProgress: (value) {
          if (!mounted) {
            return;
          }
          setState(() {
            _progress = value.clamp(0, 1);
          });
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _inferMimeType(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lowerName.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lowerName.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = _selectedFile;

    return AlertDialog(
      title: const Text('Upload Bank Statement'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a bank statement file (PDF, XLSX, or DOCX).',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
            ),
            if (selectedFile != null) ...[
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(selectedFile.size / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isUploading
                          ? null
                          : () {
                              setState(() {
                                _selectedFile = null;
                                _progress = 0;
                              });
                            },
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove file',
                    ),
                  ],
                ),
              ),
            ],
            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                'Uploading ${(100 * _progress).toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading || selectedFile == null ? null : _upload,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}