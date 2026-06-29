import 'candidate_decision_models.dart';
import 'candidate_development_objective.dart';

class CandidateDevelopmentObjectiveDraft {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String skillFocus;
  final String ownerName;
  final String mentorName;
  final String successMeasure;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime asOfDate;

  const CandidateDevelopmentObjectiveDraft({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.skillFocus,
    required this.ownerName,
    required this.mentorName,
    required this.successMeasure,
    required this.startDate,
    required this.dueDate,
    required this.asOfDate,
  });

  factory CandidateDevelopmentObjectiveDraft.empty(DateTime asOfDate) {
    return CandidateDevelopmentObjectiveDraft(
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      objectiveTitle: '',
      skillFocus: '',
      ownerName: '',
      mentorName: '',
      successMeasure: '',
      startDate: null,
      dueDate: null,
      asOfDate: asOfDate,
    );
  }

  factory CandidateDevelopmentObjectiveDraft.fromPacket({
    required CandidateDecisionPacket packet,
    required DateTime asOfDate,
  }) {
    final startDate = _objectiveStartDate(packet, asOfDate);
    return CandidateDevelopmentObjectiveDraft(
      candidateId: packet.candidateId,
      candidateName: packet.candidateName,
      role: packet.role,
      department: packet.department,
      objectiveTitle: _objectiveTitle(packet),
      skillFocus: packet.skillFocus,
      ownerName: 'Talent Partner',
      mentorName: packet.suggestedMentor,
      successMeasure:
          'Evidence attached, mentor confirmed, and first milestone completed.',
      startDate: startDate,
      dueDate: startDate.add(_objectiveDuration(packet)),
      asOfDate: asOfDate,
    );
  }

  CandidateDevelopmentObjectiveDraft copyWith({
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? objectiveTitle,
    String? skillFocus,
    String? ownerName,
    String? mentorName,
    String? successMeasure,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? asOfDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) {
    return CandidateDevelopmentObjectiveDraft(
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      objectiveTitle: objectiveTitle ?? this.objectiveTitle,
      skillFocus: skillFocus ?? this.skillFocus,
      ownerName: ownerName ?? this.ownerName,
      mentorName: mentorName ?? this.mentorName,
      successMeasure: successMeasure ?? this.successMeasure,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          candidateId.trim().isNotEmpty,
          objectiveTitle.trim().length >= 6,
          skillFocus.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          startDate != null,
          dueDate != null,
          successMeasure.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 8;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(candidateId, 'a candidate') case final error?) error,
      if (validateTitle(objectiveTitle) case final error?) error,
      if (validateRequired(skillFocus, 'a skill focus') case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateRequired(mentorName, 'a mentor') case final error?) error,
      if (validateStartDate(startDate, asOfDate) case final error?) error,
      if (validateDueDate(dueDate, startDate) case final error?) error,
      if (validateSuccessMeasure(successMeasure) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateDevelopmentObjective toObjective({
    required String id,
    required DateTime createdAt,
  }) {
    if (!isReadyToSubmit) {
      throw StateError('Complete development objective before saving.');
    }
    return CandidateDevelopmentObjective(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      objectiveTitle: objectiveTitle.trim(),
      skillFocus: skillFocus.trim(),
      ownerName: ownerName.trim(),
      mentorName: mentorName.trim(),
      successMeasure: successMeasure.trim(),
      startDate: startDate!,
      dueDate: dueDate!,
      status: CandidateDevelopmentObjectiveStatus.planned,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    final requiredError = validateRequired(value, 'an objective title');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 6) return 'Objective title is too short';
    return null;
  }

  static String? validateStartDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select a start date';

    final start = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (start.isBefore(today)) return 'Start date cannot be in the past';
    return null;
  }

  static String? validateDueDate(DateTime? dueDate, DateTime? startDate) {
    if (dueDate == null) return 'Please select a due date';
    if (startDate == null) return null;

    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    if (!due.isAfter(start)) return 'Due date must be after start date';
    return null;
  }

  static String? validateSuccessMeasure(String? value) {
    final requiredError = validateRequired(value, 'a success measure');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Success measure must be at least 12 characters';
    }
    return null;
  }
}

DateTime _objectiveStartDate(
  CandidateDecisionPacket packet,
  DateTime asOfDate,
) {
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(
    packet.decisionDueDate.year,
    packet.decisionDueDate.month,
    packet.decisionDueDate.day,
  );
  return due.isBefore(today) ? today : due;
}

Duration _objectiveDuration(CandidateDecisionPacket packet) {
  return switch (packet.recommendation) {
    CandidateDecisionRecommendation.hold => const Duration(days: 45),
    CandidateDecisionRecommendation.conditional => const Duration(days: 30),
    CandidateDecisionRecommendation.approve => const Duration(days: 21),
  };
}

String _objectiveTitle(CandidateDecisionPacket packet) {
  if (packet.skillFocus == 'No skill gaps') {
    return 'Complete ${packet.role} onboarding objective';
  }
  return 'Close ${packet.skillFocus} readiness gap';
}
