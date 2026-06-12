import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';
import 'package:kaysir/features/finance/billing/widgets/relief_impact_summary_panel.dart';

void main() {
  testWidgets('BillingExceptionReliefImpactSummaryPanel renders impact', (
    tester,
  ) async {
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
      BillingExceptionReliefImpactSummaryPanel(
        summary: summarizeBillingExceptionReliefImpact(
          packet: buildBillingExceptionReliefApplicationPacket(
            plan: plan,
            requestedBy: 'Ops lead',
            requestedAt: DateTime.utc(2026, 1, 15, 9),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-exception-relief-impact-summary')),
      findsOneWidget,
    );
    expect(find.text('Relief impact'), findsOneWidget);
    expect(find.text('High impact'), findsOneWidget);
    expect(find.text('Cash deferral'), findsOneWidget);
    expect(find.text('Collection hold'), findsOneWidget);
    expect(find.text('Late fee suppression'), findsOneWidget);
    expect(find.text('Recovery schedule'), findsOneWidget);
    expect(find.text(r'$42,600.00'), findsWidgets);
    expect(find.text(r'$2,028.57'), findsOneWidget);
  });

  testWidgets('BillingExceptionReliefImpactSummaryPanel renders blockers', (
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
      BillingExceptionReliefImpactSummaryPanel(
        summary: summarizeBillingExceptionReliefImpact(
          packet: buildBillingExceptionReliefApplicationPacket(
            plan: plan,
            requestedBy: 'Ops lead',
            requestedAt: DateTime.utc(2026, 1, 15, 9),
          ),
        ),
      ),
    );

    expect(find.text('Relief impact'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(
      find.text(
        'Relief impact cannot be finalized until packet blockers are resolved.',
      ),
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
