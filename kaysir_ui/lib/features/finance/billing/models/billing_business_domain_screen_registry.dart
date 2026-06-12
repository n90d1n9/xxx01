import 'billing_navigation_destination_id.dart';

enum BillingBusinessDomainScreenPresentation {
  embedded,
  route,
  sheet,
  workflow,
}

class BillingBusinessDomainScreenDescriptor {
  final BillingNavigationDestinationId destinationId;
  final BillingNavigationSurface surface;
  final String key;
  final bool requiresTenant;
  final BillingBusinessDomainScreenPresentation presentation;

  const BillingBusinessDomainScreenDescriptor({
    required this.destinationId,
    required this.surface,
    required this.key,
    this.requiresTenant = true,
    this.presentation = BillingBusinessDomainScreenPresentation.embedded,
  }) : assert(key.length > 0);

  BillingBusinessDomainScreenDescriptor copyWith({
    BillingNavigationDestinationId? destinationId,
    BillingNavigationSurface? surface,
    String? key,
    bool? requiresTenant,
    BillingBusinessDomainScreenPresentation? presentation,
  }) {
    return BillingBusinessDomainScreenDescriptor(
      destinationId: destinationId ?? this.destinationId,
      surface: surface ?? this.surface,
      key: key ?? this.key,
      requiresTenant: requiresTenant ?? this.requiresTenant,
      presentation: presentation ?? this.presentation,
    );
  }
}

class BillingBusinessDomainScreenRegistry {
  final List<BillingBusinessDomainScreenDescriptor> screens;

  BillingBusinessDomainScreenRegistry({
    Iterable<BillingBusinessDomainScreenDescriptor> screens = const [],
  }) : screens = List.unmodifiable(_ensureUnique(screens));

  bool get isEmpty => screens.isEmpty;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(screens.map((screen) => screen.destinationId));
  }

  bool contains(BillingNavigationDestinationId destinationId) {
    return find(destinationId) != null;
  }

  BillingBusinessDomainScreenDescriptor? find(
    BillingNavigationDestinationId destinationId,
  ) {
    for (final screen in screens) {
      if (screen.destinationId == destinationId) return screen;
    }

    return null;
  }

  BillingBusinessDomainScreenDescriptor requireScreen(
    BillingNavigationDestinationId destinationId,
  ) {
    final screen = find(destinationId);
    if (screen == null) {
      throw StateError(
        'No billing domain screen is registered for $destinationId.',
      );
    }

    return screen;
  }

  List<BillingBusinessDomainScreenDescriptor> screensForSurface(
    BillingNavigationSurface surface,
  ) {
    return List.unmodifiable(
      screens.where((screen) => screen.surface == surface),
    );
  }

  List<BillingBusinessDomainScreenDescriptor> screensForPresentation(
    BillingBusinessDomainScreenPresentation presentation,
  ) {
    return List.unmodifiable(
      screens.where((screen) => screen.presentation == presentation),
    );
  }

  BillingBusinessDomainScreenRegistry register(
    BillingBusinessDomainScreenDescriptor screen,
  ) {
    return BillingBusinessDomainScreenRegistry(screens: [...screens, screen]);
  }

  BillingBusinessDomainScreenRegistry registerAll(
    Iterable<BillingBusinessDomainScreenDescriptor> screens,
  ) {
    return BillingBusinessDomainScreenRegistry(
      screens: [...this.screens, ...screens],
    );
  }

  BillingBusinessDomainScreenRegistry without(
    Iterable<BillingNavigationDestinationId> destinationIds,
  ) {
    final hiddenDestinationIds = destinationIds.toSet();
    return BillingBusinessDomainScreenRegistry(
      screens: screens.where(
        (screen) => !hiddenDestinationIds.contains(screen.destinationId),
      ),
    );
  }

  BillingBusinessDomainScreenRegistry extend({
    Iterable<BillingNavigationDestinationId> hiddenDestinationIds = const [],
    Iterable<BillingBusinessDomainScreenDescriptor> extensions = const [],
  }) {
    final hiddenDestinationIdSet = hiddenDestinationIds.toSet();
    final extensionScreens = extensions.toList(growable: false);
    final extensionDestinationIds =
        extensionScreens.map((screen) => screen.destinationId).toSet();

    return BillingBusinessDomainScreenRegistry(
      screens: [
        ...screens.where(
          (screen) =>
              !hiddenDestinationIdSet.contains(screen.destinationId) &&
              !extensionDestinationIds.contains(screen.destinationId),
        ),
        ...extensionScreens,
      ],
    );
  }

  static List<BillingBusinessDomainScreenDescriptor> _ensureUnique(
    Iterable<BillingBusinessDomainScreenDescriptor> screens,
  ) {
    final seenDestinationIds = <BillingNavigationDestinationId>{};
    final uniqueScreens = <BillingBusinessDomainScreenDescriptor>[];

    for (final screen in screens) {
      if (screen.key.trim().isEmpty) {
        throw StateError('Billing domain screen key cannot be empty.');
      }
      if (!seenDestinationIds.add(screen.destinationId)) {
        throw StateError(
          'Duplicate billing domain screen registered for '
          '${screen.destinationId}.',
        );
      }
      uniqueScreens.add(screen);
    }

    return uniqueScreens;
  }
}
