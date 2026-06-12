import 'package:flutter/material.dart';

enum ProjectTableColumn {
  owner,
  health,
  progress,
  budget,
  openMilestones,
  extensions,
  timeline,
}

const Set<ProjectTableColumn> projectOperationsTableColumns = {
  ProjectTableColumn.owner,
  ProjectTableColumn.health,
  ProjectTableColumn.progress,
  ProjectTableColumn.budget,
  ProjectTableColumn.openMilestones,
  ProjectTableColumn.extensions,
  ProjectTableColumn.timeline,
};

const Set<ProjectTableColumn> projectDeliveryTableColumns = {
  ProjectTableColumn.owner,
  ProjectTableColumn.health,
  ProjectTableColumn.progress,
  ProjectTableColumn.openMilestones,
  ProjectTableColumn.timeline,
};

const Set<ProjectTableColumn> projectFinancialTableColumns = {
  ProjectTableColumn.owner,
  ProjectTableColumn.health,
  ProjectTableColumn.progress,
  ProjectTableColumn.budget,
  ProjectTableColumn.timeline,
};

const Set<ProjectTableColumn> projectDomainContextTableColumns = {
  ProjectTableColumn.owner,
  ProjectTableColumn.health,
  ProjectTableColumn.extensions,
  ProjectTableColumn.timeline,
};

extension ProjectTableColumnPresentation on ProjectTableColumn {
  String get label {
    return switch (this) {
      ProjectTableColumn.owner => 'Owner',
      ProjectTableColumn.health => 'Health',
      ProjectTableColumn.progress => 'Progress',
      ProjectTableColumn.budget => 'Budget',
      ProjectTableColumn.openMilestones => 'Open Milestones',
      ProjectTableColumn.extensions => 'Extensions',
      ProjectTableColumn.timeline => 'Timeline',
    };
  }
}

enum ProjectTableColumnProfile {
  operations,
  delivery,
  financial,
  domainContext,
}

extension ProjectTableColumnProfilePresentation on ProjectTableColumnProfile {
  String get label {
    return switch (this) {
      ProjectTableColumnProfile.operations => 'Operations',
      ProjectTableColumnProfile.delivery => 'Delivery',
      ProjectTableColumnProfile.financial => 'Financial',
      ProjectTableColumnProfile.domainContext => 'Domain Context',
    };
  }

  String get description {
    return switch (this) {
      ProjectTableColumnProfile.operations =>
        'Show the full operational record for repeated project reviews.',
      ProjectTableColumnProfile.delivery =>
        'Prioritize progress, milestone flow, and delivery timing.',
      ProjectTableColumnProfile.financial =>
        'Prioritize progress, budget use, and financial timing signals.',
      ProjectTableColumnProfile.domainContext =>
        'Prioritize business-domain fields and extension readiness.',
    };
  }

  IconData get icon {
    return switch (this) {
      ProjectTableColumnProfile.operations => Icons.table_rows_outlined,
      ProjectTableColumnProfile.delivery => Icons.route_outlined,
      ProjectTableColumnProfile.financial =>
        Icons.account_balance_wallet_outlined,
      ProjectTableColumnProfile.domainContext => Icons.extension_outlined,
    };
  }

  Set<ProjectTableColumn> get columns {
    return switch (this) {
      ProjectTableColumnProfile.operations => projectOperationsTableColumns,
      ProjectTableColumnProfile.delivery => projectDeliveryTableColumns,
      ProjectTableColumnProfile.financial => projectFinancialTableColumns,
      ProjectTableColumnProfile.domainContext =>
        projectDomainContextTableColumns,
    };
  }

  List<ProjectTableColumn> get orderedColumns {
    return switch (this) {
      ProjectTableColumnProfile.operations => ProjectTableColumn.values,
      ProjectTableColumnProfile.delivery => const [
        ProjectTableColumn.owner,
        ProjectTableColumn.health,
        ProjectTableColumn.progress,
        ProjectTableColumn.openMilestones,
        ProjectTableColumn.timeline,
      ],
      ProjectTableColumnProfile.financial => const [
        ProjectTableColumn.owner,
        ProjectTableColumn.health,
        ProjectTableColumn.progress,
        ProjectTableColumn.budget,
        ProjectTableColumn.timeline,
      ],
      ProjectTableColumnProfile.domainContext => const [
        ProjectTableColumn.owner,
        ProjectTableColumn.health,
        ProjectTableColumn.extensions,
        ProjectTableColumn.timeline,
      ],
    };
  }
}
