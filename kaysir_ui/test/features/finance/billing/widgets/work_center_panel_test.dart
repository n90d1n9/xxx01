import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_queue_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/work_center_panel.dart';

void main() {
  testWidgets('BillingWorkCenterPanel renders aggregate work', (tester) async {
    BillingFollowUpWorkItem? selectedItem;

    await _pumpPanel(
      tester,
      BillingWorkCenterPanel(
        queue: _queue(),
        actionLabelBuilder:
            (item) =>
                item.source == BillingFollowUpWorkSource.collections
                    ? 'Open invoices'
                    : 'Track relief',
        onItemSelected: (item) {
          selectedItem = item;
        },
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-work-center-panel')),
      findsOneWidget,
    );
    expect(find.text('Billing work center'), findsOneWidget);
    expect(find.text('Follow-up queue'), findsOneWidget);
    expect(find.text('All sources'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('Collections'), findsWidgets);
    expect(find.text('Relief monitoring'), findsWidgets);
    expect(find.text('Collect invoice #1'), findsOneWidget);
    expect(find.text('Review relief closeout'), findsOneWidget);
    expect(find.text('Open invoices'), findsOneWidget);
    expect(find.text('Track relief'), findsOneWidget);

    await tester.tap(find.text('Collect invoice #1'));
    await tester.pump();

    expect(selectedItem?.id, 'collect-1');
  });

  testWidgets('BillingWorkCenterPanel renders empty aggregate work', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingWorkCenterPanel(
        queue: BillingFollowUpWorkQueue(
          title: 'Billing work center',
          sourceLabel: 'All sources',
        ),
      ),
    );

    expect(find.text('Billing work center'), findsOneWidget);
    expect(find.text('No follow-up work is queued right now.'), findsOneWidget);
  });

  testWidgets('BillingWorkCenterPanel filters aggregate work', (tester) async {
    var filter = const BillingFollowUpWorkQueueFilter(
      status: BillingFollowUpWorkStatus.ready,
    );

    await _pumpPanel(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          return BillingWorkCenterPanel(
            queue: _queue(),
            filter: filter,
            onStatusFilterChanged: (status) {
              setState(() {
                filter = filter.withStatus(status);
              });
            },
            onSourceFilterChanged: (source) {
              setState(() {
                filter = filter.withSource(source);
              });
            },
            onOwnerRoleFilterChanged: (ownerRole) {
              setState(() {
                filter = filter.withOwnerRole(ownerRole);
              });
            },
            onResetFilters: () {
              setState(() {
                filter = filter.reset();
              });
            },
          );
        },
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-follow-up-work-filter-bar')),
      findsOneWidget,
    );
    expect(find.text('Ready 1'), findsOneWidget);
    expect(find.text('Collect invoice #1'), findsOneWidget);
    expect(find.text('Review relief closeout'), findsNothing);

    await tester.tap(find.text('Scheduled 1'));
    await tester.pumpAndSettle();

    expect(find.text('Review relief closeout'), findsOneWidget);
    expect(find.text('Collect invoice #1'), findsNothing);

    await tester.tap(find.text('Relief monitoring 1'));
    await tester.pumpAndSettle();

    expect(find.text('Review relief closeout'), findsOneWidget);

    await tester.tap(find.text('Finance owner 1'));
    await tester.pumpAndSettle();

    expect(find.text('Review relief closeout'), findsOneWidget);
    expect(find.text('Collect invoice #1'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('billing-follow-up-work-reset-filters')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collect invoice #1'), findsOneWidget);
    expect(find.text('Review relief closeout'), findsOneWidget);
  });
}

BillingFollowUpWorkQueue _queue() {
  return BillingFollowUpWorkQueue(
    title: 'Billing work center',
    sourceLabel: 'All sources',
    items: [
      BillingFollowUpWorkItem(
        id: 'collect-1',
        source: BillingFollowUpWorkSource.collections,
        priority: BillingFollowUpWorkPriority.urgent,
        status: BillingFollowUpWorkStatus.ready,
        title: 'Collect invoice #1',
        description: 'Rp 1,000 is overdue and needs collection.',
        ownerRole: 'Accounts receivable',
        dueInDays: 0,
        tags: const ['Collect', 'Rp 1,000', 'Overdue'],
      ),
      BillingFollowUpWorkItem(
        id: 'relief-1',
        source: BillingFollowUpWorkSource.reliefMonitoring,
        priority: BillingFollowUpWorkPriority.normal,
        status: BillingFollowUpWorkStatus.scheduled,
        title: 'Review relief closeout',
        description: 'Close the relief window and archive evidence.',
        ownerRole: 'Finance owner',
        dueInDays: 7,
        tags: const ['Active watch', 'Required'],
      ),
    ],
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(980, 840);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: 820, child: child),
        ),
      ),
    ),
  );
}
