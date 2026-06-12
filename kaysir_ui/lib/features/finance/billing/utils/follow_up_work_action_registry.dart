import '../models/billing_navigation_destination_id.dart';
import '../models/follow_up_work_item.dart';

/// Route action metadata for one billing follow-up work source.
class BillingFollowUpWorkActionDefinition {
  static const Set<BillingFollowUpWorkStatus> allStatuses = {
    BillingFollowUpWorkStatus.blocked,
    BillingFollowUpWorkStatus.ready,
    BillingFollowUpWorkStatus.scheduled,
    BillingFollowUpWorkStatus.optional,
  };

  final BillingFollowUpWorkSource source;
  final BillingNavigationDestinationId destination;
  final String label;
  final String? blockedLabel;
  final String? scheduledLabel;
  final String? optionalLabel;
  final Set<BillingFollowUpWorkStatus> enabledStatuses;
  final String disabledReason;

  BillingFollowUpWorkActionDefinition({
    required this.source,
    required this.destination,
    required this.label,
    this.blockedLabel,
    this.scheduledLabel,
    this.optionalLabel,
    Iterable<BillingFollowUpWorkStatus> enabledStatuses = allStatuses,
    this.disabledReason = 'This follow-up action is not available yet.',
  }) : enabledStatuses = Set.unmodifiable(enabledStatuses);

  /// Builds the resolved action state for a concrete follow-up work item.
  BillingFollowUpWorkAction resolve(BillingFollowUpWorkItem item) {
    return BillingFollowUpWorkAction(
      itemId: item.id,
      source: item.source,
      destination: destination,
      label: labelFor(item),
      canOpen: enabledStatuses.contains(item.status),
      disabledReason: disabledReason,
    );
  }

  /// Chooses the most specific action label for the item's status.
  String labelFor(BillingFollowUpWorkItem item) {
    return switch (item.status) {
      BillingFollowUpWorkStatus.blocked => blockedLabel ?? label,
      BillingFollowUpWorkStatus.scheduled => scheduledLabel ?? label,
      BillingFollowUpWorkStatus.optional => optionalLabel ?? label,
      BillingFollowUpWorkStatus.ready => label,
    };
  }
}

/// Resolved navigation intent for one follow-up work item.
class BillingFollowUpWorkAction {
  final String itemId;
  final BillingFollowUpWorkSource source;
  final BillingNavigationDestinationId destination;
  final String label;
  final bool canOpen;
  final String disabledReason;

  const BillingFollowUpWorkAction({
    required this.itemId,
    required this.source,
    required this.destination,
    required this.label,
    required this.canOpen,
    required this.disabledReason,
  });
}

/// Registry that maps work-center item sources to screen destinations.
class BillingFollowUpWorkActionRegistry {
  final Map<BillingFollowUpWorkSource, BillingFollowUpWorkActionDefinition>
  _definitionsBySource;

  BillingFollowUpWorkActionRegistry({
    Iterable<BillingFollowUpWorkActionDefinition> definitions = const [],
  }) : _definitionsBySource = _indexDefinitions(definitions);

  /// Standard action registry for the shared billing management module.
  factory BillingFollowUpWorkActionRegistry.standard() {
    return BillingFollowUpWorkActionRegistry(
      definitions: standardBillingFollowUpWorkActionDefinitions,
    );
  }

  bool get isEmpty => _definitionsBySource.isEmpty;

  bool get isNotEmpty => _definitionsBySource.isNotEmpty;

  int get definitionCount => _definitionsBySource.length;

  List<BillingFollowUpWorkActionDefinition> get definitions {
    final values =
        _definitionsBySource.values.toList()
          ..sort((a, b) => a.source.index.compareTo(b.source.index));
    return List.unmodifiable(values);
  }

  /// Returns a new registry where matching source definitions are replaced.
  BillingFollowUpWorkActionRegistry withOverrides(
    Iterable<BillingFollowUpWorkActionDefinition> overrides,
  ) {
    final overrideMap = _indexDefinitions(overrides);
    return BillingFollowUpWorkActionRegistry(
      definitions: [
        for (final definition in definitions)
          if (!overrideMap.containsKey(definition.source)) definition,
        ...overrideMap.values,
      ],
    );
  }

  /// Resolves the action metadata for a concrete work item.
  BillingFollowUpWorkAction resolve(BillingFollowUpWorkItem item) {
    final definition = _definitionsBySource[item.source];
    if (definition != null) return definition.resolve(item);

    return BillingFollowUpWorkActionDefinition(
      source: item.source,
      destination: BillingNavigationDestinationId.diagnostics,
      label: 'Open diagnostics',
    ).resolve(item);
  }

  static Map<BillingFollowUpWorkSource, BillingFollowUpWorkActionDefinition>
  _indexDefinitions(Iterable<BillingFollowUpWorkActionDefinition> definitions) {
    final indexed =
        <BillingFollowUpWorkSource, BillingFollowUpWorkActionDefinition>{};

    for (final definition in definitions) {
      if (indexed.containsKey(definition.source)) {
        throw ArgumentError.value(
          definition.source,
          'definition.source',
          'Duplicate follow-up work action definition',
        );
      }
      indexed[definition.source] = definition;
    }

    return Map.unmodifiable(indexed);
  }
}

/// Shared source-to-destination actions used by the billing work center.
final List<BillingFollowUpWorkActionDefinition>
standardBillingFollowUpWorkActionDefinitions = List.unmodifiable([
  BillingFollowUpWorkActionDefinition(
    source: BillingFollowUpWorkSource.collections,
    destination: BillingNavigationDestinationId.invoices,
    label: 'Open invoices',
    blockedLabel: 'Review invoices',
    scheduledLabel: 'Schedule collection',
  ),
  BillingFollowUpWorkActionDefinition(
    source: BillingFollowUpWorkSource.reliefMonitoring,
    destination: BillingNavigationDestinationId.policyCenter,
    label: 'Open policy center',
    blockedLabel: 'Resolve policy blocker',
    scheduledLabel: 'Track relief',
  ),
  BillingFollowUpWorkActionDefinition(
    source: BillingFollowUpWorkSource.subscription,
    destination: BillingNavigationDestinationId.invoices,
    label: 'Review renewals',
    scheduledLabel: 'Track renewal',
  ),
  BillingFollowUpWorkActionDefinition(
    source: BillingFollowUpWorkSource.milestone,
    destination: BillingNavigationDestinationId.reports,
    label: 'Open reports',
    scheduledLabel: 'Review milestone',
  ),
  BillingFollowUpWorkActionDefinition(
    source: BillingFollowUpWorkSource.external,
    destination: BillingNavigationDestinationId.diagnostics,
    label: 'Open diagnostics',
    blockedLabel: 'Inspect integration',
  ),
]);
