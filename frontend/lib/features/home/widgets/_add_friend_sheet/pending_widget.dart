import 'package:flutter/material.dart';
import '../../../../common/widgets/user_avatar.dart';
import '../../../../common/constants/user_state.dart';

enum RequestType {
  sent,
  received,
}

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  RequestType _selectedType = RequestType.received;

  // Mock data
  final List<Map<String, dynamic>> _sentRequests = [
    {'id': 1, 'name': 'Alice Johnson', 'avatar': 'https://i.pravatar.cc/150?img=1'},
    {'id': 2, 'name': 'Bob Smith', 'avatar': 'https://i.pravatar.cc/150?img=2'},
    {'id': 3, 'name': 'Charlie Brown', 'avatar': 'https://i.pravatar.cc/150?img=3'},
  ];

  final List<Map<String, dynamic>> _receivedRequests = [
    {'id': 4, 'name': 'Diana Prince', 'avatar': 'https://i.pravatar.cc/150?img=4'},
    {'id': 5, 'name': 'Eve Williams', 'avatar': 'https://i.pravatar.cc/150?img=5'},
    {'id': 6, 'name': 'Frank Miller', 'avatar': 'https://i.pravatar.cc/150?img=6'},
    {'id': 7, 'name': 'Grace Lee', 'avatar': 'https://i.pravatar.cc/150?img=7'},
  ];

  void _acceptRequest(int id, String name) {
    setState(() {
      _receivedRequests.removeWhere((user) => user['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bạn và $name đã trở thành bạn bè')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final requests = _selectedType == RequestType.sent
        ? _sentRequests
        : _receivedRequests;

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
      children: requests.map((user) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: user['avatar'],
                status: UserStatus.unknown,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (_selectedType == RequestType.received)
                ElevatedButton(
                  onPressed: () => _acceptRequest(user['id'], user['name']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
