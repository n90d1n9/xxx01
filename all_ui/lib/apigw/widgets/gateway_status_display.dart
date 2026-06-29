// Usage example for the UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/gateway_provider.dart';
import 'error_display.dart';
import 'shimmer_status_card.dart';

class GatewayStatusDisplay extends ConsumerWidget {
  const GatewayStatusDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(gatewayStatusProvider);

    // Show loading state
    if (statusState.isLoading && statusState.data == null) {
      return const ShimmerStatusCards();
    }

    // Show error state if there's an error and no data
    if (statusState.errorMessage != null && statusState.data == null) {
      return ErrorDisplay(
        message: statusState.errorMessage!,
        onRetry: () => ref.read(gatewayStatusProvider.notifier).fetchStatus(),
      );
    }

    // Show data (could be stale data while refreshing)
    if (statusState.data != null) {
      return Column(
        children: [
          // Status cards
          _buildStatusCards(statusState.data!),

          // Show a refreshing indicator if we have data but are also loading
          if (statusState.isLoading)
            const LinearProgressIndicator(minHeight: 2),

          // Last updated info
          if (statusState.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Last updated: ${_formatDateTime(statusState.lastUpdated!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          // Show error banner if we have both data and an error
          if (statusState.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed:
                        () =>
                            ref
                                .read(gatewayStatusProvider.notifier)
                                .fetchStatus(),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return const Text('No status data available');
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusCards(dynamic statusData) {
    return Container(); // Replace with your actual status cards implementation
  }
}
