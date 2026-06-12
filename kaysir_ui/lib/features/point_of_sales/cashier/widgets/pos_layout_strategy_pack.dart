import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../states/pos_layout_provider.dart';
import 'pos_layout_strategy_renderer.dart';

class POSLayoutStrategyPackValidation {
  final List<POSLayoutStrategyRegistryIssue> strategyIssues;
  final List<POSLayoutStrategyRendererRegistryIssue> rendererIssues;

  POSLayoutStrategyPackValidation({
    required Iterable<POSLayoutStrategyRegistryIssue> strategyIssues,
    required Iterable<POSLayoutStrategyRendererRegistryIssue> rendererIssues,
  }) : strategyIssues = List.unmodifiable(strategyIssues),
       rendererIssues = List.unmodifiable(rendererIssues);

  int get issueCount => strategyIssues.length + rendererIssues.length;

  bool get isValid => issueCount == 0;

  List<String> get messages {
    return List.unmodifiable([
      ...strategyIssues.map((issue) => issue.message),
      ...rendererIssues.map((issue) => issue.message),
    ]);
  }

  void throwIfInvalid() {
    if (isValid) return;

    throw StateError(messages.join('\n'));
  }
}

class POSLayoutStrategyPack {
  final POSLayoutStrategyRegistry strategyRegistry;
  final POSLayoutStrategyRendererRegistry rendererRegistry;

  POSLayoutStrategyPack({
    required this.strategyRegistry,
    required this.rendererRegistry,
  });

  POSLayoutStrategyPack.withRenderers({
    POSLayoutStrategyRegistry strategyRegistry =
        defaultPOSLayoutStrategyRegistry,
    required Iterable<POSLayoutStrategyRenderer> renderers,
  }) : strategyRegistry = strategyRegistry,
       rendererRegistry = POSLayoutStrategyRendererRegistry(
         strategyRegistry: strategyRegistry,
         renderers: renderers,
       );

  POSLayoutStrategyPackValidation validate() {
    return POSLayoutStrategyPackValidation(
      strategyIssues: strategyRegistry.validate(),
      rendererIssues: _rendererRegistryForStrategyRegistry.validate(),
    );
  }

  void throwIfInvalid() => validate().throwIfInvalid();

  POSLayoutStrategySpec resolve({
    required POSLayoutPreference preference,
    required double width,
  }) {
    return strategyRegistry.resolve(preference: preference, width: width);
  }

  Widget build({
    required POSLayoutStrategy strategy,
    required int itemCount,
    required ValueChanged<Product> onProductSelected,
  }) {
    return _rendererRegistryForStrategyRegistry.build(
      strategy: strategy,
      itemCount: itemCount,
      onProductSelected: onProductSelected,
    );
  }

  POSLayoutStrategyRendererRegistry get _rendererRegistryForStrategyRegistry {
    if (identical(rendererRegistry.strategyRegistry, strategyRegistry)) {
      return rendererRegistry;
    }

    return POSLayoutStrategyRendererRegistry(
      strategyRegistry: strategyRegistry,
      renderers: rendererRegistry.renderers,
    );
  }
}

final defaultPOSLayoutStrategyPack = POSLayoutStrategyPack(
  strategyRegistry: defaultPOSLayoutStrategyRegistry,
  rendererRegistry: defaultPOSLayoutStrategyRendererRegistry,
);
