import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/held_order_provider.dart';
import '../utils/held_order_display.dart';
import 'held_order_tile.dart';
import 'pos_ui.dart';

class HeldOrdersDialog extends ConsumerWidget {
  final Future<bool> Function(HeldOrder heldOrder) onResume;

  const HeldOrdersDialog({super.key, required this.onResume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldOrders = sortHeldOrdersForPOS(ref.watch(heldOrdersProvider));
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const POSIconBadge(icon: Icons.bookmarks_outlined),
                  const SizedBox(width: POSUiTokens.gapLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Held orders',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Resume parked sales without losing the counter flow.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  POSMetricPill(
                    label:
                        '${heldOrders.length} held order${heldOrders.length == 1 ? '' : 's'}',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: POSUiTokens.gap),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child:
                    heldOrders.isEmpty
                        ? const SizedBox(
                          height: 260,
                          child: POSEmptyState(
                            icon: Icons.bookmark_border,
                            title: 'No held orders',
                            message:
                                'Use hold when a sale needs to pause and come back later.',
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          itemCount: heldOrders.length,
                          separatorBuilder:
                              (_, _) => const SizedBox(height: POSUiTokens.gap),
                          itemBuilder: (context, index) {
                            final heldOrder = heldOrders[index];
                            return HeldOrderTile(
                              heldOrder: heldOrder,
                              now: now,
                              onResume: () async {
                                final resumed = await onResume(heldOrder);
                                if (resumed && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              onRemove: () {
                                ref
                                    .read(heldOrdersProvider.notifier)
                                    .remove(heldOrder.id);
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
