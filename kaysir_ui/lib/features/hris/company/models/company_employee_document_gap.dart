import 'company_document_requirement.dart';

enum CompanyEmployeeDocumentGapStatus {
  missing,
  requested,
  blocked,
  complete,
  waived,
}

enum CompanyEmployeeDocumentGapIssue {
  missingRequirement,
  missingOwner,
  insufficientVerifiedDocuments,
  rejectedEvidence,
  noOpenRequest,
  dueSoon,
  overdue,
}

extension CompanyEmployeeDocumentGapStatusLabels
    on CompanyEmployeeDocumentGapStatus {
  String get label {
    switch (this) {
      case CompanyEmployeeDocumentGapStatus.missing:
        return 'Missing';
      case CompanyEmployeeDocumentGapStatus.requested:
        return 'Requested';
      case CompanyEmployeeDocumentGapStatus.blocked:
        return 'Blocked';
      case CompanyEmployeeDocumentGapStatus.complete:
        return 'Complete';
      case CompanyEmployeeDocumentGapStatus.waived:
        return 'Waived';
    }
  }
}

extension CompanyEmployeeDocumentGapIssueLabels
    on CompanyEmployeeDocumentGapIssue {
  String get label {
    switch (this) {
      case CompanyEmployeeDocumentGapIssue.missingRequirement:
        return 'No matching requirement';
      case CompanyEmployeeDocumentGapIssue.missingOwner:
        return 'Assign owner';
      case CompanyEmployeeDocumentGapIssue.insufficientVerifiedDocuments:
        return 'Missing verified evidence';
      case CompanyEmployeeDocumentGapIssue.rejectedEvidence:
        return 'Rejected evidence';
      case CompanyEmployeeDocumentGapIssue.noOpenRequest:
        return 'Generate request';
      case CompanyEmployeeDocumentGapIssue.dueSoon:
        return 'Due soon';
      case CompanyEmployeeDocumentGapIssue.overdue:
        return 'Overdue';
    }
  }
}

class CompanyEmployeeDocumentSubject {
  final String id;
  final String employeeId;
  final String employeeName;
  final String entityName;
  final String jobProfileCode;
  final CompanyDocumentRequirementStage stage;
  final String ownerName;
  final DateTime dueDate;

  const CompanyEmployeeDocumentSubject({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.entityName,
    required this.jobProfileCode,
    required this.stage,
    required this.ownerName,
    required this.dueDate,
  });
}

class CompanyEmployeeDocumentEvidenceSnapshot {
  final String employeeId;
  final int verifiedDocumentCount;
  final int pendingDocumentCount;
  final int rejectedDocumentCount;
  final int openRequestCount;

  const CompanyEmployeeDocumentEvidenceSnapshot({
    required this.employeeId,
    required this.verifiedDocumentCount,
    required this.pendingDocumentCount,
    required this.rejectedDocumentCount,
    required this.openRequestCount,
  });
}

class CompanyEmployeeDocumentGap {
  final String id;
  final String employeeId;
  final String employeeName;
  final String entityName;
  final String jobProfileCode;
  final CompanyDocumentRequirementStage stage;
  final String requirementId;
  final String requirementName;
  final String ownerName;
  final DateTime dueDate;
  final int requiredDocumentCount;
  final int verifiedDocumentCount;
  final int pendingDocumentCount;
  final int rejectedDocumentCount;
  final int openRequestCount;
  final CompanyEmployeeDocumentGapStatus status;

  const CompanyEmployeeDocumentGap({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.entityName,
    required this.jobProfileCode,
    required this.stage,
    required this.requirementId,
    required this.requirementName,
    required this.ownerName,
    required this.dueDate,
    required this.requiredDocumentCount,
    required this.verifiedDocumentCount,
    required this.pendingDocumentCount,
    required this.rejectedDocumentCount,
    required this.openRequestCount,
    required this.status,
  });

  int get missingDocumentCount {
    final missing = requiredDocumentCount - verifiedDocumentCount;
    return missing < 0 ? 0 : missing;
  }

  double get coverageRatio {
    if (requiredDocumentCount <= 0) return 0;
    return (verifiedDocumentCount / requiredDocumentCount).clamp(0, 1);
  }

