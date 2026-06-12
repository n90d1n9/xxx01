import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_budget_pulse_service.dart';
import 'project_finance_control_service.dart';

/// Readiness level for a project cost structure category.
enum ProjectCostStructureLevel { ready, watch, critical }

/// Domain-neutral cost category used to adapt baselines across industries.
enum ProjectCostStructureCategory {
  labor,
  materials,
  vendor,
  technology,
  logistics,
  governance,
  training,
  program,
  contingency,
}

/// One planned cost category in a project cost baseline.
class ProjectCostStructureLine {
  const ProjectCostStructureLine({
    required this.id,
    required this.title,
    required this.detail,
    required this.category,
    required this.plannedShare,
    required this.level,
    required this.icon,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectCostStructureCategory category;
  final double plannedShare;
  final ProjectCostStructureLevel level;
  final IconData icon;

  int get plannedSharePercent => (plannedShare * 100).round();
  bool get needsAttention => level != ProjectCostStructureLevel.ready;
}

/// Cost baseline summary for project detail and future budget-line screens.
class ProjectCostStructureSummary {
  const ProjectCostStructureSummary({
    required this.projectId,
    required this.projectName,
    required this.profileLabel,
    required this.budgetPaceLabel,
    required this.lines,
  });

  final String projectId;
  final String projectName;
  final String profileLabel;
  final String budgetPaceLabel;
  final List<ProjectCostStructureLine> lines;

  int get categoryCount => lines.length;
  int get readyCount => lines.where((line) => !line.needsAttention).length;
  int get watchCount =>
      lines
          .where((line) => line.level == ProjectCostStructureLevel.watch)
          .length;
  int get criticalCount =>
      lines
          .where((line) => line.level == ProjectCostStructureLevel.critical)
          .length;
  int get contingencySharePercent {
    final share = lines
        .where(
          (line) => line.category == ProjectCostStructureCategory.contingency,
        )
        .fold<double>(0, (sum, line) => sum + line.plannedShare);
    return (share * 100).round();
  }

  ProjectCostStructureLine get primaryLine {
    final sorted = [...lines]..sort(_compareLines);
    return sorted.first;
  }

  ProjectCostStructureLevel get level {
    if (criticalCount > 0) return ProjectCostStructureLevel.critical;
    if (watchCount > 0) return ProjectCostStructureLevel.watch;
    return ProjectCostStructureLevel.ready;
  }

  String get title {
    switch (level) {
      case ProjectCostStructureLevel.ready:
        return 'Cost structure aligned';
      case ProjectCostStructureLevel.watch:
        return 'Cost controls need attention';
      case ProjectCostStructureLevel.critical:
        return 'Cost baseline needs reset';
    }
  }

  String get detail {
    return '$profileLabel baseline - ${primaryLine.title} is ${primaryLine.plannedSharePercent}% of planned cost - ${budgetPaceLabel.toLowerCase()}.';
  }
}

/// Builds a domain-adaptive project cost baseline from project finance signals.
ProjectCostStructureSummary buildProjectCostStructureSummary(
  ProjectPortfolioItem project, {
  ProjectFinanceControlSummary? financeSummary,
}) {
  final finance = financeSummary ?? buildProjectFinanceControlSummary(project);
  final templates = _templatesForDomain(project.businessDomain);
  final roles = finance.attributes.map((attribute) => attribute.role).toSet();
  final lines = [
    for (final template in templates)
      ProjectCostStructureLine(
        id: '${project.id}-${template.category.name}',
        title: template.title,
        detail: _lineDetail(template),
        category: template.category,
        plannedShare: template.plannedShare,
        level: _lineLevel(
          template: template,
          finance: finance,
          configuredRoles: roles,
        ),
        icon: template.category.icon,
      ),
  ]..sort(_compareLines);

  return ProjectCostStructureSummary(
    projectId: project.id,
    projectName: project.name,
    profileLabel: _profileLabelForDomain(project.businessDomain),
    budgetPaceLabel: finance.budgetOverview.paceLabel,
    lines: List.unmodifiable(lines),
  );
}

extension ProjectCostStructureLevelPresentation on ProjectCostStructureLevel {
  /// User-facing label for a cost structure level.
  String get label {
    switch (this) {
      case ProjectCostStructureLevel.ready:
        return 'Ready';
      case ProjectCostStructureLevel.watch:
        return 'Watch';
      case ProjectCostStructureLevel.critical:
        return 'Reset';
    }
  }

  /// Icon for a cost structure level.
  IconData get icon {
    switch (this) {
      case ProjectCostStructureLevel.ready:
        return Icons.verified_outlined;
      case ProjectCostStructureLevel.watch:
        return Icons.visibility_outlined;
      case ProjectCostStructureLevel.critical:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a cost structure level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectCostStructureLevel.ready:
        return Colors.green.shade700;
      case ProjectCostStructureLevel.watch:
        return Colors.orange.shade700;
      case ProjectCostStructureLevel.critical:
        return colorScheme.error;
    }
  }
}

extension ProjectCostStructureCategoryPresentation
    on ProjectCostStructureCategory {
  /// User-facing label for a cost category.
  String get label {
    switch (this) {
      case ProjectCostStructureCategory.labor:
        return 'Labor';
      case ProjectCostStructureCategory.materials:
        return 'Materials';
      case ProjectCostStructureCategory.vendor:
        return 'Vendor';
      case ProjectCostStructureCategory.technology:
        return 'Technology';
      case ProjectCostStructureCategory.logistics:
        return 'Logistics';
      case ProjectCostStructureCategory.governance:
        return 'Governance';
      case ProjectCostStructureCategory.training:
        return 'Training';
      case ProjectCostStructureCategory.program:
        return 'Program';
      case ProjectCostStructureCategory.contingency:
        return 'Contingency';
    }
  }

  /// Icon for a cost category.
  IconData get icon {
    switch (this) {
      case ProjectCostStructureCategory.labor:
        return Icons.engineering_outlined;
      case ProjectCostStructureCategory.materials:
        return Icons.category_outlined;
      case ProjectCostStructureCategory.vendor:
        return Icons.inventory_2_outlined;
      case ProjectCostStructureCategory.technology:
        return Icons.devices_outlined;
      case ProjectCostStructureCategory.logistics:
        return Icons.local_shipping_outlined;
      case ProjectCostStructureCategory.governance:
        return Icons.account_tree_outlined;
      case ProjectCostStructureCategory.training:
        return Icons.school_outlined;
      case ProjectCostStructureCategory.program:
        return Icons.event_note_outlined;
      case ProjectCostStructureCategory.contingency:
        return Icons.savings_outlined;
    }
  }
}

/// Private template for reusable cost baseline category definitions.
class _ProjectCostStructureTemplate {
  const _ProjectCostStructureTemplate({
    required this.category,
    required this.title,
    required this.plannedShare,
    required this.requiredRoles,
  });

  final ProjectCostStructureCategory category;
  final String title;
  final double plannedShare;
  final Set<ProjectFinanceControlRole> requiredRoles;
}

List<_ProjectCostStructureTemplate> _templatesForDomain(String domain) {
  final value = domain.toLowerCase();
  if (_containsAny(value, const ['software', 'digital', 'system', 'app'])) {
    return const [
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.labor,
        title: 'Product and engineering',
        plannedShare: 0.42,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.technology,
        title: 'Cloud and tools',
        plannedShare: 0.2,
        requiredRoles: {
          ProjectFinanceControlRole.expenseOwner,
          ProjectFinanceControlRole.approvalPolicy,
        },
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.vendor,
        title: 'Vendor services',
        plannedShare: 0.16,
        requiredRoles: {ProjectFinanceControlRole.procurement},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.training,
        title: 'Adoption and release',
        plannedShare: 0.12,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.contingency,
        title: 'Change reserve',
        plannedShare: 0.1,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
    ];
  }
  if (_containsAny(value, const ['construction', 'build', 'facility'])) {
    return const [
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.materials,
        title: 'Materials and fixtures',
        plannedShare: 0.35,
        requiredRoles: {ProjectFinanceControlRole.procurement},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.labor,
        title: 'Site labor',
        plannedShare: 0.28,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.vendor,
        title: 'Subcontractors',
        plannedShare: 0.17,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.governance,
        title: 'Permits and inspection',
        plannedShare: 0.1,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.contingency,
        title: 'Site contingency',
        plannedShare: 0.1,
        requiredRoles: {ProjectFinanceControlRole.projectFloat},
      ),
    ];
  }
  if (_containsAny(value, const ['event', 'wedding', 'music'])) {
    return const [
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.vendor,
        title: 'Venue and vendors',
        plannedShare: 0.34,
        requiredRoles: {ProjectFinanceControlRole.procurement},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.program,
        title: 'Program and talent',
        plannedShare: 0.24,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.logistics,
        title: 'Logistics and field ops',
        plannedShare: 0.17,
        requiredRoles: {ProjectFinanceControlRole.projectFloat},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.training,
        title: 'Creative and guest support',
        plannedShare: 0.1,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.contingency,
        title: 'Event reserve',
        plannedShare: 0.15,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
    ];
  }
  if (_containsAny(value, const ['education', 'government', 'public'])) {
    return const [
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.program,
        title: 'Program delivery',
        plannedShare: 0.28,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.vendor,
        title: 'Procurement packages',
        plannedShare: 0.22,
        requiredRoles: {ProjectFinanceControlRole.procurement},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.governance,
        title: 'Compliance and reporting',
        plannedShare: 0.18,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.training,
        title: 'Training and adoption',
        plannedShare: 0.17,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.contingency,
        title: 'Grant reserve',
        plannedShare: 0.15,
        requiredRoles: {ProjectFinanceControlRole.funding},
      ),
    ];
  }
  if (_containsAny(value, const ['retail', 'store'])) {
    return const [
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.labor,
        title: 'Store operations',
        plannedShare: 0.26,
        requiredRoles: {ProjectFinanceControlRole.expenseOwner},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.technology,
        title: 'Systems and inventory',
        plannedShare: 0.24,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.training,
        title: 'Training and rollout',
        plannedShare: 0.2,
        requiredRoles: {ProjectFinanceControlRole.projectFloat},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.vendor,
        title: 'Implementation vendors',
        plannedShare: 0.15,
        requiredRoles: {ProjectFinanceControlRole.procurement},
      ),
      _ProjectCostStructureTemplate(
        category: ProjectCostStructureCategory.contingency,
        title: 'Rollout reserve',
        plannedShare: 0.15,
        requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
      ),
    ];
  }
  return const [
    _ProjectCostStructureTemplate(
      category: ProjectCostStructureCategory.labor,
      title: 'Delivery labor',
      plannedShare: 0.3,
      requiredRoles: {ProjectFinanceControlRole.expenseOwner},
    ),
    _ProjectCostStructureTemplate(
      category: ProjectCostStructureCategory.vendor,
      title: 'Vendors and procurement',
      plannedShare: 0.24,
      requiredRoles: {ProjectFinanceControlRole.procurement},
    ),
    _ProjectCostStructureTemplate(
      category: ProjectCostStructureCategory.materials,
      title: 'Materials and assets',
      plannedShare: 0.18,
      requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
    ),
    _ProjectCostStructureTemplate(
      category: ProjectCostStructureCategory.logistics,
      title: 'Travel and field ops',
      plannedShare: 0.13,
      requiredRoles: {ProjectFinanceControlRole.projectFloat},
    ),
    _ProjectCostStructureTemplate(
      category: ProjectCostStructureCategory.contingency,
      title: 'Management reserve',
      plannedShare: 0.15,
      requiredRoles: {ProjectFinanceControlRole.approvalPolicy},
    ),
  ];
}

