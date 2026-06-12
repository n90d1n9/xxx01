import 'package:flutter/material.dart';

import 'dashboard_workspace_risk_signal.dart';
import 'hris_workspace.dart';

class DashboardWorkspaceEntry {
  final HrisWorkspace workspace;
  final String description;
  final List<DashboardWorkspaceMetric> metrics;
  final DashboardWorkspaceRiskSignal? riskSignal;

  const DashboardWorkspaceEntry({
    required this.workspace,
    required this.description,
    required this.metrics,
    this.riskSignal,
  });

  String get title => workspace.title;

  String get path => workspace.path;

  DashboardWorkspaceCategory get category => workspace.category;

  IconData get icon => workspace.icon;

  Color get color => workspace.color;

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final searchableValues = [
      title,
      description,
      path,
      category.name,
      for (final metric in metrics) ...[metric.label, metric.value],
      if (riskSignal != null) ...[
        riskSignal!.severityLabel,
        riskSignal!.leadingSignal,
        '${riskSignal!.totalRisks}',
        '${riskSignal!.timeSensitiveRisks}',
        'risk',
        'time-sensitive',
      ],
    ];

    return searchableValues.any(
      (value) => value.toLowerCase().contains(normalized),
    );
  }
}

class DashboardWorkspaceMetric {
  final IconData icon;
  final String label;
  final String value;

  const DashboardWorkspaceMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
}
