import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_inline_notice.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_auto_sync_state.dart';
import '../utils/order_save_outbox_operator_guidance.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';

class OrderSaveOutboxHealthOverview extends StatelessWidget {
  final POSOrderSaveOutboxSummary summary;
  final POSOrderSaveOutboxSyncState syncState;
  final POSOrderSaveOutboxAutoSyncState autoSyncState;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;

  const OrderSaveOutboxHealthOverview({
    super.key,
    required this.summary,
    required this.syncState,
    this.autoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.syncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
  });

  @override
  Widget build(BuildContext context) {
    final guidance = POSOrderSaveOutboxOperatorGuidance.resolve(
      summary: summary,
      syncState: syncState,
      autoSyncState: autoSyncState,
      syncBehavior: syncBehavior,
    );

    return POSInlineNotice(
      tone: _noticeTone(guidance.tone),
      icon: _icon(guidance.tone),
      title: guidance.title,
      message: guidance.message,
      footer: Wrap(
        spacing: POSUiTokens.gap,
        runSpacing: POSUiTokens.gap,
        children: [
          _metricPill(
            context,
            icon: Icons.cloud_upload_outlined,
            label: '${summary.pendingCount} queued',
            emphasis: summary.pendingCount > 0,
          ),
          _metricPill(
            context,
            icon: Icons.sync_outlined,
            label: '${summary.sendingCount} syncing',
            emphasis: summary.sendingCount > 0,
          ),
          _metricPill(
            context,
            icon: Icons.sync_problem_outlined,
            label: '${summary.failedCount} failed',
            danger: summary.failedCount > 0,
          ),
          _metricPill(
            context,
            icon: Icons.cloud_done_outlined,
            label: '${summary.sentCount} synced',
          ),
        ],
      ),
    );
  }

  Widget _metricPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool emphasis = false,
    bool danger = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return POSMetricPill(
      icon: Icon(icon),
      label: label,
      backgroundColor:
          danger
              ? colorScheme.errorContainer
              : emphasis
              ? colorScheme.secondaryContainer
              : colorScheme.surface,
      foregroundColor:
          danger
              ? colorScheme.onErrorContainer
              : emphasis
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
    );
  }

  POSInlineNoticeTone _noticeTone(POSOrderSaveOutboxGuidanceTone tone) {
    switch (tone) {
      case POSOrderSaveOutboxGuidanceTone.info:
        return POSInlineNoticeTone.info;
      case POSOrderSaveOutboxGuidanceTone.success:
        return POSInlineNoticeTone.success;
      case POSOrderSaveOutboxGuidanceTone.warning:
        return POSInlineNoticeTone.warning;
      case POSOrderSaveOutboxGuidanceTone.danger:
        return POSInlineNoticeTone.danger;
    }
  }

  IconData _icon(POSOrderSaveOutboxGuidanceTone tone) {
    switch (tone) {
      case POSOrderSaveOutboxGuidanceTone.info:
        return Icons.info_outline;
      case POSOrderSaveOutboxGuidanceTone.success:
        return Icons.cloud_done_outlined;
      case POSOrderSaveOutboxGuidanceTone.warning:
        return Icons.priority_high_rounded;
      case POSOrderSaveOutboxGuidanceTone.danger:
        return Icons.sync_problem_outlined;
    }
  }
}
