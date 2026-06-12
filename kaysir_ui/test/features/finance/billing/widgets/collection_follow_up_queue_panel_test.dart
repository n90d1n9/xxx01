import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_collection_task.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_collection_tasks.dart';
import 'package:kaysir/features/finance/billing/widgets/collection_follow_up_queue_panel.dart';

void main() {
  testWidgets('BillingCollectionFollowUpQueuePanel renders collection queue', (
    tester,
  ) async {
    BillingCollectionTask? selectedTask;

    await _pumpPanel(
      tester,
      BillingCollectionFollowUpQueuePanel(
        tasks: _tasks(),
        onTaskSelected: (task) {
          selectedTask = task;
        },
      ),
    );

    expect(find.text('Follow-up queue'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('Collect invoice #old-overdue'), findsOneWidget);
    expect(find.text('Accounts receivable'), findsWidgets);
    expect(find.text('Rp 1,000'), findsOneWidget);
    expect(find.text('46 days overdue'), findsOneWidget);

    await tester.tap(find.text('Collect invoice #old-overdue'));
    await tester.pump();

    expect(selectedTask?.invoice.id, 'old-overdue');
  });

  testWidgets('BillingCollectionFollowUpQueuePanel handles empty tasks', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      const BillingCollectionFollowUpQueuePanel(tasks: []),
    );

    expect(find.text('Follow-up queue'), findsOneWidget);
    expect(find.text('No follow-up work is queued right now.'), findsOneWidget);
  });
}

List<BillingCollectionTask> _tasks() {
  return buildBillingCollectionTasks(
    [
      _invoice(id: 'old-overdue', date: DateTime(2026, 5, 1), amount: 1000),
      _invoice(id: 'recent-overdue', date: DateTime(2026, 6, 10), amount: 800),
      _invoice(id: 'due-soon', date: DateTime(2026, 6, 20), amount: 500),
      _invoice(id: 'future', date: DateTime(2026, 6, 25), amount: 700),
    ],
    preferences: const BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      paymentTermsDays: 14,
    ),
    now: DateTime(2026, 6, 30),
  );
}

BillingInvoice _invoice({
  required String id,
  double amount = 1000,
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: date ?? DateTime(2026, 5, 1),
    status: status,
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(980, 820);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 760, child: child)),
      ),
    ),
  );
}
