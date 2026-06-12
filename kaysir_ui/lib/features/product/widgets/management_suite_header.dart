import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/experience_profile.dart';
import '../models/management_pack.dart';
import '../models/management_suite_destination.dart';
import '../models/sales_channel_profile.dart';
import 'management_suite_navigation_items.dart';
import 'management_suite_navigation_profiles.dart';

/// Context header for standalone product management suite screens.
class ProductManagementSuiteHeader extends StatelessWidget {
  const ProductManagementSuiteHeader({
    super.key,
    required this.title,
    required this.activeItem,
    required this.navigationProfile,
    required this.managementPack,
    required this.channelProfile,
    this.activeSection,
    this.experienceProfile,
  });

  final String title;
  final ProductManagementSuiteNavigationItem activeItem;
  final ProductManagementSuiteNavigationSection? activeSection;
  final ProductManagementSuiteNavigationProfile navigationProfile;
  final ProductManagementPack managementPack;
  final ProductSalesChannelProfile channelProfile;
  final ProductExperienceProfile? experienceProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileLabel =
        experienceProfile?.workspaceTitle ?? navigationProfile.label;
    final headerContent = LayoutBuilder(
      builder: (context, constraints) {
        final titleBlock = _ProductManagementSuiteHeaderTitle(
          title: title,
          subtitle: activeItem.subtitle,
          icon: activeItem.icon,
        );
        final contextPills = _ProductManagementSuiteHeaderPills(
          activeSection: activeSection,
          navigationProfileLabel: profileLabel,
          managementPack: managementPack,
          channelProfile: channelProfile,
        );

        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [titleBlock, const SizedBox(height: 14), contextPills],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Align(
                alignment: Alignment.centerRight,
                child: contextPills,
              ),
            ),
          ],
        );
      },
    );

    return AppSurface(
      key: const ValueKey('product-management-suite-header'),
      padding: const EdgeInsets.all(18),
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.04),
        colorScheme.surface,
      ),
      borderColor: colorScheme.primary.withValues(alpha: 0.14),
      child: headerContent,
    );
  }
}

@Preview(name: 'Product management suite header')
Widget productManagementSuiteHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementSuiteHeader(
          title: 'Channel readiness',
          activeItem: productManagementSuiteChannelReadinessItem,
          activeSection: productManagementSuiteNavigationSectionFor(
            ProductManagementSuiteDestination.channelReadiness,
          ),
          navigationProfile: productManagementCommercialNavigationProfile,
          managementPack: coreProductManagementPack,
          channelProfile: omniRetailProductSalesChannelProfile,
        ),
      ),
    ),
  );
}

class _ProductManagementSuiteHeaderTitle extends StatelessWidget {
  const _ProductManagementSuiteHeaderTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductManagementSuiteHeaderPills extends StatelessWidget {
  const _ProductManagementSuiteHeaderPills({
    required this.activeSection,
    required this.navigationProfileLabel,
    required this.managementPack,
    required this.channelProfile,
  });

  final ProductManagementSuiteNavigationSection? activeSection;
  final String navigationProfileLabel;
  final ProductManagementPack managementPack;
  final ProductSalesChannelProfile channelProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeSectionLabel = activeSection?.label;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (activeSectionLabel != null)
          AppStatusPill(
            label: '$activeSectionLabel area',
            color: colorScheme.primary,
            icon: Icons.dashboard_customize_rounded,
            maxWidth: 180,
          ),
        AppStatusPill(
          label: '$navigationProfileLabel profile',
          color: colorScheme.tertiary,
          icon: Icons.tune_rounded,
          maxWidth: 190,
        ),
        AppStatusPill(
          label: managementPack.title,
          color: colorScheme.secondary,
          icon: Icons.inventory_2_rounded,
          maxWidth: 180,
        ),
        AppStatusPill(
          label: channelProfile.title,
          color: colorScheme.error,
          icon: Icons.hub_rounded,
          maxWidth: 180,
        ),
      ],
    );
  }
}
