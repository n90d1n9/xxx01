import 'candidate_development_check_in_models.dart';
import 'candidate_development_intervention.dart';

class CandidateDevelopmentInterventionDraft {
  final String checkInId;
  final String objectiveId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String ownerName;
  final CandidateDevelopmentInterventionType type;
  final String actionNote;
  final bool escalationRequired;
  final DateTime? dueDate;
  final DateTime asOfDate;

  const CandidateDevelopmentInterventionDraft({
    required this.checkInId,
    required this.objectiveId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.ownerName,
    required this.type,
    required this.actionNote,
    required this.escalationRequired,
    required this.dueDate,
    required this.asOfDate,
  });

  factory CandidateDevelopmentInterventionDraft.empty(DateTime asOfDate) {
    return CandidateDevelopmentInterventionDraft(
      checkInId: '',
      objectiveId: '',
      candidateName: '',
      role: '',
      department: '',
      objectiveTitle: '',
      ownerName: '',
      type: CandidateDevelopmentInterventionType.coaching,
      actionNote: '',
      escalationRequired: false,
      dueDate: null,
      asOfDate: asOfDate,
    );
  }

  factory CandidateDevelopmentInterventionDraft.fromCheckIn({
    required CandidateDevelopmentCheckIn checkIn,
    required DateTime asOfDate,
  }) {
    final type = _typeFromCheckIn(checkIn);
    return CandidateDevelopmentInterventionDraft(
      checkInId: checkIn.id,
      objectiveId: checkIn.objectiveId,
      candidateName: checkIn.candidateName,
      role: checkIn.role,
      department: checkIn.department,
      objectiveTitle: checkIn.objectiveTitle,
      ownerName: checkIn.ownerName,
      type: type,
      actionNote: _actionNoteFromCheckIn(checkIn, type),
      escalationRequired:
          checkIn.status == CandidateDevelopmentCheckInStatus.blocked,
      dueDate: asOfDate.add(_durationFromCheckIn(checkIn)),
      asOfDate: asOfDate,
    );
  }

  CandidateDevelopmentInterventionDraft copyWith({
    String? checkInId,
    String? objectiveId,
    String? candidateName,
    String? role,
    String? department,
    String? objectiveTitle,
    String? ownerName,
    CandidateDevelopmentInterventionType? type,
    String? actionNote,
    bool? escalationRequired,
    DateTime? dueDate,
    DateTime? asOfDate,
    bool clearDueDate = false,
  }) {
    return CandidateDevelopmentInterventionDraft(
      checkInId: checkInId ?? this.checkInId,
      objectiveId: objectiveId ?? this.objectiveId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      objectiveTitle: objectiveTitle ?? this.objectiveTitle,
      ownerName: ownerName ?? this.ownerName,
      type: type ?? this.type,
      actionNote: actionNote ?? this.actionNote,
      escalationRequired: escalationRequired ?? this.escalationRequired,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          checkInId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionNote.trim().length >= 12,
          dueDate != null,
        ].where((item) => item).length;

    return completed / 4;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(checkInId, 'a check-in') case final error?) error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateActionNote(actionNote) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateDevelopmentIntervention toIntervention({
    required String id,
    required DateTime createdAt,
  }) {
    if (!isReadyToSubmit) {
      throw StateError('Complete development intervention before saving.');
    }
    return CandidateDevelopmentIntervention(
      id: id,
      checkInId: checkInId,
      objectiveId: objectiveId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      objectiveTitle: objectiveTitle.trim(),
      ownerName: ownerName.trim(),
      type: type,
      actionNote: actionNote.trim(),
      escalationRequired: escalationRequired,
      dueDate: dueDate!,
      status: CandidateDevelopmentInterventionStatus.open,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateActionNote(String? value) {
    final requiredError = validateRequired(value, 'an intervention action');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Intervention action must be at least 12 characters';
    }
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select a due date';

    final due = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (due.isBefore(today)) return 'Due date cannot be in the past';
    return null;
  }
}

CandidateDevelopmentInterventionType _typeFromCheckIn(
  CandidateDevelopmentCheckIn checkIn,
) {
  if (checkIn.status == CandidateDevelopmentCheckInStatus.blocked) {
    return checkIn.blockerNote.isNotEmpty
        ? CandidateDevelopmentInterventionType.unblock
        : CandidateDevelopmentInterventionType.escalation;
  }
  if (checkIn.status == CandidateDevelopmentCheckInStatus.watch) {
    return CandidateDevelopmentInterventionType.coaching;
  }
  return CandidateDevelopmentInterventionType.timelineReview;
}

Duration _durationFromCheckIn(CandidateDevelopmentCheckIn checkIn) {
  return switch (checkIn.status) {
    CandidateDevelopmentCheckInStatus.blocked => const Duration(days: 7),
    CandidateDevelopmentCheckInStatus.watch => const Duration(days: 10),
    CandidateDevelopmentCheckInStatus.onTrack => const Duration(days: 14),
  };
}

String _actionNoteFromCheckIn(
  CandidateDevelopmentCheckIn checkIn,
  CandidateDevelopmentInterventionType type,
) {
  return switch (type) {
    CandidateDevelopmentInterventionType.unblock =>
      'Remove blocker: ${checkIn.blockerNote}',
    CandidateDevelopmentInterventionType.escalation =>
      'Escalate low confidence and reset support owner.',
    CandidateDevelopmentInterventionType.coaching =>
      'Schedule targeted coaching for ${checkIn.objectiveTitle}.',
    CandidateDevelopmentInterventionType.timelineReview =>
      'Confirm next milestone and keep review cadence active.',
  };
}
