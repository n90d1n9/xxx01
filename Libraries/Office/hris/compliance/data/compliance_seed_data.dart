import '../models/compliance_models.dart';

List<ComplianceControl> buildComplianceControls(DateTime asOfDate) {
  return [
    ComplianceControl(
      id: 'ctrl-001',
      controlName: 'Payroll approval evidence',
      department: 'Finance',
      ownerName: 'Emma Rodriguez',
      completionRate: 91,
      dueDate: asOfDate.add(const Duration(days: 5)),
      status: ComplianceControlStatus.dueSoon,
    ),
    ComplianceControl(
      id: 'ctrl-002',
      controlName: 'Store safety checklist',
      department: 'Operations',
      ownerName: 'David Kim',
      completionRate: 72,
      dueDate: asOfDate.subtract(const Duration(days: 2)),
      status: ComplianceControlStatus.overdue,
    ),
    ComplianceControl(
      id: 'ctrl-003',
      controlName: 'Access review attestation',
      department: 'Engineering',
      ownerName: 'Alya Saputra',
      completionRate: 64,
      dueDate: asOfDate.add(const Duration(days: 3)),
      status: ComplianceControlStatus.blocked,
    ),
    ComplianceControl(
      id: 'ctrl-004',
      controlName: 'Design asset license audit',
      department: 'Design',
      ownerName: 'Sarah Johnson',
      completionRate: 100,
      dueDate: asOfDate.add(const Duration(days: 12)),
      status: ComplianceControlStatus.compliant,
    ),
  ];
}

List<PolicyAcknowledgement> buildPolicyAcknowledgements(DateTime asOfDate) {
  return [
    PolicyAcknowledgement(
      id: 'pol-001',
      policyName: 'Anti-harassment refresh',
      audience: 'All employees',
      department: 'All',
      requiredCount: 180,
      completedCount: 142,
      deadline: asOfDate.add(const Duration(days: 7)),
      status: PolicyAcknowledgementStatus.inProgress,
    ),
    PolicyAcknowledgement(
      id: 'pol-002',
      policyName: 'Shift safety procedures',
      audience: 'Operations floor teams',
      department: 'Operations',
      requiredCount: 88,
      completedCount: 61,
      deadline: asOfDate.add(const Duration(days: 2)),
      status: PolicyAcknowledgementStatus.escalated,
    ),
    PolicyAcknowledgement(
      id: 'pol-003',
      policyName: 'Secure development policy',
      audience: 'Engineering',
      department: 'Engineering',
      requiredCount: 40,
      completedCount: 40,
      deadline: asOfDate.add(const Duration(days: 18)),
      status: PolicyAcknowledgementStatus.complete,
    ),
    PolicyAcknowledgement(
      id: 'pol-004',
      policyName: 'Vendor confidentiality update',
      audience: 'Finance and Design',
      department: 'Finance',
      requiredCount: 42,
      completedCount: 9,
      deadline: asOfDate.add(const Duration(days: 21)),
      status: PolicyAcknowledgementStatus.draft,
    ),
  ];
}

List<ComplianceDocument> buildComplianceDocuments(DateTime asOfDate) {
  return [
    ComplianceDocument(
      id: 'doc-001',
      employeeName: 'Rizky Pratama',
      department: 'Operations',
      documentType: 'Forklift certification',
      expiresAt: asOfDate.add(const Duration(days: 9)),
      risk: DocumentExpiryRisk.high,
    ),
    ComplianceDocument(
      id: 'doc-002',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      documentType: 'Security access approval',
      expiresAt: asOfDate.add(const Duration(days: 23)),
      risk: DocumentExpiryRisk.medium,
    ),
    ComplianceDocument(
      id: 'doc-003',
      employeeName: 'Anisa Putri',
      department: 'Finance',
      documentType: 'Tax handler certification',
      expiresAt: asOfDate.add(const Duration(days: 34)),
      risk: DocumentExpiryRisk.medium,
    ),
    ComplianceDocument(
      id: 'doc-004',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      documentType: 'NDA acknowledgement',
      expiresAt: asOfDate.add(const Duration(days: 68)),
      risk: DocumentExpiryRisk.low,
    ),
  ];
}

List<AuditFinding> buildAuditFindings(DateTime asOfDate) {
  return [
    AuditFinding(
      id: 'aud-001',
      title: 'Missing overtime approval trail',
      department: 'Operations',
      ownerName: 'David Kim',
      remediation: 'Attach manager approval evidence to closed payroll cycle.',
      dueDate: asOfDate.add(const Duration(days: 6)),
      severity: AuditFindingSeverity.critical,
      status: AuditFindingStatus.remediating,
    ),
    AuditFinding(
      id: 'aud-002',
      title: 'Terminated user access delay',
      department: 'Engineering',
      ownerName: 'Alya Saputra',
      remediation: 'Automate deprovision ticket creation from HRIS events.',
      dueDate: asOfDate.add(const Duration(days: 11)),
      severity: AuditFindingSeverity.high,
      status: AuditFindingStatus.open,
    ),
    AuditFinding(
      id: 'aud-003',
      title: 'Incomplete vendor conflict review',
      department: 'Finance',
      ownerName: 'Emma Rodriguez',
      remediation: 'Collect conflict attestations from two approvers.',
      dueDate: asOfDate.add(const Duration(days: 16)),
      severity: AuditFindingSeverity.medium,
      status: AuditFindingStatus.open,
    ),
    AuditFinding(
      id: 'aud-004',
      title: 'Creative asset retention exception',
      department: 'Design',
      ownerName: 'Sarah Johnson',
      remediation: 'Exception approved and logged for legal retention window.',
      dueDate: asOfDate.subtract(const Duration(days: 4)),
      severity: AuditFindingSeverity.low,
      status: AuditFindingStatus.waived,
    ),
  ];
}
