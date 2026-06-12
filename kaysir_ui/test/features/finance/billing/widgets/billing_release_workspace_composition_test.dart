import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_composition.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release workspace composition resolves domain profile state', () {
    final composition = BillingReleaseWorkspaceComposition.forBusinessDomain(
      businessDomain: 'construction',
      selectedSavedView: billingReleaseWorkspaceConstructionFocusSavedView,
      allowExternalSelectedView: true,
    );

    expect(composition.businessDomain, 'construction');
    expect(composition.baseRegistry.deckIds, [
      billingReleaseWorkspaceConstructionFocusDeckId,
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
    expect(
      composition.savedViews.map((view) => view.id),
      contains(billingReleaseWorkspaceConstructionFocusSavedViewId),
    );
    expect(
      composition.activeSavedView.id,
      billingReleaseWorkspaceConstructionFocusSavedViewId,
    );
    expect(composition.visibleRegistry.deckIds, [
      billingReleaseWorkspaceConstructionFocusDeckId,
    ]);
    expect(composition.snapshot.visibleDeckCount, 1);
    expect(composition.snapshot.hiddenDeckCount, 3);
    expect(composition.profileContract?.profileId, 'construction');
    expect(
      composition.profileContract?.summaryLabel,
      'construction · 4 decks · 5 views',
    );
  });

  test('release workspace composition omits contract for direct overrides', () {
    final composition = BillingReleaseWorkspaceComposition.forBusinessDomain(
      businessDomain: 'construction',
      registry: standardBillingReleaseWorkspaceRegistry(
        hiddenDeckIds: {billingReleaseWorkspaceChannelLaunchDeckId},
      ),
    );

    expect(composition.profileContract, isNull);
    expect(composition.baseRegistry.deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
    ]);
  });

  test(
    'release workspace composition falls back to first visible saved view',
    () {
      const hiddenSelection = BillingReleaseWorkspaceSavedView(
        id: 'outside-local-bar',
        label: 'Outside local bar',
        description: 'Selection not present in the current saved-view list',
        deckIds: {billingReleaseWorkspaceChannelLaunchDeckId},
      );

      final composition = BillingReleaseWorkspaceComposition(
        businessDomain: 'commerce',
        registry: standardBillingReleaseWorkspaceRegistry(),
        savedViews: const [billingReleaseWorkspacePackageSavedView],
        selectedSavedView: hiddenSelection,
      );

      expect(
        composition.activeSavedView.id,
        billingReleaseWorkspacePackageSavedViewId,
      );
      expect(composition.visibleRegistry.deckIds, [
        billingReleaseWorkspacePackageReadinessDeckId,
      ]);
    },
  );

  test('release workspace composition preserves controlled external view', () {
    const externalSelection = BillingReleaseWorkspaceSavedView(
      id: 'controlled-external',
      label: 'Controlled external',
      description: 'A parent-owned saved view outside the local bar',
      deckIds: {billingReleaseWorkspaceChannelLaunchDeckId},
    );

    final composition = BillingReleaseWorkspaceComposition(
      businessDomain: 'commerce',
      registry: standardBillingReleaseWorkspaceRegistry(),
      savedViews: const [billingReleaseWorkspacePackageSavedView],
      selectedSavedView: externalSelection,
      allowExternalSelectedView: true,
    );

    expect(composition.activeSavedView.id, 'controlled-external');
    expect(composition.visibleRegistry.deckIds, [
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
    expect(
      composition.savedViews.map((view) => view.id),
      isNot(contains('controlled-external')),
    );
  });

  test('release workspace composition uses all view when bar is empty', () {
    final composition = BillingReleaseWorkspaceComposition(
      businessDomain: 'commerce',
      registry: standardBillingReleaseWorkspaceRegistry(),
      savedViews: const [],
    );

    expect(composition.hasSavedViews, isFalse);
    expect(
      composition.activeSavedView.id,
      billingReleaseWorkspaceAllSavedViewId,
    );
    expect(composition.visibleRegistry.deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
  });
}
