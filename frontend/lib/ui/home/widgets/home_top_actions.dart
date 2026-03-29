import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/friends/_add_friend_sheet.dart';
import '../views/announcements/_announcements_sheet.dart';
import '../views/distress_signal/_distress_signal_sheet.dart';
import '../../../../data/providers/global_session_provider.dart';

typedef _ActionButtonData = ({
  IconData icon,
  VoidCallback onPressed,
  bool isSpecial,
});

class HomeTopActions extends ConsumerStatefulWidget {
  final void Function(String, Widget, {Color? backgroundColor})
      onShowBottomSheet;
  final VoidCallback onProfilePressed;
  final VoidCallback onRescuerPressed;
  final VoidCallback onCharityPressed;
  final bool isSosBroadcasting;
  final Map<String, dynamic>? sosData;
  final Function(Map<String, dynamic>) onSosBroadcast;
  final VoidCallback onSosRevoke;

  const HomeTopActions({
    super.key,
    required this.onShowBottomSheet,
    required this.onProfilePressed,
    required this.onRescuerPressed,
    required this.onCharityPressed,
    required this.isSosBroadcasting,
    this.sosData,
    required this.onSosBroadcast,
    required this.onSosRevoke,
  });

  @override
  ConsumerState<HomeTopActions> createState() => _HomeTopActionsState();
}

class _HomeTopActionsState extends ConsumerState<HomeTopActions>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final buttons = <_ActionButtonData>[
      (
        icon: Icons.settings,
        onPressed: () => widget.onShowBottomSheet('Settings', Container()),
        isSpecial: false,
      ),
      (
        icon: Icons.account_circle,
        onPressed: widget.onProfilePressed,
        isSpecial: false,
      ),
      (
        icon: Icons.person_add,
        onPressed: () =>
            widget.onShowBottomSheet('Add Friend', const AddFriendSheet()),
        isSpecial: false,
      ),
      (
        icon: Icons.campaign,
        onPressed: () =>
            widget.onShowBottomSheet('Announcements', const AnnouncementsSheet()),
        isSpecial: false,
      ),
      if (currentUser?.isRescuer ?? false)
        (
          icon: Icons.shield,
          onPressed: widget.onRescuerPressed,
          isSpecial: false,
        ),
      if (currentUser?.isBenefactor ?? false)
        (
          icon: Icons.volunteer_activism,
          onPressed: widget.onCharityPressed,
          isSpecial: false,
        ),
      (
        icon: Icons.sos,
        onPressed: () => widget.onShowBottomSheet(
              'Distress Signal',
              DistressSignalSheet(
                isBroadcasting: widget.isSosBroadcasting,
                currentSignalData: widget.sosData,
                onBroadcast: widget.onSosBroadcast,
                onRevoke: widget.onSosRevoke,
              ),
            ),
        isSpecial: true,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMapIcon(
          _isExpanded ? Icons.close : Icons.widgets,
          _toggle,
          isMain: true,
        ),
        if (_isExpanded || _controller.isAnimating)
          ...List.generate(buttons.length, (i) {
            final buttonData = buttons[i];
            final animation = CurvedAnimation(
              parent: _controller, // truyền controller vào từng nút
              curve: Interval(
                (i * 0.1),
                (0.6 + i * 0.1).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 8.0 : 0, bottom: 8.0),
                  child: _buildMapIcon(
                    buttonData.icon,
                    buttonData.onPressed,
                    isSos: buttonData.isSpecial,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMapIcon(IconData icon, VoidCallback onPressed,
      {bool isMain = false, bool isSos = false}) {
    Color backgroundColor;
    Color iconColor;

    if (isMain) {
      backgroundColor = const Color(0xFF0F62FE);
      iconColor = Colors.white;
    } else if (isSos && widget.isSosBroadcasting) {
      backgroundColor = Colors.red[100]!;
      iconColor = Colors.red[700]!;
    } else {
      backgroundColor = Colors.white;
      iconColor = const Color(0xFF0F62FE);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
