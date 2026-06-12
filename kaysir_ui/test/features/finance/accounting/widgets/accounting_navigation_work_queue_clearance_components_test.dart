import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_clearance_checklist.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_work_queue_clearance_components.dart';

void main() {
  testWidgets('renders clearance readiness meter and next open step', (
    tester,
  ) async {
    var copyTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueClearancePanel(
            onCopyBrief: () => copyTapped = true,
            checklist: AccountingWorkspaceWorkQueueClearanceChecklist(
              steps: const [
                AccountingWorkspaceWorkQueueClearanceStep(
                  id: 'owner-acknowledgement',
                  title: 'Owner acknowledgement',
                  ownerLabel: 'Audit liaison',
                  evidenceLabel: 'Owner response and due-date confirmation',
                  status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
                ),
                AccountingWorkspaceWorkQueueClearanceStep(
                  id: 'evidence-pack',
                  title: 'Evidence pack',
                  ownerLabel: 'Audit liaison',
                  evidenceLabel: 'Release manifest support',
                  status: AccountingWorkspaceWorkQueueClearanceStatus.blocked,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Clearance checklist'), findsOneWidget);
    expect(find.text('1 ready / 0 waiting / 1 blocked'), findsOneWidget);
    expect(find.text('Blocked clearance'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Next: Evidence pack'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-clearance-readiness-meter'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-clearance-copy-brief')),
    );
    await tester.pump();

    expect(copyTapped, isTrue);
  });
}
