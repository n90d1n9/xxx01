import 'candidate_talent_handoff_checklist_item.dart';
import 'candidate_talent_handoff_models.dart';

class CandidateTalentHandoffChecklistDraft {
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateTalentHandoffChecklistCategory? category;
  final String title;
  final String ownerName;
  final DateTime? dueDate;
  final String detail;
  final bool requiredBeforeStart;
  final DateTime asOfDate;

  const CandidateTalentHandoffChecklistDraft({
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.category,
    required this.title,
    required this.ownerName,
    required this.dueDate,
    required this.detail,
    required this.requiredBeforeStart,
    required this.asOfDate,
  });

  factory CandidateTalentHandoffChecklistDraft.empty(DateTime asOfDate) {
    return CandidateTalentHandoffChecklistDraft(
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      category: null,
      title: '',
      ownerName: '',
      dueDate: null,
      detail: '',
      requiredBeforeStart: true,
      asOfDate: asOfDate,
    );
  }

  factory CandidateTalentHandoffChecklistDraft.fromHandoff({
    required CandidateTalentHandoff handoff,
    required DateTime asOfDate,
  }) {
    final category = _defaultCategory(handoff);
    return CandidateTalentHandoffChecklistDraft(
      handoffId: handoff.id,
      candidateId: handoff.candidateId,
      candidateName: handoff.candidateName,
      role: handoff.role,
      department: handoff.department,
      category: category,
      title: _defaultTitle(category),
      ownerName: handoff.ownerName,
      dueDate: _safeDueDate(
        targetDate: handoff.targetStartDate.subtract(const Duration(days: 2)),
        asOfDate: asOfDate,
      ),
      detail: handoff.talentFocus,
      requiredBeforeStart:
          handoff.type != CandidateTalentHandoffType.talentBench,
      asOfDate: asOfDate,
    );
  }

  CandidateTalentHandoffChecklistDraft copyWith({
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    CandidateTalentHandoffChecklistCategory? category,
    String? title,
    String? ownerName,
    DateTime? dueDate,
    String? detail,
    bool? requiredBeforeStart,
    DateTime? asOfDate,
  }) {
    return CandidateTalentHandoffChecklistDraft(
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      category: category ?? this.category,
      title: title ?? this.title,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      detail: detail ?? this.detail,
      requiredBeforeStart: requiredBeforeStart ?? this.requiredBeforeStart,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          handoffId.trim().isNotEmpty,
          category != null,
          title.trim().length >= 8,
          ownerName.trim().isNotEmpty,
          dueDate != null,
          detail.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(handoffId, 'a talent handoff') case final error?)
        error,
      if (validateCategory(category) case final error?) error,
      if (validateTitle(title) case final error?) error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateDetail(detail) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateTalentHandoffChecklistItem toItem({
    required String id,
    required DateTime createdAt,
  }) {
    return CandidateTalentHandoffChecklistItem(
      id: id,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      category: category!,
      status: CandidateTalentHandoffChecklistStatus.open,
      title: title.trim(),
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      detail: detail.trim(),
      requiredBeforeStart: requiredBeforeStart,
      createdAt: createdAt,
    );
  }

  static String? validateCategory(
    CandidateTalentHandoffChecklistCategory? value,
  ) {
    if (value == null) return 'Select a checklist category';
    return null;
  }

  static String? validateTitle(String? value) {
    final requiredError = validateRequired(value, 'a checklist title');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 8) {
      return 'Checklist title must be at least 8 characters';
    }
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a checklist due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateDetail(String? value) {
    final requiredError = validateRequired(value, 'checklist detail');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Checklist detail must be at least 12 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

CandidateTalentHandoffChecklistCategory _defaultCategory(
  CandidateTalentHandoff handoff,
) {
  if (handoff.status == CandidateTalentHandoffStatus.blocked) {
    return CandidateTalentHandoffChecklistCategory.managerKickoff;
  }
  return switch (handoff.type) {
    CandidateTalentHandoffType.offerTransition =>
      CandidateTalentHandoffChecklistCategory.paperwork,
    CandidateTalentHandoffType.preboarding =>
      CandidateTalentHandoffChecklistCategory.access,
    CandidateTalentHandoffType.talentBench =>
      CandidateTalentHandoffChecklistCategory.learning,
    CandidateTalentHandoffType.deferred =>
      CandidateTalentHandoffChecklistCategory.managerKickoff,
  };
}

String _defaultTitle(CandidateTalentHandoffChecklistCategory category) {
  return switch (category) {
    CandidateTalentHandoffChecklistCategory.paperwork =>
      'Complete offer and contract handoff',
    CandidateTalentHandoffChecklistCategory.payroll =>
      'Confirm payroll profile readiness',
    CandidateTalentHandoffChecklistCategory.access =>
      'Prepare system access package',
    CandidateTalentHandoffChecklistCategory.managerKickoff =>
      'Schedule manager kickoff',
    CandidateTalentHandoffChecklistCategory.mentor =>
      'Confirm mentor introduction',
    CandidateTalentHandoffChecklistCategory.learning =>
      'Attach first learning plan',
  };
}

DateTime _safeDueDate({
  required DateTime targetDate,
  required DateTime asOfDate,
}) {
  final target = _dateOnly(targetDate);
  final today = _dateOnly(asOfDate);
  return target.isBefore(today) ? today : target;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
