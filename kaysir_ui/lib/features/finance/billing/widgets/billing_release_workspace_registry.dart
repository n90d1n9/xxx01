import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_context_provider.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_package_panel_registry.dart';
import 'billing_product_release_channel_launch_panel_registry.dart';
import 'billing_product_release_channel_launch_panel_sources.dart';
import 'billing_product_release_panel_registry.dart';
import 'billing_readiness_panel_deck.dart';
import 'billing_readiness_panel_descriptor.dart';

typedef BillingReleaseWorkspaceDeckBuilder =
    Widget Function({
      required BillingDiagnosticsReleaseContext releaseContext,
      required ValueChanged<BillingNavigationDestinationId>
      onDestinationSelected,
    });

typedef BillingReleaseWorkspaceSourceResolver =
    Iterable<Object> Function({
      required BillingDiagnosticsReleaseContext releaseContext,
      required ValueChanged<BillingNavigationDestinationId>
      onDestinationSelected,
    });

const billingReleaseWorkspacePackageReadinessDeckId =
    'billing-release-workspace.package-readiness.deck';
const billingReleaseWorkspaceProductReleaseDeckId =
    'billing-release-workspace.product-release.deck';
const billingReleaseWorkspaceChannelLaunchDeckId =
    'billing-release-workspace.channel-launch.deck';

class BillingReleaseWorkspaceDeckDescriptor {
  final String id;
  final int priority;
  final BillingReleaseWorkspaceDeckBuilder builder;

  const BillingReleaseWorkspaceDeckDescriptor({
    required this.id,
    required this.builder,
    this.priority = 100,
  });

  factory BillingReleaseWorkspaceDeckDescriptor.readinessDeck({
    required String id,
    required BillingReadinessPanelDescriptorRegistry panelRegistry,
    required BillingReleaseWorkspaceSourceResolver sourceResolver,
    int priority = 100,
    Widget? emptyState,
  }) {
    return BillingReleaseWorkspaceDeckDescriptor(
      id: id,
      priority: priority,
      builder: ({required releaseContext, required onDestinationSelected}) {
        return BillingReadinessPanelDeck(
          registry: panelRegistry,
          sources: sourceResolver(
            releaseContext: releaseContext,
            onDestinationSelected: onDestinationSelected,
          ),
          emptyState: emptyState,
        );
      },
    );
  }

  Widget build({
    required BillingDiagnosticsReleaseContext releaseContext,
    required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
  }) {
    return builder(
      releaseContext: releaseContext,
      onDestinationSelected: onDestinationSelected,
    );
  }
}

class BillingReleaseWorkspaceRegistry {
  final List<BillingReleaseWorkspaceDeckDescriptor> deckDescriptors;

  factory BillingReleaseWorkspaceRegistry({
    Iterable<BillingReleaseWorkspaceDeckDescriptor> deckDescriptors = const [],
  }) {
    return BillingReleaseWorkspaceRegistry._(
      _sortedReleaseWorkspaceDeckDescriptors(
        _validatedReleaseWorkspaceDeckDescriptors(deckDescriptors),
      ),
    );
  }

  const BillingReleaseWorkspaceRegistry._(this.deckDescriptors);

  bool get isEmpty => deckDescriptors.isEmpty;

  int get count => deckDescriptors.length;

  List<String> get deckIds {
    return List.unmodifiable(
      deckDescriptors.map((descriptor) => descriptor.id),
    );
  }

  bool contains(String deckId) {
    return find(deckId) != null;
  }

  BillingReleaseWorkspaceDeckDescriptor? find(String deckId) {
    final normalizedDeckId = deckId.trim();

    for (final descriptor in deckDescriptors) {
      if (descriptor.id == normalizedDeckId) return descriptor;
    }

    return null;
  }

  BillingReleaseWorkspaceDeckDescriptor requireDeck(String deckId) {
    final descriptor = find(deckId);
    if (descriptor == null) {
      throw StateError(
        'No billing release workspace deck is registered for $deckId.',
      );
    }

    return descriptor;
  }

  Widget build(
    String deckId, {
    required BillingDiagnosticsReleaseContext releaseContext,
    required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
  }) {
    return requireDeck(deckId).build(
      releaseContext: releaseContext,
      onDestinationSelected: onDestinationSelected,
    );
  }

