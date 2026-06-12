import 'candidate_ramp_models.dart';

enum CandidateRampActionStatus {
  submitted('Submitted'),
  active('Active'),
  completed('Completed');

  final String label;

  const CandidateRampActionStatus(this.label);
}

class CandidateRampAction {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String mentorName;
  final String learningPlanTitle;
  final String ownerName;
  final DateTime kickoffDate;
  final DateTime readinessDate;
  final String notes;
  final CandidateRampActionStatus status;
  final DateTime createdAt;

  const CandidateRampAction({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.mentorName,
    required this.learningPlanTitle,
    required this.ownerName,
    required this.kickoffDate,
    required this.readinessDate,
    required this.notes,
    required this.status,
    required this.createdAt,
  });
}

class CandidateRampActionDraft {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String mentorName;
  final String learningPlanTitle;
  final String ownerName;
  final DateTime? kickoffDate;
  final DateTime? readinessDate;
  final String notes;
  final DateTime asOfDate;

  const CandidateRampActionDraft({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.mentorName,
    required this.learningPlanTitle,
    required this.ownerName,
    required this.kickoffDate,
    required this.readinessDate,
    required this.notes,
    required this.asOfDate,
  });

  factory CandidateRampActionDraft.empty(DateTime asOfDate) {
    return CandidateRampActionDraft(
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      mentorName: '',
      learningPlanTitle: '',
      ownerName: '',
      kickoffDate: null,
      readinessDate: null,
      notes: '',
      asOfDate: asOfDate,
    );
  }

  factory CandidateRampActionDraft.fromPlan({
    required CandidateRampPlan plan,
    required DateTime asOfDate,
  }) {
    return CandidateRampActionDraft(
      candidateId: plan.id,
      candidateName: plan.candidateName,
      role: plan.role,
      department: plan.department,
      mentorName: plan.mentorName,
      learningPlanTitle: plan.learningPlanTitle,
      ownerName: 'Talent Partner',
      kickoffDate: plan.rampStartDate,
      readinessDate: plan.readinessDate,
      notes: plan.action,
      asOfDate: asOfDate,
    );
  }

  CandidateRampActionDraft copyWith({
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? mentorName,
    String? learningPlanTitle,
    String? ownerName,
    DateTime? kickoffDate,
    DateTime? readinessDate,
    String? notes,
    DateTime? asOfDate,
    bool clearKickoffDate = false,
    bool clearReadinessDate = false,
  }) {
    return CandidateRampActionDraft(
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      mentorName: mentorName ?? this.mentorName,
      learningPlanTitle: learningPlanTitle ?? this.learningPlanTitle,
      ownerName: ownerName ?? this.ownerName,
      kickoffDate: clearKickoffDate ? null : kickoffDate ?? this.kickoffDate,
      readinessDate:
          clearReadinessDate ? null : readinessDate ?? this.readinessDate,
      notes: notes ?? this.notes,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          candidateId.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          learningPlanTitle.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          kickoffDate != null,
          readinessDate != null,
          notes.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 7;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateRequired(candidateId, 'a candidate'),
      validateRequired(mentorName, 'a mentor'),
      validateRequired(learningPlanTitle, 'a learning plan'),
      validateRequired(ownerName, 'an owner'),
      validateKickoffDate(kickoffDate, asOfDate),
      validateReadinessDate(readinessDate, kickoffDate),
      validateNotes(notes),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateRampAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return CandidateRampAction(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      mentorName: mentorName.trim(),
      learningPlanTitle: learningPlanTitle.trim(),
      ownerName: ownerName.trim(),
      kickoffDate: kickoffDate!,
      readinessDate: readinessDate!,
      notes: notes.trim(),
      status: CandidateRampActionStatus.submitted,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateKickoffDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select a kickoff date';

    final kickoff = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (kickoff.isBefore(today)) {
      return 'Kickoff date cannot be in the past';
    }
    return null;
  }

  static String? validateReadinessDate(
    DateTime? readinessDate,
    DateTime? kickoffDate,
  ) {
    if (readinessDate == null) return 'Please select a readiness date';
    if (kickoffDate == null) return null;

    final ready = DateTime(
      readinessDate.year,
      readinessDate.month,
      readinessDate.day,
    );
    final kickoff = DateTime(
      kickoffDate.year,
      kickoffDate.month,
      kickoffDate.day,
    );
    if (ready.isBefore(kickoff)) {
      return 'Readiness date cannot be before kickoff';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    final requiredError = validateRequired(value, 'ramp notes');
    if (requiredError != null) return requiredError;

    if (value!.trim().length < 12) {
      return 'Ramp notes must be at least 12 characters';
    }
    return null;
  }
}

class CandidateRampActionSummary {
  final int totalCount;
  final int submittedCount;
  final int activeCount;
  final int completedCount;
  final String nextAction;

  const CandidateRampActionSummary({
    required this.totalCount,
    required this.submittedCount,
    required this.activeCount,
    required this.completedCount,
    required this.nextAction,
  });

  factory CandidateRampActionSummary.fromActions(
    List<CandidateRampAction> actions,
  ) {
    final submittedCount =
        actions
            .where(
              (action) => action.status == CandidateRampActionStatus.submitted,
            )
            .length;
    final activeCount =
        actions
            .where(
              (action) => action.status == CandidateRampActionStatus.active,
            )
            .length;
    final completedCount =
        actions
            .where(
              (action) => action.status == CandidateRampActionStatus.completed,
            )
            .length;

    return CandidateRampActionSummary(
      totalCount: actions.length,
      submittedCount: submittedCount,
      activeCount: activeCount,
      completedCount: completedCount,
      nextAction: _nextAction(
        submittedCount: submittedCount,
        activeCount: activeCount,
      ),
    );
  }
}

String _nextAction({required int submittedCount, required int activeCount}) {
  if (submittedCount > 0) return 'Review submitted ramp plans with managers.';
  if (activeCount > 0) return 'Track active ramp checkpoints weekly.';
  return 'Create a ramp action from a candidate plan.';
}
