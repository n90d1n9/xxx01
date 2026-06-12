import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import '../../inventory/models/inventory_product_catalog_view_mode.dart';
import 'product_catalog_starter_saved_views.dart';

class ProductCatalogSavedViewDeck {
  const ProductCatalogSavedViewDeck._({
    required this.savedViews,
    required this.starterSavedViews,
    required this.starterSavedViewIds,
    required this.starterSavedViewSectionLabels,
  });

  factory ProductCatalogSavedViewDeck.from({
    required Iterable<InventoryProductCatalogSavedView> savedViews,
    required ProductCatalogStarterSavedViewSet starterSet,
  }) {
    return ProductCatalogSavedViewDeck.fromStarterViews(
      savedViews: savedViews,
      starterSavedViews: starterSet.views,
      starterSavedViewIds: starterSet.viewIds,
      starterSavedViewSectionLabels: starterSet.viewSectionLabels,
    );
  }

  factory ProductCatalogSavedViewDeck.fromStarterViews({
    required Iterable<InventoryProductCatalogSavedView> savedViews,
    required Iterable<InventoryProductCatalogSavedView> starterSavedViews,
    required Iterable<String> starterSavedViewIds,
    Map<String, String> starterSavedViewSectionLabels =
        const <String, String>{},
  }) {
    final normalizedSavedViews = normalizeInventoryProductCatalogSavedViews(
      savedViews,
    );
    final normalizedStarterViews = normalizeInventoryProductCatalogSavedViews(
      starterSavedViews,
    );
    final normalizedStarterViewIds = Set.unmodifiable({
      for (final id in starterSavedViewIds)
        if (id.trim().isNotEmpty) id.trim(),
      for (final view in normalizedStarterViews) view.id,
    });
    final normalizedStarterViewSectionLabels =
        Map<String, String>.unmodifiable({
          for (final entry in starterSavedViewSectionLabels.entries)
            if (normalizedStarterViewIds.contains(entry.key.trim()) &&
                entry.value.trim().isNotEmpty)
              entry.key.trim(): entry.value.trim(),
        });
    final savedViewIds = {for (final view in normalizedSavedViews) view.id};

    return ProductCatalogSavedViewDeck._(
      savedViews: normalizeInventoryProductCatalogSavedViews([
        ...normalizedSavedViews,
        for (final starterView in normalizedStarterViews)
          if (!savedViewIds.contains(starterView.id)) starterView,
      ]),
      starterSavedViews: List.unmodifiable(normalizedStarterViews),
      starterSavedViewIds: normalizedStarterViewIds,
      starterSavedViewSectionLabels: normalizedStarterViewSectionLabels,
    );
  }

  static const empty = ProductCatalogSavedViewDeck._(
    savedViews: [],
    starterSavedViews: [],
    starterSavedViewIds: {},
    starterSavedViewSectionLabels: {},
  );

  final List<InventoryProductCatalogSavedView> savedViews;
  final List<InventoryProductCatalogSavedView> starterSavedViews;
  final Set<String> starterSavedViewIds;
  final Map<String, String> starterSavedViewSectionLabels;

  Iterable<InventoryProductCatalogSavedView> get editableSavedViews {
    return savedViews.where(canManage);
  }

  bool isStarter(InventoryProductCatalogSavedView savedView) {
    return starterSavedViewIds.contains(savedView.id);
  }

  bool canManage(InventoryProductCatalogSavedView savedView) {
    return !isStarter(savedView);
  }

  String sectionLabelFor(InventoryProductCatalogSavedView savedView) {
    if (!isStarter(savedView)) return 'My views';

    return starterSavedViewSectionLabels[savedView.id] ?? 'Starter views';
  }

  ProductCatalogSavedViewDeck withEditableSavedView(
    InventoryProductCatalogSavedView savedView,
  ) {
    if (isStarter(savedView)) return this;

    return withEditableSavedViews([
      for (final view in editableSavedViews)
        if (view.id != savedView.id) view,
      savedView,
    ]);
  }

