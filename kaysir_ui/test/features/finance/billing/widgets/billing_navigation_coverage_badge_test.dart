import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_coverage_badge.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets('BillingNavigationCoverageBadge renders complete coverage', (
    tester,
  ) async {
    final summary =
        BillingNavigationCoverageReport.forModule(
          commerceBillingDomainModule(),
        ).summary;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingNavigationCoverageBadge(summary: summary)),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(
      find.byTooltip('Billing navigation coverage is complete.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('BillingNavigationCoverageBadge renders unavailable coverage', (
    tester,
  ) async {
    final summary =
        BillingNavigationCoverageReport.forModule(
          commerceBillingDomainModule(),
          hasTenant: false,
        ).summary;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingNavigationCoverageBadge(summary: summary)),
      ),
    );

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.byTooltip(summary.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('BillingNavigationCoverageBadge renders missing plans', (
    tester,
  ) async {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service operations',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final summary = BillingNavigationCoverageSummary(
      issues: [
        BillingNavigationCoverageIssue(
          profile: profile,
          destination: billingNavigationDestinationFor(
            BillingNavigationDestinationId.reports,
          ),
          surfaceDecisions: const [
            BillingNavigationIssueSurfaceDecision(
              surface: BillingNavigationSurface.dashboard,
              isActionable: false,
              isUnavailable: false,
              isMissingPlan: true,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingNavigationCoverageBadge(summary: summary)),
      ),
    );

    expect(find.text('Incomplete'), findsOneWidget);
    expect(find.byTooltip('1 navigation gap across 1 domain.'), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
  });
}
