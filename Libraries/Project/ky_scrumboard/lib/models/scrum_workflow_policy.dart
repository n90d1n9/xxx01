import 'scrum_task_status.dart';

class ScrumWorkflowPolicy {
  const ScrumWorkflowPolicy({
    this.wipLimits = const {
      ScrumTaskStatus.todo: 8,
      ScrumTaskStatus.inProgress: 4,
      ScrumTaskStatus.review: 3,
    },
    this.enforceWipLimits = false,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
  });

  final Map<ScrumTaskStatus, int> wipLimits;
  final bool enforceWipLimits;
  final int dueSoonDays;
  final int reviewAgeWarningDays;

  int? limitFor(ScrumTaskStatus status) => wipLimits[status];

  int projectedCountFor(
    ScrumTaskStatus status,
    int currentCount, {
    bool movingWithinStatus = false,
  }) {
    return movingWithinStatus ? currentCount : currentCount + 1;
  }

  bool wouldExceedLimit(
    ScrumTaskStatus status,
    int currentCount, {
    bool movingWithinStatus = false,
  }) {
    if (movingWithinStatus) return false;
    final limit = limitFor(status);
    if (limit == null) return false;
    return projectedCountFor(
          status,
          currentCount,
          movingWithinStatus: movingWithinStatus,
        ) >
        limit;
  }

  bool isOverLimit(ScrumTaskStatus status, int count) {
    final limit = limitFor(status);
    return limit != null && count > limit;
  }

  ScrumWorkflowPolicy copyWith({
    Map<ScrumTaskStatus, int>? wipLimits,
    bool? enforceWipLimits,
    int? dueSoonDays,
    int? reviewAgeWarningDays,
  }) {
    return ScrumWorkflowPolicy(
      wipLimits: wipLimits ?? this.wipLimits,
      enforceWipLimits: enforceWipLimits ?? this.enforceWipLimits,
      dueSoonDays: dueSoonDays ?? this.dueSoonDays,
      reviewAgeWarningDays: reviewAgeWarningDays ?? this.reviewAgeWarningDays,
    );
  }
}