ProjectCostStructureLevel _lineLevel({
  required _ProjectCostStructureTemplate template,
  required ProjectFinanceControlSummary finance,
  required Set<ProjectFinanceControlRole> configuredRoles,
}) {
  final hasRequiredRoles = template.requiredRoles.every(
    configuredRoles.contains,
  );
  final budgetState = finance.budgetOverview.state;
  final majorLine = template.plannedShare >= 0.2;
  final reserveLine =
      template.category == ProjectCostStructureCategory.contingency;

  if (budgetState == ProjectBudgetPulseState.critical &&
      (majorLine || reserveLine || !hasRequiredRoles)) {
    return ProjectCostStructureLevel.critical;
  }
  if (!hasRequiredRoles ||
      (budgetState == ProjectBudgetPulseState.pressure && majorLine)) {
    return ProjectCostStructureLevel.watch;
  }
  return ProjectCostStructureLevel.ready;
}

String _lineDetail(_ProjectCostStructureTemplate template) {
  final controls = template.requiredRoles.map((role) => role.label).join(', ');
  final controlText = controls.isEmpty ? 'standard finance review' : controls;
  return 'Needs $controlText before this baseline category becomes ledger-ready.';
}

String _profileLabelForDomain(String domain) {
  final value = domain.toLowerCase();
  if (_containsAny(value, const ['software', 'digital', 'system', 'app'])) {
    return 'Software delivery';
  }
  if (_containsAny(value, const ['construction', 'build', 'facility'])) {
    return 'Construction delivery';
  }
  if (_containsAny(value, const ['event', 'wedding', 'music'])) {
    return 'Event production';
  }
  if (_containsAny(value, const ['education', 'government', 'public'])) {
    return 'Public program';
  }
  if (_containsAny(value, const ['retail', 'store'])) {
    return 'Retail rollout';
  }
  return 'General project';
}

int _compareLines(
  ProjectCostStructureLine left,
  ProjectCostStructureLine right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final shareCompare = right.plannedShare.compareTo(left.plannedShare);
  if (shareCompare != 0) return shareCompare;

  return left.title.compareTo(right.title);
}

int _levelRank(ProjectCostStructureLevel level) {
  switch (level) {
    case ProjectCostStructureLevel.critical:
      return 0;
    case ProjectCostStructureLevel.watch:
      return 1;
    case ProjectCostStructureLevel.ready:
      return 2;
  }
}

bool _containsAny(String value, List<String> tokens) {
  return tokens.any(value.contains);
}
