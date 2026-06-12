import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';

class IncomingTalentSuccessionNominationDraft {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String promotionTrack;
  final String sponsorName;
  final String panelName;
  final IncomingTalentSuccessionNominationType? nominationType;
  final IncomingTalentSuccessionNominationStatus? status;
  final IncomingTalentSuccessionReadiness? readiness;
  final IncomingTalentSuccessionRisk? risk;
  final DateTime? nominationDate;
  final DateTime? panelDate;
  final String businessCase;
  final String evidenceSummary;
  final String successPlan;
  final DateTime asOfDate;

  const IncomingTalentSuccessionNominationDraft({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.promotionTrack,
    required this.sponsorName,
    required this.panelName,
    required this.nominationType,
    required this.status,
    required this.readiness,
    required this.risk,
    required this.nominationDate,
    required this.panelDate,
    required this.businessCase,
    required this.evidenceSummary,
    required this.successPlan,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionNominationDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionNominationDraft(
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      promotionTrack: '',
      sponsorName: '',
      panelName: '',
      nominationType: null,
      status: null,
      readiness: null,
      risk: null,
      nominationDate: null,
      panelDate: null,
      businessCase: '',
      evidenceSummary: '',
      successPlan: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionNominationDraft.fromCandidate({
    required IncomingTalentSuccessionCandidate candidate,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionNominationDraft(
      candidateId: candidate.candidateId,
      candidateName: candidate.candidateName,
      role: candidate.role,
      department: candidate.department,
      targetRole: candidate.targetRole,
      promotionTrack: candidate.promotionTrack,
      sponsorName: '${candidate.department} sponsor',
      panelName: '${candidate.department} succession panel',
      nominationType: _nominationType(candidate.readiness),
      status: IncomingTalentSuccessionNominationStatus.panelReview,
      readiness: candidate.readiness,
      risk: candidate.risk,
      nominationDate: asOfDate,
      panelDate: asOfDate.add(const Duration(days: 14)),
      businessCase:
          '${candidate.candidateName} is nominated for ${candidate.targetRole.toLowerCase()} based on ${candidate.latestCalibrationDecisionLabel.toLowerCase()} evidence.',
      evidenceSummary: candidate.evidenceSummary,
      successPlan: candidate.nextAction,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionNominationDraft copyWith({
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? promotionTrack,
    String? sponsorName,
    String? panelName,
    IncomingTalentSuccessionNominationType? nominationType,
    IncomingTalentSuccessionNominationStatus? status,
    IncomingTalentSuccessionReadiness? readiness,
    IncomingTalentSuccessionRisk? risk,
    DateTime? nominationDate,
    DateTime? panelDate,
    String? businessCase,
    String? evidenceSummary,
    String? successPlan,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionNominationDraft(
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      promotionTrack: promotionTrack ?? this.promotionTrack,
      sponsorName: sponsorName ?? this.sponsorName,
      panelName: panelName ?? this.panelName,
      nominationType: nominationType ?? this.nominationType,
      status: status ?? this.status,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      nominationDate: nominationDate ?? this.nominationDate,
      panelDate: panelDate ?? this.panelDate,
      businessCase: businessCase ?? this.businessCase,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      successPlan: successPlan ?? this.successPlan,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          candidateId.trim().isNotEmpty,
          sponsorName.trim().isNotEmpty,
          panelName.trim().isNotEmpty,
          nominationType != null,
          status != null,
          readiness != null,
          risk != null,
          nominationDate != null,
          panelDate != null,
          businessCase.trim().length >= 12,
          evidenceSummary.trim().length >= 12,
          successPlan.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(candidateId, 'a succession candidate')
          case final error?)
        error,
      if (validateRequired(sponsorName, 'a sponsor') case final error?) error,
      if (validateRequired(panelName, 'a panel') case final error?) error,
      if (validateNominationType(nominationType) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateReadiness(readiness) case final error?) error,
      if (validateRisk(risk) case final error?) error,
      if (validateNominationDate(nominationDate, asOfDate) case final error?)
        error,
      if (validatePanelDate(nominationDate, panelDate) case final error?) error,
      if (validateBusinessCase(businessCase) case final error?) error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateSuccessPlan(successPlan) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionNomination toNomination({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionNomination(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      promotionTrack: promotionTrack.trim(),
      sponsorName: sponsorName.trim(),
      panelName: panelName.trim(),
      nominationType: nominationType!,
      status: status!,
      readiness: readiness!,
      risk: risk!,
      nominationDate: nominationDate!,
      panelDate: panelDate!,
      businessCase: businessCase.trim(),
      evidenceSummary: evidenceSummary.trim(),
      successPlan: successPlan.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateNominationType(
    IncomingTalentSuccessionNominationType? value,
  ) {
    if (value == null) return 'Select nomination type';
    return null;
  }

  static String? validateStatus(
    IncomingTalentSuccessionNominationStatus? value,
  ) {
    if (value == null) return 'Select nomination status';
    return null;
  }

  static String? validateReadiness(IncomingTalentSuccessionReadiness? value) {
    if (value == null) return 'Select readiness';
    return null;
  }

  static String? validateRisk(IncomingTalentSuccessionRisk? value) {
    if (value == null) return 'Select risk';
    return null;
  }

  static String? validateNominationDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select nomination date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Nomination date cannot be in the past';
    }
    return null;
  }

  static String? validatePanelDate(
    DateTime? nominationDate,
    DateTime? panelDate,
  ) {
    if (panelDate == null) return 'Select panel date';
    if (nominationDate == null) return null;
    if (_dateOnly(panelDate).isBefore(_dateOnly(nominationDate))) {
      return 'Panel date cannot be before nomination date';
    }
    return null;
  }

  static String? validateBusinessCase(String? value) {
    return _validateLongText(value, 'business case');
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateSuccessPlan(String? value) {
    return _validateLongText(value, 'success plan');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionNominationType _nominationType(
  IncomingTalentSuccessionReadiness readiness,
) {
  return switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow =>
      IncomingTalentSuccessionNominationType.promotion,
    IncomingTalentSuccessionReadiness.readySoon =>
      IncomingTalentSuccessionNominationType.sponsorTrack,
    IncomingTalentSuccessionReadiness.developing =>
      IncomingTalentSuccessionNominationType.stretchAssignment,
    IncomingTalentSuccessionReadiness.blocked =>
      IncomingTalentSuccessionNominationType.successionBench,
  };
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionNominationDraft.validateRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
