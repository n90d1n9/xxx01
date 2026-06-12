import 'package:flutter/material.dart';

import '../experiences/pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack_switch_availability.dart';
import '../experiences/pos_product_runtime_pack_switch_plan.dart';
import '../experiences/pos_product_runtime_pack_switch_preview.dart';
import 'pos_runtime_pack_switch_preview_summary.dart';
import 'pos_switch_section_header.dart';
import 'pos_ui.dart';

class POSRuntimePackSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final BoxConstraints constraints;

  const POSRuntimePackSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.constraints = const BoxConstraints(minWidth: 304, maxWidth: 304),
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchSectionHeader(
      title: title,
      countLabel: '$count pack${count == 1 ? '' : 's'}',
      constraints: constraints,
    );
  }
}

class POSRuntimePackOptionTile extends StatelessWidget {
  final POSProductRuntimePack pack;
  final POSProductRuntimePackSwitchPlan plan;
  final POSProductRuntimePackSwitchAvailability availability;
  final POSProductRuntimePackSwitchPreview? preview;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;

  const POSRuntimePackOptionTile({
    super.key,
    required this.pack,
    required this.plan,
    required this.availability,
    this.preview,
    this.constraints = const BoxConstraints(minWidth: 304, maxWidth: 304),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPreview = preview;

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            POSIconBadge(
              icon: Icons.inventory_2_outlined,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pack.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      POSRuntimePackStatusPill(availability: availability),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pack.productLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _packScopeLabel(pack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _decisionImpactLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.selectionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (resolvedPreview != null) ...[
                    const SizedBox(height: 5),
                    POSRuntimePackSwitchPreviewSummary(
                      preview: resolvedPreview,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _packScopeLabel(POSProductRuntimePack pack) {
    final profileCount = pack.productProfileCatalog.profiles.length;
    final channelCount = pack.commerceChannelRegistry.channels.length;

    return '${_countLabel(profileCount, 'mode')} | '
        '${_countLabel(channelCount, 'channel')}';
  }

  String _countLabel(int count, String singular) {
    return '$count $singular${count == 1 ? '' : 's'}';
  }

  String get _decisionImpactLabel {
    if (!availability.decision.hasActiveOrder) return plan.impactLabel;
    return '${availability.statusLabel}: ${plan.impactLabel}';
  }
}

class POSRuntimePackStatusPill extends StatelessWidget {
  final POSProductRuntimePackSwitchAvailability availability;

  const POSRuntimePackStatusPill({super.key, required this.availability});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme.colorScheme);

    return Container(
      height: 24,
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 13, color: colors.foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              availability.statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    switch (availability.status) {
      case POSProductRuntimePackSwitchAvailabilityStatus.current:
        return Icons.check_circle;
      case POSProductRuntimePackSwitchAvailabilityStatus.available:
        return Icons.check_circle_outline;
      case POSProductRuntimePackSwitchAvailabilityStatus.confirm:
        return Icons.info_outline;
      case POSProductRuntimePackSwitchAvailabilityStatus.blocked:
        return Icons.block;
    }
  }

  _POSRuntimePackPillColors _colors(ColorScheme colorScheme) {
    switch (availability.status) {
      case POSProductRuntimePackSwitchAvailabilityStatus.current:
        return _POSRuntimePackPillColors(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          border: colorScheme.primary.withValues(alpha: 0.24),
        );
      case POSProductRuntimePackSwitchAvailabilityStatus.available:
        return _POSRuntimePackPillColors(
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.onSurfaceVariant,
          border: colorScheme.outlineVariant.withValues(alpha: 0.72),
        );
      case POSProductRuntimePackSwitchAvailabilityStatus.confirm:
        return _POSRuntimePackPillColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withValues(alpha: 0.24),
        );
      case POSProductRuntimePackSwitchAvailabilityStatus.blocked:
        return _POSRuntimePackPillColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withValues(alpha: 0.22),
        );
    }
  }
}

class _POSRuntimePackPillColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _POSRuntimePackPillColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
