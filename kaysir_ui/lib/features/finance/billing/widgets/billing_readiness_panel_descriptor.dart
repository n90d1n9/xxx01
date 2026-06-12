import 'package:flutter/material.dart';

import 'billing_readiness_metric_provider.dart';
import 'billing_readiness_metric_provider_panel.dart';

typedef BillingReadinessPanelSummaryResolver<T extends Object> =
    String Function(T source);
typedef BillingReadinessPanelChildBuilder<T extends Object> =
    Widget Function(T source);
typedef BillingReadinessPanelTrailingBuilder<T extends Object> =
    Widget? Function(T source);

abstract class BillingReadinessPanelDescriptorBase {
  String get id;

  int get priority;

  bool supports(Object source);

  Widget buildObject(Object source);
}

class BillingReadinessMetricProviderPanelDescriptor<T extends Object>
    implements BillingReadinessPanelDescriptorBase {
  @override
  final String id;

  @override
  final int priority;

  final BillingReadinessMetricProvider<T> metricProvider;
  final String title;
  final BillingReadinessPanelSummaryResolver<T> summaryResolver;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final BillingReadinessPanelChildBuilder<T> childBuilder;
  final BillingReadinessPanelTrailingBuilder<T>? trailingBuilder;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const BillingReadinessMetricProviderPanelDescriptor({
    required this.id,
    required this.metricProvider,
    required this.title,
    required this.summaryResolver,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.childBuilder,
    this.trailingBuilder,
    this.priority = 100,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });

  Widget build(T source) {
    return BillingReadinessMetricProviderPanel<T>(
      source: source,
      metricProvider: metricProvider,
      title: title,
      summary: summaryResolver(source),
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      trailing: trailingBuilder?.call(source),
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      child: childBuilder(source),
    );
  }

  @override
  bool supports(Object source) {
    return source is T;
  }

  @override
  Widget buildObject(Object source) {
    if (source is! T) {
      throw ArgumentError.value(
        source,
        'source',
        'must be a $T source for billing readiness panel $id',
      );
    }

    return build(source);
  }
}

class BillingReadinessPanelDescriptorRegistry {
  final List<BillingReadinessPanelDescriptorBase> descriptors;

  factory BillingReadinessPanelDescriptorRegistry({
    Iterable<BillingReadinessPanelDescriptorBase> descriptors = const [],
  }) {
    return BillingReadinessPanelDescriptorRegistry._(
      _sortedPanelDescriptors(_validatedPanelDescriptors(descriptors)),
    );
  }

  const BillingReadinessPanelDescriptorRegistry._(this.descriptors);

  bool get isEmpty => descriptors.isEmpty;

  int get count => descriptors.length;

  List<String> get descriptorIds {
    return List.unmodifiable(descriptors.map((descriptor) => descriptor.id));
  }

  bool contains(String descriptorId) {
    return find(descriptorId) != null;
  }

  BillingReadinessPanelDescriptorBase? find(String descriptorId) {
    final normalizedDescriptorId = descriptorId.trim();

    for (final descriptor in descriptors) {
      if (descriptor.id == normalizedDescriptorId) return descriptor;
    }

    return null;
  }

  BillingReadinessPanelDescriptorBase requireDescriptor(String descriptorId) {
    final descriptor = find(descriptorId);
    if (descriptor == null) {
      throw StateError(
        'No billing readiness panel is registered for $descriptorId.',
      );
    }

    return descriptor;
  }

  Widget build(String descriptorId, Object source) {
    return requireDescriptor(descriptorId).buildObject(source);
  }

  List<BillingReadinessPanelDescriptorBase> descriptorsForSource(
    Object source,
  ) {
    return List.unmodifiable(
      descriptors.where((descriptor) => descriptor.supports(source)),
    );
  }

  List<Widget> buildForSource(Object source) {
    return List.unmodifiable(
      descriptorsForSource(
        source,
      ).map((descriptor) => descriptor.buildObject(source)),
    );
  }

  BillingReadinessPanelDescriptorRegistry register(
    BillingReadinessPanelDescriptorBase descriptor,
  ) {
    return BillingReadinessPanelDescriptorRegistry(
      descriptors: [...descriptors, descriptor],
    );
  }

  BillingReadinessPanelDescriptorRegistry registerAll(
    Iterable<BillingReadinessPanelDescriptorBase> descriptors,
  ) {
    return BillingReadinessPanelDescriptorRegistry(
      descriptors: [...this.descriptors, ...descriptors],
    );
  }

  BillingReadinessPanelDescriptorRegistry without(
    Iterable<String> descriptorIds,
  ) {
    final hiddenDescriptorIds = descriptorIds.map((id) => id.trim()).toSet();
    return BillingReadinessPanelDescriptorRegistry(
      descriptors: descriptors.where(
        (descriptor) => !hiddenDescriptorIds.contains(descriptor.id),
      ),
    );
  }

  BillingReadinessPanelDescriptorRegistry extend({
    Iterable<String> hiddenDescriptorIds = const [],
    Iterable<BillingReadinessPanelDescriptorBase> extensions = const [],
  }) {
    final hiddenDescriptorIdSet =
        hiddenDescriptorIds.map((id) => id.trim()).toSet();
    final extensionDescriptors = extensions.toList(growable: false);
    final extensionDescriptorIds =
        extensionDescriptors.map((descriptor) => descriptor.id).toSet();

    return BillingReadinessPanelDescriptorRegistry(
      descriptors: [
        ...descriptors.where(
          (descriptor) =>
              !hiddenDescriptorIdSet.contains(descriptor.id) &&
              !extensionDescriptorIds.contains(descriptor.id),
        ),
        ...extensionDescriptors,
      ],
    );
  }
}

List<BillingReadinessPanelDescriptorBase> _validatedPanelDescriptors(
  Iterable<BillingReadinessPanelDescriptorBase> descriptors,
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
        'must be unique in a billing readiness panel registry',
      );
    }
  }

  return descriptorList;
}

List<BillingReadinessPanelDescriptorBase> _sortedPanelDescriptors(
  Iterable<BillingReadinessPanelDescriptorBase> descriptors,
) {
  final sorted = descriptors.toList(growable: false)..sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    return left.id.compareTo(right.id);
  });

  return List.unmodifiable(sorted);
}
