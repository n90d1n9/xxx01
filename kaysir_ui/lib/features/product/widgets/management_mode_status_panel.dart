import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/sales_channel_profile.dart';

/// Summary panel for the active product management pack and channel profile.
class ProductManagementModeStatusPanel extends StatelessWidget {
  const ProductManagementModeStatusPanel({
    super.key,
    required this.pack,
    required this.channelProfile,
    required this.canReset,
    required this.onReset,
  });

  final ProductManagementPack pack;
  final ProductSalesChannelProfile channelProfile;
  final bool canReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Active product mode',
      subtitle:
          '${pack.businessModelLabel} | '
          '${channelProfile.behavior.businessModelLabel}',
      leadingIcon: Icons.space_dashboard_rounded,
      trailing: TextButton.icon(
        onPressed: canReset ? onReset : null,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('Reset'),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final metrics = [
            _ModeMetric(
              icon: _packIcon(pack),
              label: 'Pack',
              value: pack.title,
              detail: pack.operatorFocusLabel,
            ),
            _ModeMetric(
              icon: _profileIcon(channelProfile.id),
              label: 'Channel',
              value: channelProfile.title,
              detail: channelProfile.behavior.operatorFocusLabel,
            ),
            _ModeMetric(
              icon: Icons.fact_check_rounded,
              label: 'Contract',
              value:
                  '${pack.requiredFields.length}/${pack.fields.length} required fields',
              detail:
                  '${channelProfile.definitions.length} selling channels active',
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < metrics.length; index += 1) ...[
                      if (index > 0) const SizedBox(width: 16),
                      Expanded(child: metrics[index]),
                    ],
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < metrics.length; index += 1) ...[
                      if (index > 0) const SizedBox(height: 14),
                      metrics[index],
                    ],
                  ],
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusPill(
                    label: canReset ? 'Custom mode' : 'Default mode',
                    color:
                        canReset
                            ? Colors.indigo.shade700
                            : Colors.teal.shade700,
                    icon:
                        canReset ? Icons.tune_rounded : Icons.verified_rounded,
                    maxWidth: 132,
                  ),
                  for (final label in pack.capabilityLabels.take(3))
                    AppStatusPill(
                      label: label,
                      color: colorScheme.primary,
                      showDot: true,
                      maxWidth: 180,
                    ),
                  for (final label in channelProfile.behavior.capabilityLabels
                      .take(2))
                    AppStatusPill(
                      label: label,
                      color: Colors.blueGrey.shade700,
                      showDot: true,
                      maxWidth: 180,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product management mode status')
Widget productManagementModeStatusPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementModeStatusPanel(
          pack: groceryFreshGoodsProductManagementPack,
          channelProfile: groceryFreshGoodsProductSalesChannelProfile,
          canReset: true,
          onReset: () {},
        ),
      ),
    ),
  );
}

class _ModeMetric extends StatelessWidget {
  const _ModeMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

IconData _packIcon(ProductManagementPack pack) {
  if (pack.id == ProductManagementPackId.groceryFreshGoods) {
    return Icons.local_grocery_store_rounded;
  }

  return Icons.inventory_2_rounded;
}

IconData _profileIcon(ProductSalesChannelProfileId id) {
  if (id == ProductSalesChannelProfileId.counterService) {
    return Icons.point_of_sale_rounded;
  }
  if (id == ProductSalesChannelProfileId.digitalCommerce) {
    return Icons.language_rounded;
  }

  return Icons.hub_rounded;
}
