import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_reason_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair reasons explain priority health and due date context', () {
    final target = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'field-app',
        name: 'Field App',
        businessDomain: 'Software Development',
        health: ProjectHealth.blocked,
        endDate: DateTime(2026, 6, 8),
      ),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );

    final reasonSet = buildProjectDomainGapRepairReasonSet(
      target: target,
      today: DateTime(2026, 6, 1),
      dueSoonDays: 10,
    );

    expect(reasonSet.target, target);
    expect(reasonSet.reasons.map((reason) => reason.kind), [
      ProjectDomainGapRepairReasonKind.requiredField,
      ProjectDomainGapRepairReasonKind.blockedProject,
      ProjectDomainGapRepairReasonKind.dueSoon,
    ]);
    expect(reasonSet.reasons.map((reason) => reason.label), [
      'Mandatory context',
      'Blocked project',
      'Due in 7d',
    ]);
    expect(
      reasonSet.compactLabel,
      'Mandatory context - Blocked project - Due in 7d',
    );
    expect(
      reasonSet.reasons.first.detail,
      'Repository is required for the Software Development project profile.',
    );
  });

  test('repair reasons flag overdue projects deterministically', () {
    final target = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
        health: ProjectHealth.atRisk,
        endDate: DateTime(2026, 5, 30),
      ),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );

    final reasonSet = buildProjectDomainGapRepairReasonSet(
      target: target,
      today: DateTime(2026, 6, 4),
    );

    expect(reasonSet.reasons.map((reason) => reason.label), [
      'Watched risk field',
      'At-risk project',
      '5d overdue',
    ]);
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
  required ProjectHealth health,
  required DateTime endDate,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 5),
    endDate: endDate,
    progress: 0.2,
    budgetUsed: 0.1,
    health: health,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column({required String key, required String label}) {
  return ProjectTableCustomColumn(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: const {},
    filledProjectIds: const {},
    pinnedProjectIds: const {},
    requiredProjectIds: const {},
    recommendedProjectIds: const {},
    riskWatchedProjectIds: const {},
  );
}
