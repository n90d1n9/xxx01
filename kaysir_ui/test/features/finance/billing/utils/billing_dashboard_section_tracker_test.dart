import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_dashboard_section_tracker.dart';

void main() {
  test('activeBillingDashboardSection selects the nearest active section', () {
    final active = activeBillingDashboardSection(const [
      BillingDashboardSectionPosition(
        section: 'dashboard',
        leadingOffset: -420,
      ),
      BillingDashboardSectionPosition(section: 'reports', leadingOffset: 72),
      BillingDashboardSectionPosition(section: 'invoices', leadingOffset: 620),
    ]);

    expect(active, 'reports');
  });

  test(
    'activeBillingDashboardSection keeps the first section before threshold',
    () {
      final active = activeBillingDashboardSection(const [
        BillingDashboardSectionPosition(
          section: 'dashboard',
          leadingOffset: 12,
        ),
        BillingDashboardSectionPosition(section: 'reports', leadingOffset: 360),
      ]);

      expect(active, 'dashboard');
    },
  );

  test('activeBillingDashboardSection ignores invalid offsets', () {
    final active = activeBillingDashboardSection(const [
      BillingDashboardSectionPosition(
        section: 'dashboard',
        leadingOffset: double.nan,
      ),
      BillingDashboardSectionPosition(section: 'invoices', leadingOffset: 24),
    ]);

    expect(active, 'invoices');
  });

  test('activeBillingDashboardSection honors custom activation offsets', () {
    final active = activeBillingDashboardSection(const [
      BillingDashboardSectionPosition(section: 'reports', leadingOffset: -360),
      BillingDashboardSectionPosition(section: 'invoices', leadingOffset: 560),
    ], activationOffset: 620);

    expect(active, 'invoices');
  });
}
