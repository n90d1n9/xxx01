import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_filter_badge.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';

void main() {
  testWidgets('diagnostics release profile filter badge hides when inactive', (
    tester,
  ) async {
    await _pumpBadge(
      tester,
      BillingDiagnosticsReleaseProfileFilterSnapshot(
        scope: _scope,
        state: const BillingDiagnosticsReleaseProfileFilterState(),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsNothing,
    );
  });

  testWidgets('diagnostics release profile filter badge clears filters', (
    tester,
  ) async {
    var clearCount = 0;

    await _pumpBadge(
      tester,
      BillingDiagnosticsReleaseProfileFilterSnapshot(
        scope: _scope,
        state: BillingDiagnosticsReleaseProfileFilterState(
          statusOption: BillingReleaseProfileStatusFilterOption.standard,
          domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
            'retail',
          ),
        ),
      ),
      onClear: () {
        clearCount += 1;
      },
    );

    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(
              const ValueKey(
                'billing-diagnostics-release-profile-filter-badge-button',
              ),
            ),
          )
          .tooltip,
      'Clear release profile filters. 2 filters active: Status: Standard; '
      'Domain: Retail.',
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'billing-diagnostics-release-profile-filter-badge-button',
        ),
      ),
    );
    await tester.pump();

    expect(clearCount, 1);
  });
}

final _scope = BillingDiagnosticsReleaseProfileFilterScope(
  tenantId: 'tenant-a',
  businessDomain: 'commerce',
);

Future<void> _pumpBadge(
  WidgetTester tester,
  BillingDiagnosticsReleaseProfileFilterSnapshot snapshot, {
  VoidCallback? onClear,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            BillingDiagnosticsReleaseProfileFilterBadge(
              snapshot: snapshot,
              onClear: onClear,
            ),
          ],
        ),
      ),
    ),
  );
}
