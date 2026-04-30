import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/review_frame.dart';
import '../../widgets/announcements/new_announcement_form.dart';
import '../../widgets/announcements/new_announcement_overview.dart';
import '../../widgets/announcements/published_announcement_detail.dart';
import '../../widgets/announcements/published_announcements_list.dart';
import '../../view_models/announcements_view_model.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key, this.sectionQuery});

  final String? sectionQuery;

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _captionController;
  String? _fileName;
  String? _mimeType;
  Uint8List? _fileBytes;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  bool get _isPublishedSection =>
      (widget.sectionQuery ?? 'new').toLowerCase() == 'published';

  void _resetDraft() {
    _titleController.clear();
    _captionController.clear();
    setState(() {
      _fileName = null;
      _mimeType = null;
      _fileBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authorityAnnouncementsViewModelProvider);
    final viewModel = ref.read(authorityAnnouncementsViewModelProvider.notifier);

    if (_isPublishedSection &&
        !state.isLoading &&
        state.announcements.isEmpty &&
        state.endMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        viewModel.load();
      });
    }

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
        viewModel.clearError();
      });
    }

    return AuthorityReviewFrame(
      title: 'Announcements',
      filters: const [],
      listContent: _isPublishedSection
          ? PublishedAnnouncementsList(
              state: state,
              onSelect: viewModel.selectAnnouncement,
              onLoadMore: viewModel.loadMore,
            )
          : const NewAnnouncementOverview(),
      detailPanel: _isPublishedSection
          ? PublishedAnnouncementDetail(
              state: state,
              onDelete: () async {
                try {
                  await viewModel.deleteSelectedAnnouncement();
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement deleted successfully.'),
                    ),
                  );
                } catch (_) {
                  // handled by snackbar from state.errorMessage
                }
              },
              onOpenDocument: _openAnnouncementDocument,
            )
          : NewAnnouncementForm(
              titleController: _titleController,
              captionController: _captionController,
              fileName: _fileName,
              isPickingFile: _isPickingFile,
              fileUploadProgress: state.publishProgress,
              isPublishing: state.isPublishing,
              onPickFile: _pickDocument,
              onClearFile: () {
                setState(() {
                  _fileName = null;
                  _mimeType = null;
                  _fileBytes = null;
                });
              },
              onPublish: () async {
                final title = _titleController.text.trim();
                final caption = _captionController.text.trim();
                final fileBytes = _fileBytes;
                final fileName = _fileName;
                final mimeType = _mimeType;

                if (title.isEmpty || caption.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill title and caption.'),
                    ),
                  );
                  return;
                }

                if ((fileBytes == null) != (fileName == null) || (fileBytes == null) != (mimeType == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attachment data is incomplete.'),
                    ),
                  );
                  return;
                }

                try {
                  await viewModel.publishAnnouncement(
                    title: title,
                    caption: caption,
                    bytes: fileBytes,
                    fileName: fileName,
                    mimeType: mimeType,
                  );
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement published successfully.'),
                    ),
                  );
                  _resetDraft();
                } catch (_) {
                  // handled by state snackbar
                }
              },
            ),
    );
  }

  Future<void> _pickDocument() async {
    if (_isPickingFile) {
      return;
    }

    setState(() {
      _isPickingFile = true;
    });

    try {
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
      final mimeType = _inferMimeType(lowerName);
      if (mimeType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only PDF, DOCX, or XLSX files are allowed.')),
        );
        return;
      }

      setState(() {
        _fileName = file.name;
        _mimeType = mimeType;
        _fileBytes = file.bytes;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  String? _inferMimeType(String lowerName) {
    if (lowerName.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lowerName.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lowerName.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    return null;
  }

  Future<void> _openAnnouncementDocument(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid document URL.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open the document.')),
      );
    }
  }
}
