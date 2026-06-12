import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_data_list_section.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('renders data list section header and rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminDataListSection(
            title: 'Top products',
            subtitle: 'Best-selling items.',
            leadingIcon: Icons.sell_outlined,
            children: [Text('Signature Retail Pack'), Text('Express Bundle')],
          ),
        ),
      ),
    );

    expect(find.text('Top products'), findsOneWidget);
    expect(find.text('Best-selling items.'), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    expect(find.text('Signature Retail Pack'), findsOneWidget);
    expect(find.text('Express Bundle'), findsOneWidget);
  });

  testWidgets('renders the supplied empty state when there are no rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminDataListSection(
            title: 'Invoices',
            emptyState: AppEmptyState(title: 'No invoices'),
            children: [],
          ),
        ),
      ),
    );

    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('No invoices'), findsOneWidget);
  });
}
