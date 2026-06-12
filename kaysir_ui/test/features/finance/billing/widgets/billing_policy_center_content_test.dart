import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_policy_center_content.dart';

void main() {
  testWidgets('BillingPolicyCenterContent renders policy coverage', (
    tester,
  ) async {
    await _pumpContent(
      tester,
      BillingPolicyCenterContent(
        config: constructionBillingPolicyConfig(),
        capabilities: standardBillingPolicyCapabilities(),
        businessDomainLabel: 'Construction',
      ),
    );

    expect(find.text('Billing policy center'), findsOneWidget);
    expect(find.text('Capability gates'), findsOneWidget);
    expect(find.text('Split preview'), findsOneWidget);
    expect(find.text('Exception conditions'), findsOneWidget);
    expect(find.text('Relief workflow'), findsOneWidget);
    expect(find.text('Application packet'), findsOneWidget);
    expect(find.text('Impact summary'), findsOneWidget);
    expect(find.text('Approval guidance'), findsWidgets);
    expect(find.text('Execution handoff'), findsWidgets);
    expect(find.text('Monitoring plan'), findsWidgets);
    expect(find.text('Follow-up queue'), findsWidgets);
    expect(find.text('Decision preview'), findsOneWidget);
    expect(find.text('Split billing'), findsOneWidget);
    expect(find.text('Split allocation'), findsOneWidget);
    expect(find.text('Primary payer'), findsOneWidget);
    expect(find.text('Force majeure relief plan'), findsOneWidget);
    expect(find.text('Relief application packet'), findsOneWidget);
    expect(find.text('Relief impact'), findsOneWidget);
    expect(find.text('Cash deferral'), findsOneWidget);
    expect(find.text('Finance owner sign-off'), findsWidgets);
    expect(find.text('Cash forecast update'), findsWidgets);
    expect(find.text('Apply relief commands'), findsOneWidget);
    expect(find.text('Cash forecast review'), findsWidgets);
    expect(find.text('Relief closeout'), findsOneWidget);
    expect(find.text('Exception relief'), findsOneWidget);
    expect(find.text('Customer success'), findsWidgets);
    expect(find.text('Submit approval'), findsOneWidget);
    expect(find.text('Milestone billing'), findsOneWidget);
    expect(find.text('Force majeure'), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Suspend dunning'), findsWidgets);
  });

  testWidgets('BillingPolicyCenterContent forwards capability toggles', (
    tester,
  ) async {
    BillingPolicyCapabilityId? selectedCapability;
    bool? selectedEnabled;

    await _pumpContent(
      tester,
      BillingPolicyCenterContent(
        config: agnosticBillingPolicyConfig(),
        capabilities: standardBillingPolicyCapabilities(),
        onCapabilityChanged: (capabilityId, enabled) {
          selectedCapability = capabilityId;
          selectedEnabled = enabled;
        },
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('billing-policy-capability-toggle-splitBilling'),
      ),
    );
    await tester.pump();

    expect(selectedCapability, BillingPolicyCapabilityId.splitBilling);
    expect(selectedEnabled, isTrue);
  });
}

Future<void> _pumpContent(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
  );
}
