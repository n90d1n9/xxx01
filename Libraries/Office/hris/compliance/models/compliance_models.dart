enum ComplianceControlStatus { compliant, dueSoon, overdue, blocked }

enum PolicyAcknowledgementStatus { draft, inProgress, complete, escalated }

enum DocumentExpiryRisk { low, medium, high }

enum AuditFindingSeverity { low, medium, high, critical }

enum AuditFindingStatus { open, remediating, verified, waived }

class ComplianceControl {
  final String id;
  final String controlName;
  final String department;
  final String ownerName;
  final int completionRate;
  final DateTime dueDate;
  final ComplianceControlStatus status;

  const ComplianceControl({
    required this.id,
    required this.controlName,
    required this.department,
    required this.ownerName,
    required this.completionRate,
    required this.dueDate,
    required this.status,
  });
}

class PolicyAcknowledgement {
  final String id;
  final String policyName;
  final String audience;
  final String department;
  final int requiredCount;
  final int completedCount;
  final DateTime deadline;
  final PolicyAcknowledgementStatus status;

  const PolicyAcknowledgement({
    required this.id,
    required this.policyName,
    required this.audience,
    required this.department,
    required this.requiredCount,
    required this.completedCount,
    required this.deadline,
    required this.status,
  });

  int get pendingCount {
    final value = requiredCount - completedCount;
    return value < 0 ? 0 : value;
  }

  double get completionRate =>
      requiredCount == 0 ? 0 : completedCount / requiredCount;
}

class ComplianceDocument {
  final String id;
  final String employeeName;
  final String department;
  final String documentType;
  final DateTime expiresAt;
  final DocumentExpiryRisk risk;

  const ComplianceDocument({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.documentType,
    required this.expiresAt,
    required this.risk,
  });
}

class AuditFinding {
  final String id;
  final String title;
  final String department;
  final String ownerName;
  final String remediation;
  final DateTime dueDate;
  final AuditFindingSeverity severity;
  final AuditFindingStatus status;

  const AuditFinding({
    required this.id,
    required this.title,
    required this.department,
    required this.ownerName,
    required this.remediation,
    required this.dueDate,
    required this.severity,
    required this.status,
  });
}

class ComplianceSummary {
  final int controlsDue;
  final int overdueControls;
  final int pendingAcknowledgements;
  final int documentRisks;
  final int openFindings;
  final int criticalFindings;

  const ComplianceSummary({
    required this.controlsDue,
    required this.overdueControls,
    required this.pendingAcknowledgements,
    required this.documentRisks,
    required this.openFindings,
    required this.criticalFindings,
  });
}

class ComplianceEscalationSummary {
  final int blockedControls;
  final int escalatedPolicies;
  final int highRiskDocuments;
  final int criticalFindings;
  final int dueWithinSevenDays;

  const ComplianceEscalationSummary({
    required this.blockedControls,
    required this.escalatedPolicies,
    required this.highRiskDocuments,
    required this.criticalFindings,
    required this.dueWithinSevenDays,
  });

  int get totalEscalations =>
      blockedControls +
      escalatedPolicies +
      highRiskDocuments +
      criticalFindings;

  factory ComplianceEscalationSummary.fromData({
    required List<ComplianceControl> controls,
    required List<PolicyAcknowledgement> policies,
    required List<ComplianceDocument> documents,
    required List<AuditFinding> findings,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 7));

    return ComplianceEscalationSummary(
      blockedControls:
          controls
              .where((item) => item.status == ComplianceControlStatus.blocked)
              .length,
      escalatedPolicies:
          policies
              .where(
                (item) => item.status == PolicyAcknowledgementStatus.escalated,
              )
              .length,
      highRiskDocuments:
          documents
              .where((item) => item.risk == DocumentExpiryRisk.high)
              .length,
      criticalFindings:
          findings
              .where((item) => item.severity == AuditFindingSeverity.critical)
              .length,
      dueWithinSevenDays:
          controls.where((item) => !item.dueDate.isAfter(dueThreshold)).length +
          policies
              .where((item) => !item.deadline.isAfter(dueThreshold))
              .length +
          documents
              .where((item) => !item.expiresAt.isAfter(dueThreshold))
              .length +
          findings.where((item) => !item.dueDate.isAfter(dueThreshold)).length,
    );
  }
}