  List<Widget> buildDecks({
    required BillingDiagnosticsReleaseContext releaseContext,
    required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
  }) {
    return List.unmodifiable(
      deckDescriptors.map(
        (descriptor) => descriptor.build(
          releaseContext: releaseContext,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }

  BillingReleaseWorkspaceRegistry register(
    BillingReleaseWorkspaceDeckDescriptor descriptor,
  ) {
    return BillingReleaseWorkspaceRegistry(
      deckDescriptors: [...deckDescriptors, descriptor],
    );
  }

  BillingReleaseWorkspaceRegistry registerAll(
    Iterable<BillingReleaseWorkspaceDeckDescriptor> descriptors,
  ) {
    return BillingReleaseWorkspaceRegistry(
      deckDescriptors: [...deckDescriptors, ...descriptors],
    );
  }

  BillingReleaseWorkspaceRegistry without(Iterable<String> deckIds) {
    final hiddenDeckIds = deckIds.map((id) => id.trim()).toSet();
    return BillingReleaseWorkspaceRegistry(
      deckDescriptors: deckDescriptors.where(
        (descriptor) => !hiddenDeckIds.contains(descriptor.id),
      ),
    );
  }

  BillingReleaseWorkspaceRegistry only(Iterable<String> deckIds) {
    final visibleDeckIds = deckIds.map((id) => id.trim()).toSet();
    return BillingReleaseWorkspaceRegistry(
      deckDescriptors: deckDescriptors.where(
        (descriptor) => visibleDeckIds.contains(descriptor.id),
      ),
    );
  }

  BillingReleaseWorkspaceRegistry extend({
    Iterable<String> hiddenDeckIds = const [],
    Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
  }) {
    final hiddenDeckIdSet = hiddenDeckIds.map((id) => id.trim()).toSet();
    final extensionDescriptors = extensions.toList(growable: false);
    final extensionDeckIds =
        extensionDescriptors.map((descriptor) => descriptor.id).toSet();

    return BillingReleaseWorkspaceRegistry(
      deckDescriptors: [
        ...deckDescriptors.where(
          (descriptor) =>
              !hiddenDeckIdSet.contains(descriptor.id) &&
              !extensionDeckIds.contains(descriptor.id),
        ),
        ...extensionDescriptors,
      ],
    );
  }
}

final billingReleaseWorkspacePackageReadinessDeckDescriptor =
    BillingReleaseWorkspaceDeckDescriptor.readinessDeck(
      id: billingReleaseWorkspacePackageReadinessDeckId,
      priority: 100,
      panelRegistry: standardBillingProductPackagePanelRegistry(),
      sourceResolver: _packageReadinessSources,
    );

final billingReleaseWorkspaceProductReleaseDeckDescriptor =
    BillingReleaseWorkspaceDeckDescriptor.readinessDeck(
      id: billingReleaseWorkspaceProductReleaseDeckId,
      priority: 200,
      panelRegistry: standardBillingProductReleasePanelRegistry(),
      sourceResolver: _productReleaseSources,
    );

final billingReleaseWorkspaceChannelLaunchDeckDescriptor =
    BillingReleaseWorkspaceDeckDescriptor.readinessDeck(
      id: billingReleaseWorkspaceChannelLaunchDeckId,
      priority: 300,
      panelRegistry: standardBillingProductReleaseChannelLaunchPanelRegistry(),
      sourceResolver: _channelLaunchSources,
    );

BillingReleaseWorkspaceRegistry standardBillingReleaseWorkspaceRegistry({
  Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
  Set<String> hiddenDeckIds = const {},
}) {
  return BillingReleaseWorkspaceRegistry(
    deckDescriptors: [
      for (final descriptor in standardBillingReleaseWorkspaceDeckDescriptors())
        if (!hiddenDeckIds.contains(descriptor.id)) descriptor,
      ...extensions,
    ],
  );
}

List<BillingReleaseWorkspaceDeckDescriptor>
standardBillingReleaseWorkspaceDeckDescriptors() {
  return List.unmodifiable([
    billingReleaseWorkspacePackageReadinessDeckDescriptor,
    billingReleaseWorkspaceProductReleaseDeckDescriptor,
    billingReleaseWorkspaceChannelLaunchDeckDescriptor,
  ]);
}

Iterable<Object> _packageReadinessSources({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return [
    releaseContext.packagePortfolio,
    releaseContext.packagePlaybook,
    releaseContext.releaseManifestCatalog,
    releaseContext.releaseBundleCatalog,
  ];
}

Iterable<Object> _productReleaseSources({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return [
    releaseContext.releaseEditionCatalog,
    releaseContext.releaseChannelMatrix,
  ];
}

Iterable<Object> _channelLaunchSources({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return [
    BillingProductReleaseChannelLaunchPlanPanelSource(
      launchPlan: releaseContext.releaseChannelLaunchPlan,
      dispatchPlan: releaseContext.releaseChannelLaunchDispatchPlan,
      onDestinationSelected: onDestinationSelected,
    ),
    releaseContext.releaseChannelLaunchRunbook,
    BillingProductReleaseChannelLaunchQueuePanelSource(
      queue: releaseContext.releaseChannelLaunchQueue,
      onDestinationSelected: onDestinationSelected,
    ),
  ];
}

List<BillingReleaseWorkspaceDeckDescriptor>
_validatedReleaseWorkspaceDeckDescriptors(
  Iterable<BillingReleaseWorkspaceDeckDescriptor> descriptors,
) {
  final descriptorList = descriptors.toList(growable: false);
  final ids = <String>{};

  for (final descriptor in descriptorList) {
    final normalizedId = descriptor.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        descriptor.id,
        'descriptor.id',
        'must not be blank',
      );
    }
    if (normalizedId != descriptor.id) {
      throw ArgumentError.value(
        descriptor.id,
        'descriptor.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!ids.add(normalizedId)) {
      throw ArgumentError.value(
        descriptor.id,
        'descriptor.id',
        'must be unique in a billing release workspace registry',
      );
    }
  }

  return descriptorList;
}

List<BillingReleaseWorkspaceDeckDescriptor>
_sortedReleaseWorkspaceDeckDescriptors(
  Iterable<BillingReleaseWorkspaceDeckDescriptor> descriptors,
) {
  final sorted = descriptors.toList(growable: false)..sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    return left.id.compareTo(right.id);
  });

  return List.unmodifiable(sorted);
}
