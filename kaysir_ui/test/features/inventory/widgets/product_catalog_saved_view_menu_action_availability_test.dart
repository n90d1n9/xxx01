import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_saved_view_menu_action_availability.dart';

void main() {
  test('saved view menu action availability requires callbacks', () {
    final availability =
        const InventoryProductCatalogSavedViewMenuActionAvailabilityResolver()
            .resolve(_savedView());

    expect(availability.canCopy, isFalse);
    expect(availability.canRename, isFalse);
    expect(availability.canUpdate, isFalse);
    expect(availability.canDelete, isFalse);
    expect(availability.canSetDefault, isFalse);
    expect(availability.hasActions, isFalse);
  });

  test('saved view menu action availability respects predicates', () {
    final view = _savedView();
    final availability =
        InventoryProductCatalogSavedViewMenuActionAvailabilityResolver(
          onCopySavedView: (_) {},
          onRenameSavedView: (_) {},
          onUpdateSavedView: (_, _) {},
          onDeleteSavedView: (_) {},
          onDefaultSavedViewChanged: (_) {},
          canCopySavedView: (_) => true,
          canRenameSavedView: (_) => false,
          canUpdateSavedView: (_) => true,
          canDeleteSavedView: (_) => false,
          canSetDefaultSavedView: (_) => true,
        ).resolve(view);

    expect(availability.canCopy, isTrue);
    expect(availability.canRename, isFalse);
    expect(availability.canUpdate, isTrue);
    expect(availability.canDelete, isFalse);
    expect(availability.canSetDefault, isTrue);
    expect(availability.hasActions, isTrue);
  });
}

InventoryProductCatalogSavedView _savedView() {
  return InventoryProductCatalogSavedView(
    id: 'pricing-review',
    label: 'Pricing review',
    description: 'Margin review',
    presentationState:
        InventoryProductCatalogPresentationPreset.pricing.presentationState,
  );
}
