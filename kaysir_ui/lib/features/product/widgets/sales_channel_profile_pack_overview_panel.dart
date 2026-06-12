import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_profile.dart';
import '../models/sales_channel_profile_pack_overview.dart';

/// Panel that explains which runtime packs contribute sales-channel profiles.
class ProductSalesChannelProfilePackOverviewPanel extends StatelessWidget {
  const ProductSalesChannelProfilePackOverviewPanel({
    super.key,
    required this.overview,
  });

  final ProductSalesChannelProfilePackOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Runtime packs',
      subtitle: overview.subtitleLabel,
      leadingIcon: Icons.extension_rounded,
      trailing: AppStatusPill(
        label: overview.statusLabel,
        color: colorScheme.primary,
        icon: Icons.schema_rounded,
        maxWidth: 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PackMetrics(overview: overview),
          const SizedBox(height: 14),
          if (overview.packs.isEmpty)
            _RegistryOverrideRow(overview: overview)
          else
            Column(
              children: [
                for (var index = 0; index < overview.packs.length; index += 1)
                  _PackRow(
                    summary: overview.packs[index],
                    showDivider: index != overview.packs.length - 1,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Sales channel profile packs')
Widget productSalesChannelProfilePackOverviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelProfilePackOverviewPanel(
          overview: buildProductSalesChannelProfilePackOverview(
            packs: [defaultProductSalesChannelProfilePack],
            registry: defaultProductSalesChannelProfileRegistry,
            selectedProfile: defaultProductSalesChannelProfile,
          ),
        ),
      ),
    ),
  );
}

/// Header metrics for sales-channel profile pack composition.
class _PackMetrics extends StatelessWidget {
  const _PackMetrics({required this.overview});

  final ProductSalesChannelProfilePackOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                icon: Icons.view_module_rounded,
                label: 'Packs',
                value: overview.packCountLabel,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.account_tree_rounded,
                label: 'Profiles',
                value: overview.profileCountLabel,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.bolt_rounded,
                label: 'Current source',
                value: overview.selectedSourceLabel,
                color: Colors.indigo.shade700,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricText(
                icon: Icons.flag_rounded,
                label: 'Fallback',
                value: overview.fallbackProfile.title,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Small label/value metric used by the pack overview panel.
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

/// Row describing one sales-channel profile pack.
class _PackRow extends StatelessWidget {
  const _PackRow({required this.summary, required this.showDivider});

  final ProductSalesChannelProfilePackSummary summary;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        summary.isSelectedSource
            ? colorScheme.primary
            : summary.isFallbackSource
            ? colorScheme.tertiary
            : colorScheme.outline;

    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.extension_rounded, size: 20, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                summary.profilePreviewLabel,
                maxLines: 1,
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
    final badges = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(label: summary.statusLabel, color: accent, maxWidth: 132),
        AppStatusPill(
          label: summary.profileCountLabel,
          color: Colors.blueGrey.shade700,
          showDot: true,
          maxWidth: 116,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 640) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleBlock, const SizedBox(height: 10), badges],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 16),
                badges,
              ],
            );
          },
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Empty-pack explanation for direct registry overrides.
class _RegistryOverrideRow extends StatelessWidget {
  const _RegistryOverrideRow({required this.overview});

  final ProductSalesChannelProfilePackOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.schema_rounded, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'This workspace is running from a direct profile registry override.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
