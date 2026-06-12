import '../experiences/pos_experience_manifest.dart';
import '../states/pos_layout_strategy.dart';

/// Describes the business action a touch quick button should trigger.
///
/// The intent stores stable IDs instead of callbacks so product-line packs can
/// persist, sync, and override quick-button layouts without coupling to UI code.
class POSQuickButtonIntent {
  final POSQuickButtonIntentKind kind;
  final String targetId;
  final Map<String, String> payload;

  const POSQuickButtonIntent._({
    required this.kind,
    this.targetId = '',
    this.payload = const {},
  });

  const POSQuickButtonIntent.commandAction(String actionId)
    : this._(kind: POSQuickButtonIntentKind.commandAction, targetId: actionId);

  const POSQuickButtonIntent.product(String productId)
    : this._(kind: POSQuickButtonIntentKind.product, targetId: productId);

  const POSQuickButtonIntent.category(String categoryId)
    : this._(kind: POSQuickButtonIntentKind.category, targetId: categoryId);

  const POSQuickButtonIntent.discount(String discountId)
    : this._(kind: POSQuickButtonIntentKind.discount, targetId: discountId);

  const POSQuickButtonIntent.modifierSet(String modifierSetId)
    : this._(
        kind: POSQuickButtonIntentKind.modifierSet,
        targetId: modifierSetId,
      );

  const POSQuickButtonIntent.customerAction(String actionId)
    : this._(kind: POSQuickButtonIntentKind.customerAction, targetId: actionId);

  const POSQuickButtonIntent.layoutProfile(String profileId)
    : this._(kind: POSQuickButtonIntentKind.layoutProfile, targetId: profileId);

  const POSQuickButtonIntent.customFlow({
    String targetId = '',
    Map<String, String> payload = const {},
  }) : this._(
         kind: POSQuickButtonIntentKind.customFlow,
         targetId: targetId,
         payload: payload,
       );

  bool get requiresTarget => kind != POSQuickButtonIntentKind.customFlow;

  bool get isComplete {
    if (requiresTarget) return targetId.trim().isNotEmpty;
    return targetId.trim().isNotEmpty || payload.isNotEmpty;
  }

  String get semanticKey {
    final target = targetId.trim();
    if (target.isEmpty) return kind.name;
    return '${kind.name}:$target';
  }
}

/// Supported intent families for configurable POS touch quick buttons.
enum POSQuickButtonIntentKind {
  commandAction,
  product,
  category,
  discount,
  modifierSet,
  customerAction,
  layoutProfile,
  customFlow,
}

/// Screen region where a quick button is expected to appear.
enum POSQuickButtonSurface {
  primaryGrid,
  commandBar,
  utilityRail,
  orderFooter,
  kioskHero,
}

/// Runtime facts used to decide whether a quick button is visible.
class POSQuickButtonContext {
  final POSQuickButtonSurface surface;
  final POSExperienceFormFactor formFactor;
  final POSLayoutPreference layoutPreference;
  final String productLine;
  final List<String> traits;

  const POSQuickButtonContext({
    required this.surface,
    required this.formFactor,
    required this.layoutPreference,
    this.productLine = '',
    this.traits = const [],
  });

  bool hasTrait(String trait) {
    final normalized = trait.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return traits.any(
      (candidate) => candidate.trim().toLowerCase() == normalized,
    );
  }

  bool hasAllTraits(Iterable<String> requiredTraits) {
    return requiredTraits.every(hasTrait);
  }
}

/// A configurable touch target for high-frequency POS actions.
///
/// Buttons are intentionally data-only so the same definitions can drive
/// desktop cashier grids, tablet counters, kiosks, and future synced layouts.
class POSQuickButton {
  final String id;
  final String label;
  final String description;
  final POSQuickButtonIntent intent;
  final POSQuickButtonSurface surface;
  final String iconKey;
  final String accentColorHex;
  final int priority;
  final bool enabled;
  final List<POSExperienceFormFactor> supportedFormFactors;
  final List<POSLayoutPreference> layoutPreferences;
  final List<String> productLines;
  final List<String> requiredTraits;
  final List<String> tags;

  const POSQuickButton({
    required this.id,
    required this.label,
    required this.description,
    required this.intent,
    required this.surface,
    this.iconKey = '',
    this.accentColorHex = '',
    this.priority = 0,
    this.enabled = true,
    this.supportedFormFactors = const [],
    this.layoutPreferences = const [],
    this.productLines = const [],
    this.requiredTraits = const [],
    this.tags = const [],
  });

  bool isAvailableFor(POSQuickButtonContext context) {
    if (!enabled) return false;
    if (surface != context.surface) return false;
    if (supportedFormFactors.isNotEmpty &&
        !supportedFormFactors.contains(context.formFactor)) {
      return false;
    }
    if (layoutPreferences.isNotEmpty &&
        !layoutPreferences.contains(context.layoutPreference)) {
      return false;
    }
    if (productLines.isNotEmpty &&
        !_containsNormalized(productLines, context.productLine)) {
      return false;
    }

    return context.hasAllTraits(requiredTraits);
  }

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return label.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        tags.any((tag) => tag.toLowerCase().contains(normalized));
  }

  POSQuickButton copyWith({
    String? id,
    String? label,
    String? description,
    POSQuickButtonIntent? intent,
    POSQuickButtonSurface? surface,
    String? iconKey,
    String? accentColorHex,
    int? priority,
    bool? enabled,
    List<POSExperienceFormFactor>? supportedFormFactors,
    List<POSLayoutPreference>? layoutPreferences,
    List<String>? productLines,
    List<String>? requiredTraits,
    List<String>? tags,
  }) {
    return POSQuickButton(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      intent: intent ?? this.intent,
      surface: surface ?? this.surface,
      iconKey: iconKey ?? this.iconKey,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      supportedFormFactors: supportedFormFactors ?? this.supportedFormFactors,
      layoutPreferences: layoutPreferences ?? this.layoutPreferences,
      productLines: productLines ?? this.productLines,
      requiredTraits: requiredTraits ?? this.requiredTraits,
      tags: tags ?? this.tags,
    );
  }
}

extension POSQuickButtonIntentKindLabel on POSQuickButtonIntentKind {
  String get label {
    switch (this) {
      case POSQuickButtonIntentKind.commandAction:
        return 'Command';
      case POSQuickButtonIntentKind.product:
        return 'Product';
      case POSQuickButtonIntentKind.category:
        return 'Category';
      case POSQuickButtonIntentKind.discount:
        return 'Discount';
      case POSQuickButtonIntentKind.modifierSet:
        return 'Modifier';
      case POSQuickButtonIntentKind.customerAction:
        return 'Customer';
      case POSQuickButtonIntentKind.layoutProfile:
        return 'Layout';
      case POSQuickButtonIntentKind.customFlow:
        return 'Custom';
    }
  }
}

extension POSQuickButtonSurfaceLabel on POSQuickButtonSurface {
  String get label {
    switch (this) {
      case POSQuickButtonSurface.primaryGrid:
        return 'Primary grid';
      case POSQuickButtonSurface.commandBar:
        return 'Command bar';
      case POSQuickButtonSurface.utilityRail:
        return 'Utility rail';
      case POSQuickButtonSurface.orderFooter:
        return 'Order footer';
      case POSQuickButtonSurface.kioskHero:
        return 'Kiosk hero';
    }
  }
}

bool _containsNormalized(Iterable<String> values, String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  return values.any(
    (candidate) => candidate.trim().toLowerCase() == normalized,
  );
}
