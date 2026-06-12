enum POSLayoutPreference { auto, counter, compact, checkout }

enum POSLayoutStrategy { counter, compact, checkout }

enum POSLayoutSlot { commandBar, catalog, order, checkout }

enum POSLayoutStrategyRegistryIssueType {
  emptyRegistry,
  blankStrategyId,
  duplicateStrategyId,
  duplicateStrategy,
  duplicatePreference,
  emptySlots,
  blankTrait,
}

class POSLayoutStrategyRegistryIssue {
  final POSLayoutStrategyRegistryIssueType type;
  final String strategyId;
  final String message;

  const POSLayoutStrategyRegistryIssue({
    required this.type,
    required this.strategyId,
    required this.message,
  });

  @override
  String toString() => message;
}

enum POSLayoutStrategyRendererRegistryIssueType {
  missingRenderer,
  duplicateRenderer,
  unknownStrategy,
}

class POSLayoutStrategyRendererRegistryIssue {
  final POSLayoutStrategyRendererRegistryIssueType type;
  final POSLayoutStrategy strategy;
  final String message;

  const POSLayoutStrategyRendererRegistryIssue({
    required this.type,
    required this.strategy,
    required this.message,
  });

  @override
  String toString() => message;
}

class POSLayoutStrategySpec {
  final String id;
  final POSLayoutStrategy strategy;
  final POSLayoutPreference preference;
  final String label;
  final String description;
  final double autoMinWidth;
  final List<POSLayoutSlot> slots;
  final List<String> traits;

  const POSLayoutStrategySpec({
    required this.id,
    required this.strategy,
    required this.preference,
    required this.label,
    required this.description,
    required this.autoMinWidth,
    required this.slots,
    this.traits = const [],
  });

  bool supportsAutoWidth(double width) => width >= autoMinWidth;

  String get slotSummary {
    return slots.map((slot) => slot.label).join(' + ');
  }

  String get traitSummary {
    if (traits.isEmpty) return 'No traits';
    return traits.join(', ');
  }
}

class POSLayoutStrategyRegistry {
  final List<POSLayoutStrategySpec> strategies;

  const POSLayoutStrategyRegistry({required this.strategies});

  List<POSLayoutStrategyRegistryIssue> validate() {
    final issues = <POSLayoutStrategyRegistryIssue>[];
    if (strategies.isEmpty) {
      issues.add(
        const POSLayoutStrategyRegistryIssue(
          type: POSLayoutStrategyRegistryIssueType.emptyRegistry,
          strategyId: '',
          message: 'No POS layout strategies are registered.',
        ),
      );
      return List.unmodifiable(issues);
    }

    final idCounts = <String, int>{};
    final strategyCounts = <POSLayoutStrategy, int>{};
    final preferenceCounts = <POSLayoutPreference, int>{};

    for (final spec in strategies) {
      final id = spec.id.trim();
      if (id.isNotEmpty) idCounts[id] = (idCounts[id] ?? 0) + 1;
      strategyCounts[spec.strategy] = (strategyCounts[spec.strategy] ?? 0) + 1;
      preferenceCounts[spec.preference] =
          (preferenceCounts[spec.preference] ?? 0) + 1;
    }

    for (final spec in strategies) {
      if (spec.id.trim().isEmpty) {
        issues.add(
          POSLayoutStrategyRegistryIssue(
            type: POSLayoutStrategyRegistryIssueType.blankStrategyId,
            strategyId: spec.id,
            message: 'POS layout strategy id cannot be blank.',
          ),
        );
      }

      if (spec.slots.isEmpty) {
        issues.add(
          POSLayoutStrategyRegistryIssue(
            type: POSLayoutStrategyRegistryIssueType.emptySlots,
            strategyId: spec.id,
            message:
                'POS layout strategy "${spec.label}" must declare at least one slot.',
          ),
        );
      }

      if (spec.traits.any((trait) => trait.trim().isEmpty)) {
        issues.add(
          POSLayoutStrategyRegistryIssue(
            type: POSLayoutStrategyRegistryIssueType.blankTrait,
            strategyId: spec.id,
            message: 'POS layout strategy "${spec.label}" has a blank trait.',
          ),
        );
      }
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSLayoutStrategyRegistryIssue(
          type: POSLayoutStrategyRegistryIssueType.duplicateStrategyId,
          strategyId: entry.key,
          message: 'Duplicate POS layout strategy id "${entry.key}" found.',
        ),
      );
    }

