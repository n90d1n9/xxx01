import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/widgets/relief_application_packet_panel.dart';

void main() {
  testWidgets(
    'BillingExceptionReliefApplicationPacketPanel renders ready packets',
    (tester) async {
      final plan = planBillingExceptionRelief(
        config: constructionBillingPolicyConfig(),
        kind: BillingExceptionEventKind.forceMajeure,
        affectedInvoiceCount: 12,
        openAmount: 42600,
        reliefDurationDays: 21,
        approvalGranted: true,
        evidenceCaptured: true,
      );

      await _pumpPanel(
        tester,
        BillingExceptionReliefApplicationPacketPanel(
          packet: buildBillingExceptionReliefApplicationPacket(
            plan: plan,
            requestedBy: 'Ops lead',
            requestedAt: DateTime.utc(2026, 1, 15, 9),
          ),
        ),
      );

      expect(
        find.byKey(
          const ValueKey('billing-exception-relief-application-packet'),
        ),
        findsOneWidget,
      );
      expect(find.text('Relief application packet'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(
        find.text('4 relief commands ready for force majeure.'),
        findsOneWidget,
      );
      expect(find.text('Pause due dates'), findsOneWidget);
      expect(find.text('Exposure'), findsOneWidget);
      expect(find.text(r'$42,600.00'), findsOneWidget);
      expect(find.text('Ops lead'), findsOneWidget);
    },
  );

  testWidgets('BillingExceptionReliefApplicationPacketPanel renders blockers', (
    tester,
  ) async {
    final plan = planBillingExceptionRelief(
      config: constructionBillingPolicyConfig(),
      kind: BillingExceptionEventKind.forceMajeure,
      affectedInvoiceCount: 12,
      openAmount: 42600,
      reliefDurationDays: 21,
      evidenceCaptured: true,
    );

    await _pumpPanel(
      tester,
      BillingExceptionReliefApplicationPacketPanel(
        packet: buildBillingExceptionReliefApplicationPacket(
          plan: plan,
          requestedBy: 'Ops lead',
          requestedAt: DateTime.utc(2026, 1, 15, 9),
        ),
      ),
    );

    expect(find.text('Relief application packet'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(
      find.text('Application is blocked until the relief plan is actionable.'),
      findsOneWidget,
    );
    expect(
      find.text('Resolve relief plan blockers before applying changes.'),
      findsOneWidget,
    );
    expect(
      find.text('Approval must be granted before relief is applied.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 660, child: child)),
      ),
    ),
  );
}
