import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';
import 'sales_channel_profile_comparison_strip.dart';
import 'sales_channel_profile_readiness_strip.dart';

/// Strategy selector for choosing the active sales-channel profile.
class ProductSalesChannelProfileSelectorPanel extends StatelessWidget {
  const ProductSalesChannelProfileSelectorPanel({
    super.key,
    required this.profiles,
    required this.selectedProfile,
    required this.onChanged,
    this.readinessSummary,
    this.readinessOptions = const [],
  });

  final List<ProductSalesChannelProfile> profiles;
  final ProductSalesChannelProfile selectedProfile;
  final ValueChanged<ProductSalesChannelProfileId> onChanged;
  final ProductSalesChannelProfileReadinessSummary? readinessSummary;
  final List<ProductSalesChannelProfileReadinessOption> readinessOptions;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Channel strategy',
      subtitle: selectedProfile.subtitle,
      leadingIcon: Icons.tune_rounded,
      trailing: AppStatusPill(
        label: '${selectedProfile.definitions.length} channels',
        color: colorScheme.primary,
        maxWidth: 112,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ProductSalesChannelProfileId>(
              showSelectedIcon: false,
              segments: [
                for (final profile in profiles)
                  ButtonSegment(
                    value: profile.id,
                    icon: Icon(_icon(profile.id)),
                    label: Text(profile.title),
                  ),
              ],
              selected: {selectedProfile.id},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                onChanged(selection.first);
              },
            ),
          ),
          if (readinessSummary != null) ...[
            const SizedBox(height: 12),
            ProductSalesChannelProfileReadinessStrip(
              summary: readinessSummary!,
            ),
          ],
          if (readinessOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ProductSalesChannelProfileComparisonStrip(
              options: readinessOptions,
              onSelected: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Sales channel profile selector')
Widget productSalesChannelProfileSelectorPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelProfileSelectorPanel(
          profiles: defaultProductSalesChannelProfiles,
          selectedProfile: defaultProductSalesChannelProfile,
          readinessSummary: _previewReadinessSummary,
          readinessOptions: _previewReadinessOptions,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

IconData _icon(ProductSalesChannelProfileId id) {
  if (id == ProductSalesChannelProfileId.omniRetail) {
    return Icons.hub_rounded;
  }
  if (id == ProductSalesChannelProfileId.counterService) {
    return Icons.point_of_sale_rounded;
  }
  if (id == ProductSalesChannelProfileId.digitalCommerce) {
    return Icons.language_rounded;
  }

  return Icons.category_rounded;
}

final _previewReadinessSummary = summarizeProductSalesChannelProfileReadiness(
  buildProductSalesChannelReadiness(const []),
);

final _previewReadinessOptions =
    buildProductSalesChannelProfileReadinessOptions(
      const [],
      profiles: defaultProductSalesChannelProfiles,
      selectedProfileId: defaultProductSalesChannelProfile.id,
    );
