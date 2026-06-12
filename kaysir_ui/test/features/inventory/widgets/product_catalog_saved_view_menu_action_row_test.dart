import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_saved_view_menu_action_row.dart';

void main() {
  testWidgets('saved view menu action row renders enabled actions', (
    tester,
  ) async {
    var copied = false;
    var renamed = false;
    var updated = false;
    var deleted = false;
    var defaultToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogSavedViewMenuActionRow(
            view: _savedView(),
            defaulted: false,
            canCopy: true,
            canRename: true,
            canUpdate: true,
            canDelete: true,
            canSetDefault: true,
            onCopy: () => copied = true,
            onRename: () => renamed = true,
            onUpdate: () => updated = true,
            onDelete: () => deleted = true,
            onToggleDefault: () => defaultToggled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Set Pricing review as default'));
    await tester.tap(find.byTooltip('Save editable copy of Pricing review'));
    await tester.tap(find.byTooltip('Rename Pricing review'));
    await tester.tap(find.byTooltip('Update Pricing review'));
    await tester.tap(find.byTooltip('Delete Pricing review'));

    expect(defaultToggled, isTrue);
    expect(copied, isTrue);
    expect(renamed, isTrue);
    expect(updated, isTrue);
    expect(deleted, isTrue);
  });

  test('saved view menu action row exposes action availability', () {
    final actionRow = InventoryProductCatalogSavedViewMenuActionRow(
      view: _savedView(),
      defaulted: false,
      canCopy: false,
      canRename: false,
      canUpdate: false,
      canDelete: false,
      canSetDefault: false,
      onCopy: () {},
      onRename: () {},
      onUpdate: () {},
      onDelete: () {},
      onToggleDefault: () {},
    );

    expect(actionRow.hasActions, isFalse);
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
