import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';

void main() {
  test('diagnostics release context resolves default release state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final releaseContext = container.read(
      billingDiagnosticsReleaseContextProvider(
        const BillingDiagnosticsReleaseContextRequest(),
      ),
    );

    expect(releaseContext.isDefaultScoped, isTrue);
    expect(releaseContext.isTenantScoped, isFalse);
    expect(releaseContext.businessDomain, 'commerce');
    expect(releaseContext.scopeLabel, 'Default release context');
    expect(releaseContext.releaseChannelLaunchPlan.actionCount, 14);
    expect(releaseContext.releaseChannelMatrix.blockedCellCount, 14);
    expect(releaseContext.releaseChannelLaunchQueue.itemCount, 14);
    expect(releaseContext.releaseChannelLaunchQueue.readyNowCount, 0);
    expect(releaseContext.releaseChannelLaunchQueue.blockedCount, 14);
    expect(
      releaseContext.summaryLabel,
      '14 launch tasks need release or routing work.',
    );
  });

  test(
    'diagnostics release context resolves commerce tenant release state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final releaseContext = container.read(
        billingDiagnosticsReleaseContextProvider(
          BillingDiagnosticsReleaseContextRequest.fromTenant(
            preferences: const BillingTenantPreferences(),
            tenantId: 'tenant-a',
          ),
        ),
      );

      expect(releaseContext.isTenantScoped, isTrue);
      expect(releaseContext.businessDomain, 'commerce');
      expect(releaseContext.scopeLabel, 'Tenant commerce release context');
      expect(releaseContext.releaseChannelLaunchPlan.actionCount, 14);
      expect(releaseContext.releaseChannelMatrix.publishNowCellCount, 2);
      expect(releaseContext.releaseChannelMatrix.blockedCellCount, 12);
      expect(releaseContext.releaseChannelLaunchQueue.readyNowCount, 2);
      expect(releaseContext.releaseChannelLaunchQueue.blockedCount, 12);
      expect(
        releaseContext.summaryLabel,
        '2 launch tasks ready now; 12 need release or routing work.',
      );
    },
  );

  test(
    'diagnostics release context resolves construction tenant release state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final releaseContext = container.read(
        billingDiagnosticsReleaseContextProvider(
          BillingDiagnosticsReleaseContextRequest.fromTenant(
            preferences: const BillingTenantPreferences(
              businessDomain: 'construction',
            ),
            tenantId: 'tenant-a',
          ),
        ),
      );

      expect(releaseContext.isTenantScoped, isTrue);
      expect(releaseContext.businessDomain, 'construction');
      expect(releaseContext.scopeLabel, 'Tenant construction release context');
      expect(releaseContext.releaseChannelLaunchPlan.actionCount, 14);
      expect(releaseContext.releaseChannelMatrix.reviewCellCount, 5);
      expect(releaseContext.releaseChannelMatrix.blockedCellCount, 9);
      expect(releaseContext.releaseChannelLaunchQueue.readyNowCount, 5);
      expect(releaseContext.releaseChannelLaunchQueue.blockedCount, 9);
      expect(
        releaseContext.summaryLabel,
        '5 launch tasks ready now; 9 need release or routing work.',
      );
    },
  );
}
