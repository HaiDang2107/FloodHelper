import 'package:flutter/material.dart';

class CharityLocationRow extends StatelessWidget {
  final String location;
  final VoidCallback? onMapPressed;
  final VoidCallback? onFocusMapPressed;

  const CharityLocationRow({
    super.key,
    required this.location,
    this.onMapPressed,
    this.onFocusMapPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Relief Location:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (onMapPressed != null)
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: onMapPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                if (onFocusMapPressed != null)
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.teal, size: 18),
                    tooltip: 'Focus campaign on map',
                    onPressed: onFocusMapPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
