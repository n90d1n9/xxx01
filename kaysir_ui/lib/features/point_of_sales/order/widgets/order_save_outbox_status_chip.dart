import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_auto_sync_state.dart';
import '../utils/order_save_outbox_freshness.dart';
import '../utils/order_save_outbox_status_presentation.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_status_visuals.dart';

class OrderSaveOutboxStatusChip extends StatelessWidget {
  final POSOrderSaveOutboxSummary summary;
  final POSOrderSaveOutboxSyncState syncState;
  final POSOrderSaveOutboxAutoSyncState autoSyncState;
  final POSOrderSaveOutboxFreshnessState freshnessState;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;
  final VoidCallback? onPressed;
  final bool compact;

  const OrderSaveOutboxStatusChip({
    super.key,
    required this.summary,
    this.syncState = const POSOrderSaveOutboxSyncState.idle(),
    this.autoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.freshnessState = const POSOrderSaveOutboxFreshnessState.fresh(),
    this.syncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    this.onPressed,
    this.compact = false,
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
    );
    if (!presentation.shouldSurface) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final palette = POSOrderSaveOutboxStatusVisuals.chipPalette(
      theme,
      presentation.intent,
    );

    return Tooltip(
      message: presentation.tooltip,
      child: Material(
        color: palette.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          side: BorderSide(color: palette.foreground.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: presentation.canPress ? onPressed : null,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          child: SizedBox(
            height: POSUiTokens.controlHeight,
            child: Padding(
              padding: POSUiTokens.controlPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (presentation.isBusy)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.foreground,
                      ),
                    )
                  else
                    Icon(palette.icon, size: 18, color: palette.foreground),
                  if (!compact) ...[
                    const SizedBox(width: POSUiTokens.gap),
                    Text(
                      presentation.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
