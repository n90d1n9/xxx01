import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';

/// Shows a confirmation dialog before changing sales-channel profile strategy.
Future<bool> showProductSalesChannelProfileSwitchDialog(
  BuildContext context, {
  required ProductSalesChannelProfileReadinessOption option,
}) async {
  if (option.isSelected) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => ProductSalesChannelProfileSwitchDialog(option: option),
  );

  return confirmed ?? false;
}

/// Confirmation dialog that explains the impact of a profile switch.
class ProductSalesChannelProfileSwitchDialog extends StatelessWidget {
  const ProductSalesChannelProfileSwitchDialog({
    super.key,
    required this.option,
  });

  final ProductSalesChannelProfileReadinessOption option;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _levelColor(option.summary.level);

    return AlertDialog(
      title: const Text('Switch channel strategy?'),
      content: SizedBox(
        width: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option.titleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppStatusPill(
                  label: option.statusLabel,
                  color: accent,
                  maxWidth: 130,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              option.profile.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: option.switchImpactLabel,
                  color: accent,
                  icon: Icons.compare_arrows_rounded,
                  maxWidth: 230,
                ),
                AppStatusPill(
                  label: option.readyChannelDeltaLabel,
                  color: Colors.blue.shade700,
                  icon: Icons.hub_rounded,
                  maxWidth: 190,
                ),
                AppStatusPill(
                  label: option.summary.blockerLabel,
                  color:
                      option.summary.blockedProductSlotCount == 0
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                  icon: Icons.rule_rounded,
                  maxWidth: 230,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next action',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.summary.nextActionLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppActionButton(
          label: 'Cancel',
          icon: Icons.close_rounded,
          variant: AppActionButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppActionButton(
          label: 'Switch profile',
          icon: Icons.swap_horiz_rounded,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

@Preview(name: 'Sales channel profile switch dialog')
Widget productSalesChannelProfileSwitchDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProductSalesChannelProfileSwitchDialog(
          option: _previewSwitchOption,
        ),
      ),
    ),
  );
}

Color _levelColor(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Colors.red.shade700;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Colors.orange.shade700;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Colors.green.shade700;
  }
}

final _previewSwitchOption =
    productSalesChannelProfileReadinessOptionFor(
      buildProductSalesChannelProfileReadinessOptions(
        const [],
        profiles: defaultProductSalesChannelProfiles,
        selectedProfileId: ProductSalesChannelProfileId.omniRetail,
      ),
      ProductSalesChannelProfileId.counterService,
    )!;
