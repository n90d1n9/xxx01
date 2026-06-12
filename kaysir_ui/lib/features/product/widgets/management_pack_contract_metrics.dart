import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_contribution_bundle.dart';

/// Compact metrics for pack fields, channels, and workflow contracts.
class ProductManagementPackContractMetrics extends StatelessWidget {
  const ProductManagementPackContractMetrics({super.key, required this.bundle});

  final ProductManagementPackContributionBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BundleMetrics(bundle: bundle),
        const SizedBox(height: 14),
        _CapabilityStrip(capabilities: bundle.managementPack.capabilities),
      ],
    );
  }
}

@Preview(name: 'Management pack contract metrics')
Widget productManagementPackContractMetricsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackContractMetrics(bundle: _previewBundle),
      ),
    ),
  );
}

/// Responsive row of contract counters.
class _BundleMetrics extends StatelessWidget {
  const _BundleMetrics({required this.bundle});

  final ProductManagementPackContributionBundle bundle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 760 ? 4 : 2;
        const gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.dataset_rounded,
                label: 'Fields',
                value: bundle.fieldCountLabel,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.verified_rounded,
                label: 'Required',
                value: bundle.requiredFieldCountLabel,
                color: Colors.indigo.shade700,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.route_rounded,
                label: 'Channels',
                value: bundle.profilePackCountLabel,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.bolt_rounded,
                label: 'Workflows',
                value: bundle.workspaceActionGroupCountLabel,
                color: Colors.deepOrange.shade700,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Icon-led label/value pair for one contract metric.
class _MetricText extends StatelessWidget {
  const _MetricText({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Capability chips declared by the active management pack.
class _CapabilityStrip extends StatelessWidget {
  const _CapabilityStrip({required this.capabilities});

  final List<ProductManagementCapability> capabilities;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.deepOrange.shade700,
      Colors.blueGrey.shade700,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < capabilities.length; index += 1)
          AppStatusPill(
            label: capabilities[index].label,
            color: colors[index % colors.length],
            showDot: true,
            maxWidth: 190,
          ),
      ],
    );
  }
}

final _previewBundle = ProductManagementPackContributionBundle(
  managementPack: coreProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: const [],
  recommendationContributions: const [],
);
