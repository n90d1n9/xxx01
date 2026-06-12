import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/screens/product_editor_route_screen.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/product_provider.dart';

void main() {
  testWidgets('product editor route opens add form with focused pack field', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          productManagementPackIdProvider.overrideWith(
            (ref) => _packIdNotifier(ProductManagementPackId.groceryFreshGoods),
          ),
        ],
        child: const MaterialApp(
          home: ProductEditorRouteScreen(
            initialFocusFieldId: ProductManagementFieldId.expiryDate,
          ),
        ),
      ),
    );

    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);

    final expiryField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('product-pack-field-expiry_date')),
        matching: find.byType(EditableText),
      ),
    );
    expect(expiryField.autofocus, isTrue);
  });

  testWidgets('product editor route resolves local product for editing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsProvider.overrideWith(
            (ref) => ProductsNotifier(
              ref,
              initialProducts: [
                Product(
                  id: 'p1',
                  name: 'Spinach',
                  sku: 'SP-001',
                  category: 'Fresh',
                  description: 'Leafy greens',
                  barcode: '8990001',
                  price: 12,
                ),
              ],
              loadOnStart: false,
            ),
          ),
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          productManagementPackIdProvider.overrideWith(
            (ref) => _packIdNotifier(ProductManagementPackId.groceryFreshGoods),
          ),
        ],
        child: const MaterialApp(
          home: ProductEditorRouteScreen(
            productId: 'p1',
            initialFocusFieldId: ProductManagementFieldId.batchNumber,
          ),
        ),
      ),
    );

    expect(find.text('Edit Product'), findsOneWidget);
    final nameField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(nameField.controller?.text, 'Spinach');

    final batchField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('product-pack-field-batch_number')),
        matching: find.byType(EditableText),
      ),
    );
    expect(batchField.autofocus, isTrue);
  });
}

ProductManagementPackIdNotifier _packIdNotifier(
  ProductManagementPackId packId,
) {
  return ProductManagementPackIdNotifier(
    repository: ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
    registry: ProductManagementPackRegistry.fromPacks([
      coreProductManagementPack,
      groceryFreshGoodsProductManagementPack,
    ]),
    initialPackId: packId,
    autoHydrate: false,
  );
}
