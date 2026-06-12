import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';

void main() {
  test('standard billing release workspace registry keeps deck order', () {
    final registry = standardBillingReleaseWorkspaceRegistry();

    expect(registry.deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
  });

  testWidgets('billing release workspace registry builds release decks', (
    tester,
  ) async {
    final releaseContext = _releaseContext();
    final registry = standardBillingReleaseWorkspaceRegistry();

    await _pumpReleaseWorkspace(
      tester,
      Column(
        children: registry.buildDecks(
          releaseContext: releaseContext,
          onDestinationSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Product release editions'), findsOneWidget);
    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
  });

  testWidgets(
    'billing release workspace registry supports hidden decks and extensions',
    (tester) async {
      final releaseContext = _releaseContext();
      final registry = standardBillingReleaseWorkspaceRegistry(
        hiddenDeckIds: {billingReleaseWorkspaceChannelLaunchDeckId},
        extensions: [_customDeckDescriptor],
      );

      await _pumpReleaseWorkspace(
        tester,
        BillingDiagnosticsReleaseSection(
          releaseContext: releaseContext,
          onDestinationSelected: (_) {},
          workspaceRegistry: registry,
        ),
      );

      expect(registry.deckIds, [
        _customDeckId,
        billingReleaseWorkspacePackageReadinessDeckId,
        billingReleaseWorkspaceProductReleaseDeckId,
      ]);
      expect(find.text('Custom release workspace deck'), findsOneWidget);
      expect(find.text('Product packages'), findsOneWidget);
      expect(find.text('Product release editions'), findsOneWidget);
      expect(find.text('Channel launch queue'), findsNothing);
    },
  );

  test('billing release workspace registry rejects invalid descriptors', () {
    expect(
      () => BillingReleaseWorkspaceRegistry(
        deckDescriptors: [_customDeckDescriptor, _customDeckDescriptor],
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => BillingReleaseWorkspaceRegistry(
        deckDescriptors: [
          const BillingReleaseWorkspaceDeckDescriptor(
            id: ' ',
            builder: _buildCustomDeck,
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

BillingDiagnosticsReleaseContext _releaseContext() {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  return container.read(
    billingDiagnosticsReleaseContextProvider(
      BillingDiagnosticsReleaseContextRequest.fromTenant(
        preferences: const BillingTenantPreferences(
          businessDomain: 'construction',
        ),
        tenantId: 'tenant-a',
      ),
    ),
  );
}

Future<void> _pumpReleaseWorkspace(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 1280, child: child)),
      ),
    ),
  );
}

const _customDeckId = 'billing-release-workspace.custom.deck';

const _customDeckDescriptor = BillingReleaseWorkspaceDeckDescriptor(
  id: _customDeckId,
  priority: 50,
  builder: _buildCustomDeck,
);

Widget _buildCustomDeck({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return const Text('Custom release workspace deck');
}
