import 'employee_directory_quality_gate_models.dart';

/// Captures reviewer input before signing off the roster quality gate.
class EmployeeDirectoryQualityGateSignoffDraft {
  final String reviewer;
  final String note;
  final bool acceptReviewItems;

  const EmployeeDirectoryQualityGateSignoffDraft({
    this.reviewer = '',
    this.note = '',
    this.acceptReviewItems = false,
  });

  bool get hasInput {
    return reviewer.trim().isNotEmpty ||
        note.trim().isNotEmpty ||
        acceptReviewItems;
  }

  EmployeeDirectoryQualityGateSignoffDraft copyWith({
    String? reviewer,
    String? note,
    bool? acceptReviewItems,
  }) {
    return EmployeeDirectoryQualityGateSignoffDraft(
      reviewer: reviewer ?? this.reviewer,
      note: note ?? this.note,
      acceptReviewItems: acceptReviewItems ?? this.acceptReviewItems,
    );
  }
}

/// Immutable roster gate sign-off record for audit history.
class EmployeeDirectoryQualityGateSignoff {
  final String id;
  final String reviewer;
  final String note;
  final DateTime signedAt;
  final EmployeeDirectoryQualityGateStatus gateStatus;
  final int readinessScore;
  final int memberCount;
  final int acceptedReviewCount;

  const EmployeeDirectoryQualityGateSignoff({
    required this.id,
    required this.reviewer,
    required this.note,
    required this.signedAt,
    required this.gateStatus,
    required this.readinessScore,
    required this.memberCount,
    required this.acceptedReviewCount,
  });

  String get statusLabel => gateStatus.label;

  String get summaryLabel {
    if (acceptedReviewCount == 0) {
      return '$readinessScore% readiness across $memberCount profiles.';
    }
    return '$readinessScore% readiness with $acceptedReviewCount accepted '
        'review item${acceptedReviewCount == 1 ? '' : 's'}.';
  }
}

/// Validates gate sign-off readiness against the current roster quality gate.
class EmployeeDirectoryQualityGateSignoffReview {
  final EmployeeDirectoryQualityGate gate;
  final EmployeeDirectoryQualityGateSignoffDraft draft;
  final List<EmployeeDirectoryQualityGateSignoff> signoffs;
  final List<String> errors;

  const EmployeeDirectoryQualityGateSignoffReview({
    required this.gate,
    required this.draft,
    required this.signoffs,
    required this.errors,
  });

  factory EmployeeDirectoryQualityGateSignoffReview.fromState({
    required EmployeeDirectoryQualityGate gate,
    required EmployeeDirectoryQualityGateSignoffDraft draft,
    required List<EmployeeDirectoryQualityGateSignoff> signoffs,
  }) {
    final review = EmployeeDirectoryQualityGateSignoffReview(
      gate: gate,
      draft: draft,
      signoffs: signoffs,
      errors: const [],
    );

    return EmployeeDirectoryQualityGateSignoffReview(
      gate: gate,
      draft: draft,
      signoffs: signoffs,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryQualityGateSignoff? get latestSignoff {
    return signoffs.isEmpty ? null : signoffs.first;
  }

  int get reviewItemCount => gate.reviewCount + gate.advisoryCount;

  bool get canSubmit => errors.isEmpty;

  double get completionRatio {
    final checks = [
      draft.reviewer.trim().length >= 3,
      draft.note.trim().length >= 12,
      gate.status != EmployeeDirectoryQualityGateStatus.review ||
          draft.acceptReviewItems,
      gate.status != EmployeeDirectoryQualityGateStatus.blocked,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  String get statusLabel {
    if (gate.status == EmployeeDirectoryQualityGateStatus.blocked) {
      return 'Blocked';
    }
    return canSubmit ? 'Ready' : 'Needs review';
  }

  EmployeeDirectoryQualityGateSignoff toSignoff({
    required String id,
    required DateTime signedAt,
  }) {
    if (!canSubmit) {
      throw StateError(errors.first);
    }

    return EmployeeDirectoryQualityGateSignoff(
      id: id,
      reviewer: draft.reviewer.trim(),
      note: draft.note.trim(),
      signedAt: signedAt,
      gateStatus: gate.status,
      readinessScore: gate.readinessScore,
      memberCount: gate.memberCount,
      acceptedReviewCount: draft.acceptReviewItems ? reviewItemCount : 0,
    );
  }
}

List<String> _validate(EmployeeDirectoryQualityGateSignoffReview review) {
  final errors = <String>[];
  final gate = review.gate;
  final draft = review.draft;

  if (gate.status == EmployeeDirectoryQualityGateStatus.blocked) {
    errors.add(
      'Resolve ${gate.blockerCount} payroll blocker'
      '${gate.blockerCount == 1 ? '' : 's'} before sign-off.',
    );
  }
  if (gate.status == EmployeeDirectoryQualityGateStatus.review &&
      !draft.acceptReviewItems) {
    errors.add(
      'Accept ${review.reviewItemCount} review item'
      '${review.reviewItemCount == 1 ? '' : 's'} or resolve before sign-off.',
    );
  }
  if (draft.reviewer.trim().length < 3) {
    errors.add('Reviewer is required.');
  }
  if (draft.note.trim().length < 12) {
    errors.add('Sign-off note must be at least 12 characters.');
  }

  return errors;
}
