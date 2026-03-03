import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/widgets/user_avatar.dart';
import '../../../core/common/constants/user_state.dart';
import '../../view_models/friend_view_model.dart';

enum RequestType {
  sent,
  received,
}

class PendingWidget extends ConsumerStatefulWidget {
  const PendingWidget({super.key});

  @override
  ConsumerState<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends ConsumerState<PendingWidget> {
  RequestType _selectedType = RequestType.received;

  void _acceptRequest(String requestId, String name) {
    ref.read(friendViewModelProvider.notifier).acceptFriendRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bạn và $name đã trở thành bạn bè')),
    );
  }

  void _rejectRequest(String requestId) {
    ref.read(friendViewModelProvider.notifier).rejectFriendRequest(requestId);
  }

  void _cancelRequest(String requestId) {
    ref.read(friendViewModelProvider.notifier).cancelFriendRequest(requestId);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to trigger rebuilds on state changes
    ref.watch(friendViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<RequestType>(
            segments: const [
              ButtonSegment(
                value: RequestType.sent,
                label: Text('Sent Requests'),
                icon: Icon(Icons.send),
              ),
              ButtonSegment(
                value: RequestType.received,
                label: Text('Received Requests'),
                icon: Icon(Icons.inbox),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<RequestType> newSelection) {
              setState(() {
                _selectedType = newSelection.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF0F62FE);
                  }
                  return Colors.white;
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black87;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRequestList(),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    final state = ref.watch(friendViewModelProvider);
    final requests = _selectedType == RequestType.sent
        ? state.sentRequests
        : state.receivedRequests;

    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _selectedType == RequestType.sent
                ? 'No sent requests'
                : 'No received requests',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      children: requests.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: request.user.avatarUrl ?? 'https://i.pravatar.cc/150',
                status: UserStatus.unknown,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.user.effectiveDisplayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (request.note != null && request.note!.isNotEmpty)
                      Text(
                        request.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (_selectedType == RequestType.received) ...[
                ElevatedButton(
                  onPressed: () => _acceptRequest(
                    request.requestId,
                    request.user.effectiveDisplayName,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _rejectRequest(request.requestId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
              ],
              if (_selectedType == RequestType.sent)
                IconButton(
                  onPressed: () => _cancelRequest(request.requestId),
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Cancel request',
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
