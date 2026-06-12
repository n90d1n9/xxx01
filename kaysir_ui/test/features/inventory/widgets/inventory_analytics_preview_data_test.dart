import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';

void main() {
  test('analytics preview data keeps branch drill-down fixtures linked', () {
    final branchValues = inventoryAnalyticsPreviewBranchValues();
    final branchDetails = inventoryAnalyticsPreviewBranchDetails();

    expect(branchValues, isNotEmpty);
    expect(branchDetails, hasLength(branchValues.length));
    expect(branchDetails.first.branchId, branchValues.first.branchId);
    expect(branchDetails.first.warehouses, isNotEmpty);
    expect(branchDetails.first.recentMovements, isNotEmpty);
  });

  testWidgets('analytics preview scaffold provides a Material shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      inventoryAnalyticsPreviewScaffold(const Text('Preview child')),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Preview child'), findsOneWidget);
  });
}
