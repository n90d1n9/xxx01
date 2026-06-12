import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/widgets/management_pack_extension_hook_kind_section_list.dart';

void main() {
  testWidgets('hook kind section list renders diagnostic-only empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductManagementPackExtensionHookKindSectionList(sections: []),
        ),
      ),
    );

    expect(
      find.text('No hook outputs registered for this module'),
      findsOneWidget,
    );
  });
}
