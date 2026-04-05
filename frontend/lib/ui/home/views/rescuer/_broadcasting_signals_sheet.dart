import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/broadcasting_signals_local_storage.dart';
import '../../../../domain/models/broadcasting_signal.dart';
import '../../widgets/_broadcasting_signal_sheet/broadcasting_signal_sort_dialog.dart';
import '../../view_models/broadcasting_signals_view_model.dart';

class BroadcastingSignalsSheet extends ConsumerStatefulWidget {
  final Future<bool> Function(String victimUserId) onLocateVictim;

  const BroadcastingSignalsSheet({super.key, required this.onLocateVictim});

  @override
  ConsumerState<BroadcastingSignalsSheet> createState() =>
      _BroadcastingSignalsSheetState();
}

class _BroadcastingSignalsSheetState
    extends ConsumerState<BroadcastingSignalsSheet> {
  String? _locateMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(broadcastingSignalsViewModelProvider.notifier).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(broadcastingSignalsViewModelProvider);
    final viewModel = ref.read(broadcastingSignalsViewModelProvider.notifier);

    ref.listen<BroadcastingSignalsState>(broadcastingSignalsViewModelProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        viewModel.clearError();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${state.signals.length} active signals',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showSortDialog(context, state.sortCriteria),
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Sort'),
              ),
              IconButton(
                onPressed: state.isLoading ? null : viewModel.refresh,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_locateMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0F62FE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF0F62FE),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locateMessage!,
                        style: const TextStyle(
                          color: Color(0xFF0F62FE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.signals.isEmpty)
            _EmptySignals(onRefresh: viewModel.refresh)
          else
            Column(
              children: state.signals
                  .map(
                    (signal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SignalCard(
                        signal: signal,
                        onLocate: () async {
                          final focused = await widget.onLocateVictim(
                            signal.createdBy,
                          );
                          if (!focused) {
                            _showLocateMessage(
                              'Victim location is not available yet',
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  void _showLocateMessage(String message) {
    setState(() {
      _locateMessage = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _locateMessage = null;
      });
    });
  }

  Future<void> _showSortDialog(
    BuildContext context,
    List<BroadcastingSignalsSortCriterion> current,
  ) async {
    final selected = await showDialog<List<BroadcastingSignalsSortCriterion>>(
      context: context,
      builder: (dialogContext) =>
          BroadcastingSignalSortDialog(currentCriteria: current),
    );

    if (selected != null && selected.isNotEmpty && mounted) {
      await ref
          .read(broadcastingSignalsViewModelProvider.notifier)
          .applySortCriteria(selected);
    }
  }
}

class _SignalCard extends StatelessWidget {
  final BroadcastingSignal signal;
  final Future<void> Function() onLocate;

  const _SignalCard({required this.signal, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    final createdLabel = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(signal.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signal.userFullname.isEmpty
                          ? signal.createdBy
                          : signal.userFullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signal.userPhoneNumber ?? 'No phone number',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BROADCASTING',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Trapped', value: '${signal.trappedCount}'),
              _InfoChip(label: 'Children', value: '${signal.childrenNum}'),
              _InfoChip(label: 'Elderly', value: '${signal.elderlyNum}'),
              _InfoChip(label: 'Food', value: signal.hasFood ? 'Yes' : 'No'),
              _InfoChip(label: 'Water', value: signal.hasWater ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 10),
          if ((signal.note ?? '').isNotEmpty)
            Text(
              'Note: ${signal.note}',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          if ((signal.note ?? '').isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Created: $createdLabel',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onLocate(),
                icon: const Icon(Icons.location_searching),
                label: const Text('Locate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptySignals extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptySignals({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.shield_outlined, size: 42, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            const Text(
              'No active distress broadcasts right now.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
