import 'package:flutter/material.dart';

import '../utils/order_save_outbox_auto_sync_state.dart';
import '../utils/order_save_outbox_freshness.dart';
import '../utils/order_save_outbox_status_presentation.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_status_visuals.dart';

class OrderSaveOutboxStatusAction extends StatelessWidget {
  final POSOrderSaveOutboxSummary summary;
  final POSOrderSaveOutboxSyncState syncState;
  final POSOrderSaveOutboxAutoSyncState autoSyncState;
  final POSOrderSaveOutboxFreshnessState freshnessState;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;
  final VoidCallback? onPressed;

  const OrderSaveOutboxStatusAction({
    super.key,
    required this.summary,
    this.syncState = const POSOrderSaveOutboxSyncState.idle(),
    this.autoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.freshnessState = const POSOrderSaveOutboxFreshnessState.fresh(),
    this.syncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: summary,
      syncState: syncState,
      autoSyncState: autoSyncState,
      freshnessState: freshnessState,
      syncBehavior: syncBehavior,
      hasAction: onPressed != null,
      actionKind: POSOrderSaveOutboxStatusActionKind.review,
    );
    if (!presentation.shouldSurface) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: presentation.tooltip,
      icon: Badge.count(
        count: summary.attentionCount,
        isLabelVisible: summary.attentionCount > 0,
        child: Icon(
          POSOrderSaveOutboxStatusVisuals.iconFor(presentation.intent),
        ),
      ),
      onPressed: presentation.canPress ? onPressed : null,
    );
  }
}
