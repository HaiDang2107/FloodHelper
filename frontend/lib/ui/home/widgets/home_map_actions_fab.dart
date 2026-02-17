import 'package:flutter/material.dart';
import 'segmented_button.dart';

class HomeMapActionsFab extends StatefulWidget {
  final MapType mapType;

  const HomeMapActionsFab({super.key, required this.mapType});

  @override
  State<HomeMapActionsFab> createState() => _HomeMapActionsFabState();
}

class _HomeMapActionsFabState extends State<HomeMapActionsFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  List<Map<String, dynamic>> _getActions() {
    if (widget.mapType == MapType.transport) {
      return [
        {'icon': Icons.traffic, 'label': 'Traffic', 'tag': 'transport_1'},
        {'icon': Icons.directions_bus, 'label': 'Bus', 'tag': 'transport_2'},
      ];
    } else {
      return [
        {'icon': Icons.water_drop, 'label': 'Rain', 'tag': 'weather_1'},
        {'icon': Icons.thermostat, 'label': 'Temp', 'tag': 'weather_2'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _getActions();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(actions.length, (index) {
          return ScaleTransition(
            scale: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FloatingActionButton.small(
                heroTag: actions[index]['tag'],
                onPressed: () {
                  // TODO: Handle action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${actions[index]['label']} clicked'),
                    ),
                  );
                },
                backgroundColor: Colors.white,
                child: Icon(
                  actions[index]['icon'],
                  color: const Color(0xFF0F62FE),
                ),
              ),
            ),
          );
        }).reversed,
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: const Color(0xFF0F62FE),

          child: Icon(
            _isExpanded ? Icons.close : Icons.layers,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
