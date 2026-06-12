import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_actions.dart';
import '../utils/order_save_outbox_auto_sync_state.dart';
import '../utils/order_save_outbox_display.dart';
import '../utils/order_save_outbox_freshness.dart';
import '../utils/order_save_outbox_header_summary.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_action_bar.dart';
import 'order_save_outbox_auto_sync_notice.dart';
import 'order_save_outbox_activity_timeline.dart';
import 'order_save_outbox_browser.dart';
import 'order_save_outbox_freshness_notice.dart';
import 'order_save_outbox_health_overview.dart';
import 'order_save_outbox_sync_notice.dart';
import 'order_save_outbox_sync_policy_strip.dart';

class OrderSaveOutboxDetailsDialog extends StatelessWidget {
  final POSOrderSaveOutbox outbox;
  final POSOrderSaveOutboxSummary summary;
  final POSOrderSaveOutboxSyncState syncState;
  final POSOrderSaveOutboxAutoSyncState autoSyncState;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;
  final POSOrderSaveOutboxViewFilter? initialFilter;
  final VoidCallback? onSync;
  final VoidCallback? onClearSent;
  final ValueChanged<POSOrderSaveOutboxEntry>? onRetry;
  final ValueChanged<List<POSOrderSaveOutboxEntry>>? onRetryEntries;
  final DateTime? freshnessNow;

  const OrderSaveOutboxDetailsDialog({
    super.key,
    required this.outbox,
    required this.summary,
    required this.syncState,
    this.autoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.syncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    this.initialFilter,
    this.onSync,
    this.onClearSent,
    this.onRetry,
    this.onRetryEntries,
    this.freshnessNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: summary,
      syncState: syncState,
      syncBehavior: syncBehavior,
      hasSyncHandler: onSync != null,
      hasClearSentHandler: onClearSent != null,
    );
    final freshnessState = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: syncBehavior,
      now: freshnessNow ?? DateTime.now(),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
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
                  const POSIconBadge(icon: Icons.cloud_sync_outlined),
                  const SizedBox(width: POSUiTokens.gapLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          syncBehavior.queueTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          syncState.operatorMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: POSUiTokens.gap),
                        _OrderSaveOutboxHeaderSummary(summary: summary),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  key: const ValueKey('order-save-outbox-details-scroll'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderSaveOutboxHealthOverview(
                        summary: summary,
                        syncState: syncState,
                        autoSyncState: autoSyncState,
                        syncBehavior: syncBehavior,
                      ),
                      if (freshnessState.shouldSurface) ...[
                        const SizedBox(height: 16),
                        OrderSaveOutboxFreshnessNotice(
                          freshnessState: freshnessState,
                        ),
                      ],
                      const SizedBox(height: 16),
                      OrderSaveOutboxActionBar(
                        actions: actions,
                        onSync: onSync,
                        onClearSent: onClearSent,
                      ),
                      const SizedBox(height: 16),
                      OrderSaveOutboxSyncPolicyStrip(behavior: syncBehavior),
                      const SizedBox(height: 16),
                      OrderSaveOutboxAutoSyncNotice(
                        autoSyncState: autoSyncState,
                      ),
                      if (autoSyncState.shouldSurface)
                        const SizedBox(height: 16),
                      OrderSaveOutboxSyncNotice(syncState: syncState),
                      if (syncState.phase != POSOrderSaveOutboxSyncPhase.idle)
                        const SizedBox(height: 16),
                      OrderSaveOutboxActivityTimeline(
                        activity: outbox.activity,
                      ),
                      if (outbox.activity.isNotEmpty)
                        const SizedBox(height: 16),
                      OrderSaveOutboxBrowser(
                        outbox: outbox,
                        summary: summary,
                        syncState: syncState,
                        syncBehavior: syncBehavior,
                        initialFilter: initialFilter,
                        onRetry: onRetry,
                        onRetryEntries: onRetryEntries,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSaveOutboxHeaderSummary extends StatelessWidget {
  final POSOrderSaveOutboxSummary summary;

  const _OrderSaveOutboxHeaderSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerSummary = POSOrderSaveOutboxHeaderSummary.fromSummary(summary);

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          headerSummary.metrics.map((metric) {
            final palette = _metricPalette(theme, metric.kind);
            return POSMetricPill(
              icon: Icon(_metricIcon(metric.kind)),
              label: metric.label,
              value: metric.value,
              backgroundColor: palette.background,
              foregroundColor: palette.foreground,
            );
          }).toList(),
    );
  }

  IconData _metricIcon(POSOrderSaveOutboxHeaderMetricKind kind) {
    switch (kind) {
      case POSOrderSaveOutboxHeaderMetricKind.status:
        return _statusIcon();
      case POSOrderSaveOutboxHeaderMetricKind.review:
        return Icons.priority_high_rounded;
      case POSOrderSaveOutboxHeaderMetricKind.synced:
        return Icons.cloud_done_outlined;
    }
  }

  IconData _statusIcon() {
    switch (summary.health) {
      case POSOrderSaveOutboxHealth.failed:
        return Icons.sync_problem_outlined;
      case POSOrderSaveOutboxHealth.syncing:
        return Icons.sync_outlined;
      case POSOrderSaveOutboxHealth.queued:
        return Icons.cloud_upload_outlined;
      case POSOrderSaveOutboxHealth.ready:
        return Icons.cloud_done_outlined;
    }
  }

  _OrderSaveOutboxHeaderPalette _metricPalette(
    ThemeData theme,
    POSOrderSaveOutboxHeaderMetricKind kind,
  ) {
    switch (kind) {
      case POSOrderSaveOutboxHeaderMetricKind.status:
        return _statusPalette(theme);
      case POSOrderSaveOutboxHeaderMetricKind.review:
        return _OrderSaveOutboxHeaderPalette(
          background: theme.colorScheme.errorContainer,
          foreground: theme.colorScheme.onErrorContainer,
        );
      case POSOrderSaveOutboxHeaderMetricKind.synced:
        return _OrderSaveOutboxHeaderPalette(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );
    }
  }

  _OrderSaveOutboxHeaderPalette _statusPalette(ThemeData theme) {
    switch (summary.health) {
      case POSOrderSaveOutboxHealth.failed:
        return _OrderSaveOutboxHeaderPalette(
          background: theme.colorScheme.errorContainer,
          foreground: theme.colorScheme.onErrorContainer,
        );
      case POSOrderSaveOutboxHealth.syncing:
      case POSOrderSaveOutboxHealth.queued:
        return _OrderSaveOutboxHeaderPalette(
          background: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
        );
      case POSOrderSaveOutboxHealth.ready:
        return _OrderSaveOutboxHeaderPalette(
          background: theme.colorScheme.primaryContainer,
          foreground: theme.colorScheme.onPrimaryContainer,
        );
    }
  }
}

class _OrderSaveOutboxHeaderPalette {
  final Color background;
  final Color foreground;

  const _OrderSaveOutboxHeaderPalette({
    required this.background,
    required this.foreground,
  });
}
