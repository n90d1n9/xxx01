import 'follow_up_work_item.dart';

const Object _unsetFilterValue = Object();

/// Filter state for reusable billing follow-up work queues.
class BillingFollowUpWorkQueueFilter {
  final BillingFollowUpWorkStatus? status;
  final BillingFollowUpWorkSource? source;
  final String? ownerRole;

  const BillingFollowUpWorkQueueFilter({
    this.status,
    this.source,
    this.ownerRole,
  });

  String? get normalizedOwnerRole => _normalizeOwnerRole(ownerRole);

  bool get isDefault =>
      status == null && source == null && normalizedOwnerRole == null;

  bool get isNotDefault => !isDefault;

  int get activeFilterCount {
    return [
      status,
      source,
      normalizedOwnerRole,
    ].where((value) => value != null).length;
  }

  /// Returns a copy with a new status filter.
  BillingFollowUpWorkQueueFilter withStatus(BillingFollowUpWorkStatus? value) {
    return BillingFollowUpWorkQueueFilter(
      status: value,
      source: source,
      ownerRole: ownerRole,
    );
  }

  /// Returns a copy with a new source filter.
  BillingFollowUpWorkQueueFilter withSource(BillingFollowUpWorkSource? value) {
    return BillingFollowUpWorkQueueFilter(
      status: status,
      source: value,
      ownerRole: ownerRole,
    );
  }

  /// Returns a copy with a new owner-role filter.
  BillingFollowUpWorkQueueFilter withOwnerRole(String? value) {
    return BillingFollowUpWorkQueueFilter(
      status: status,
      source: source,
      ownerRole: _normalizeOwnerRole(value),
    );
  }

  /// Clears all active queue filters.
  BillingFollowUpWorkQueueFilter reset() {
    return const BillingFollowUpWorkQueueFilter();
  }

  /// Returns a copy with optional filter overrides.
  BillingFollowUpWorkQueueFilter copyWith({
    Object? status = _unsetFilterValue,
    Object? source = _unsetFilterValue,
    Object? ownerRole = _unsetFilterValue,
  }) {
    return BillingFollowUpWorkQueueFilter(
      status:
          identical(status, _unsetFilterValue)
              ? this.status
              : status as BillingFollowUpWorkStatus?,
      source:
          identical(source, _unsetFilterValue)
              ? this.source
              : source as BillingFollowUpWorkSource?,
      ownerRole:
          identical(ownerRole, _unsetFilterValue)
              ? this.ownerRole
              : _normalizeOwnerRole(ownerRole as String?),
    );
  }

  /// Whether the supplied work item is included by this filter.
  bool matches(BillingFollowUpWorkItem item) {
    if (status != null && item.status != status) return false;
    if (source != null && item.source != source) return false;
    if (normalizedOwnerRole != null &&
        _normalizeOwnerRole(item.ownerRole) != normalizedOwnerRole) {
      return false;
    }
    return true;
  }

  /// Applies this filter and returns a display queue for the visible work.
  BillingFollowUpWorkQueue applyTo(BillingFollowUpWorkQueue queue) {
    if (isDefault) return queue;

    final items = queue.items.where(matches).toList(growable: false);
    final blockers =
        status == null || status == BillingFollowUpWorkStatus.blocked
            ? queue.blockers
            : const <String>[];

    return BillingFollowUpWorkQueue(
      title: queue.title,
      sourceLabel: source?.label ?? queue.sourceLabel,
      items: items,
      blockers: blockers,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingFollowUpWorkQueueFilter &&
            other.status == status &&
            other.source == source &&
            other.normalizedOwnerRole == normalizedOwnerRole;
  }

  @override
  int get hashCode => Object.hash(status, source, normalizedOwnerRole);
}

String? _normalizeOwnerRole(String? ownerRole) {
  final normalizedOwnerRole = ownerRole?.trim();
  if (normalizedOwnerRole == null || normalizedOwnerRole.isEmpty) return null;
  return normalizedOwnerRole;
}
