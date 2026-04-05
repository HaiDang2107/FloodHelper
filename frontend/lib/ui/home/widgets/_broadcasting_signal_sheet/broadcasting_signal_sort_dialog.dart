import 'package:flutter/material.dart';

import '../../../../data/services/broadcasting_signals_local_storage.dart';

class BroadcastingSignalSortDialog extends StatefulWidget {
  final List<BroadcastingSignalsSortCriterion> currentCriteria;

  const BroadcastingSignalSortDialog({
    super.key,
    required this.currentCriteria,
  });

  @override
  State<BroadcastingSignalSortDialog> createState() =>
      _BroadcastingSignalSortDialogState();
}

class _BroadcastingSignalSortDialogState
    extends State<BroadcastingSignalSortDialog> {
  late List<BroadcastingSignalsSortCriterion> _draft;

  @override
  void initState() {
    super.initState();
    _draft = List<BroadcastingSignalsSortCriterion>.from(
      widget.currentCriteria,
    );
  }

  void _moveUp(int index) {
    if (index <= 0) {
      return;
    }

    setState(() {
      final moved = _draft[index];
      _draft[index] = _draft[index - 1];
      _draft[index - 1] = moved;
    });
  }

  void _moveDown(int index) {
    if (index >= _draft.length - 1) {
      return;
    }

    setState(() {
      final moved = _draft[index];
      _draft[index] = _draft[index + 1];
      _draft[index + 1] = moved;
    });
  }

  String _criterionLabel(BroadcastingSignalsSortCriterion criterion) {
    return switch (criterion) {
      BroadcastingSignalsSortCriterion.trappedCounts => 'Trapped Counts',
      BroadcastingSignalsSortCriterion.childrenNumbers => 'Children Numbers',
      BroadcastingSignalsSortCriterion.elderlyNumbers => 'Elderly Numbers',
      BroadcastingSignalsSortCriterion.hasFood => 'Has Food',
      BroadcastingSignalsSortCriterion.hasWater => 'Has Water',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort Priority'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Signals are sorted by this priority order.\nIf all criteria tie, earlier created signal comes first.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ...List.generate(_draft.length, (index) {
              final criterion = _draft[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF0F62FE),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_criterionLabel(criterion)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: index == 0 ? null : () => _moveUp(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: index == _draft.length - 1
                          ? null
                          : () => _moveDown(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_draft),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
