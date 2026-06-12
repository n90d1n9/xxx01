import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/widgets/product_core_information_field_helper.dart';
import 'package:kaysir/features/product/widgets/product_core_information_field_metadata.dart';

void main() {
  testWidgets('core information field helper renders metadata affordances', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCoreInformationFieldHelper(
            metadata: ProductCoreInformationFieldMetadata.forField(
              ProductCoreInformationFieldIds.description,
              isEditing: false,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Short product copy used by catalog and channels.'),
      findsOneWidget,
    );
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Long text'), findsOneWidget);
  });
}
