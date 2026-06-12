import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/widgets/product_core_information_fields.dart';

void main() {
  testWidgets('product core information fields render and validate input', (
    tester,
  ) async {
    final harness = _CoreInformationFieldHarness(
      name: 'Spinach',
      sku: 'SP-001',
      category: 'Fresh',
      price: 'abc',
      stock: '1.5',
      description: 'Leafy greens',
    );
    addTearDown(harness.dispose);
    String? reviewedFieldId;

    await tester.pumpWidget(
      harness.build(
        isEditing: false,
        onReviewField: (fieldId) {
          reviewedFieldId = fieldId;
        },
      ),
    );

    expect(find.text('Product Information'), findsOneWidget);
    expect(
      find.text('Catalog identity, pricing, and opening stock for launch.'),
      findsOneWidget,
    );
    expect(find.text('6 fields'), findsOneWidget);
    expect(find.text('4/6 ready'), findsOneWidget);
    expect(find.text('2 invalid'), findsOneWidget);
    expect(find.text('Price needs correction'), findsOneWidget);
    expect(find.text('Review Price'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(
      find.text('Customer-facing name used across product surfaces.'),
      findsOneWidget,
    );
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Number'), findsOneWidget);
    expect(
      harness.keys[ProductCoreInformationFieldIds.price]?.currentContext,
      isNotNull,
    );

    expect(harness.formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Please enter a valid price'), findsOneWidget);
    expect(find.text('Please enter a whole number'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review Price'));
    await tester.pump();

    expect(reviewedFieldId, ProductCoreInformationFieldIds.price);

    await tester.enterText(
      find.byKey(const ValueKey('product-core-field-price')),
      '12',
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-core-field-initial-stock')),
      '8',
    );
    await tester.pumpWidget(harness.build(isEditing: false));

    expect(find.text('6/6 ready'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Review Price'), findsNothing);

    expect(harness.formKey.currentState!.validate(), isTrue);
  });

  testWidgets(
    'product core information fields lock opening stock when editing',
    (tester) async {
      final harness = _CoreInformationFieldHarness(
        name: 'Spinach',
        sku: 'SP-001',
        category: 'Fresh',
        price: '12',
        stock: '8',
        description: 'Leafy greens',
      );
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build(isEditing: true));

      final stockField = tester.widget<TextFormField>(
        find.byKey(const ValueKey('product-core-field-initial-stock')),
      );
      expect(stockField.enabled, isFalse);
      expect(find.text('6/6 ready'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
      expect(find.text('1 locked'), findsOneWidget);
      expect(
        find.text(
          'Locked after creation and managed through inventory movements.',
        ),
        findsOneWidget,
      );
    },
  );
}

/// Test harness for rendering core information fields with owned controllers.
class _CoreInformationFieldHarness {
  _CoreInformationFieldHarness({
    required String name,
    required String sku,
    required String category,
    required String price,
    required String stock,
    required String description,
  }) : nameController = TextEditingController(text: name),
       skuController = TextEditingController(text: sku),
       categoryController = TextEditingController(text: category),
       priceController = TextEditingController(text: price),
       stockController = TextEditingController(text: stock),
       descriptionController = TextEditingController(text: description),
       focusNodes = {
         for (final fieldId in ProductCoreInformationFieldIds.all)
           fieldId: FocusNode(debugLabel: 'test-$fieldId'),
       },
       keys = {
         for (final fieldId in ProductCoreInformationFieldIds.all)
           fieldId: GlobalKey(debugLabel: 'test-$fieldId'),
       };

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController descriptionController;
  final Map<String, FocusNode> focusNodes;
  final Map<String, GlobalKey> keys;

  Widget build({required bool isEditing, ValueChanged<String>? onReviewField}) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: ProductCoreInformationFields(
              nameController: nameController,
              skuController: skuController,
              categoryController: categoryController,
              priceController: priceController,
              stockController: stockController,
              descriptionController: descriptionController,
              isEditing: isEditing,
              onReviewField: onReviewField,
              fieldFocusNodes: focusNodes,
              fieldKeys: keys,
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    for (final focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }
}
