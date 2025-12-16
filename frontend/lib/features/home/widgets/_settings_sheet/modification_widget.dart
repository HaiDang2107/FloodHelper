import 'package:flutter/material.dart';
import '../../../../common/widgets/user_avatar.dart';
import '../../../../common/constants/user_state.dart';

class ModificationWidget extends StatefulWidget {
  const ModificationWidget({super.key});

  @override
  State<ModificationWidget> createState() => _ModificationWidgetState();
}

class _ModificationWidgetState extends State<ModificationWidget> {
  bool _isModifying = false;

  // Mock data
  final List<Map<String, dynamic>> _seeMeUsers = [
    {'id': 1, 'name': 'Alice', 'avatar': 'https://i.pravatar.cc/150?img=1', 'status': UserStatus.online},
    {'id': 2, 'name': 'Bob', 'avatar': 'https://i.pravatar.cc/150?img=2', 'status': UserStatus.offline},
    {'id': 3, 'name': 'Charlie', 'avatar': 'https://i.pravatar.cc/150?img=3', 'status': UserStatus.online},
    {'id': 4, 'name': 'Diana', 'avatar': 'https://i.pravatar.cc/150?img=4', 'status': UserStatus.unknown},
  ];

  final List<Map<String, dynamic>> _freezeUsers = [
    {'id': 5, 'name': 'Eve', 'avatar': 'https://i.pravatar.cc/150?img=5', 'status': UserStatus.offline},
    {'id': 6, 'name': 'Frank', 'avatar': 'https://i.pravatar.cc/150?img=6', 'status': UserStatus.online},
  ];

  void _moveToFreeze(int id) {
    setState(() {
      final user = _seeMeUsers.firstWhere((user) => user['id'] == id);
      _seeMeUsers.removeWhere((user) => user['id'] == id);
      _freezeUsers.add(user);
    });
  }

  void _moveToSeeMe(int id) {
    setState(() {
      final user = _freezeUsers.firstWhere((user) => user['id'] == id);
      _freezeUsers.removeWhere((user) => user['id'] == id);
      _seeMeUsers.add(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Friends Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isModifying = !_isModifying;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F62FE),
                ),
                child: Text(
                  _isModifying ? 'Done' : 'Modify',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // See Me Section
          _buildSection(
            title: 'See Me',
            users: _seeMeUsers,
            iconColor: const Color(0xFF0F62FE), // Blue
            onRemove: _moveToFreeze,
          ),
          const SizedBox(height: 24),
          // Freeze Section
          _buildSection(
            title: 'Freeze',
            users: _freezeUsers,
            iconColor: Colors.red,
            onRemove: _moveToSeeMe,
          ),
        ],
      );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> users,
    required Color iconColor,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    UserAvatar(
                      imageUrl: user['avatar'],
                      status: user['status'],
                      size: 60,
                      topRightIcon: _isModifying ? Icons.remove : null,
                      topRightIconBackgroundColor: iconColor,
                      onTopRightIconTap: () => onRemove(user['id']),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        user['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
