import '../experiences/pos_experience_manifest.dart';
import '../states/pos_layout_strategy.dart';
import 'pos_quick_button.dart';

/// Controls how dense touch targets should feel for a POS layout profile.
enum POSTouchLayoutDensity { compact, comfortable, spacious, kiosk }

/// Preferred placement for the active order panel inside a touch layout.
enum POSTouchOrderPanelPlacement { left, right, bottom, hidden }

/// Catalog interaction style emphasized by a touch layout profile.
enum POSTouchCatalogEmphasis {
  scannerFirst,
  favoritesFirst,
  categoryFirst,
  menuFirst,
  assistedSelling,
  selfService,
}

/// A named group of quick buttons for one touch surface.
class POSQuickButtonGroup {
  final String id;
  final String label;
  final String description;
  final POSQuickButtonSurface surface;
  final int priority;
  final int maxVisibleButtons;
  final List<POSQuickButton> buttons;

  const POSQuickButtonGroup({
    required this.id,
    required this.label,
    required this.description,
    required this.surface,
    required this.buttons,
    this.priority = 0,
    this.maxVisibleButtons = 0,
  });

  List<POSQuickButton> visibleButtonsFor(POSQuickButtonContext context) {
    final visible =
        buttons.where((button) => button.isAvailableFor(context)).toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    if (maxVisibleButtons <= 0 || visible.length <= maxVisibleButtons) {
      return List.unmodifiable(visible);
    }

    return List.unmodifiable(visible.take(maxVisibleButtons));
  }
}

/// Reusable touch layout contract for a POS product-line or operator workflow.
///
/// Profiles sit below the broad responsive layout strategy and describe the
/// touch surfaces, density, order-panel placement, and quick-button groups.
class POSTouchLayoutProfile {
  final String id;
  final String label;
  final String description;
  final String productLine;
  final POSLayoutPreference preferredLayout;
  final POSTouchLayoutDensity density;
  final POSTouchOrderPanelPlacement orderPanelPlacement;
  final POSTouchCatalogEmphasis catalogEmphasis;
  final double minTileExtent;
  final int maxGridColumns;
  final bool showOrderPanelByDefault;
  final bool supportsScannerInput;
  final List<POSExperienceFormFactor> supportedFormFactors;
  final List<String> traits;
  final List<POSQuickButtonGroup> groups;

  const POSTouchLayoutProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.productLine,
    required this.preferredLayout,
    required this.density,
    required this.orderPanelPlacement,
    required this.catalogEmphasis,
    required this.groups,
    this.minTileExtent = 96,
    this.maxGridColumns = 6,
    this.showOrderPanelByDefault = true,
    this.supportsScannerInput = true,
    this.supportedFormFactors = const [],
    this.traits = const [],
  });

  int get buttonCount {
    return groups.fold<int>(0, (total, group) => total + group.buttons.length);
  }

  bool supportsFormFactor(POSExperienceFormFactor formFactor) {
    return supportedFormFactors.isEmpty ||
        supportedFormFactors.contains(formFactor);
  }

  POSQuickButtonContext contextFor({
    required POSQuickButtonSurface surface,
    required POSExperienceFormFactor formFactor,
    POSLayoutPreference? layoutPreference,
    Iterable<String> extraTraits = const [],
  }) {
    return POSQuickButtonContext(
      surface: surface,
      formFactor: formFactor,
      layoutPreference: layoutPreference ?? preferredLayout,
      productLine: productLine,
      traits: [...traits, ...extraTraits],
    );
  }

  List<POSQuickButtonGroup> groupsForSurface(POSQuickButtonSurface surface) {
    final matches =
        groups.where((group) => group.surface == surface).toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    return List.unmodifiable(matches);
  }

  List<POSQuickButton> visibleButtonsFor({
    required POSQuickButtonSurface surface,
    required POSExperienceFormFactor formFactor,
    POSLayoutPreference? layoutPreference,
    Iterable<String> extraTraits = const [],
  }) {
    final context = contextFor(
      surface: surface,
      formFactor: formFactor,
      layoutPreference: layoutPreference,
      extraTraits: extraTraits,
    );

    return List.unmodifiable([
      for (final group in groupsForSurface(surface))
        ...group.visibleButtonsFor(context),
    ]);
  }

  int matchScore({
    required String productLine,
    required POSExperienceFormFactor formFactor,
    required POSLayoutPreference preferredLayout,
    Iterable<String> traits = const [],
  }) {
    if (!supportsFormFactor(formFactor)) return -1;

    var score = 1;
    if (_equalsNormalized(this.productLine, productLine)) score += 8;
    if (this.preferredLayout == preferredLayout) score += 4;
    if (density == POSTouchLayoutDensity.kiosk &&
        formFactor == POSExperienceFormFactor.kiosk) {
      score += 4;
    }

    final incomingTraits = traits
        .map(_normalize)
        .where((trait) => trait.isNotEmpty);
    final profileTraits = this.traits.map(_normalize).toSet();
    for (final trait in incomingTraits) {
      if (profileTraits.contains(trait)) score += 1;
    }

    return score;
  }
}

extension POSTouchLayoutDensityLabel on POSTouchLayoutDensity {
  String get label {
    switch (this) {
      case POSTouchLayoutDensity.compact:
        return 'Compact';
      case POSTouchLayoutDensity.comfortable:
        return 'Comfortable';
      case POSTouchLayoutDensity.spacious:
        return 'Spacious';
      case POSTouchLayoutDensity.kiosk:
        return 'Kiosk';
    }
  }
}

/// Decodes persisted touch density values while tolerating older snapshots.
POSTouchLayoutDensity? decodePOSTouchLayoutDensity(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;

  for (final density in POSTouchLayoutDensity.values) {
    if (density.name.toLowerCase() == normalized) return density;
    if (density.label.toLowerCase() == normalized) return density;
  }

  return null;
}

extension POSTouchOrderPanelPlacementLabel on POSTouchOrderPanelPlacement {
  String get label {
    switch (this) {
      case POSTouchOrderPanelPlacement.left:
        return 'Left';
      case POSTouchOrderPanelPlacement.right:
        return 'Right';
      case POSTouchOrderPanelPlacement.bottom:
        return 'Bottom';
      case POSTouchOrderPanelPlacement.hidden:
        return 'Hidden';
    }
  }
}

extension POSTouchCatalogEmphasisLabel on POSTouchCatalogEmphasis {
  String get label {
    switch (this) {
      case POSTouchCatalogEmphasis.scannerFirst:
        return 'Scanner first';
      case POSTouchCatalogEmphasis.favoritesFirst:
        return 'Favorites first';
      case POSTouchCatalogEmphasis.categoryFirst:
        return 'Category first';
      case POSTouchCatalogEmphasis.menuFirst:
        return 'Menu first';
      case POSTouchCatalogEmphasis.assistedSelling:
        return 'Assisted selling';
      case POSTouchCatalogEmphasis.selfService:
        return 'Self service';
    }
  }
}

bool _equalsNormalized(String left, String right) {
  return _normalize(left) == _normalize(right);
}

String _normalize(String value) => value.trim().toLowerCase();
