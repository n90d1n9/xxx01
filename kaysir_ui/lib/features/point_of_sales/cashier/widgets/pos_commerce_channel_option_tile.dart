import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_behavior.dart';
import '../experiences/pos_commerce_channel_switch_preview.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel_behavior_summary.dart';
import 'pos_commerce_channel_icons.dart';
import 'pos_commerce_channel_switch_preview_summary.dart';
import 'pos_ui.dart';

class POSCommerceChannelOptionTile extends StatelessWidget {
  final POSCommerceChannel channel;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final bool showDescription;
  final String? statusLabel;
  final bool statusRequiresAttention;
  final POSCommerceChannelSwitchPreview? preview;
  final POSCommerceChannelBehaviorProfile? behaviorProfile;

  const POSCommerceChannelOptionTile({
    super.key,
    required this.channel,
    this.constraints = const BoxConstraints.tightFor(width: 286),
    this.padding = EdgeInsets.zero,
    this.showDescription = false,
    this.statusLabel,
    this.statusRequiresAttention = false,
    this.preview,
    this.behaviorProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            POSIconBadge(
              icon: posCommerceChannelIcon(channel.kind),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              size: 34,
            ),
            const SizedBox(width: POSUiTokens.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    channel.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (statusLabel != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _POSCommerceChannelStatusChip(
                        label: statusLabel!,
                        requiresAttention: statusRequiresAttention,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    showDescription
                        ? channel.description
                        : channel.fulfillmentSummary,
                    maxLines: showDescription ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _POSCommerceChannelMetaChip(
                        icon: posLayoutPreferenceIcon(channel.preferredLayout),
                        label: channel.preferredLayout.label,
                      ),
                      _POSCommerceChannelMetaChip(
                        icon: Icons.local_shipping_outlined,
                        label: _summaryLabel(
                          channel.fulfillmentModes,
                          (mode) => mode.label,
                        ),
                      ),
                      if (showDescription)
                        _POSCommerceChannelMetaChip(
                          icon: Icons.tune_outlined,
                          label: _summaryLabel(
                            channel.capabilities,
                            (capability) => capability.label,
                          ),
                        ),
                    ],
                  ),
                  if (preview != null) ...[
                    const SizedBox(height: 5),
                    POSCommerceChannelSwitchPreviewSummary(preview: preview!),
                  ],
                  if (behaviorProfile != null) ...[
                    const SizedBox(height: 5),
                    POSCommerceChannelBehaviorSummary(profile: behaviorProfile),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summaryLabel<T>(List<T> values, String Function(T value) labelOf) {
    if (values.isEmpty) return 'None';
    if (values.length == 1) return labelOf(values.first);
    if (values.length == 2) {
      return values.map(labelOf).join(', ');
    }

    return '${labelOf(values.first)} +${values.length - 1}';
  }
}

class _POSCommerceChannelStatusChip extends StatelessWidget {
  final String label;
  final bool requiresAttention;

  const _POSCommerceChannelStatusChip({
    required this.label,
    required this.requiresAttention,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        requiresAttention
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer;
    final foreground =
        requiresAttention
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSecondaryContainer;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _POSCommerceChannelMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _POSCommerceChannelMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
