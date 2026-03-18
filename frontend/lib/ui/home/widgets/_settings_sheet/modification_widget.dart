import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/widgets/user_avatar.dart';
import '../../../core/common/constants/user_state.dart';
import '../../../../data/models/friend_model.dart';
import '../../view_models/home_view_model.dart';

class ModificationWidget extends ConsumerStatefulWidget {
  const ModificationWidget({super.key});

  @override
  ConsumerState<ModificationWidget> createState() => _ModificationWidgetState();
}

class _ModificationWidgetState extends ConsumerState<ModificationWidget> {
  bool _isModifying = false;

  late List<FriendModel> _seeMeUsers;
  late List<FriendModel> _freezeUsers;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = ref.read(homeViewModelProvider);
      // Split friends by friendMapMode
      _seeMeUsers = state.friendsWithMapMode
          .where((f) => f.friendMapMode)
          .toList();
      _freezeUsers = state.friendsWithMapMode
          .where((f) => !f.friendMapMode)
          .toList();
      _initialized = true;
    }
  }

  void _moveToFreeze(String id) {
    setState(() {
      final user = _seeMeUsers.firstWhere((u) => u.userId == id);
      _seeMeUsers.removeWhere((u) => u.userId == id);
      _freezeUsers.add(user);
    });
  }

  void _moveToSeeMe(String id) {
    setState(() {
      final user = _freezeUsers.firstWhere((u) => u.userId == id);
      _freezeUsers.removeWhere((u) => u.userId == id);
      _seeMeUsers.add(user);
    });
  }

  void _onDone() {
    setState(() {
      _isModifying = false;
    });
    // Persist to backend via ViewModel
    final seeMeIds = _seeMeUsers.map((u) => u.userId).toList();
    final freezeIds = _freezeUsers.map((u) => u.userId).toList();
    ref.read(homeViewModelProvider.notifier).updateFriendMapModes(
      seeMeIds: seeMeIds,
      freezeIds: freezeIds,
    );
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
                onPressed: _isModifying
                    ? _onDone
                    : () {
                        setState(() {
                          _isModifying = true;
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
    required List<FriendModel> users,
    required Color iconColor,
    required Function(String) onRemove,
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
          child: users.isEmpty
              ? const Center(
                  child: Text(
                    'No friends in this group',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          UserAvatar(
                            imageUrl: user.avatarUrl,
                            status: UserStatus.offline,
                            size: 60,
                            topRightIcon: _isModifying ? Icons.remove : null,
                            topRightIconBackgroundColor: iconColor,
                            onTopRightIconTap: () => onRemove(user.userId),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              user.effectiveDisplayName,
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
