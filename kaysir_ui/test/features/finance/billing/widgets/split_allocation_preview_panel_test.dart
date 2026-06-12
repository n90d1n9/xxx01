import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/split_allocation_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/split_allocation_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/split_allocation_preview_panel.dart';

void main() {
  testWidgets('BillingSplitAllocationPreviewPanel renders ready allocation', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingSplitAllocationPreviewPanel(
        plan: planBillingSplitAllocation(
          config: constructionBillingPolicyConfig(),
          totalAmount: 1200,
          recipients: const [
            BillingSplitAllocationRecipient(
              id: 'primary',
              label: 'Primary payer',
              share: 0.5,
            ),
            BillingSplitAllocationRecipient(
              id: 'co-payer',
              label: 'Co-payer',
              share: 0.3,
            ),
            BillingSplitAllocationRecipient(
              id: 'sponsor',
              label: 'Sponsor',
              share: 0.2,
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-split-allocation-preview')),
      findsOneWidget,
    );
    expect(find.text('Split allocation'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Primary payer'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text(r'$600.00'), findsOneWidget);
  });

  testWidgets('BillingSplitAllocationPreviewPanel renders blockers', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingSplitAllocationPreviewPanel(
        plan: planBillingSplitAllocation(
          config: agnosticBillingPolicyConfig(),
          totalAmount: 1200,
          recipients: const [
            BillingSplitAllocationRecipient(
              id: 'primary',
              label: 'Primary payer',
              share: 1,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Needs capability'), findsOneWidget);
    expect(
      find.text('Enable split billing before allocation can be used.'),
      findsOneWidget,
    );
    expect(
      find.text('Split billing must be enabled for this split.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(900, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 620, child: child)),
      ),
    ),
  );
}
