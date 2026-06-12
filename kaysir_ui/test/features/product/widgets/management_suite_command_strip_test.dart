import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/widgets/management_suite_command_strip.dart';

void main() {
  testWidgets('product management suite command strip delegates actions', (
    tester,
  ) async {
    final selectedActions = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteCommandStrip(
            onOpenWorkspace: () => selectedActions.add('workspace'),
            onOpenCatalog: () => selectedActions.add('catalog'),
            onAddProduct: () => selectedActions.add('add-product'),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product-management-suite-command-strip')),
      findsOneWidget,
    );
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Add product'), findsOneWidget);

    await tester.tap(find.text('Workspace'));
    await tester.tap(find.text('Catalog'));
    await tester.tap(find.text('Add product'));
    await tester.pump();

    expect(selectedActions, ['workspace', 'catalog', 'add-product']);
  });
}
