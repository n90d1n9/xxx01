import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_suite_destination.dart';
import 'management_suite_navigation_items.dart';
import 'management_suite_navigation_profiles.dart';

export '../models/management_suite_destination.dart';
export 'management_suite_navigation_items.dart';
export 'management_suite_navigation_profiles.dart';

/// Layout strategies for product management suite navigation.
enum ProductManagementSuiteNavigationLayout { adaptive, segmented, compact }

/// Reusable navigation surface for product management suite destinations.
class ProductManagementSuiteNavigation extends StatelessWidget {
  const ProductManagementSuiteNavigation({
    super.key,
    required this.activeDestination,
    required this.onSelected,
    this.layout = ProductManagementSuiteNavigationLayout.adaptive,
    this.sections = productManagementSuiteNavigationSections,
  });

  const ProductManagementSuiteNavigation.withSections({
    super.key,
    required this.activeDestination,
    required this.onSelected,
    required this.sections,
    this.layout = ProductManagementSuiteNavigationLayout.adaptive,
  });

  factory ProductManagementSuiteNavigation.withProfile({
    Key? key,
    required ProductManagementSuiteDestination activeDestination,
    required ValueChanged<ProductManagementSuiteDestination> onSelected,
    required ProductManagementSuiteNavigationProfile profile,
    ProductManagementSuiteNavigationLayout layout =
        ProductManagementSuiteNavigationLayout.adaptive,
  }) {
    return ProductManagementSuiteNavigation(
      key: key,
      activeDestination: activeDestination,
      onSelected: onSelected,
      layout: layout,
      sections: profile.sections,
    );
  }

  final ProductManagementSuiteDestination activeDestination;
  final ValueChanged<ProductManagementSuiteDestination> onSelected;
  final ProductManagementSuiteNavigationLayout layout;
  final List<ProductManagementSuiteNavigationSection> sections;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeItem = productManagementSuiteNavigationItemFor(
      activeDestination,
      sections: sections,
    );

    return AppContentPanel(
      title: 'Product management',
      subtitle: activeItem.subtitle,
      leadingIcon: Icons.account_tree_rounded,
      trailing: AppStatusPill(
        label: activeItem.label,
        color: colorScheme.primary,
        icon: activeItem.icon,
        maxWidth: 132,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedLayout = _resolvedLayoutFor(
            layout: layout,
            width: constraints.maxWidth,
          );

          return switch (resolvedLayout) {
            ProductManagementSuiteNavigationLayout.compact =>
              _ProductManagementSuiteCompactNavigation(
                activeDestination: activeDestination,
                onSelected: onSelected,
                sections: sections,
              ),
            ProductManagementSuiteNavigationLayout.segmented ||
            ProductManagementSuiteNavigationLayout
                .adaptive => _ProductManagementSuiteSegmentedNavigation(
              activeDestination: activeDestination,
              onSelected: onSelected,
              sections: sections,
            ),
          };
        },
      ),
    );
  }
}

@Preview(name: 'Product management suite navigation')
Widget productManagementSuiteNavigationPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementSuiteNavigation.withProfile(
          activeDestination: ProductManagementSuiteDestination.channelReadiness,
          profile: productManagementCommercialNavigationProfile,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

ProductManagementSuiteNavigationLayout _resolvedLayoutFor({
  required ProductManagementSuiteNavigationLayout layout,
  required double width,
}) {
  if (layout != ProductManagementSuiteNavigationLayout.adaptive) return layout;

  return width < 640
      ? ProductManagementSuiteNavigationLayout.compact
      : ProductManagementSuiteNavigationLayout.segmented;
}

class _ProductManagementSuiteSegmentedNavigation extends StatelessWidget {
  const _ProductManagementSuiteSegmentedNavigation({
    required this.activeDestination,
    required this.onSelected,
    required this.sections,
  });

  final ProductManagementSuiteDestination activeDestination;
  final ValueChanged<ProductManagementSuiteDestination> onSelected;
  final List<ProductManagementSuiteNavigationSection> sections;

  @override
  Widget build(BuildContext context) {
    final visibleSections = sections
        .where((section) => section.hasItems)
        .toList(growable: false);

    if (visibleSections.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < visibleSections.length; index++)
            Padding(
              padding: EdgeInsets.only(
                right: index == visibleSections.length - 1 ? 0 : 12,
              ),
              child: _ProductManagementSuiteSegmentSection(
                section: visibleSections[index],
                activeDestination: activeDestination,
                onSelected: onSelected,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductManagementSuiteSegmentSection extends StatelessWidget {
  const _ProductManagementSuiteSegmentSection({
    required this.section,
    required this.activeDestination,
    required this.onSelected,
  });

  final ProductManagementSuiteNavigationSection section;
  final ProductManagementSuiteDestination activeDestination;
  final ValueChanged<ProductManagementSuiteDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected =
        section.contains(activeDestination)
            ? {activeDestination}
            : <ProductManagementSuiteDestination>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            section.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SegmentedButton<ProductManagementSuiteDestination>(
          showSelectedIcon: false,
          emptySelectionAllowed: true,
          selected: selected,
          segments: [
            for (final item in section.items)
              ButtonSegment(
                value: item.destination,
                icon: Icon(item.icon),
                label: Text(item.label),
              ),
          ],
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            final destination = selection.first;
            if (destination == activeDestination) return;

            onSelected(destination);
          },
        ),
      ],
    );
  }
}

class _ProductManagementSuiteCompactNavigation extends StatelessWidget {
  const _ProductManagementSuiteCompactNavigation({
    required this.activeDestination,
    required this.onSelected,
    required this.sections,
  });

  final ProductManagementSuiteDestination activeDestination;
  final ValueChanged<ProductManagementSuiteDestination> onSelected;
  final List<ProductManagementSuiteNavigationSection> sections;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeItem = productManagementSuiteNavigationItemFor(
      activeDestination,
      sections: sections,
    );
    final items = productManagementSuiteNavigationItemsForSections(sections);
    if (items.isEmpty) return const SizedBox.shrink();

    final selectedDestination =
        items.any((item) => item.destination == activeDestination)
            ? activeDestination
            : items.first.destination;
    final radius = BorderRadius.circular(8);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return DropdownButtonFormField<ProductManagementSuiteDestination>(
      key: const ValueKey('product-management-suite-navigation-select'),
      initialValue: selectedDestination,
      isExpanded: true,
      itemHeight: 64,
      menuMaxHeight: 360,
      borderRadius: radius,
      decoration: InputDecoration(
        labelText: 'Product area',
        prefixIcon: Icon(activeItem.icon, size: 18),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
      ),
      selectedItemBuilder:
          (context) => [
            for (final item in items)
              Text(item.label, overflow: TextOverflow.ellipsis),
          ],
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item.destination,
            child: _ProductManagementSuiteMenuOption(item: item),
          ),
      ],
      onChanged: (destination) {
        if (destination == null || destination == activeDestination) return;

        onSelected(destination);
      },
    );
  }
}

class _ProductManagementSuiteMenuOption extends StatelessWidget {
  const _ProductManagementSuiteMenuOption({required this.item});

  final ProductManagementSuiteNavigationItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(item.icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
