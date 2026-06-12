import 'billing_navigation_destination_id.dart';

class BillingBusinessDomainNavigationPolicy {
  final List<BillingNavigationDestinationId>? destinationIds;
  final List<BillingNavigationDestinationId>? quickActionIds;
  final BillingNavigationDestinationId? defaultDestinationId;

  BillingBusinessDomainNavigationPolicy({
    Iterable<BillingNavigationDestinationId>? destinationIds,
    Iterable<BillingNavigationDestinationId>? quickActionIds,
    this.defaultDestinationId,
  }) : destinationIds = _optionalUnique(destinationIds, 'destination'),
       quickActionIds = _optionalUnique(quickActionIds, 'quick action') {
    _ensureDefaultDestination(this.destinationIds, defaultDestinationId);
    _ensureQuickActions(this.destinationIds, this.quickActionIds);
  }

  bool get hasExplicitDestinations => destinationIds != null;

  bool get hasExplicitQuickActions => quickActionIds != null;

  BillingBusinessDomainNavigationPolicy copyWith({
    Object? destinationIds = _unset,
    Object? quickActionIds = _unset,
    Object? defaultDestinationId = _unset,
  }) {
    return BillingBusinessDomainNavigationPolicy(
      destinationIds:
          identical(destinationIds, _unset)
              ? this.destinationIds
              : destinationIds as Iterable<BillingNavigationDestinationId>?,
      quickActionIds:
          identical(quickActionIds, _unset)
              ? this.quickActionIds
              : quickActionIds as Iterable<BillingNavigationDestinationId>?,
      defaultDestinationId:
          identical(defaultDestinationId, _unset)
              ? this.defaultDestinationId
              : defaultDestinationId as BillingNavigationDestinationId?,
    );
  }

  BillingBusinessDomainNavigationPolicy constrainedTo(
    Iterable<BillingNavigationDestinationId> allowedDestinationIds,
  ) {
    final allowedDestinationIdSet = allowedDestinationIds.toSet();
    final nextDestinationIds = _constrainedValues(
      destinationIds,
      allowedDestinationIdSet,
      'destination',
    );
    final quickActionScope =
        nextDestinationIds?.toSet() ?? allowedDestinationIdSet;
    final nextQuickActionIds = _constrainedValues(
      quickActionIds,
      quickActionScope,
      'quick action',
      emptyAsNull: true,
    );
    final nextDefaultDestinationId =
        defaultDestinationId != null &&
                quickActionScope.contains(defaultDestinationId)
            ? defaultDestinationId
            : null;

    return BillingBusinessDomainNavigationPolicy(
      destinationIds: nextDestinationIds,
      quickActionIds: nextQuickActionIds,
      defaultDestinationId: nextDefaultDestinationId,
    );
  }

  static List<BillingNavigationDestinationId>? _optionalUnique(
    Iterable<BillingNavigationDestinationId>? values,
    String label,
  ) {
    if (values == null) return null;

    final seen = <BillingNavigationDestinationId>{};
    final uniqueValues = <BillingNavigationDestinationId>[];
    for (final value in values) {
      if (!seen.add(value)) {
        throw StateError('Duplicate billing navigation $label: $value.');
      }
      uniqueValues.add(value);
    }

    if (uniqueValues.isEmpty) {
      throw StateError('Billing navigation $label list cannot be empty.');
    }

    return List.unmodifiable(uniqueValues);
  }

  static List<BillingNavigationDestinationId>? _constrainedValues(
    List<BillingNavigationDestinationId>? values,
    Set<BillingNavigationDestinationId> allowedValues,
    String label, {
    bool emptyAsNull = false,
  }) {
    if (values == null) return null;

    final constrainedValues = values.where(allowedValues.contains).toList();
    if (constrainedValues.isEmpty) {
      if (emptyAsNull) return null;
      throw StateError(
        'Constrained billing navigation $label list cannot be empty.',
      );
    }

    return List.unmodifiable(constrainedValues);
  }

  static void _ensureDefaultDestination(
    List<BillingNavigationDestinationId>? destinationIds,
    BillingNavigationDestinationId? defaultDestinationId,
  ) {
    if (destinationIds == null || defaultDestinationId == null) return;
    if (destinationIds.contains(defaultDestinationId)) return;

    throw StateError(
      'Default billing navigation destination must be exposed by the policy.',
    );
  }

  static void _ensureQuickActions(
    List<BillingNavigationDestinationId>? destinationIds,
    List<BillingNavigationDestinationId>? quickActionIds,
  ) {
    if (destinationIds == null || quickActionIds == null) return;

    for (final quickActionId in quickActionIds) {
      if (!destinationIds.contains(quickActionId)) {
        throw StateError(
          'Billing quick action $quickActionId must be exposed by the policy.',
        );
      }
    }
  }
}

const _unset = Object();
