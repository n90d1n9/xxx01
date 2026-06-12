import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_strategy.dart';
import 'text_badge.dart';
import 'tone.dart';

class ChannelCoverageSignalTile extends StatelessWidget {
  const ChannelCoverageSignalTile({
    required this.width,
    required this.signal,
    this.showRequirementBadge = false,
    super.key,
  });

  final double width;
  final ChannelCoverageSignal signal;
  final bool showRequirementBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = channelCoverageToneColor(theme.colorScheme, signal.tone);

    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            channelCoverageSignalIcon(signal.type),
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        signal.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (showRequirementBadge) ...[
                      const SizedBox(width: POSUiTokens.gap),
                      ChannelCoverageRequirementBadge(
                        isRequired: signal.isRequired,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  signal.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  signal.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelCoverageRequirementBadge extends StatelessWidget {
  const ChannelCoverageRequirementBadge({required this.isRequired, super.key});

  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isRequired) {
      return TextBadge(
        label: 'Required',
        tone: VisualTone.primary,
        backgroundSource: ToneBackgroundSource.foreground,
        backgroundAlpha: 0.1,
        borderAlpha: 0.2,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      );
    }

    final color = theme.colorScheme.outline;

    return TextBadge(
      label: 'Optional',
      foregroundColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

IconData channelCoverageSignalIcon(ChannelCoverageSignalType type) {
  return switch (type) {
    ChannelCoverageSignalType.channels => Icons.hub_outlined,
    ChannelCoverageSignalType.fulfillment => Icons.local_shipping_outlined,
    ChannelCoverageSignalType.payments => Icons.payments_outlined,
    ChannelCoverageSignalType.customers => Icons.account_circle_outlined,
    ChannelCoverageSignalType.fulfillmentTracking =>
      Icons.track_changes_outlined,
    ChannelCoverageSignalType.channelRequirement => Icons.fact_check_outlined,
  };
}

Color channelCoverageToneColor(ColorScheme scheme, ChannelCoverageTone tone) {
  return switch (tone) {
    ChannelCoverageTone.ready => scheme.secondary,
    ChannelCoverageTone.attention => scheme.error,
  };
}
