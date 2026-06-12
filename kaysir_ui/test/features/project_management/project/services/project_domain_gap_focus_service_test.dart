import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';

void main() {
  test('domain gap focus matches missing required and risk signal fields', () {
    final incomplete = _project('incomplete', [
      _attribute('workstream', 'Workstream', 'Operations'),
      _attribute('region', 'Region', 'Jakarta'),
    ]);
    final complete = _project('complete', [
      _attribute('workstream', 'Workstream', 'Operations'),
      _attribute('priority', 'Priority', 'Medium'),
      _attribute('region', 'Region', 'Jakarta'),
      _attribute('kpi-owner', 'KPI Owner', 'Maya'),
    ]);

    expect(
      projectMatchesDomainGapFocus(
        incomplete,
        ProjectDomainGapFocus.missingAny,
      ),
      isTrue,
    );
    expect(
      projectMatchesDomainGapFocus(
        incomplete,
        ProjectDomainGapFocus.missingRequired,
      ),
      isTrue,
    );
    expect(
      projectMatchesDomainGapFocus(
        incomplete,
        ProjectDomainGapFocus.missingRecommended,
      ),
      isTrue,
    );
    expect(
      projectMatchesDomainGapFocus(
        incomplete,
        ProjectDomainGapFocus.missingRiskSignals,
      ),
      isTrue,
    );
    expect(
      projectMatchesDomainGapFocus(complete, ProjectDomainGapFocus.missingAny),
      isFalse,
    );
    expect(
      projectMatchesDomainGapFocus(
        complete,
        ProjectDomainGapFocus.missingRequired,
      ),
      isFalse,
    );
    expect(
      projectMatchesDomainGapFocus(
        complete,
        ProjectDomainGapFocus.missingRiskSignals,
      ),
      isFalse,
    );
  });
}

ProjectPortfolioItem _project(
  String id,
  List<ProjectCustomAttribute> customAttributes,
) {
  return ProjectPortfolioItem(
    id: id,
    name: id,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.onTrack,
    milestones: const [],
    customAttributes: customAttributes,
  );
}

ProjectCustomAttribute _attribute(String key, String label, String value) {
  return ProjectCustomAttribute(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    value: value,
    isPinned: true,
  );
}
