import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/management_pack_field_input_helper.dart';
import 'package:kaysir/features/product/widgets/management_pack_field_input_metadata.dart';

void main() {
  testWidgets(
    'management pack field helper renders requirement and type chips',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductManagementPackFieldInputHelper(
              metadata: ProductManagementPackFieldInputMetadata.fromField(
                groceryFreshGoodsFields.first,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Date used to protect fresh goods from expired selling.'),
        findsOneWidget,
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    },
  );

  testWidgets(
    'management pack field helper includes unit chips when available',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductManagementPackFieldInputHelper(
              metadata: ProductManagementPackFieldInputMetadata.fromField(
                groceryFreshGoodsFields[3],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
    },
  );
}