  int daysUntilDue(DateTime asOfDate) {
    return _dateOnly(dueDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyEmployeeDocumentGapIssue> issues(DateTime asOfDate) {
    if (status == CompanyEmployeeDocumentGapStatus.complete ||
        status == CompanyEmployeeDocumentGapStatus.waived) {
      return const [];
    }

    final days = daysUntilDue(asOfDate);
    return [
      if (requirementId.trim().isEmpty)
        CompanyEmployeeDocumentGapIssue.missingRequirement,
      if (ownerName.trim().isEmpty)
        CompanyEmployeeDocumentGapIssue.missingOwner,
      if (missingDocumentCount > 0)
        CompanyEmployeeDocumentGapIssue.insufficientVerifiedDocuments,
      if (rejectedDocumentCount > 0)
        CompanyEmployeeDocumentGapIssue.rejectedEvidence,
      if (openRequestCount <= 0 && missingDocumentCount > 0)
        CompanyEmployeeDocumentGapIssue.noOpenRequest,
      if (days < 0) CompanyEmployeeDocumentGapIssue.overdue,
      if (days >= 0 && days <= 14) CompanyEmployeeDocumentGapIssue.dueSoon,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyEmployeeDocumentGap copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? entityName,
    String? jobProfileCode,
    CompanyDocumentRequirementStage? stage,
    String? requirementId,
    String? requirementName,
    String? ownerName,
    DateTime? dueDate,
    int? requiredDocumentCount,
    int? verifiedDocumentCount,
    int? pendingDocumentCount,
    int? rejectedDocumentCount,
    int? openRequestCount,
    CompanyEmployeeDocumentGapStatus? status,
  }) {
    return CompanyEmployeeDocumentGap(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      entityName: entityName ?? this.entityName,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      stage: stage ?? this.stage,
      requirementId: requirementId ?? this.requirementId,
      requirementName: requirementName ?? this.requirementName,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      requiredDocumentCount:
          requiredDocumentCount ?? this.requiredDocumentCount,
      verifiedDocumentCount:
          verifiedDocumentCount ?? this.verifiedDocumentCount,
      pendingDocumentCount: pendingDocumentCount ?? this.pendingDocumentCount,
      rejectedDocumentCount:
          rejectedDocumentCount ?? this.rejectedDocumentCount,
      openRequestCount: openRequestCount ?? this.openRequestCount,
      status: status ?? this.status,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

List<CompanyEmployeeDocumentGap> buildCompanyEmployeeDocumentGaps({
  required List<CompanyEmployeeDocumentSubject> subjects,
  required List<CompanyDocumentRequirement> requirements,
  required List<CompanyEmployeeDocumentEvidenceSnapshot> evidenceSnapshots,
  required DateTime asOfDate,
}) {
  return [
    for (final subject in subjects)
      _buildGap(
        subject: subject,
        requirement: _matchingRequirement(subject, requirements),
        evidence: _evidenceFor(subject.employeeId, evidenceSnapshots),
        asOfDate: asOfDate,
      ),
  ];
}

CompanyEmployeeDocumentGap _buildGap({
  required CompanyEmployeeDocumentSubject subject,
  required CompanyDocumentRequirement? requirement,
  required CompanyEmployeeDocumentEvidenceSnapshot evidence,
  required DateTime asOfDate,
}) {
  final requiredCount = requirement?.requiredDocumentCount ?? 0;
  final missingCount = requiredCount - evidence.verifiedDocumentCount;
  final status =
      missingCount <= 0 && requirement != null
          ? CompanyEmployeeDocumentGapStatus.complete
          : evidence.rejectedDocumentCount > 0 ||
              subject.dueDate.isBefore(asOfDate)
          ? CompanyEmployeeDocumentGapStatus.blocked
          : evidence.openRequestCount > 0
          ? CompanyEmployeeDocumentGapStatus.requested
          : CompanyEmployeeDocumentGapStatus.missing;

  return CompanyEmployeeDocumentGap(
    id: subject.id,
    employeeId: subject.employeeId,
    employeeName: subject.employeeName,
    entityName: subject.entityName,
    jobProfileCode: subject.jobProfileCode,
    stage: subject.stage,
    requirementId: requirement?.id ?? '',
    requirementName: requirement?.requirementName ?? 'Unmapped requirement',
    ownerName:
        subject.ownerName.trim().isEmpty
            ? requirement?.ownerName ?? ''
            : subject.ownerName,
    dueDate: subject.dueDate,
    requiredDocumentCount: requiredCount,
    verifiedDocumentCount: evidence.verifiedDocumentCount,
    pendingDocumentCount: evidence.pendingDocumentCount,
    rejectedDocumentCount: evidence.rejectedDocumentCount,
    openRequestCount: evidence.openRequestCount,
    status: status,
  );
}

CompanyDocumentRequirement? _matchingRequirement(
  CompanyEmployeeDocumentSubject subject,
  List<CompanyDocumentRequirement> requirements,
) {
  for (final requirement in requirements) {
    if (requirement.entityName == subject.entityName &&
        requirement.jobProfileCode == subject.jobProfileCode &&
        requirement.stage == subject.stage) {
      return requirement;
    }
  }
  return null;
}

CompanyEmployeeDocumentEvidenceSnapshot _evidenceFor(
  String employeeId,
  List<CompanyEmployeeDocumentEvidenceSnapshot> snapshots,
) {
  for (final snapshot in snapshots) {
    if (snapshot.employeeId == employeeId) return snapshot;
  }
  return CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: employeeId,
    verifiedDocumentCount: 0,
    pendingDocumentCount: 0,
    rejectedDocumentCount: 0,
    openRequestCount: 0,
  );
}
