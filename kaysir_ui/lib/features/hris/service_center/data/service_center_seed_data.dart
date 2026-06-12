import '../models/service_center_models.dart';

List<ServiceDeskCase> buildServiceDeskCases(DateTime asOfDate) {
  return [
    ServiceDeskCase(
      id: 'case-001',
      requesterName: 'Rizky Pratama',
      category: 'Payroll',
      subject: 'Overtime allowance mismatch',
      assignedTo: 'Anisa Putri',
      createdAt: asOfDate.subtract(const Duration(hours: 7)),
      dueAt: asOfDate.add(const Duration(hours: 5)),
      priority: ServiceCasePriority.urgent,
      status: ServiceCaseStatus.inProgress,
    ),
    ServiceDeskCase(
      id: 'case-002',
      requesterName: 'Nadia Rahman',
      category: 'Benefits',
      subject: 'Medical reimbursement eligibility',
      assignedTo: 'Emma Rodriguez',
      createdAt: asOfDate.subtract(const Duration(hours: 20)),
      dueAt: asOfDate.add(const Duration(hours: 17)),
      priority: ServiceCasePriority.medium,
      status: ServiceCaseStatus.waiting,
    ),
    ServiceDeskCase(
      id: 'case-003',
      requesterName: 'Michael Chen',
      category: 'Access',
      subject: 'Need HRIS approver permission',
      assignedTo: 'Alya Saputra',
      createdAt: asOfDate.subtract(const Duration(hours: 2)),
      dueAt: asOfDate.add(const Duration(hours: 22)),
      priority: ServiceCasePriority.high,
      status: ServiceCaseStatus.newCase,
    ),
    ServiceDeskCase(
      id: 'case-004',
      requesterName: 'Casey Johnson',
      category: 'Policy',
      subject: 'Clarify replacement leave rule',
      assignedTo: 'People Support',
      createdAt: asOfDate.subtract(const Duration(days: 3)),
      dueAt: asOfDate.subtract(const Duration(hours: 4)),
      priority: ServiceCasePriority.high,
      status: ServiceCaseStatus.inProgress,
    ),
  ];
}

List<DocumentRequest> buildDocumentRequests(DateTime asOfDate) {
  return [
    DocumentRequest(
      id: 'doc-001',
      employeeName: 'Sarah Johnson',
      documentType: 'Employment verification',
      purpose: 'Mortgage application',
      owner: 'People Support',
      requestedAt: asOfDate.subtract(const Duration(days: 1)),
      neededBy: asOfDate.add(const Duration(days: 1)),
      status: DocumentRequestStatus.pendingApproval,
    ),
    DocumentRequest(
      id: 'doc-002',
      employeeName: 'David Kim',
      documentType: 'Salary statement',
      purpose: 'Visa extension',
      owner: 'Finance Ops',
      requestedAt: asOfDate.subtract(const Duration(hours: 8)),
      neededBy: asOfDate.add(const Duration(days: 3)),
      status: DocumentRequestStatus.ready,
    ),
    DocumentRequest(
      id: 'doc-003',
      employeeName: 'Olivia Wilson',
      documentType: 'Tax slip copy',
      purpose: 'Annual filing',
      owner: 'Payroll Team',
      requestedAt: asOfDate.subtract(const Duration(days: 4)),
      neededBy: asOfDate.add(const Duration(days: 5)),
      status: DocumentRequestStatus.delivered,
    ),
    DocumentRequest(
      id: 'doc-004',
      employeeName: 'Rizky Pratama',
      documentType: 'Contract addendum',
      purpose: 'Role transfer',
      owner: 'HR Operations',
      requestedAt: asOfDate.subtract(const Duration(hours: 3)),
      neededBy: asOfDate.add(const Duration(days: 2)),
      status: DocumentRequestStatus.draft,
    ),
  ];
}

const servicePolicyArticles = [
  PolicyArticle(
    id: 'kb-001',
    title: 'Leave and replacement day policy',
    category: 'Policy',
    summary: 'Rules for annual leave, sick leave, and replacement days.',
    views: 420,
    helpfulVotes: 362,
    type: PolicyArticleType.policy,
  ),
  PolicyArticle(
    id: 'kb-002',
    title: 'Payroll correction request guide',
    category: 'Payroll',
    summary:
        'How employees submit payroll disputes and missing allowance cases.',
    views: 318,
    helpfulVotes: 241,
    type: PolicyArticleType.guide,
  ),
  PolicyArticle(
    id: 'kb-003',
    title: 'Benefits reimbursement FAQ',
    category: 'Benefits',
    summary: 'Common questions about medical and wellbeing reimbursement.',
    views: 276,
    helpfulVotes: 230,
    type: PolicyArticleType.faq,
  ),
  PolicyArticle(
    id: 'kb-004',
    title: 'HRIS account access checklist',
    category: 'Access',
    summary: 'Approver access, role changes, and access recertification steps.',
    views: 198,
    helpfulVotes: 151,
    type: PolicyArticleType.guide,
  ),
];

List<ServiceAnnouncement> buildServiceAnnouncements(DateTime asOfDate) {
  return [
    ServiceAnnouncement(
      id: 'ann-001',
      title: 'Payroll cutoff reminder',
      audience: 'All employees',
      message: 'Submit allowance corrections before Friday 15:00.',
      publishAt: asOfDate.add(const Duration(hours: 3)),
      tone: AnnouncementTone.warning,
    ),
    ServiceAnnouncement(
      id: 'ann-002',
      title: 'Benefits claim window extended',
      audience: 'Operations team',
      message: 'Q2 medical claims can be uploaded through next Wednesday.',
      publishAt: asOfDate.add(const Duration(days: 1)),
      tone: AnnouncementTone.success,
    ),
    ServiceAnnouncement(
      id: 'ann-003',
      title: 'HRIS maintenance',
      audience: 'Managers',
      message:
          'Approval screens will be read-only during Saturday maintenance.',
      publishAt: asOfDate.add(const Duration(days: 2)),
      tone: AnnouncementTone.info,
    ),
  ];
}
