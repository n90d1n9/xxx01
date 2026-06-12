import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_filtered_empty_state.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('inventory filtered empty state renders empty copy', (
    tester,
  ) async {
    var created = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryFilteredEmptyState(
            totalCount: 0,
            emptyTitle: 'No warehouses yet',
            emptyMessage: 'Add a warehouse before creating stock lines.',
            filteredTitle: 'No warehouses in this branch',
            filteredMessage: 'Try another branch or reset filters.',
            icon: Icons.warehouse_outlined,
            emptyAction: TextButton(
              onPressed: () => created = true,
              child: const Text('Add warehouse'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No warehouses yet'), findsOneWidget);
    expect(
      find.text('Add a warehouse before creating stock lines.'),
      findsOneWidget,
    );
    expect(find.text('No warehouses in this branch'), findsNothing);

    await tester.tap(find.text('Add warehouse'));
    await tester.pump();

    expect(created, isTrue);
  });

  testWidgets('inventory filtered empty state can reset filtered rows', (
    tester,
  ) async {
    var reset = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryFilteredEmptyState(
            totalCount: 3,
            emptyTitle: 'No warehouses yet',
            emptyMessage: 'Add a warehouse before creating stock lines.',
            filteredTitle: 'No warehouses in this branch',
            filteredMessage: 'Try another branch or reset filters.',
            icon: Icons.warehouse_outlined,
            onResetFilters: () => reset = true,
          ),
        ),
      ),
    );

    expect(find.text('No warehouses in this branch'), findsOneWidget);
    expect(find.text('Try another branch or reset filters.'), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(reset, isTrue);
  });
}
