import 'package:flutter/material.dart';
import '../view_models/home_view_model.dart';

class HomeMapTypeSwitch extends StatelessWidget {
  final MapType selectedMapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const HomeMapTypeSwitch({
    super.key,
    required this.selectedMapType,
    required this.onMapTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MapType>(
      segments: const [
        ButtonSegment(
          value: MapType.transport,
          label: Text('Transport'),
          icon: Icon(Icons.directions_car),
        ),
        ButtonSegment(
          value: MapType.weather,
          label: Text('Weather'),
          icon: Icon(Icons.cloud),
        ),
      ],
      selected: {selectedMapType},
      onSelectionChanged: (Set<MapType> newSelection) {
        onMapTypeChanged(newSelection.first);
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
            return Colors.black;
          },
        ),
      ),
    );
  }
}
