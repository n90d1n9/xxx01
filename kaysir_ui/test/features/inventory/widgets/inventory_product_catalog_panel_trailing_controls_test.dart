import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_components.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_preview_data.dart';

void main() {
  testWidgets('catalog trailing controls compose saved views and table tools', (
    tester,
  ) async {
    final savedViews = inventoryProductCatalogPreviewSavedViews();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanelTrailingControls(
            presentationState:
                InventoryProductCatalogPresentationPreset
                    .pricing
                    .presentationState,
            savedViews: savedViews,
            activeSavedViewId: savedViews.first.id,
            onPresentationStateChanged: (_) {},
            onTablePreferencesChanged: (_) {},
            onTablePresetSelected: (_) {},
            onSaveCurrentView: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Saved catalog views'), findsOneWidget);
    expect(find.byTooltip('Apply catalog view preset'), findsOneWidget);
    expect(find.byTooltip('Apply table preset'), findsOneWidget);
    expect(find.byTooltip('Choose table columns'), findsOneWidget);
    expect(find.text('View: Pricing review'), findsNothing);
  });
}
