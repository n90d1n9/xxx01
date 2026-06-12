import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_auto_summary_preview.dart';

void main() {
  testWidgets('auto summary preview renders derived workspace description', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceAutoSummaryPreview(
            workspace: _filteredWorkspace,
          ),
        ),
      ),
    );

    expect(find.text('Auto summary preview'), findsOneWidget);
    expect(
      find.text(
        'Channel: Delivery App • Status: Ready Now • Search: rush pickup • '
        'Sort: Oldest',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

const _filteredWorkspace = OrderSavedWorkspace(
  id: 'saved_filtered',
  label: 'Filtered workspace',
  description: 'Filtered workspace',
  filter: OrderFilter(
    channelId: 'delivery_app',
    status: 'ready_now',
    query: 'rush pickup',
  ),
  sortMode: OrderSortMode.oldest,
);
