import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/finance/billing/billing_features.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_saved_view_registry_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_section_registry_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_route_contract_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_dashboard_screen.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_screen.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';

void main() {
  testWidgets('BillingDiagnosticsScreen renders module readiness', (
    tester,
  ) async {
    final container = _container(tester);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Billing Diagnostics'), findsWidgets);
    expect(find.text('Billing modules'), findsOneWidget);
    expect(find.text('Commerce'), findsWidgets);
    await _dragUntilDiagnosticsTextVisible(tester, 'Domain catalog');
    expect(find.text('Domain catalog'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Product blueprints');
    expect(find.text('Product blueprints'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Blueprint fit matrix');
    expect(find.text('Blueprint fit matrix'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Product launch plan');
    expect(find.text('Product launch plan'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Product packages');
    expect(find.text('Product packages'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Package launch playbook');
    expect(find.text('Package launch playbook'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Package release manifests');
    expect(find.text('Package release manifests'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Package release bundles');
    expect(find.text('Package release bundles'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Product release editions');
    expect(find.text('Product release editions'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Edition channel matrix');
    expect(find.text('Edition channel matrix'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Channel launch plan');
    expect(find.text('Channel launch plan'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Channel launch runbook');
    expect(find.text('Channel launch runbook'), findsOneWidget);
    await _dragUntilDiagnosticsTextVisible(tester, 'Channel launch queue');
    expect(find.text('Channel launch queue'), findsOneWidget);
    await _dragUntilDiagnosticsFinderVisible(
      tester,
      find.byKey(const ValueKey('billing-diagnostics-section-release-gate')),
    );
    expect(find.text('Release gate'), findsOneWidget);
    await _dragUntilDiagnosticsFinderVisible(
      tester,
      find.byKey(const ValueKey('billing-diagnostics-section-navigation')),
    );
    expect(find.text('Route launch center'), findsOneWidget);
    expect(find.text('Navigation coverage'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-navigation-tile-diagnostics')),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsScreen renders route contract section', (
    tester,
  ) async {
    final container = _container(
      tester,
      diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
        hiddenSectionIds: const {
          billingDiagnosticsOverviewSectionId,
          billingDiagnosticsDomainSectionId,
          billingDiagnosticsReleaseProfileCoverageSectionId,
          billingDiagnosticsReleaseSectionId,
          billingDiagnosticsReleaseGateSectionId,
          billingDiagnosticsRouteExtensionManifestSectionId,
          billingDiagnosticsNavigationSectionId,
        },
      ),
    );
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-route-contract')),
      findsOneWidget,
    );
    expect(find.text('Route contract'), findsOneWidget);
    expect(
      find.text(
        'Billing route contract is complete across '
        '${BillingRoutes.sidebarRoutes.length} routes.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'BillingDiagnosticsScreen uses route contract provider override',
    (tester) async {
      final container = _container(
        tester,
        diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
          hiddenSectionIds: const {
            billingDiagnosticsOverviewSectionId,
            billingDiagnosticsDomainSectionId,
            billingDiagnosticsReleaseProfileCoverageSectionId,
            billingDiagnosticsReleaseSectionId,
            billingDiagnosticsReleaseGateSectionId,
            billingDiagnosticsRouteExtensionManifestSectionId,
            billingDiagnosticsNavigationSectionId,
          },
        ),
        routeContractReport: _routeContractReportWithIssues([
          BillingRouteContractIssue(
            kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
            severity: BillingRouteContractIssueSeverity.blocker,
            routeName: BillingRoutes.checkoutRouteName,
            message: 'Missing checkout page builder',
          ),
        ]),
      );
      container.read(selectedBillingTenantIdProvider.notifier).state =
          'tenant-a';

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDiagnosticsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Billing route contract has 1 blocker and 0 warnings.'),
        findsOneWidget,
      );
      expect(
        find.text('Attach ${BillingRoutes.checkoutRouteName} page builder'),
        findsOneWidget,
      );
      expect(find.text('Open checkout'), findsOneWidget);
    },
  );

  testWidgets(
    'BillingDiagnosticsScreen uses manifest readiness provider override',
    (tester) async {
      final container = _container(
        tester,
        diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
          hiddenSectionIds: const {
            billingDiagnosticsOverviewSectionId,
            billingDiagnosticsDomainSectionId,
            billingDiagnosticsReleaseProfileCoverageSectionId,
            billingDiagnosticsReleaseSectionId,
            billingDiagnosticsReleaseGateSectionId,
            billingDiagnosticsRouteContractSectionId,
            billingDiagnosticsNavigationSectionId,
          },
        ),
        routeExtensionManifestReport: BillingRouteExtensionManifestReport(
          manifests: const [],
          issues: [
            BillingRouteExtensionManifestIssue(
              kind: BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
              severity: BillingRouteExtensionManifestIssueSeverity.warning,
              manifestId: 'billing.subscription',
              message:
                  'billingSubscription has a page builder but no route definition.',
              details: const ['routeIdentityKey=billingSubscription'],
            ),
          ],
        ),
      );
      container.read(selectedBillingTenantIdProvider.notifier).state =
          'tenant-a';

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDiagnosticsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Route extension manifests'), findsOneWidget);
      expect(
        find.text(
          'Billing route extension manifests have 0 blockers and 1 warning.',
        ),
        findsOneWidget,
      );
      expect(find.text('Orphan page builder'), findsOneWidget);
      expect(find.text('billing.subscription'), findsOneWidget);
      expect(find.text('Suggested fixes'), findsOneWidget);
      expect(
        find.text('Resolve billing.subscription orphan builder'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'BillingDiagnosticsScreen scopes release queue to tenant domain',
    (tester) async {
      final container = _container(
        tester,
        tenantPreferences: const BillingTenantPreferences(
          businessDomain: 'construction',
        ),
      );
      container.read(selectedBillingTenantIdProvider.notifier).state =
          'tenant-a';

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDiagnosticsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Construction milestone diagnostics'), findsOneWidget);
      expect(find.text('Milestone billing'), findsOneWidget);
      await _dragUntilDiagnosticsTextVisible(tester, 'Channel launch queue');

      expect(find.text('Channel launch queue'), findsOneWidget);
      expect(
        find.text('5 launch tasks ready now; 9 need release or routing work.'),
        findsOneWidget,
      );
      expect(find.text('Ready now'), findsWidgets);
      expect(find.text('Blocked by release'), findsWidgets);
    },
  );

  testWidgets('BillingDiagnosticsScreen supports registry provider overrides', (
    tester,
  ) async {
    final container = _container(
      tester,
      diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
        hiddenSectionIds: {billingDiagnosticsReleaseSectionId},
        extensions: [
          BillingDiagnosticsSectionDescriptor(
            id: 'subscription-health',
            priority: 150,
            builder:
                (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Subscription health diagnostics'),
                ),
          ),
        ],
      ),
    );
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Subscription health diagnostics'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-release')),
      findsNothing,
    );
  });

  testWidgets(
    'BillingDiagnosticsScreen supports release profile saved-view registry overrides',
    (tester) async {
      final container = _container(
        tester,
        releaseProfileSavedViewRegistry:
            BillingDiagnosticsReleaseProfileSavedViewRegistry.standard(
              hiddenViewIds: {
                billingDiagnosticsReleaseProfileCurrentDomainSavedViewId,
              },
            ),
      );
      container.read(selectedBillingTenantIdProvider.notifier).state =
          'tenant-a';

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDiagnosticsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await _dragUntilDiagnosticsTextVisible(
        tester,
        'Release profile coverage',
      );

      expect(find.text('Profile views'), findsOneWidget);
      expect(find.text('Current domain'), findsNothing);
      expect(find.text('Standard profiles'), findsOneWidget);
    },
  );

  testWidgets('BillingDiagnosticsScreen persists release profile filters', (
    tester,
  ) async {
    final container = _container(tester);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await _dragUntilDiagnosticsTextVisible(tester, 'Release profile coverage');
    await tester.tap(find.text('Standard 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All domains'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail · 1 profile'));
    await tester.pumpAndSettle();

    final filterScope = BillingDiagnosticsReleaseProfileFilterScope(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
    );
    final selectedState = container.read(
      billingDiagnosticsReleaseProfileFilterProvider(filterScope),
    );
    expect(
      selectedState.statusOption,
      BillingReleaseProfileStatusFilterOption.standard,
    );
    expect(
      selectedState.domainSelection,
      BillingReleaseProfileDomainFilterSelection.domain('retail'),
    );
    expect(
      find.text('Showing 1 standard release profile · Scoped to Retail'),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await _dragUntilDiagnosticsTextVisible(
      tester,
      'Showing 1 standard release profile · Scoped to Retail',
    );

    expect(
      find.text('Showing 1 standard release profile · Scoped to Retail'),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'billing-diagnostics-release-profile-filter-badge-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(
        billingDiagnosticsReleaseProfileFilterProvider(filterScope),
      ),
      const BillingDiagnosticsReleaseProfileFilterState(),
    );
    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsNothing,
    );
  });

  testWidgets('BillingDiagnosticsScreen copies active diagnostics link', (
    tester,
  ) async {
    final copiedLinks = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedLinks.add(arguments['text']! as String);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final container = _container(tester);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';
    final filterScope = BillingDiagnosticsReleaseProfileFilterScope(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
    );
    container
        .read(
          billingDiagnosticsReleaseProfileFilterProvider(filterScope).notifier,
        )
        .hydrate(
          BillingDiagnosticsReleaseProfileFilterState(
            statusOption: BillingReleaseProfileStatusFilterOption.standard,
            domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
              'retail',
            ),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDiagnosticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('billing-diagnostics-copy-link-action')),
    );
    await tester.pump();

    expect(copiedLinks, hasLength(1));
    final copiedUri = Uri.parse(copiedLinks.single);
    final diagnosticsUri =
        copiedUri.fragment.isEmpty ? copiedUri : Uri.parse(copiedUri.fragment);
    expect(diagnosticsUri.path, BillingRoutes.diagnosticsPath);
    expect(
      diagnosticsUri.queryParameters[BillingRoutes.tenantQueryKey],
      'tenant-a',
    );
    expect(
      diagnosticsUri.queryParameters[BillingRoutes.businessDomainQueryKey],
      'commerce',
    );
    expect(
      diagnosticsUri
          .queryParameters[billingDiagnosticsReleaseProfileStatusQueryKey],
      'standard',
    );
    expect(
      diagnosticsUri
          .queryParameters[billingDiagnosticsReleaseProfileDomainQueryKey],
      'retail',
    );
    expect(find.text('Diagnostics link copied'), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsScreen opens shared filtered route links', (
    tester,
  ) async {
    final container = _container(tester);
    final router = _billingDiagnosticsRouter(
      initialLocation:
          '${BillingRoutes.diagnosticsPath}?'
          '${BillingRoutes.tenantQueryKey}=tenant-a&'
          '${BillingRoutes.businessDomainQueryKey}=commerce&'
          '$billingDiagnosticsReleaseProfileStatusQueryKey=standard&'
          '$billingDiagnosticsReleaseProfileDomainQueryKey=retail',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BillingDiagnosticsScreen), findsOneWidget);
    expect(container.read(selectedBillingTenantIdProvider), 'tenant-a');

    final filterScope = BillingDiagnosticsReleaseProfileFilterScope(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
    );
    final filterState = container.read(
      billingDiagnosticsReleaseProfileFilterProvider(filterScope),
    );

    expect(
      filterState.statusOption,
      BillingReleaseProfileStatusFilterOption.standard,
    );
    expect(
      filterState.domainSelection,
      BillingReleaseProfileDomainFilterSelection.domain('retail'),
    );
    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-release-profile-filter-badge'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('BillingDashboardScreen opens diagnostics from sidebar', (
    tester,
  ) async {
    final container = _container(tester);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-a';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final diagnosticsTile = find.byKey(
      const ValueKey('billing-navigation-tile-diagnostics'),
    );
    await tester.ensureVisible(diagnosticsTile);
    await tester.pumpAndSettle();
    await tester.tap(diagnosticsTile);
    await tester.pumpAndSettle();

    expect(find.byType(BillingDiagnosticsScreen), findsOneWidget);
    expect(find.text('Billing modules'), findsOneWidget);
  });
}

GoRouter _billingDiagnosticsRouter({required String initialLocation}) {
  final diagnosticsRoute = _billingFeatureRoute(BillingRoutes.diagnosticsPath);

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: diagnosticsRoute.path!,
        name: diagnosticsRoute.goRouteName,
        pageBuilder: diagnosticsRoute.pageBuilder!,
      ),
    ],
  );
}

FeatureRoutes _billingFeatureRoute(String path) {
  final root = BillingFeatures().registerScreens().single;

  for (final route in root.items) {
    if (route.path == path) return route;
  }

  throw StateError('Missing billing feature route for $path');
}

BillingRouteContractReport _routeContractReportWithIssues(
  Iterable<BillingRouteContractIssue> issues,
) {
  final registryReport = BillingRouteContractReport.forRouteRegistry();

  return BillingRouteContractReport(
    rootRoute: registryReport.rootRoute,
    routeDefinitions: registryReport.routeDefinitions,
    issues: issues,
  );
}

Future<void> _dragUntilDiagnosticsTextVisible(
  WidgetTester tester,
  String text,
) async {
  await _dragUntilDiagnosticsFinderVisible(tester, find.text(text));
}

Future<void> _dragUntilDiagnosticsFinderVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.dragUntilVisible(
    finder,
    find.byKey(const ValueKey('billing-diagnostics-scroll')),
    const Offset(0, -420),
    maxIteration: 40,
  );
  await tester.pumpAndSettle();
}

ProviderContainer _container(
  WidgetTester tester, {
  BillingTenantPreferences tenantPreferences = const BillingTenantPreferences(),
  BillingDiagnosticsSectionRegistry? diagnosticsSectionRegistry,
  BillingDiagnosticsReleaseProfileSavedViewRegistry?
  releaseProfileSavedViewRegistry,
  BillingRouteContractReport? routeContractReport,
  BillingRouteExtensionManifestReport? routeExtensionManifestReport,
}) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      billingDashboardRepositoryProvider.overrideWithValue(
        _FakeBillingDashboardRepository(tenantPreferences: tenantPreferences),
      ),
      if (diagnosticsSectionRegistry != null)
        billingDiagnosticsSectionRegistryProvider.overrideWithValue(
          diagnosticsSectionRegistry,
        ),
      if (releaseProfileSavedViewRegistry != null)
        billingDiagnosticsReleaseProfileSavedViewRegistryProvider
            .overrideWithValue(releaseProfileSavedViewRegistry),
      if (routeContractReport != null)
        billingRouteContractReportProvider.overrideWithValue(
          routeContractReport,
        ),
      if (routeExtensionManifestReport != null)
        billingRouteExtensionManifestReportProvider.overrideWithValue(
          routeExtensionManifestReport,
        ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final BillingTenantPreferences tenantPreferences;

  const _FakeBillingDashboardRepository({
    this.tenantPreferences = const BillingTenantPreferences(),
  });

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return [
      BillingTenantAccount(
        id: 'tenant-a',
        name: 'Acme Corp',
        logoUrl: '',
        planName: 'Enterprise',
        currentBalance: 1200,
        preferences: tenantPreferences,
      ),
    ];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return [
      BillingInvoice(
        id: 'inv-1',
        tenantId: tenantId,
        amount: 250,
        date: DateTime(2026, 6),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 250,
      pendingAmount: 250,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
      usageData: const [BillingUsagePoint(label: 'Jun', amount: 250)],
    );
  }
}
