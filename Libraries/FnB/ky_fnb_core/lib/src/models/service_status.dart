/// Shared operating pressure states used across FnB service and kitchen flows.
enum FnbServiceStatus {
  calm,
  busy,
  critical,
  blocked;

  /// Human-readable label for dashboards, chips, and controls.
  String get label => switch (this) {
    FnbServiceStatus.calm => 'Calm',
    FnbServiceStatus.busy => 'Busy',
    FnbServiceStatus.critical => 'Critical',
    FnbServiceStatus.blocked => 'Blocked',
  };

  /// Relative severity used when ranking operational attention.
  int get priorityScore => switch (this) {
    FnbServiceStatus.blocked => 4,
    FnbServiceStatus.critical => 3,
    FnbServiceStatus.busy => 2,
    FnbServiceStatus.calm => 1,
  };

  /// Whether the status should be shown as requiring operator attention.
  bool get needsAttention => this != FnbServiceStatus.calm;

  /// Whether this status is at least as urgent as [threshold].
  bool isAtLeast(FnbServiceStatus threshold) {
    return priorityScore >= threshold.priorityScore;
  }

  /// Returns the more urgent status between this value and [other].
  FnbServiceStatus mostUrgent(FnbServiceStatus other) {
    return isAtLeast(other) ? this : other;
  }
}
