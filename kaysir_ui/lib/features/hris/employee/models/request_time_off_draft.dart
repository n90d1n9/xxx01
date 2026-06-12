class TimeOffBalance {
  final String type;
  final int usedDays;
  final int totalDays;

  const TimeOffBalance({
    required this.type,
    required this.usedDays,
    required this.totalDays,
  });

  int get remainingDays => totalDays - usedDays;

  double get usageRatio => totalDays == 0 ? 0 : usedDays / totalDays;

  int projectedRemaining(int requestDays) => remainingDays - requestDays;
}

class RequestTimeOffDraft {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const RequestTimeOffDraft({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.reason = '',
  });

  int get durationDays {
    final value = endDate.difference(startDate).inDays + 1;
    return value < 0 ? 0 : value;
  }

  bool get hasReason => reason.trim().isNotEmpty;

  RequestTimeOffDraft copyWith({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
  }) {
    return RequestTimeOffDraft(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
    );
  }
}

class RequestTimeOffReview {
  final RequestTimeOffDraft draft;
  final TimeOffBalance balance;

  const RequestTimeOffReview({required this.draft, required this.balance});

  int get durationDays => draft.durationDays;

  int get remainingAfterRequest => balance.projectedRemaining(durationDays);

  bool get exceedsBalance => remainingAfterRequest < 0;

  bool get canSubmit => durationDays > 0 && draft.hasReason && !exceedsBalance;

  String get guidance {
    if (durationDays <= 0) {
      return 'Choose a valid date range.';
    }
    if (!draft.hasReason) {
      return 'Add a short reason before submitting.';
    }
    if (exceedsBalance) {
      return 'This request exceeds the available ${balance.type} balance.';
    }
    return 'Ready for manager review.';
  }
}