  ProductCatalogSavedViewDeck withoutEditableSavedView(
    InventoryProductCatalogSavedView savedView,
  ) {
    if (isStarter(savedView)) return this;

    return withEditableSavedViews([
      for (final view in editableSavedViews)
        if (view.id != savedView.id) view,
    ]);
  }

  ProductCatalogSavedViewDeck withEditableSavedViews(
    Iterable<InventoryProductCatalogSavedView> views,
  ) {
    return ProductCatalogSavedViewDeck.fromStarterViews(
      savedViews: views.where(canManage),
      starterSavedViews: starterSavedViews,
      starterSavedViewIds: starterSavedViewIds,
      starterSavedViewSectionLabels: starterSavedViewSectionLabels,
    );
  }

  InventoryProductCatalogSavedView? matchingView(
    InventoryProductCatalogPresentationState presentationState, {
    bool editableOnly = false,
  }) {
    final normalizedState = presentationState.normalized;
    final candidates = editableOnly ? editableSavedViews : savedViews;
    for (final view in candidates) {
      if (view.presentationState.matches(normalizedState)) return view;
    }

    return null;
  }

  String? matchingViewId(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    return matchingView(presentationState)?.id;
  }

  String? idIfPresent(String? viewId) {
    final id = viewId?.trim();
    if (id == null || id.isEmpty) return null;

    for (final view in savedViews) {
      if (view.id == id) return id;
    }

    return null;
  }

  InventoryProductCatalogSavedView createSavedView(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    final normalizedState = presentationState.normalized;
    final id = _nextEditableSavedViewId();

    return InventoryProductCatalogSavedView(
      id: id,
      label: _uniqueEditableLabel(_savedViewLabel(id)),
      description: productCatalogSavedViewDescription(normalizedState),
      presentationState: normalizedState,
    );
  }

  InventoryProductCatalogSavedView renameEditableView(
    InventoryProductCatalogSavedView savedView,
    String label,
  ) {
    if (isStarter(savedView)) return savedView;

    return savedView.copyWith(
      label: _uniqueEditableLabel(label, excludingViewId: savedView.id),
    );
  }

  InventoryProductCatalogSavedView createEditableCopy(
    InventoryProductCatalogSavedView sourceView,
  ) {
    final id = _nextEditableSavedViewId();

    return InventoryProductCatalogSavedView(
      id: id,
      label: _uniqueEditableLabel(_savedViewCopyLabel(sourceView.label)),
      description: sourceView.description,
      presentationState: sourceView.presentationState.normalized,
    );
  }

  String _nextEditableSavedViewId() {
    final userSavedViews = editableSavedViews.toList(growable: false);
    var index = userSavedViews.length + 1;
    while (userSavedViews.any((view) => view.id == 'saved-view-$index')) {
      index += 1;
    }

    return 'saved-view-$index';
  }

  String _uniqueEditableLabel(String label, {String? excludingViewId}) {
    final baseLabel = _cleanSavedViewLabel(label);
    final existingLabels = {
      for (final view in editableSavedViews)
        if (view.id != excludingViewId) _labelKey(view.label),
    };
    if (!existingLabels.contains(_labelKey(baseLabel))) return baseLabel;

    var index = 2;
    while (existingLabels.contains(_labelKey('$baseLabel ($index)'))) {
      index += 1;
    }

    return '$baseLabel ($index)';
  }
}

String productCatalogSavedViewDescription(
  InventoryProductCatalogPresentationState presentationState,
) {
  final preset = presentationState.matchingPreset;
  if (preset != null) return preset.label;

  switch (presentationState.viewMode) {
    case InventoryProductCatalogViewMode.cards:
      return 'Custom card view';
    case InventoryProductCatalogViewMode.table:
      return 'Custom table view';
  }
}

String _savedViewLabel(String id) {
  final suffix = id.split('-').last;
  return 'Saved view $suffix';
}

String _savedViewCopyLabel(String label) {
  return '${_cleanSavedViewLabel(label)} copy';
}

String _cleanSavedViewLabel(String label) {
  final trimmedLabel = label.trim();
  if (trimmedLabel.isEmpty) return 'Saved view';

  return trimmedLabel;
}

String _labelKey(String label) {
  return label.trim().toLowerCase();
}
