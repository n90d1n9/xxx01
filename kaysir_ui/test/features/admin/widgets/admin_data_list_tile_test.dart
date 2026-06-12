import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_data_list_tile.dart';

void main() {
  testWidgets('renders data list tile metadata and values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminDataListTile(
            leadingIcon: Icons.inventory_2_outlined,
            title: 'Signature Retail Pack',
            subtitle: 'SKU 6426327',
            primaryValue: 'Rp 1.3M',
            secondaryValue: '1276 sold',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('Signature Retail Pack'), findsOneWidget);
    expect(find.text('SKU 6426327'), findsOneWidget);
    expect(find.text('Rp 1.3M'), findsOneWidget);
    expect(find.text('1276 sold'), findsOneWidget);
  });
}
