import 'employee_directory_models.dart';

enum EmployeeManagementHealth {
  healthy('Healthy'),
  review('Review'),
  actionRequired('Action required');

  final String label;

  const EmployeeManagementHealth(this.label);
}

enum EmployeeLifecycleEventType {
  hire('Hire'),
  roleChange('Role change'),
  performance('Performance'),
  compliance('Compliance'),
  onboarding('Onboarding');

  final String label;

  const EmployeeLifecycleEventType(this.label);
}

enum EmployeeRecordItemStatus {
  complete('Complete'),
  pending('Pending'),
  overdue('Overdue'),
  missing('Missing'),
  active('Active'),
  provisioning('Provisioning');

  final String label;

  const EmployeeRecordItemStatus(this.label);
}

class EmployeeLifecycleEvent {
  final String id;
  final EmployeeLifecycleEventType type;
  final String title;
  final String detail;
  final DateTime date;

  const EmployeeLifecycleEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.date,
  });
}

class EmployeeComplianceDocument {
  final String id;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeeRecordItemStatus status;

  const EmployeeComplianceDocument({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
  });

  bool get needsAttention {
    return status == EmployeeRecordItemStatus.pending ||
        status == EmployeeRecordItemStatus.overdue ||
        status == EmployeeRecordItemStatus.missing;
  }
}

class EmployeeAssetAssignment {
  final String id;
  final String name;
  final String owner;
  final EmployeeRecordItemStatus status;

  const EmployeeAssetAssignment({
    required this.id,
    required this.name,
    required this.owner,
    required this.status,
  });

  bool get isPending => status == EmployeeRecordItemStatus.provisioning;
}

class EmployeeManagementSnapshot {
  final EmployeeDirectoryMember member;
  final DateTime asOfDate;
  final EmployeeManagementHealth health;
  final int readinessScore;
  final String payrollGroup;
  final String employmentType;
  final String jobLevel;
  final String costCenter;
  final String nextAction;
  final List<EmployeeLifecycleEvent> lifecycle;
  final List<EmployeeComplianceDocument> documents;
  final List<EmployeeAssetAssignment> assets;

  const EmployeeManagementSnapshot({
    required this.member,
    required this.asOfDate,
    required this.health,
    required this.readinessScore,
    required this.payrollGroup,
    required this.employmentType,
    required this.jobLevel,
    required this.costCenter,
    required this.nextAction,
    required this.lifecycle,
    required this.documents,
    required this.assets,
  });

  int get documentAttentionCount {
    return documents.where((document) => document.needsAttention).length;
  }

  int get overdueDocumentCount {
    return documents
        .where(
          (document) => document.status == EmployeeRecordItemStatus.overdue,
        )
        .length;
  }

  int get missingDocumentCount {
    return documents
        .where(
          (document) => document.status == EmployeeRecordItemStatus.missing,
        )
        .length;
  }

  int get pendingAssetCount {
    return assets.where((asset) => asset.isPending).length;
  }

  int get activeAssetCount {
    return assets
        .where((asset) => asset.status == EmployeeRecordItemStatus.active)
        .length;
  }

  EmployeeLifecycleEvent? get latestEvent {
    if (lifecycle.isEmpty) return null;
    return lifecycle.first;
  }
}

class EmployeeManagementDirectorySummary {
  final int employeeCount;
  final int healthyCount;
  final int reviewCount;
  final int actionRequiredCount;
  final int documentAttentionCount;
  final int pendingAssetCount;
  final int onboardingCount;
  final String nextAction;

  const EmployeeManagementDirectorySummary({
    required this.employeeCount,
    required this.healthyCount,
    required this.reviewCount,
    required this.actionRequiredCount,
    required this.documentAttentionCount,
    required this.pendingAssetCount,
    required this.onboardingCount,
    required this.nextAction,
  });

  factory EmployeeManagementDirectorySummary.fromSnapshots(
    List<EmployeeManagementSnapshot> snapshots,
  ) {
    final actionRequiredCount =
        snapshots
            .where(
              (snapshot) =>
                  snapshot.health == EmployeeManagementHealth.actionRequired,
            )
            .length;
    final reviewCount =
        snapshots
            .where(
              (snapshot) => snapshot.health == EmployeeManagementHealth.review,
            )
            .length;

    return EmployeeManagementDirectorySummary(
      employeeCount: snapshots.length,
      healthyCount:
          snapshots
              .where(
                (snapshot) =>
                    snapshot.health == EmployeeManagementHealth.healthy,
              )
              .length,
      reviewCount: reviewCount,
      actionRequiredCount: actionRequiredCount,
      documentAttentionCount: snapshots.fold<int>(
        0,
        (total, snapshot) => total + snapshot.documentAttentionCount,
      ),
      pendingAssetCount: snapshots.fold<int>(
        0,
        (total, snapshot) => total + snapshot.pendingAssetCount,
      ),
      onboardingCount:
          snapshots
              .where(
                (snapshot) =>
                    snapshot.member.status ==
                    EmployeeDirectoryStatus.onboarding,
              )
              .length,
      nextAction: _directoryNextAction(
        actionRequiredCount: actionRequiredCount,
        reviewCount: reviewCount,
      ),
    );
  }
}

String _directoryNextAction({
  required int actionRequiredCount,
  required int reviewCount,
}) {
  if (actionRequiredCount > 0) {
    return 'Resolve $actionRequiredCount employee records needing action.';
  }
  if (reviewCount > 0) {
    return 'Review $reviewCount employee records before payroll cutoff.';
  }
  return 'Employee records are ready for the next payroll cycle.';
}
