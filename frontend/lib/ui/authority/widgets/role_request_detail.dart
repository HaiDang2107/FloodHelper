import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/authority/role_request.dart';
import '../theme/authority_theme.dart';

class RoleRequestDetail extends StatefulWidget {
  const RoleRequestDetail({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.isSubmitting = false,
  });

  final RoleRequest? request;
  final Future<void> Function(String? note)? onApprove;
  final Future<void> Function(String? note)? onReject;
  final bool isSubmitting;

  @override
  State<RoleRequestDetail> createState() => _RoleRequestDetailState();
}

class _RoleRequestDetailState extends State<RoleRequestDetail> {
  late final TextEditingController _noteController;
  String? _lastRequestId;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _syncNoteFromRequest(force: true);
  }

  @override
  void didUpdateWidget(covariant RoleRequestDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNoteFromRequest();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _syncNoteFromRequest({bool force = false}) {
    final request = widget.request;
    final requestId = request?.id;
    if (!force && requestId == _lastRequestId) {
      return;
    }

    _lastRequestId = requestId;
    _noteController.text = request?.notes ?? '';
  }

  String? _currentNote() {
    final trimmed = _noteController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.request == null) {
      return _emptyState(context);
    }

    final currentRequest = widget.request!;
    final dateLabel = DateFormat('MMM d, yyyy • h:mm a')
        .format(currentRequest.submittedAt);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(widget.request!.id),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E6F4)),
        ),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AuthorityTheme.brandBlue.withValues(alpha: 0.12),
                  child: Text(
                    currentRequest.requesterName.isNotEmpty
                        ? currentRequest.requesterName.substring(0, 1)
                        : '?',
                    style: const TextStyle(
                      color: AuthorityTheme.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRequest.requesterName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentRequest.requesterEmail,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF667085)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: currentRequest.status),
              ],
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Requested role', value: currentRequest.requestedRole.label),
            _InfoRow(label: 'Submitted', value: dateLabel),
            _InfoRow(label: 'Nickname', value: currentRequest.nickname ?? '-'),
            _InfoRow(label: 'Phone', value: currentRequest.phone),
            _InfoRow(label: 'Gender', value: currentRequest.gender ?? '-'),
            _InfoRow(label: 'Date of birth', value: currentRequest.dob ?? '-'),
            _InfoRow(label: 'Place of origin', value: currentRequest.placeOfOrigin ?? '-'),
            _InfoRow(label: 'Address', value: currentRequest.address),
            _InfoRow(label: 'Identity number', value: currentRequest.idNumber),
            _InfoRow(label: 'Date of issue', value: currentRequest.dateOfIssue ?? '-'),
            _InfoRow(label: 'Date of expire', value: currentRequest.dateOfExpire ?? '-'),
            _InfoRow(label: 'Job position', value: currentRequest.jobPosition ?? '-'),
            if (currentRequest.status != RoleRequestStatus.pending) ...[
              const SizedBox(height: 16),
              Text(
                'Reviewer notes',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                currentRequest.notes,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF475467)),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'ID documents',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ImageCard(
                    label: 'Front side',
                    imageUrl: currentRequest.frontImageUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageCard(
                    label: 'Back side',
                    imageUrl: currentRequest.backImageUrl,
                  ),
                ),
              ],
            ),
            if (currentRequest.status == RoleRequestStatus.pending) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Decision note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFE1E6F4)),
                      ),
                      onPressed: widget.isSubmitting
                          ? null
                          : () async {
                              if (widget.onReject != null) {
                                await widget.onReject!(_currentNote());
                              }
                            },
                      child: const Text('Reject request'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.isSubmitting
                          ? null
                          : () async {
                              if (widget.onApprove != null) {
                                await widget.onApprove!(_currentNote());
                              }
                            },
                      child: widget.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Approve request'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 42,
            color: AuthorityTheme.brandBlue.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a request to review',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Details and documents will appear on the right.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: const Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RoleRequestStatus status;

  Color _statusColor() {
    switch (status) {
      case RoleRequestStatus.pending:
        return const Color(0xFFCC7A00);
      case RoleRequestStatus.approved:
        return const Color(0xFF157F3B);
      case RoleRequestStatus.rejected:
        return const Color(0xFFB42318);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF667085)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: const Color(0xFF475467)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
