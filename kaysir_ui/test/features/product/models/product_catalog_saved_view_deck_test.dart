import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/product/models/product_catalog_saved_view_deck.dart';
import 'package:kaysir/features/product/models/product_catalog_starter_saved_views.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('merges editable and starter saved views without duplicates', () {
    final starterSet = _starterSet();
    final starterView = _starterView(starterSet, 'Omni readiness');
    final editableView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Morning audit',
      description: 'Daily operations review',
      presentationState:
          InventoryProductCatalogPresentationPreset
              .operationsTable
              .presentationState,
    );

    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [
        starterView.copyWith(description: 'Persisted startup starter'),
        editableView,
      ],
      starterSet: starterSet,
    );

    expect(
      deck.savedViews.where((view) => view.id == starterView.id),
      hasLength(1),
    );
    expect(deck.isStarter(starterView), isTrue);
    expect(deck.canManage(starterView), isFalse);
    expect(deck.canManage(editableView), isTrue);
    expect(deck.sectionLabelFor(editableView), 'My views');
    expect(deck.sectionLabelFor(starterView), 'Channel views');
    expect(deck.editableSavedViews.map((view) => view.id), ['saved-view-1']);
  });

  test('uses fallback starter section labels for raw starter views', () {
    final starterSet = _starterSet();
    final starterView = _starterView(starterSet, 'Omni readiness');
    final deck = ProductCatalogSavedViewDeck.fromStarterViews(
      savedViews: const [],
      starterSavedViews: [starterView],
      starterSavedViewIds: [starterView.id],
    );

    expect(deck.sectionLabelFor(starterView), 'Starter views');
  });

  test('matches starter views while editable matching ignores starters', () {
    final starterSet = _starterSet();
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: const [],
      starterSet: starterSet,
    );
    final starterState =
        InventoryProductCatalogPresentationPreset
            .channelSignals
            .presentationState;

    expect(deck.matchingView(starterState)?.label, 'Omni readiness');
    expect(deck.matchingView(starterState, editableOnly: true), isNull);
    expect(deck.matchingViewId(starterState), startsWith('starter-'));
  });

  test('creates editable saved views with stable ids and descriptions', () {
    final starterSet = _starterSet();
    final existingView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Existing view',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [existingView],
      starterSet: starterSet,
    );

    final savedView = deck.createSavedView(
      InventoryProductCatalogPresentationPreset
          .operationsTable
          .presentationState,
    );
    final nextDeck = deck.withEditableSavedView(savedView);

    expect(savedView.id, 'saved-view-2');
    expect(savedView.label, 'Saved view 2');
    expect(savedView.description, 'Operations table');
    expect(
      nextDeck.matchingViewId(savedView.presentationState),
      'saved-view-2',
    );
  });

  test('copies starter saved views into editable saved views', () {
    final starterSet = _starterSet();
    final starterView = _starterView(starterSet, 'Omni readiness');
    final existingView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Existing view',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [existingView],
      starterSet: starterSet,
    );

    final copiedView = deck.createEditableCopy(starterView);
    final nextDeck = deck.withEditableSavedView(copiedView);

    expect(copiedView.id, 'saved-view-2');
    expect(copiedView.label, 'Omni readiness copy');
    expect(copiedView.description, starterView.description);
    expect(
      copiedView.presentationState.matches(starterView.presentationState),
      isTrue,
    );
    expect(nextDeck.isStarter(copiedView), isFalse);
    expect(nextDeck.canManage(copiedView), isTrue);
  });

  test('keeps copied saved view labels unique', () {
    final starterSet = _starterSet();
    final starterView = _starterView(starterSet, 'Omni readiness');
    final existingView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Omni readiness copy',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [existingView],
      starterSet: starterSet,
    );

    final copiedView = deck.createEditableCopy(starterView);

    expect(copiedView.id, 'saved-view-2');
    expect(copiedView.label, 'Omni readiness copy (2)');
  });

  test('keeps renamed saved view labels unique', () {
    final starterSet = _starterSet();
    final firstView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Front counter',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final secondView = InventoryProductCatalogSavedView(
      id: 'saved-view-2',
      label: 'Back office',
      presentationState:
          InventoryProductCatalogPresentationPreset
              .operationsTable
              .presentationState,
    );
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [firstView, secondView],
      starterSet: starterSet,
    );

    final renamedView = deck.renameEditableView(secondView, ' Front counter ');

    expect(renamedView.id, 'saved-view-2');
    expect(renamedView.label, 'Front counter (2)');
  });

  test('removes editable saved views and clears missing ids', () {
    final starterSet = _starterSet();
    final editableView = InventoryProductCatalogSavedView(
      id: 'saved-view-1',
      label: 'Morning audit',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final deck = ProductCatalogSavedViewDeck.from(
      savedViews: [editableView],
      starterSet: starterSet,
    );

    final nextDeck = deck.withoutEditableSavedView(editableView);

    expect(nextDeck.idIfPresent('saved-view-1'), isNull);
    expect(
      nextDeck.idIfPresent('starter-core_catalog.omni_retail.overview'),
      isNotNull,
    );
    expect(nextDeck.editableSavedViews, isEmpty);
  });
}

ProductCatalogStarterSavedViewSet _starterSet() {
  return buildProductCatalogStarterSavedViewSet(
    pack: coreProductManagementPack,
    channelProfile: omniRetailProductSalesChannelProfile,
  );
}

InventoryProductCatalogSavedView _starterView(
  ProductCatalogStarterSavedViewSet starterSet,
  String label,
) {
  return starterSet.views.firstWhere((view) => view.label == label);
}
