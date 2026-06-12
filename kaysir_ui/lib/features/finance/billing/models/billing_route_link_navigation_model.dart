import '../utils/billing_route_link.dart';
import 'billing_navigation_destination.dart';

/// Groups billing route links into sidebar navigation sections.
class BillingRouteLinkNavigationModel {
  final List<BillingRouteLink> routeLinks;
  final List<BillingRouteLinkNavigationSection> sections;
  final BillingNavigationDestinationId selectedDestinationId;

  BillingRouteLinkNavigationModel._({
    required this.routeLinks,
    required this.sections,
    required this.selectedDestinationId,
  });

  factory BillingRouteLinkNavigationModel({
    required Iterable<BillingRouteLink> routeLinks,
    required BillingNavigationDestinationId selectedDestinationId,
  }) {
    final resolvedRouteLinks = List<BillingRouteLink>.unmodifiable(
      routeLinks.where((routeLink) => routeLink.isExposed),
    );

    return BillingRouteLinkNavigationModel._(
      routeLinks: resolvedRouteLinks,
      sections: billingRouteLinkNavigationSections(resolvedRouteLinks),
      selectedDestinationId: billingRouteLinkSelectedDestinationIdFor(
        resolvedRouteLinks,
        selectedDestinationId,
      ),
    );
  }

  bool get isEmpty => routeLinks.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<BillingRouteLinkNavigationItem> get items {
    return List.unmodifiable(sections.expand((section) => section.items));
  }

  List<BillingRouteLinkNavigationItem> get enabledItems {
    return List.unmodifiable(items.where((item) => item.isEnabled));
  }

  List<BillingRouteLinkNavigationItem> get disabledItems {
    return List.unmodifiable(items.where((item) => !item.isEnabled));
  }

  BillingRouteLinkNavigationItem? itemFor(
    BillingNavigationDestinationId destinationId,
  ) {
    for (final item in items) {
      if (item.destinationId == destinationId) return item;
    }

    return null;
  }

  BillingRouteLinkNavigationItem? itemForRouteIdentityKey(
    String routeIdentityKey,
  ) {
    final normalizedKey = routeIdentityKey.trim();
    if (normalizedKey.isEmpty) return null;

    for (final item in items) {
      if (item.routeIdentityKey == normalizedKey) return item;
    }

    return null;
  }

  bool isSelected(BillingRouteLinkNavigationItem item) {
    return item.destinationId == selectedDestinationId;
  }
}

/// Navigation item rendered from a billing route link.
class BillingRouteLinkNavigationItem {
  final BillingRouteLink routeLink;
  final BillingNavigationDestination destination;

  const BillingRouteLinkNavigationItem({
    required this.routeLink,
    required this.destination,
  });

  BillingNavigationDestinationId get destinationId => routeLink.destinationId;

  String get routeIdentityKey => routeLink.routeIdentityKey;

  bool get isEnabled => routeLink.isEnabled;

  String get description {
    if (routeLink.isEnabled) return routeLink.availabilityDescription;
    return routeLink.disabledReason ?? routeLink.availabilityDescription;
  }

  String? get sectionLabel => destination.sectionLabel;
}

/// Navigation section grouping route links by their destination metadata.
class BillingRouteLinkNavigationSection {
  final String? label;
  final List<BillingRouteLinkNavigationItem> items;

  BillingRouteLinkNavigationSection({
    required Iterable<BillingRouteLinkNavigationItem> items,
    this.label,
  }) : items = List.unmodifiable(items);

  bool get hasLabel => label?.trim().isNotEmpty == true;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(items.map((item) => item.destinationId));
  }

  List<BillingRouteLinkNavigationItem> get enabledItems {
    return List.unmodifiable(items.where((item) => item.isEnabled));
  }

  List<BillingRouteLinkNavigationItem> get disabledItems {
    return List.unmodifiable(items.where((item) => !item.isEnabled));
  }
}

List<BillingRouteLinkNavigationSection> billingRouteLinkNavigationSections(
  Iterable<BillingRouteLink> routeLinks,
) {
  final sections = <BillingRouteLinkNavigationSection>[];
  final currentItems = <BillingRouteLinkNavigationItem>[];
  String? currentLabel;

  void flushSection() {
    if (currentItems.isEmpty) return;

    sections.add(
      BillingRouteLinkNavigationSection(
        label: currentLabel,
        items: currentItems,
      ),
    );
    currentItems.clear();
  }

  for (final routeLink in routeLinks) {
    final destination = billingNavigationDestinationFor(
      routeLink.destinationId,
    );
    final sectionLabel = destination.sectionLabel;
    if (sectionLabel != null) {
      flushSection();
      currentLabel = sectionLabel;
    }

    currentItems.add(
      BillingRouteLinkNavigationItem(
        routeLink: routeLink,
        destination: destination,
      ),
    );
  }

  flushSection();

  return List.unmodifiable(sections);
}

BillingNavigationDestinationId billingRouteLinkSelectedDestinationIdFor(
  Iterable<BillingRouteLink> routeLinks,
  BillingNavigationDestinationId selectedDestination,
) {
  for (final routeLink in routeLinks) {
    if (routeLink.destinationId == selectedDestination && routeLink.isEnabled) {
      return selectedDestination;
    }
  }

  for (final routeLink in routeLinks) {
    if (routeLink.isEnabled) return routeLink.destinationId;
  }

  return selectedDestination;
}
