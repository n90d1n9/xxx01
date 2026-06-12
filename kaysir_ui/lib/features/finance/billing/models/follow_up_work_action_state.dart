import 'follow_up_work_item.dart';

/// Presentation state for the visible action on a billing follow-up item.
class BillingFollowUpWorkActionState {
  final String label;
  final bool isEnabled;
  final String? disabledReason;

  const BillingFollowUpWorkActionState({
    required this.label,
    this.isEnabled = true,
    this.disabledReason,
  });

  /// Creates a visible action from a plain label when one is available.
  static BillingFollowUpWorkActionState? fromLabel(String? label) {
    final trimmedLabel = label?.trim();
    if (trimmedLabel == null || trimmedLabel.isEmpty) return null;

    return BillingFollowUpWorkActionState(label: trimmedLabel);
  }

  /// Returns the normalized action or null when there is nothing to show.
  BillingFollowUpWorkActionState? normalized() {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) return null;
    final trimmedDisabledReason = disabledReason?.trim();

    return BillingFollowUpWorkActionState(
      label: trimmedLabel,
      isEnabled: isEnabled,
      disabledReason:
          trimmedDisabledReason?.isEmpty == true ? null : trimmedDisabledReason,
    );
  }
}

/// Builds the action presentation shown for a follow-up work item.
typedef BillingFollowUpWorkActionStateBuilder =
    BillingFollowUpWorkActionState? Function(BillingFollowUpWorkItem item);
