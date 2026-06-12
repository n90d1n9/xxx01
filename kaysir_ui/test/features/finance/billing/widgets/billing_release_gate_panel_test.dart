import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_panel.dart';

void main() {
  testWidgets('BillingReleaseGatePanel renders ready lanes', (tester) async {
    await _pumpPanel(
      tester,
      BillingReleaseGatePanel(
        report: BillingReleaseGateReport(
          lanes: const [
            BillingReleaseGateLane(
              id: billingReleaseGateRouteContractLaneId,
              title: 'Route contract',
              status: BillingReleaseGateStatus.ready,
              summaryLabel: 'Billing route contract is complete.',
              blockerCount: 0,
              warningCount: 0,
              actionCount: 0,
              priority: 100,
            ),
            BillingReleaseGateLane(
              id: billingReleaseGateRouteExecutionLaneId,
              title: 'Route execution',
              status: BillingReleaseGateStatus.ready,
              summaryLabel: 'Billing route execution is ready.',
              blockerCount: 0,
              warningCount: 0,
              actionCount: 0,
              priority: 200,
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-release-gate-panel')),
      findsOneWidget,
    );
    expect(find.text('Release gate'), findsOneWidget);
    expect(
      find.text('Billing release gate is ready across 2 lanes.'),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Route contract'), findsOneWidget);
    expect(find.text('Route execution'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsWidgets);
  });

  testWidgets('BillingReleaseGatePanel renders blocked and overflow lanes', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingReleaseGatePanel(
        maxVisibleLanes: 2,
        report: BillingReleaseGateReport(
          lanes: const [
            BillingReleaseGateLane(
              id: billingReleaseGateRouteContractLaneId,
              title: 'Route contract',
              status: BillingReleaseGateStatus.ready,
              summaryLabel: 'Billing route contract is complete.',
              blockerCount: 0,
              warningCount: 0,
              actionCount: 0,
              priority: 100,
            ),
            BillingReleaseGateLane(
              id: billingReleaseGateRouteExecutionLaneId,
              title: 'Route execution',
              status: BillingReleaseGateStatus.blocked,
              summaryLabel: 'Billing route execution has 1 builder blocker.',
              blockerCount: 1,
              warningCount: 0,
              actionCount: 1,
              priority: 200,
            ),
            BillingReleaseGateLane(
              id: billingReleaseGateRouteExtensionManifestLaneId,
              title: 'Route extension manifests',
              status: BillingReleaseGateStatus.hardening,
              summaryLabel: 'Billing route extension manifests have 1 warning.',
              blockerCount: 0,
              warningCount: 1,
              actionCount: 1,
              priority: 300,
            ),
          ],
        ),
      ),
    );

    expect(
      find.text('Billing release gate is blocked by 1 blocker across 1 lane.'),
      findsOneWidget,
    );
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Hardening'), findsNothing);
    expect(find.text('Route execution'), findsOneWidget);
    expect(find.text('Route extension manifests'), findsNothing);
    expect(find.text('+1 more lane hidden'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-release-gate-lane-route-execution')),
      findsOneWidget,
    );
  });

  testWidgets('BillingReleaseGatePanel dispatches lane actions', (
    tester,
  ) async {
    String? selectedLaneId;

    await _pumpPanel(
      tester,
      BillingReleaseGatePanel(
        onLaneSelected: (lane) {
          selectedLaneId = lane.id;
        },
        report: BillingReleaseGateReport(
          lanes: const [
            BillingReleaseGateLane(
              id: billingReleaseGateRouteExecutionLaneId,
              title: 'Route execution',
              status: BillingReleaseGateStatus.blocked,
              summaryLabel: 'Billing route execution has 1 builder blocker.',
              blockerCount: 1,
              warningCount: 0,
              actionCount: 1,
              priority: 100,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Review blockers'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('billing-release-gate-lane-action-route-execution'),
      ),
    );
    await tester.pump();

    expect(selectedLaneId, billingReleaseGateRouteExecutionLaneId);
  });

  testWidgets('BillingReleaseGatePanel hides disabled lane actions', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingReleaseGatePanel(
        onLaneSelected: (_) {},
        canSelectLane: (_) => false,
        report: BillingReleaseGateReport(
          lanes: const [
            BillingReleaseGateLane(
              id: billingReleaseGateRouteExecutionLaneId,
              title: 'Route execution',
              status: BillingReleaseGateStatus.blocked,
              summaryLabel: 'Billing route execution has 1 builder blocker.',
              blockerCount: 1,
              warningCount: 0,
              actionCount: 1,
              priority: 100,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Review blockers'), findsNothing);
    expect(
      find.byKey(
        const ValueKey('billing-release-gate-lane-action-route-execution'),
      ),
      findsNothing,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(960, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(width: 720, child: child),
          ),
        ),
      ),
    ),
  );
}
