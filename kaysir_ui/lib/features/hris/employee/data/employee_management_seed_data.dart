import '../models/employee_directory_models.dart';
import '../models/employee_management_models.dart';

EmployeeManagementSnapshot buildEmployeeManagementSnapshot({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final lifecycle = _buildLifecycle(member, asOfDate);
  final documents = _buildDocuments(member, asOfDate);
  final assets = _buildAssets(member);
  final readinessScore = _readinessScore(
    member: member,
    documents: documents,
    assets: assets,
  );

  return EmployeeManagementSnapshot(
    member: member,
    asOfDate: asOfDate,
    health: _health(member: member, documents: documents, assets: assets),
    readinessScore: readinessScore,
    payrollGroup: _payrollGroup(member),
    employmentType:
        member.status == EmployeeDirectoryStatus.onboarding
            ? 'Probationary'
            : 'Permanent',
    jobLevel: _jobLevel(member),
    costCenter: '${member.department.substring(0, 3).toUpperCase()}-001',
    nextAction: _nextAction(
      member: member,
      documents: documents,
      assets: assets,
    ),
    lifecycle: lifecycle,
    documents: documents,
    assets: assets,
  );
}

List<EmployeeLifecycleEvent> _buildLifecycle(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final events = [
    EmployeeLifecycleEvent(
      id: '${member.id}-role',
      type: EmployeeLifecycleEventType.roleChange,
      title: member.position,
      detail: '${member.department} assignment under ${member.manager}.',
      date: member.joiningDate.add(const Duration(days: 30)),
    ),
    EmployeeLifecycleEvent(
      id: '${member.id}-hire',
      type: EmployeeLifecycleEventType.hire,
      title: 'Employee hired',
      detail: '${member.location} employee record created.',
      date: member.joiningDate,
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    events.insert(
      0,
      EmployeeLifecycleEvent(
        id: '${member.id}-onboarding',
        type: EmployeeLifecycleEventType.onboarding,
        title: 'Onboarding checkpoint',
        detail: 'Complete new hire paperwork and access provisioning.',
        date: asOfDate.add(const Duration(days: 3)),
      ),
    );
  } else if (member.status == EmployeeDirectoryStatus.watchlist) {
    events.insert(
      0,
      EmployeeLifecycleEvent(
        id: '${member.id}-watchlist',
        type: EmployeeLifecycleEventType.performance,
        title: 'Manager follow-up required',
        detail: 'Performance trend needs documented manager coaching.',
        date: asOfDate.add(const Duration(days: 5)),
      ),
    );
  } else if (member.isHighPerformer) {
    events.insert(
      0,
      EmployeeLifecycleEvent(
        id: '${member.id}-growth',
        type: EmployeeLifecycleEventType.performance,
        title: 'Growth plan review',
        detail: 'Prepare retention and development plan for top talent.',
        date: asOfDate.add(const Duration(days: 14)),
      ),
    );
  }

  events.sort((a, b) => b.date.compareTo(a.date));
  return events;
}

List<EmployeeComplianceDocument> _buildDocuments(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final documents = [
    EmployeeComplianceDocument(
      id: '${member.id}-identity',
      title: 'Identity verification',
      owner: 'HR Operations',
      dueDate: member.joiningDate.add(const Duration(days: 3)),
      status: EmployeeRecordItemStatus.complete,
    ),
    EmployeeComplianceDocument(
      id: '${member.id}-agreement',
      title: 'Employment agreement',
      owner: 'People Operations',
      dueDate: member.joiningDate,
      status: EmployeeRecordItemStatus.complete,
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    documents.addAll([
      EmployeeComplianceDocument(
        id: '${member.id}-tax',
        title: 'Payroll tax documents',
        owner: 'Payroll',
        dueDate: asOfDate.subtract(const Duration(days: 1)),
        status: EmployeeRecordItemStatus.overdue,
      ),
      EmployeeComplianceDocument(
        id: '${member.id}-checklist',
        title: 'Onboarding checklist',
        owner: 'Hiring Manager',
        dueDate: asOfDate.add(const Duration(days: 3)),
        status: EmployeeRecordItemStatus.pending,
      ),
    ]);
  } else if (member.status == EmployeeDirectoryStatus.watchlist) {
    documents.addAll([
      EmployeeComplianceDocument(
        id: '${member.id}-coaching',
        title: 'Manager coaching notes',
        owner: member.manager,
        dueDate: asOfDate.add(const Duration(days: 5)),
        status: EmployeeRecordItemStatus.pending,
      ),
      EmployeeComplianceDocument(
        id: '${member.id}-pip',
        title: 'Performance improvement plan',
        owner: 'HR Business Partner',
        dueDate: asOfDate.add(const Duration(days: 7)),
        status: EmployeeRecordItemStatus.missing,
      ),
    ]);
  } else if (member.isHighPerformer) {
    documents.add(
      EmployeeComplianceDocument(
        id: '${member.id}-growth-plan',
        title: 'Growth and retention plan',
        owner: member.manager,
        dueDate: asOfDate.add(const Duration(days: 14)),
        status: EmployeeRecordItemStatus.pending,
      ),
    );
  }

  return documents;
}

List<EmployeeAssetAssignment> _buildAssets(EmployeeDirectoryMember member) {
  final assets = [
    EmployeeAssetAssignment(
      id: '${member.id}-laptop',
      name: 'Work laptop',
      owner: 'IT Operations',
      status:
          member.status == EmployeeDirectoryStatus.onboarding
              ? EmployeeRecordItemStatus.provisioning
              : EmployeeRecordItemStatus.active,
    ),
    EmployeeAssetAssignment(
      id: '${member.id}-badge',
      name: 'Access badge',
      owner: 'Facilities',
      status: EmployeeRecordItemStatus.active,
    ),
  ];

  if (member.department == 'Engineering') {
    assets.add(
      EmployeeAssetAssignment(
        id: '${member.id}-repo-access',
        name: 'Source repository access',
        owner: 'Engineering Operations',
        status: EmployeeRecordItemStatus.active,
      ),
    );
  }

  return assets;
}

EmployeeManagementHealth _health({
  required EmployeeDirectoryMember member,
  required List<EmployeeComplianceDocument> documents,
  required List<EmployeeAssetAssignment> assets,
}) {
  final hasBlockingDocument = documents.any(
    (document) =>
        document.status == EmployeeRecordItemStatus.overdue ||
        document.status == EmployeeRecordItemStatus.missing,
  );
  if (hasBlockingDocument ||
      member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeManagementHealth.actionRequired;
  }
  if (documents.any((document) => document.needsAttention) ||
      assets.any((asset) => asset.isPending) ||
      member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeManagementHealth.review;
  }
  return EmployeeManagementHealth.healthy;
}

int _readinessScore({
  required EmployeeDirectoryMember member,
  required List<EmployeeComplianceDocument> documents,
  required List<EmployeeAssetAssignment> assets,
}) {
  final documentAttentionCount =
      documents.where((document) => document.needsAttention).length;
  final overdueCount =
      documents
          .where(
            (document) => document.status == EmployeeRecordItemStatus.overdue,
          )
          .length;
  final missingCount =
      documents
          .where(
            (document) => document.status == EmployeeRecordItemStatus.missing,
          )
          .length;
  final pendingAssetCount = assets.where((asset) => asset.isPending).length;

  final score =
      100 -
      (documentAttentionCount * 12) -
      (overdueCount * 18) -
      (missingCount * 18) -
      (pendingAssetCount * 8) -
      (member.status == EmployeeDirectoryStatus.watchlist ? 10 : 0) -
      (member.status == EmployeeDirectoryStatus.onboarding ? 6 : 0);
  return score.clamp(0, 100).toInt();
}

String _nextAction({
  required EmployeeDirectoryMember member,
  required List<EmployeeComplianceDocument> documents,
  required List<EmployeeAssetAssignment> assets,
}) {
  if (documents.any(
    (document) => document.status == EmployeeRecordItemStatus.overdue,
  )) {
    return 'Resolve overdue employee documents.';
  }
  if (documents.any(
    (document) => document.status == EmployeeRecordItemStatus.missing,
  )) {
    return 'Complete missing employee documents.';
  }
  if (assets.any((asset) => asset.isPending)) {
    return 'Complete access and asset provisioning.';
  }
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return 'Schedule manager check-in and coaching record.';
  }
  if (member.isHighPerformer) {
    return 'Prepare retention and growth plan.';
  }
  return 'Keep employee record ready for payroll.';
}

String _payrollGroup(EmployeeDirectoryMember member) {
  return switch (member.location) {
    'Singapore' => 'SG-Monthly',
    'Jakarta' || 'Bandung' || 'Surabaya' => 'ID-Monthly',
    _ => 'Global-Monthly',
  };
}

String _jobLevel(EmployeeDirectoryMember member) {
  if (member.position.toLowerCase().contains('senior')) return 'L4';
  if (member.position.toLowerCase().contains('manager')) return 'M2';
  if (member.status == EmployeeDirectoryStatus.onboarding) return 'L1';
  return 'L3';
}
