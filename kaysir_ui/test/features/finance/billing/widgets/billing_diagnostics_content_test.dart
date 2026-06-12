import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_domain_context_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_screen_context_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_content.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_lane_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';

void main() {
  testWidgets('BillingDiagnosticsContent renders the diagnostics chain', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
      ),
    );

    expect(find.byKey(const ValueKey('billing-diagnostics-scroll')), findsOne);
    expect(find.text('Billing Diagnostics'), findsOneWidget);
    expect(find.text('Billing modules'), findsOneWidget);
    await _dragUntilContentTextVisible(tester, 'Release profile coverage');
    expect(find.text('Release profile coverage'), findsOneWidget);
    expect(
      find.text('3 release workspace profiles cover 14 business domains.'),
      findsOneWidget,
    );
    expect(find.text('Commerce · Covered'), findsOneWidget);
    expect(
      find.text('Commerce uses the commerce release workspace profile.'),
      findsOneWidget,
    );
    await _dragUntilContentTextVisible(tester, 'Product packages');
    expect(find.text('Product packages'), findsOneWidget);
    await _dragUntilContentTextVisible(tester, 'Channel launch queue');
    expect(find.text('Channel launch queue'), findsOneWidget);
    await _dragUntilContentFinderVisible(
      tester,
      find.byKey(const ValueKey('billing-diagnostics-section-release-gate')),
    );
    expect(find.text('Release gate'), findsOneWidget);
    await _dragUntilContentFinderVisible(
      tester,
      find.byKey(
        const ValueKey('billing-diagnostics-section-route-extension-manifests'),
      ),
    );
    expect(find.text('Route extension manifests'), findsOneWidget);
    await _dragUntilContentFinderVisible(
      tester,
      find.byKey(const ValueKey('billing-diagnostics-section-navigation')),
    );
    expect(find.text('Route launch center'), findsOneWidget);
    expect(find.text('Navigation coverage'), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsContent renders route contract section', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
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
      ),
    );

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

  testWidgets('BillingDiagnosticsContent renders release gate section', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        releaseGateReport: BillingReleaseGateReport(
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
          ],
        ),
        diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
          hiddenSectionIds: const {
            billingDiagnosticsOverviewSectionId,
            billingDiagnosticsDomainSectionId,
            billingDiagnosticsReleaseProfileCoverageSectionId,
            billingDiagnosticsReleaseSectionId,
            billingDiagnosticsRouteExtensionManifestSectionId,
            billingDiagnosticsRouteContractSectionId,
            billingDiagnosticsNavigationSectionId,
          },
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-release-gate')),
      findsOneWidget,
    );
    expect(find.text('Release gate'), findsOneWidget);
    expect(
      find.text('Billing release gate is blocked by 1 blocker across 1 lane.'),
      findsOneWidget,
    );
    expect(find.text('Route execution'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsContent jumps from release gate lanes', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        releaseGateReport: BillingReleaseGateReport(
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
        diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
          hiddenSectionIds: const {
            billingDiagnosticsOverviewSectionId,
            billingDiagnosticsDomainSectionId,
            billingDiagnosticsReleaseProfileCoverageSectionId,
            billingDiagnosticsReleaseSectionId,
            billingDiagnosticsRouteExtensionManifestSectionId,
            billingDiagnosticsNavigationSectionId,
          },
        ),
      ),
      viewSize: const Size(960, 520),
    );

    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-release-gate')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey('billing-release-gate-lane-action-route-execution'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-route-contract')),
      findsOneWidget,
    );
    expect(find.text('Route contract'), findsOneWidget);
  });

  testWidgets(
    'BillingDiagnosticsContent jumps from extension release gate lanes',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final context = _diagnosticsContext(container);

      await _pumpContent(
        tester,
        BillingDiagnosticsContent(
          diagnosticsContext: context,
          includeSafeArea: false,
          releaseGateReport: BillingReleaseGateReport(
            lanes: const [
              BillingReleaseGateLane(
                id: 'construction-handover',
                title: 'Construction handover',
                status: BillingReleaseGateStatus.hardening,
                summaryLabel: 'Construction handover has 1 warning.',
                blockerCount: 0,
                warningCount: 1,
                actionCount: 1,
                priority: 100,
              ),
            ],
          ),
          releaseGateLaneTargetRegistry:
              standardBillingReleaseGateLaneTargetRegistry(
                extensions: const [
                  BillingReleaseGateLaneTarget(
                    laneId: 'construction-handover',
                    sectionId: 'construction-signal',
                  ),
                ],
              ),
          diagnosticsSectionRegistry:
              BillingDiagnosticsSectionRegistry.standard(
                hiddenSectionIds: const {
                  billingDiagnosticsOverviewSectionId,
                  billingDiagnosticsDomainSectionId,
                  billingDiagnosticsReleaseProfileCoverageSectionId,
                  billingDiagnosticsReleaseSectionId,
                  billingDiagnosticsRouteExtensionManifestSectionId,
                  billingDiagnosticsRouteContractSectionId,
                  billingDiagnosticsNavigationSectionId,
                },
                extensions: [
                  BillingDiagnosticsSectionDescriptor(
                    id: 'construction-signal',
                    priority: 360,
                    builder:
                        (_) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Construction signal diagnostics'),
                        ),
                  ),
                ],
              ),
        ),
        viewSize: const Size(960, 420),
      );

      await tester.tap(
        find.byKey(
          const ValueKey(
            'billing-release-gate-lane-action-construction-handover',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Construction signal diagnostics'), findsOneWidget);
    },
  );

  testWidgets('BillingDiagnosticsContent renders manifest readiness section', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        routeExtensionManifestReport: BillingRouteExtensionManifestReport(
          manifests: const [],
          issues: [
            BillingRouteExtensionManifestIssue(
              kind: BillingRouteExtensionManifestIssueKind.missingPageBuilder,
              severity: BillingRouteExtensionManifestIssueSeverity.blocker,
              manifestId: 'billing.entitlements',
              message:
                  'billingEntitlements is declared without a manifest page builder.',
              details: const ['routeIdentityKey=billingEntitlements'],
            ),
          ],
        ),
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
      ),
    );

    expect(
      find.byKey(
        const ValueKey('billing-diagnostics-section-route-extension-manifests'),
      ),
      findsOneWidget,
    );
    expect(find.text('Route extension manifests'), findsOneWidget);
    expect(
      find.text(
        'Billing route extension manifests have 1 blocker and 0 warnings.',
      ),
      findsOneWidget,
    );
    expect(find.text('Missing page builder'), findsOneWidget);
    expect(find.text('billing.entitlements'), findsOneWidget);
    expect(find.text('Suggested fixes'), findsOneWidget);
    expect(
      find.text('Attach billing.entitlements page builder'),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsContent forwards route execution report', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);
    final routeRegistry = BillingRouteDefinitionRegistry(
      extensionDefinitions: const [_entitlementsRoute],
    );

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        routeContractReport: BillingRouteContractReport.forRouteRegistry(
          routeDefinitions: routeRegistry.routeDefinitions,
        ),
        routeExecutionReport: BillingRouteExecutionReport.forRegistry(
          routeDefinitionRegistry: routeRegistry,
        ),
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
      ),
    );

    expect(find.text('Route execution readiness'), findsOneWidget);
    expect(
      find.text('Billing route execution has 1 builder blocker.'),
      findsOneWidget,
    );
    expect(
      find.text('Entitlements uses the fallback billing route page.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsContent forwards route contract remediation', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);
    BillingNavigationDestinationId? selectedDestination;

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
        routeContractReport: _routeContractReportWithIssues([
          BillingRouteContractIssue(
            kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
            severity: BillingRouteContractIssueSeverity.blocker,
            routeName: BillingRoutes.checkoutRouteName,
            message: 'Missing checkout page builder',
          ),
        ]),
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
      ),
    );

    await tester.tap(
      find.byKey(
        ValueKey(
          'billing-route-contract-remediation-open-'
          '${BillingRoutes.checkoutRouteName}:missingFeaturePageBuilder:0',
        ),
      ),
    );
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.cartCheckout);
    expect(find.text('Open checkout'), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsContent forwards route selections', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);
    BillingNavigationDestinationId? selectedDestination;

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    final productRemediation = find.byKey(
      const ValueKey(
        'billing-pack-remediation-open-construction:module:missingLineItemAdapter:0',
      ),
    );
    await tester.dragUntilVisible(
      productRemediation,
      find.byKey(const ValueKey('billing-diagnostics-scroll')),
      const Offset(0, -420),
      maxIteration: 40,
    );
    await tester.pumpAndSettle();
    await tester.tap(productRemediation);
    await tester.pump();

    expect(
      selectedDestination,
      BillingNavigationDestinationId.productWorkspace,
    );

    await _dragUntilContentTextVisible(tester, 'Route launch center');
    final invoiceRoute = find.byKey(
      const ValueKey('billing-launch-center-open-invoices'),
    );
    await tester.ensureVisible(invoiceRoute);
    await tester.pump();
    await tester.tap(invoiceRoute);
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.invoices);
  });

  testWidgets('BillingDiagnosticsContent supports custom section registry', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        sectionRegistry: [
          BillingDiagnosticsSectionDescriptor(
            id: 'custom',
            priority: 10,
            builder:
                (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Custom diagnostics section'),
                ),
          ),
        ],
      ),
    );

    expect(find.text('Custom diagnostics section'), findsOneWidget);
    expect(find.text('Billing Diagnostics'), findsNothing);
    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-custom')),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsContent supports registry value object', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        diagnosticsSectionRegistry: BillingDiagnosticsSectionRegistry.standard(
          hiddenSectionIds: {billingDiagnosticsReleaseSectionId},
          extensions: [
            BillingDiagnosticsSectionDescriptor(
              id: 'domain-risk',
              priority: 150,
              builder:
                  (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Domain risk diagnostics'),
                  ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Billing Diagnostics'), findsOneWidget);
    expect(find.text('Domain risk diagnostics'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-diagnostics-section-release')),
      findsNothing,
    );
  });

  testWidgets('BillingDiagnosticsContent passes release workspace catalog', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        releaseWorkspaceProfileCatalog: BillingReleaseWorkspaceProfileCatalog(
          profiles: [
            BillingReleaseWorkspaceProfile(
              id: 'commerce-release-addon',
              businessDomains: const ['commerce'],
              extensions: const [_customReleaseDeckDescriptor],
            ),
          ],
        ),
      ),
    );

    await _dragUntilContentTextVisible(tester, 'Release profile coverage');
    expect(
      find.text('1 release workspace profile covers 1 business domain.'),
      findsOneWidget,
    );
    expect(find.text('Commerce · Covered'), findsOneWidget);
    expect(
      find.text('1 domain deck extends release workspace behavior.'),
      findsOneWidget,
    );

    await _dragUntilContentTextVisible(tester, 'Custom commerce release deck');

    expect(find.text('Custom commerce release deck'), findsOneWidget);
  });

  testWidgets(
    'BillingDiagnosticsContent passes release profile saved-view registry',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final context = _diagnosticsContext(container);

      await _pumpContent(
        tester,
        BillingDiagnosticsContent(
          diagnosticsContext: context,
          includeSafeArea: false,
          releaseProfileSavedViewRegistry:
              BillingDiagnosticsReleaseProfileSavedViewRegistry.standard(
                hiddenViewIds: {
                  billingDiagnosticsReleaseProfileCurrentDomainSavedViewId,
                },
              ),
        ),
      );

      await _dragUntilContentTextVisible(tester, 'Release profile coverage');

      expect(find.text('Profile views'), findsOneWidget);
      expect(find.text('Current domain'), findsNothing);
      expect(find.text('Standard profiles'), findsOneWidget);
      expect(find.text('Extended profiles'), findsOneWidget);
    },
  );

  testWidgets('BillingDiagnosticsContent forwards release profile remediation', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = _diagnosticsContext(container);
    BillingNavigationDestinationId? selectedDestination;

    await _pumpContent(
      tester,
      BillingDiagnosticsContent(
        diagnosticsContext: context,
        includeSafeArea: false,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
        releaseWorkspaceProfileCatalog: BillingReleaseWorkspaceProfileCatalog(
          profiles: [
            BillingReleaseWorkspaceProfile(
              id: 'construction-only',
              businessDomains: const ['construction'],
            ),
          ],
        ),
      ),
    );

    await _dragUntilContentTextVisible(tester, 'Commerce · Standard fallback');

    expect(
      find.text('Register Commerce release workspace profile'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'billing-release-profile-coverage-open-commerce:release-workspace-profile',
        ),
      ),
    );
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.diagnostics);
  });
}

