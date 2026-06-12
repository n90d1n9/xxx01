import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_page_header.dart';

void main() {
  testWidgets('renders page title, metadata, actions, and toolbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminPageHeader(
            breadcrumbs: ['Admin', 'Inventory'],
            eyebrow: 'Operations',
            leadingIcon: Icons.inventory_2_outlined,
            title: 'Inventory',
            subtitle: 'Monitor stock health across locations.',
            actions: [Text('Export')],
            toolbar: Text('Filter bar'),
          ),
        ),
      ),
    );

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Inventory'), findsNWidgets(2));
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Monitor stock health across locations.'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Filter bar'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
