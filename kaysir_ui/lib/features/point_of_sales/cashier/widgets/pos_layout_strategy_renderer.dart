import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../states/pos_layout_provider.dart';
import 'pos_layout_slots.dart';
import 'pos_layouts.dart';

typedef POSLayoutStrategyWidgetBuilder =
    Widget Function(POSLayoutStrategyBuildScope scope);

class POSLayoutStrategyBuildScope {
  final POSLayoutStrategySpec spec;
  final int itemCount;
  final ValueChanged<Product> onProductSelected;
  final POSLayoutSlotContent slots;

  POSLayoutStrategyBuildScope({
    required this.spec,
    required this.itemCount,
    required this.onProductSelected,
    POSLayoutSlotContent? slots,
  }) : slots =
           slots ??
           POSLayoutSlotContent(
             itemCount: itemCount,
             onProductSelected: onProductSelected,
           );

  POSLayoutStrategy get strategy => spec.strategy;
}

class POSLayoutStrategyRenderer {
  final POSLayoutStrategy strategy;
  final POSLayoutStrategyWidgetBuilder builder;

  const POSLayoutStrategyRenderer({
    required this.strategy,
    required this.builder,
  });

  Widget build(POSLayoutStrategyBuildScope scope) => builder(scope);
}

class POSLayoutStrategyRendererRegistry {
  final POSLayoutStrategyRegistry strategyRegistry;
  final List<POSLayoutStrategyRenderer> renderers;

  POSLayoutStrategyRendererRegistry({
    this.strategyRegistry = defaultPOSLayoutStrategyRegistry,
    required Iterable<POSLayoutStrategyRenderer> renderers,
  }) : renderers = List.unmodifiable(renderers);

  bool supports(POSLayoutStrategy strategy) {
    return renderers.any((renderer) => renderer.strategy == strategy);
  }

  List<POSLayoutStrategyRendererRegistryIssue> validate() {
    final issues = <POSLayoutStrategyRendererRegistryIssue>[];
    final knownStrategies =
        strategyRegistry.strategies.map((spec) => spec.strategy).toSet();
    final rendererCounts = <POSLayoutStrategy, int>{};

    for (final renderer in renderers) {
      rendererCounts[renderer.strategy] =
          (rendererCounts[renderer.strategy] ?? 0) + 1;
    }

    for (final strategy in knownStrategies) {
      if ((rendererCounts[strategy] ?? 0) > 0) continue;
      issues.add(
        POSLayoutStrategyRendererRegistryIssue(
          type: POSLayoutStrategyRendererRegistryIssueType.missingRenderer,
          strategy: strategy,
          message: 'No POS layout renderer registered for ${strategy.name}.',
        ),
      );
    }

    for (final entry in rendererCounts.entries) {
      final strategy = entry.key;
      if (!knownStrategies.contains(strategy)) {
        issues.add(
          POSLayoutStrategyRendererRegistryIssue(
            type: POSLayoutStrategyRendererRegistryIssueType.unknownStrategy,
            strategy: strategy,
            message:
                'POS layout renderer for ${strategy.name} has no matching strategy spec.',
          ),
        );
      }

      if (entry.value <= 1) continue;
      issues.add(
        POSLayoutStrategyRendererRegistryIssue(
          type: POSLayoutStrategyRendererRegistryIssueType.duplicateRenderer,
          strategy: strategy,
          message:
              'Duplicate POS layout renderer registered for ${strategy.name}.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(issues.map((issue) => issue.message).join('\n'));
  }

  List<POSLayoutStrategy> get missingStrategies {
    return strategyRegistry.strategies
        .map((spec) => spec.strategy)
        .where((strategy) => !supports(strategy))
        .toList(growable: false);
  }

  POSLayoutStrategyRenderer rendererFor(POSLayoutStrategy strategy) {
    for (final renderer in renderers) {
      if (renderer.strategy == strategy) return renderer;
    }

    throw StateError('No POS layout renderer registered for ${strategy.name}.');
  }

  Widget build({
    required POSLayoutStrategy strategy,
    required int itemCount,
    required ValueChanged<Product> onProductSelected,
  }) {
    final spec = strategyRegistry.specForStrategy(strategy);
    return rendererFor(strategy).build(
      POSLayoutStrategyBuildScope(
        spec: spec,
        itemCount: itemCount,
        onProductSelected: onProductSelected,
      ),
    );
  }
}

final defaultPOSLayoutStrategyRendererRegistry =
    POSLayoutStrategyRendererRegistry(
      renderers: [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.counter,
          builder: _buildCounterLayout,
        ),
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.compact,
          builder: _buildCompactLayout,
        ),
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.checkout,
          builder: _buildCheckoutLayout,
        ),
      ],
    );

Widget _buildCounterLayout(POSLayoutStrategyBuildScope scope) {
  return POSCounterLayout(
    slots: scope.slots,
    onProductSelected: scope.onProductSelected,
  );
}

Widget _buildCompactLayout(POSLayoutStrategyBuildScope scope) {
  return POSCompactLayout(
    slots: scope.slots,
    itemCount: scope.itemCount,
    onProductSelected: scope.onProductSelected,
  );
}

Widget _buildCheckoutLayout(POSLayoutStrategyBuildScope scope) {
  return POSCheckoutLayout(
    slots: scope.slots,
    onProductSelected: scope.onProductSelected,
  );
}