const _customReleaseDeckDescriptor = BillingReleaseWorkspaceDeckDescriptor(
  id: 'billing-release-workspace.commerce-addon.deck',
  priority: 50,
  builder: _buildCustomReleaseDeck,
);

const _entitlementsRoute = BillingManagementRouteDefinition(
  name: 'Billing Entitlements',
  routeName: 'billingEntitlements',
  title: 'Entitlements',
  subtitle: 'Access billing',
  description:
      'Review entitlement billing policies for the selected workspace.',
  icon: 'billing-entitlements',
  path: '${BillingRoutes.managementPath}/entitlements',
  destinationId: BillingNavigationDestinationId.diagnostics,
  routeIdentityKey: 'billingEntitlements',
  surface: BillingManagementRouteSurface.dashboard,
);

Widget _buildCustomReleaseDeck({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Custom commerce release deck'),
  );
}

BillingDiagnosticsScreenContext _diagnosticsContext(
  ProviderContainer container,
) {
  const preferences = BillingTenantPreferences();
  return BillingDiagnosticsScreenContext(
    selectedTenant: BillingTenantAccount(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      planName: 'Enterprise',
      currentBalance: 1200,
      preferences: preferences,
    ),
    overview: container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: preferences,
          tenantId: 'tenant-a',
        ),
      ),
    ),
    domainContext: container.read(
      billingDiagnosticsDomainContextProvider(true),
    ),
  );
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

Future<void> _pumpContent(
  WidgetTester tester,
  Widget child, {
  Size viewSize = const Size(1280, 900),
}) {
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 1120, child: child))),
  );
}

Future<void> _dragUntilContentTextVisible(
  WidgetTester tester,
  String text,
) async {
  await _dragUntilContentFinderVisible(tester, find.text(text));
}

Future<void> _dragUntilContentFinderVisible(
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
