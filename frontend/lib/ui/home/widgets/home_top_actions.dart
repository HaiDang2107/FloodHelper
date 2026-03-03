import 'package:flutter/material.dart';
import '../../charity_campaign/screens/existing_charity_screen.dart';
import '../views/friends/_add_friend_sheet.dart';
import '../views/announcements/_announcements_sheet.dart';
import '../views/distress_signal/_distress_signal_sheet.dart';

class HomeTopActions extends StatefulWidget {
  final void Function(String, Widget, {Color? backgroundColor})
      onShowBottomSheet;
  final VoidCallback onProfilePressed;
  final bool isSosBroadcasting;
  final Map<String, dynamic>? sosData;
  final Function(Map<String, dynamic>) onSosBroadcast;
  final VoidCallback onSosRevoke;

  const HomeTopActions({
    super.key,
    required this.onShowBottomSheet,
    required this.onProfilePressed,
    required this.isSosBroadcasting,
    this.sosData,
    required this.onSosBroadcast,
    required this.onSosRevoke,
  });

  @override
  State<HomeTopActions> createState() => _HomeTopActionsState();
}

class _HomeTopActionsState extends State<HomeTopActions>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;

  late final List<
      ({
        IconData icon,
        VoidCallback Function() onPressedBuilder,
        bool isSpecial
      })> _buttons;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttons = [
      (
        icon: Icons.settings,
        onPressedBuilder: () =>
            () => widget.onShowBottomSheet('Settings', Container()),
        isSpecial: false,
      ),
      (
        icon: Icons.account_circle,
        onPressedBuilder: () => widget.onProfilePressed,
        isSpecial: false,
      ),
      (
        icon: Icons.person_add,
        onPressedBuilder: () =>
            () => widget.onShowBottomSheet('Add Friend', const AddFriendSheet()),
        isSpecial: false,
      ),
      (
        icon: Icons.campaign,
        onPressedBuilder: () => () => widget.onShowBottomSheet(
            'Announcements', const AnnouncementsSheet()),
        isSpecial: false,
      ),
      (
        icon: Icons.health_and_safety,
        onPressedBuilder: () => () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rescuer feature coming soon!')),
              );
            },
        isSpecial: false,
      ),
      (
        icon: Icons.volunteer_activism,
        onPressedBuilder: () => () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExistingCharityScreen()),
              );
            },
        isSpecial: false,
      ),
      (
        icon: Icons.sos,
        onPressedBuilder: () => () => widget.onShowBottomSheet(
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
          ...List.generate(_buttons.length, (i) {
            final buttonData = _buttons[i];
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
                    buttonData.onPressedBuilder(),
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
            color: Colors.black.withOpacity(0.1),
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