    for (final entry in strategyCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSLayoutStrategyRegistryIssue(
          type: POSLayoutStrategyRegistryIssueType.duplicateStrategy,
          strategyId: entry.key.name,
          message: 'Duplicate POS layout strategy "${entry.key.name}" found.',
        ),
      );
    }

    for (final entry in preferenceCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSLayoutStrategyRegistryIssue(
          type: POSLayoutStrategyRegistryIssueType.duplicatePreference,
          strategyId: entry.key.name,
          message: 'Duplicate POS layout preference "${entry.key.name}" found.',
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

  List<POSLayoutPreference> get preferenceOptions {
    final registeredPreferences =
        strategies.map((strategy) => strategy.preference).toSet();

    return List.unmodifiable([
      POSLayoutPreference.auto,
      ...POSLayoutPreference.values.where(
        (preference) =>
            preference != POSLayoutPreference.auto &&
            registeredPreferences.contains(preference),
      ),
    ]);
  }

  POSLayoutStrategySpec resolve({
    required POSLayoutPreference preference,
    required double width,
  }) {
    final fixedStrategy = preference.fixedStrategy;
    if (fixedStrategy != null) return specForStrategy(fixedStrategy);

    final ordered = strategies.toList(growable: false)
      ..sort((a, b) => a.autoMinWidth.compareTo(b.autoMinWidth));
    POSLayoutStrategySpec? selected;
    for (final strategy in ordered) {
      if (strategy.supportsAutoWidth(width)) selected = strategy;
    }

    if (selected != null) return selected;
    if (ordered.isNotEmpty) return ordered.first;
    throw StateError('No POS layout strategies are registered.');
  }

  POSLayoutStrategySpec specForPreference(POSLayoutPreference preference) {
    final fixedStrategy = preference.fixedStrategy;
    if (fixedStrategy == null) {
      return resolve(preference: preference, width: double.infinity);
    }

    return specForStrategy(fixedStrategy);
  }

  POSLayoutStrategySpec specForStrategy(POSLayoutStrategy strategy) {
    for (final spec in strategies) {
      if (spec.strategy == strategy) return spec;
    }

    throw StateError('No POS layout strategy registered for ${strategy.name}.');
  }
}

const defaultPOSLayoutStrategyRegistry = POSLayoutStrategyRegistry(
  strategies: [
    POSLayoutStrategySpec(
      id: 'compact',
      strategy: POSLayoutStrategy.compact,
      preference: POSLayoutPreference.compact,
      label: 'Compact',
      description: 'Tabbed layout for phones and constrained counters.',
      autoMinWidth: 0,
      slots: [POSLayoutSlot.catalog, POSLayoutSlot.order],
      traits: ['single-column', 'touch-first', 'tabbed'],
    ),
    POSLayoutStrategySpec(
      id: 'checkout',
      strategy: POSLayoutStrategy.checkout,
      preference: POSLayoutPreference.checkout,
      label: 'Checkout',
      description: 'Tender-first split layout for tablet and medium screens.',
      autoMinWidth: 720,
      slots: [
        POSLayoutSlot.order,
        POSLayoutSlot.checkout,
        POSLayoutSlot.catalog,
      ],
      traits: ['checkout-first', 'split-pane', 'tablet'],
    ),
    POSLayoutStrategySpec(
      id: 'counter',
      strategy: POSLayoutStrategy.counter,
      preference: POSLayoutPreference.counter,
      label: 'Counter',
      description: 'Product-first desk layout for full cashier workstations.',
      autoMinWidth: 1120,
      slots: [
        POSLayoutSlot.catalog,
        POSLayoutSlot.order,
        POSLayoutSlot.commandBar,
      ],
      traits: ['catalog-first', 'split-pane', 'desktop'],
    ),
  ],
);

extension POSLayoutPreferenceLabel on POSLayoutPreference {
  String get label {
    switch (this) {
      case POSLayoutPreference.auto:
        return 'Auto';
      case POSLayoutPreference.counter:
        return 'Counter';
      case POSLayoutPreference.compact:
        return 'Compact';
      case POSLayoutPreference.checkout:
        return 'Checkout';
    }
  }

  POSLayoutStrategy? get fixedStrategy {
    switch (this) {
      case POSLayoutPreference.auto:
        return null;
      case POSLayoutPreference.counter:
        return POSLayoutStrategy.counter;
      case POSLayoutPreference.compact:
        return POSLayoutStrategy.compact;
      case POSLayoutPreference.checkout:
        return POSLayoutStrategy.checkout;
    }
  }
}

extension POSLayoutStrategyLabel on POSLayoutStrategy {
  String get label {
    switch (this) {
      case POSLayoutStrategy.counter:
        return 'Counter';
      case POSLayoutStrategy.compact:
        return 'Compact';
      case POSLayoutStrategy.checkout:
        return 'Checkout';
    }
  }
}

extension POSLayoutSlotLabel on POSLayoutSlot {
  String get label {
    switch (this) {
      case POSLayoutSlot.commandBar:
        return 'Commands';
      case POSLayoutSlot.catalog:
        return 'Catalog';
      case POSLayoutSlot.order:
        return 'Order';
      case POSLayoutSlot.checkout:
        return 'Checkout';
    }
  }
}
