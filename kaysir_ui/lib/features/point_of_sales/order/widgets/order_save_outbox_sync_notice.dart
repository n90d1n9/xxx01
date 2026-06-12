import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_inline_notice.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_sync_display.dart';
import '../utils/order_save_outbox_sync_state.dart';

class OrderSaveOutboxSyncNotice extends StatelessWidget {
  final POSOrderSaveOutboxSyncState syncState;

  const OrderSaveOutboxSyncNotice({super.key, required this.syncState});

  @override
  Widget build(BuildContext context) {
    final display = POSOrderSaveOutboxSyncDisplay.fromState(syncState);
    if (!display.isVisible) return const SizedBox.shrink();

    return POSInlineNotice(
      tone: _noticeTone(display.tone),
      icon: _noticeIcon(display.tone, syncState.phase),
      title: display.title,
      message: display.message,
      footer:
          display.metrics.isEmpty
              ? null
              : Wrap(
                spacing: POSUiTokens.gap,
                runSpacing: POSUiTokens.gap,
                children:
                    display.metrics.map((metric) {
                      return _OrderSaveOutboxSyncMetricChip(metric: metric);
                    }).toList(),
              ),
    );
  }

  POSInlineNoticeTone _noticeTone(POSOrderSaveOutboxSyncNoticeTone tone) {
    switch (tone) {
      case POSOrderSaveOutboxSyncNoticeTone.info:
        return POSInlineNoticeTone.info;
      case POSOrderSaveOutboxSyncNoticeTone.success:
        return POSInlineNoticeTone.success;
      case POSOrderSaveOutboxSyncNoticeTone.warning:
        return POSInlineNoticeTone.warning;
      case POSOrderSaveOutboxSyncNoticeTone.danger:
        return POSInlineNoticeTone.danger;
    }
  }

  IconData _noticeIcon(
    POSOrderSaveOutboxSyncNoticeTone tone,
    POSOrderSaveOutboxSyncPhase phase,
  ) {
    if (phase == POSOrderSaveOutboxSyncPhase.running) {
      return Icons.sync_outlined;
    }

    switch (tone) {
      case POSOrderSaveOutboxSyncNoticeTone.info:
        return Icons.info_outline;
      case POSOrderSaveOutboxSyncNoticeTone.success:
        return Icons.cloud_done_outlined;
      case POSOrderSaveOutboxSyncNoticeTone.warning:
        return Icons.sync_problem_outlined;
      case POSOrderSaveOutboxSyncNoticeTone.danger:
        return Icons.error_outline;
    }
  }
}

class _OrderSaveOutboxSyncMetricChip extends StatelessWidget {
  final POSOrderSaveOutboxSyncMetric metric;

  const _OrderSaveOutboxSyncMetricChip({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            metric.value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
