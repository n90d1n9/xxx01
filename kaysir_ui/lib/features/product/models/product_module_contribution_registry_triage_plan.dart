import 'product_module_contribution_manifest.dart';
import 'product_module_contribution_registry_diagnostic_detail.dart';

/// Action plan derived from the registry diagnostics currently in view.
class ProductModuleContributionRegistryTriagePlan {
  ProductModuleContributionRegistryTriagePlan({
    required List<ProductModuleContributionRegistryDiagnosticDetail>
    diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics),
       groups = List.unmodifiable(_groupsFor(diagnostics)),
       actions = List.unmodifiable(_actionsFor(diagnostics));

  /// Builds a triage plan from inspectable registry diagnostic details.
  factory ProductModuleContributionRegistryTriagePlan.fromDiagnostics(
    List<ProductModuleContributionRegistryDiagnosticDetail> diagnostics,
  ) {
    return ProductModuleContributionRegistryTriagePlan(
      diagnostics: diagnostics,
    );
  }

  final List<ProductModuleContributionRegistryDiagnosticDetail> diagnostics;
  final List<ProductModuleContributionRegistryTriageGroup> groups;
  final List<ProductModuleContributionRegistryTriageAction> actions;

  bool get hasActions => actions.isNotEmpty;
  bool get hasGroups => groups.isNotEmpty;
  int get diagnosticCount => diagnostics.length;
  int get actionCount => actions.length;
  bool get hasDiagnostics => diagnostics.isNotEmpty;

  ProductModuleContributionDiagnosticSeverity get highestSeverity {
    if (diagnostics.any(
      (diagnostic) =>
          diagnostic.severity ==
          ProductModuleContributionDiagnosticSeverity.error,
    )) {
      return ProductModuleContributionDiagnosticSeverity.error;
    }

    if (diagnostics.any(
      (diagnostic) =>
          diagnostic.severity ==
          ProductModuleContributionDiagnosticSeverity.warning,
    )) {
      return ProductModuleContributionDiagnosticSeverity.warning;
    }

    return ProductModuleContributionDiagnosticSeverity.info;
  }

  String get title {
    if (!hasDiagnostics) return 'Registry triage clear';

    return switch (highestSeverity) {
      ProductModuleContributionDiagnosticSeverity.error =>
        'Resolve registry blockers',
      ProductModuleContributionDiagnosticSeverity.warning =>
        'Review registry conflicts',
      ProductModuleContributionDiagnosticSeverity.info =>
        'Review registry notes',
    };
  }

  String get summaryLabel {
    if (!hasDiagnostics) return 'No visible diagnostics';

    return '${_countLabel(diagnosticCount, 'visible issue')} | '
        '${_countLabel(actionCount, 'action')}';
  }

  String get primaryActionLabel {
    if (actions.isEmpty) return 'No action needed';

    return actions.first.title;
  }

  String get highestSeverityLabel => highestSeverity.label;

  List<ProductModuleContributionRegistryTriageAction> previewActions({
    int limit = 3,
  }) {
    if (limit <= 0) {
      return const <ProductModuleContributionRegistryTriageAction>[];
    }

    return List.unmodifiable(actions.take(limit));
  }

  List<ProductModuleContributionRegistryTriageGroup> previewGroups({
    int actionLimit = 3,
  }) {
    if (actionLimit <= 0) {
      return const <ProductModuleContributionRegistryTriageGroup>[];
    }

    var remaining = actionLimit;
    final visibleGroups = <ProductModuleContributionRegistryTriageGroup>[];

    for (final group in groups) {
      if (remaining <= 0) break;

      final visibleActions = group.actions.take(remaining).toList();
      if (visibleActions.isEmpty) continue;

      visibleGroups.add(group.copyWithActions(visibleActions));
      remaining -= visibleActions.length;
    }

    return List.unmodifiable(visibleGroups);
  }

  int hiddenActionCount({int visibleLimit = 3}) {
    if (visibleLimit <= 0) return actionCount;

    final hiddenCount = actionCount - visibleLimit;
    if (hiddenCount <= 0) return 0;

    return hiddenCount;
  }

  String hiddenActionCountLabel({int visibleLimit = 3}) {
    return _countLabel(
      hiddenActionCount(visibleLimit: visibleLimit),
      'more action',
    );
  }

  String get reportText {
    final buffer =
        StringBuffer()
          ..writeln('Product module registry triage plan')
          ..writeln('Title: $title')
          ..writeln('Visible issues: $diagnosticCount')
          ..writeln('Actions: $actionCount')
          ..writeln('Highest severity: $highestSeverityLabel');

    if (!hasActions) {
      buffer.writeln('No registry actions needed for the current filter.');
      return buffer.toString().trimRight();
    }

    for (var index = 0; index < actions.length; index += 1) {
      final action = actions[index];
      buffer
        ..writeln()
        ..writeln('${index + 1}. ${action.title}')
        ..writeln('   ${action.description}')
        ..writeln('   Diagnostic: ${action.diagnosticTitle}')
        ..writeln('   Issue: ${action.issueLabel}')
        ..writeln('   Severity: ${action.severityLabel}');
    }

    return buffer.toString().trimRight();
  }
}

/// Triage actions grouped under one parent registry diagnostic.
class ProductModuleContributionRegistryTriageGroup {
  ProductModuleContributionRegistryTriageGroup({
    required this.detail,
    required this.diagnosticTitle,
    required this.issueLabel,
    required this.severity,
    required List<ProductModuleContributionRegistryTriageAction> actions,
  }) : actions = List.unmodifiable(actions);

