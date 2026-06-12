import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_inline_notice.dart';
import '../utils/order_save_outbox_auto_sync_state.dart';

class OrderSaveOutboxAutoSyncNotice extends StatelessWidget {
  final POSOrderSaveOutboxAutoSyncState autoSyncState;

  const OrderSaveOutboxAutoSyncNotice({super.key, required this.autoSyncState});

  @override
  Widget build(BuildContext context) {
    if (!autoSyncState.shouldSurface) return const SizedBox.shrink();

    return POSInlineNotice(
      tone: _tone(autoSyncState),
      icon: _icon(autoSyncState.phase),
      title: autoSyncState.title,
      message: autoSyncState.operatorMessage,
    );
  }

  POSInlineNoticeTone _tone(POSOrderSaveOutboxAutoSyncState state) {
    switch (state.phase) {
      case POSOrderSaveOutboxAutoSyncPhase.idle:
      case POSOrderSaveOutboxAutoSyncPhase.running:
        return POSInlineNoticeTone.info;
      case POSOrderSaveOutboxAutoSyncPhase.skipped:
        return state.skipReason == POSOrderSaveOutboxAutoSyncSkipReason.disabled
            ? POSInlineNoticeTone.info
            : POSInlineNoticeTone.warning;
      case POSOrderSaveOutboxAutoSyncPhase.completed:
        return state.result?.hasFailures == true
            ? POSInlineNoticeTone.warning
            : POSInlineNoticeTone.success;
      case POSOrderSaveOutboxAutoSyncPhase.failed:
        return POSInlineNoticeTone.danger;
    }
  }

  IconData _icon(POSOrderSaveOutboxAutoSyncPhase phase) {
    switch (phase) {
      case POSOrderSaveOutboxAutoSyncPhase.idle:
        return Icons.autorenew_outlined;
      case POSOrderSaveOutboxAutoSyncPhase.skipped:
        return Icons.pause_circle_outline;
      case POSOrderSaveOutboxAutoSyncPhase.running:
        return Icons.sync_outlined;
      case POSOrderSaveOutboxAutoSyncPhase.completed:
        return Icons.cloud_done_outlined;
      case POSOrderSaveOutboxAutoSyncPhase.failed:
        return Icons.sync_problem_outlined;
    }
  }
}
