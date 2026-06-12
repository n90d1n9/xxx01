import 'action.dart';
import 'module.dart';
import 'product_profile.dart';

enum RegistryIssueSource { profile, module, action }

extension RegistryIssueSourceLabel on RegistryIssueSource {
  String get label {
    return switch (this) {
      RegistryIssueSource.profile => 'Profile',
      RegistryIssueSource.module => 'Module',
      RegistryIssueSource.action => 'Action',
    };
  }

  String get summaryLabel {
    return switch (this) {
      RegistryIssueSource.profile => 'Profiles',
      RegistryIssueSource.module => 'Modules',
      RegistryIssueSource.action => 'Actions',
    };
  }
}

class RegistryIssueEntry {
  final int index;
  final RegistryIssueSource source;
  final String typeName;
  final String message;

  const RegistryIssueEntry({
    required this.index,
    required this.source,
    required this.typeName,
    required this.message,
  });
}

class RegistrySourceSummary {
  final RegistryIssueSource source;
  final int count;

  const RegistrySourceSummary({required this.source, required this.count});

  bool get hasIssues => count > 0;

  String get label => source.summaryLabel;

  String get valueLabel => hasIssues ? '$count' : 'Ready';
}

class RegistryDiagnostics {
  final int productProfileIssueCount;
  final int moduleIssueCount;
  final int actionRuleIssueCount;
  final List<RegistryIssueEntry> issues;
  final List<RegistrySourceSummary> sourceSummaries;

  const RegistryDiagnostics({
    required this.productProfileIssueCount,
    required this.moduleIssueCount,
    required this.actionRuleIssueCount,
    required this.issues,
    required this.sourceSummaries,
  });

  factory RegistryDiagnostics.fromIssues({
    Iterable<ProductProfileIssue> productProfileIssues = const [],
    required Iterable<ModuleIssue> moduleIssues,
    required Iterable<ActionRuleIssue> actionRuleIssues,
  }) {
    var index = 0;
    final productProfileIssueList = productProfileIssues.toList(
      growable: false,
    );
    final moduleIssueList = moduleIssues.toList(growable: false);
    final actionRuleIssueList = actionRuleIssues.toList(growable: false);

    return RegistryDiagnostics(
      productProfileIssueCount: productProfileIssueList.length,
      moduleIssueCount: moduleIssueList.length,
      actionRuleIssueCount: actionRuleIssueList.length,
      sourceSummaries: List.unmodifiable([
        RegistrySourceSummary(
          source: RegistryIssueSource.profile,
          count: productProfileIssueList.length,
        ),
        RegistrySourceSummary(
          source: RegistryIssueSource.module,
          count: moduleIssueList.length,
        ),
        RegistrySourceSummary(
          source: RegistryIssueSource.action,
          count: actionRuleIssueList.length,
        ),
      ]),
      issues: List.unmodifiable([
        ...productProfileIssueList.map(
          (issue) => RegistryIssueEntry(
            index: index++,
            source: RegistryIssueSource.profile,
            typeName: issue.type.name,
            message: issue.message,
          ),
        ),
        ...moduleIssueList.map(
          (issue) => RegistryIssueEntry(
            index: index++,
            source: RegistryIssueSource.module,
            typeName: issue.type.name,
            message: issue.message,
          ),
        ),
        ...actionRuleIssueList.map(
          (issue) => RegistryIssueEntry(
            index: index++,
            source: RegistryIssueSource.action,
            typeName: issue.type.name,
            message: issue.message,
          ),
        ),
      ]),
    );
  }

  int get totalIssueCount => issues.length;

  bool get hasIssues => issues.isNotEmpty;

  List<RegistryIssueEntry> visibleIssues(int maxVisible) {
    if (maxVisible <= 0) return const [];
    return List.unmodifiable(issues.take(maxVisible));
  }

  int hiddenIssueCount(int maxVisible) {
    if (maxVisible <= 0) return totalIssueCount;
    final hiddenCount = totalIssueCount - maxVisible;
    return hiddenCount <= 0 ? 0 : hiddenCount;
  }

  String get noticeTitle => 'Workspace registries need review';

  String get noticeMessage {
    if (!hasIssues) {
      return 'Workspace registries are ready across profiles, modules, and actions.';
    }

    return '$totalIssueCount ${_noun(totalIssueCount, 'registry issue')} can affect Commerce Workspace navigation and priority actions.';
  }
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