  final ProductModuleContributionRegistryDiagnosticDetail detail;
  final String diagnosticTitle;
  final String issueLabel;
  final ProductModuleContributionDiagnosticSeverity severity;
  final List<ProductModuleContributionRegistryTriageAction> actions;

  bool get hasActions => actions.isNotEmpty;
  int get actionCount => actions.length;
  String get severityLabel => severity.label;
  String get actionCountLabel => _countLabel(actionCount, 'action');

  ProductModuleContributionRegistryTriageGroup copyWithActions(
    List<ProductModuleContributionRegistryTriageAction> actions,
  ) {
    return ProductModuleContributionRegistryTriageGroup(
      detail: detail,
      diagnosticTitle: diagnosticTitle,
      issueLabel: issueLabel,
      severity: severity,
      actions: actions,
    );
  }
}

/// One flattened remediation action with its parent diagnostic context.
class ProductModuleContributionRegistryTriageAction {
  const ProductModuleContributionRegistryTriageAction({
    required this.title,
    required this.description,
    required this.diagnosticTitle,
    required this.issueLabel,
    required this.severity,
  });

  final String title;
  final String description;
  final String diagnosticTitle;
  final String issueLabel;
  final ProductModuleContributionDiagnosticSeverity severity;

  String get severityLabel => severity.label;
}

List<ProductModuleContributionRegistryTriageAction> _actionsFor(
  List<ProductModuleContributionRegistryDiagnosticDetail> diagnostics,
) {
  return [for (final group in _groupsFor(diagnostics)) ...group.actions];
}

List<ProductModuleContributionRegistryTriageGroup> _groupsFor(
  List<ProductModuleContributionRegistryDiagnosticDetail> diagnostics,
) {
  return [
    for (final diagnostic in diagnostics)
      if (diagnostic.hasNextActions)
        ProductModuleContributionRegistryTriageGroup(
          detail: diagnostic,
          diagnosticTitle: diagnostic.title,
          issueLabel: diagnostic.issueLabel,
          severity: diagnostic.severity,
          actions: [
            for (final action in diagnostic.nextActions)
              ProductModuleContributionRegistryTriageAction(
                title: action.title,
                description: action.description,
                diagnosticTitle: diagnostic.title,
                issueLabel: diagnostic.issueLabel,
                severity: diagnostic.severity,
              ),
          ],
        ),
  ];
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
