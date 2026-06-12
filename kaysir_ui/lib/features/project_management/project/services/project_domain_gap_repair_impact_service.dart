import '../models/project_portfolio_item.dart';
import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairImpactSummary {
  const ProjectDomainGapRepairImpactSummary({
    required this.totalTargetCount,
    required this.projectCount,
    required this.fieldCount,
    required this.domains,
    required this.blockedProjectCount,
    required this.atRiskProjectCount,
    required this.nextTarget,
  });

  factory ProjectDomainGapRepairImpactSummary.fromPlan(
    ProjectDomainGapRepairPlan plan,
  ) {
    final projectIds = <String>{};
    final fieldKeys = <String>{};
    final domains = <String>{};
    final blockedProjectIds = <String>{};
    final atRiskProjectIds = <String>{};

    for (final target in plan.allTargets) {
      projectIds.add(target.project.id);
      fieldKeys.add(target.column.key);
      domains.add(_domainFor(target.project));

      switch (target.project.health) {
        case ProjectHealth.blocked:
          blockedProjectIds.add(target.project.id);
        case ProjectHealth.atRisk:
          atRiskProjectIds.add(target.project.id);
        case ProjectHealth.onTrack:
          break;
      }
    }

    final sortedDomains = domains.toList()..sort();

    return ProjectDomainGapRepairImpactSummary(
      totalTargetCount: plan.totalTargetCount,
      projectCount: projectIds.length,
      fieldCount: fieldKeys.length,
      domains: List.unmodifiable(sortedDomains),
      blockedProjectCount: blockedProjectIds.length,
      atRiskProjectCount: atRiskProjectIds.length,
      nextTarget: plan.allTargets.isEmpty ? null : plan.allTargets.first,
    );
  }

  final int totalTargetCount;
  final int projectCount;
  final int fieldCount;
  final List<String> domains;
  final int blockedProjectCount;
  final int atRiskProjectCount;
  final ProjectDomainGapRepairTarget? nextTarget;

  bool get isEmpty => totalTargetCount == 0;
  bool get hasUrgentHealthContext =>
      blockedProjectCount > 0 || atRiskProjectCount > 0;
  int get domainCount => domains.length;
  String get nextFixLabel {
    final target = nextTarget;
    if (target == null) return 'No fixes queued';
    return '${target.fieldLabel} - ${target.projectLabel}';
  }

  String get projectScopeLabel => _countLabel(projectCount, 'project');
  String get fieldScopeLabel => _countLabel(fieldCount, 'field');
  String get domainScopeLabel {
    if (domains.isEmpty) return 'No domain';
    if (domains.length == 1) return domains.single;
    return '${domains.length} domains';
  }

  String get domainTooltip =>
      domains.isEmpty ? 'No domain' : domains.join(', ');
  String get urgencyLabel {
    if (blockedProjectCount > 0) {
      return _countLabel(blockedProjectCount, 'blocked project');
    }
    if (atRiskProjectCount > 0) {
      return _countLabel(atRiskProjectCount, 'at-risk project');
    }
    return 'Healthy project set';
  }
}

ProjectDomainGapRepairImpactSummary buildProjectDomainGapRepairImpactSummary({
  required ProjectDomainGapRepairPlan plan,
}) {
  return ProjectDomainGapRepairImpactSummary.fromPlan(plan);
}

String _domainFor(ProjectPortfolioItem project) {
  final value = project.businessDomain.trim();
  return value.isEmpty ? 'General Business' : value;
}

String _countLabel(int count, String singularLabel) {
  final label = count == 1 ? singularLabel : '${singularLabel}s';
  return '$count $label';
}
