import 'employee_document_escalation_plan.dart';

/// Aggregated preview for a batch employee document owner escalation.
class EmployeeDocumentEscalationPreview {
  final List<EmployeeDocumentEscalationPreviewOwner> owners;

  const EmployeeDocumentEscalationPreview({required this.owners});

  bool get isEmpty => owners.isEmpty;

  int get ownerCount => owners.length;

  int get criticalCount {
    return owners
        .where(
          (owner) =>
              owner.plan.priority ==
              EmployeeDocumentEscalationPriority.critical,
        )
        .length;
  }

  int get gapCount =>
      owners.fold(0, (total, owner) => total + owner.plan.gapCount);

  int get missingDocumentCount {
    return owners.fold(
      0,
      (total, owner) => total + owner.plan.missingDocumentCount,
    );
  }

  int get openRequestCount {
    return owners.fold(
      0,
      (total, owner) => total + owner.plan.openRequestCount,
    );
  }

  List<String> get ownerNames => [
    for (final owner in owners) owner.plan.ownerName,
  ];
}

/// Owner-level escalation preview row with risk and freshness context.
class EmployeeDocumentEscalationPreviewOwner {
  final EmployeeDocumentEscalationPlan plan;

  const EmployeeDocumentEscalationPreviewOwner({required this.plan});

  String get actionSummary {
    if (plan.primaryEmployeeName.trim().isEmpty) {
      return '${plan.actionLabel}, ${plan.workloadScore} workload score';
    }
    return '${plan.actionLabel} for ${plan.primaryEmployeeName}';
  }
}

/// Builds a deduplicated escalation preview from selected owner names.
EmployeeDocumentEscalationPreview buildEmployeeDocumentEscalationPreview({
  required Iterable<String> ownerNames,
  required List<EmployeeDocumentEscalationPlan> plans,
  bool includeCoolingDown = false,
}) {
  final plansByOwner = {
    for (final plan in plans) _ownerKey(plan.ownerName): plan,
  };
  final seenOwners = <String>{};
  final owners = <EmployeeDocumentEscalationPreviewOwner>[];

  for (final ownerName in ownerNames) {
    final key = _ownerKey(ownerName);
    if (!seenOwners.add(key)) continue;

    final plan = plansByOwner[key];
    if (plan == null) continue;
    if (!includeCoolingDown && plan.escalationCoolingDown) continue;

    owners.add(EmployeeDocumentEscalationPreviewOwner(plan: plan));
  }

  return EmployeeDocumentEscalationPreview(owners: owners);
}

String _ownerKey(String ownerName) => ownerName.trim().toLowerCase();
