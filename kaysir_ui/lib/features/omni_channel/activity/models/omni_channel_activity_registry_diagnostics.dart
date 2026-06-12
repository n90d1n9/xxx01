import 'omni_channel_activity.dart';
import 'omni_channel_activity_action.dart';
import 'omni_channel_activity_module_manifest.dart';
import 'omni_channel_activity_module_registry_diagnostics.dart';
import 'omni_channel_activity_registry_issue.dart';
import 'omni_channel_activity_triage.dart';
import '../services/omni_channel_activity_registry_diagnostics_builder.dart';

/// Diagnostic read-model for registered omni-channel activity extensions.
class OmniChannelActivityRegistryDiagnostics {
  final int entryCount;
  final int moduleCount;
  final List<OmniChannelActivityModuleDiagnostic> modules;
  final List<OmniChannelActivityModuleRegistrationIssue>
  moduleRegistrationIssues;
  final int actionContributorCount;
  final List<OmniChannelActivityActionContributorDiagnostic> actionContributors;
  final List<OmniChannelActivityActionContributorRegistrationIssue>
  contributorRegistrationIssues;
  final List<OmniChannelActivityActionDuplicateDiagnostic> duplicateActions;
  final List<OmniChannelActivityTriageDimensionDuplicateDiagnostic>
  duplicateDimensions;
  final List<OmniChannelActivityTriageDimensionDiagnostic> triageDimensions;
  final List<OmniChannelActivityActionDiagnostic> actions;

  OmniChannelActivityRegistryDiagnostics({
    required this.entryCount,
    this.moduleCount = 0,
    Iterable<OmniChannelActivityModuleDiagnostic> modules = const [],
    Iterable<OmniChannelActivityModuleRegistrationIssue>
        moduleRegistrationIssues =
        const [],
    required this.actionContributorCount,
    Iterable<OmniChannelActivityActionContributorDiagnostic>
        actionContributors =
        const [],
    Iterable<OmniChannelActivityActionContributorRegistrationIssue>
        contributorRegistrationIssues =
        const [],
    Iterable<OmniChannelActivityActionDuplicateDiagnostic> duplicateActions =
        const [],
    Iterable<OmniChannelActivityTriageDimensionDuplicateDiagnostic>
        duplicateDimensions =
        const [],
    Iterable<OmniChannelActivityTriageDimensionDiagnostic> triageDimensions =
        const [],
    Iterable<OmniChannelActivityActionDiagnostic> actions = const [],
  }) : modules = List.unmodifiable(modules),
       moduleRegistrationIssues = List.unmodifiable(moduleRegistrationIssues),
       actionContributors = List.unmodifiable(actionContributors),
       contributorRegistrationIssues = List.unmodifiable(
         contributorRegistrationIssues,
       ),
       duplicateActions = List.unmodifiable(duplicateActions),
       duplicateDimensions = List.unmodifiable(duplicateDimensions),
       triageDimensions = List.unmodifiable(triageDimensions),
       actions = List.unmodifiable(actions);

  bool get hasContributions {
    return moduleCount > 0 ||
        actionContributorCount > 0 ||
        triageDimensions.isNotEmpty;
  }

  int get activeModuleCount {
    return modules.where((module) => module.hasActivity).length;
  }

  int get readyModuleCount {
    return modules.where((module) => module.isHealthy).length;
  }

  int get moduleRegistrationIssueCount {
    return moduleRegistrationIssues.length;
  }

  int get activeDimensionCount {
    return triageDimensions
        .where((dimension) => dimension.hasResolvedQueues)
        .length;
  }

  int get activeActionCount => actions.length;

  int get duplicateActionCount => duplicateActions.length;

  int get contributorRegistrationIssueCount {
    return contributorRegistrationIssues.length;
  }

  int get duplicateDimensionCount => duplicateDimensions.length;

  int get activeActionContributorCount {
    return actionContributors
        .where((contributor) => contributor.hasResolvedActions)
        .length;
  }

  bool get hasDuplicateActions => duplicateActions.isNotEmpty;

  bool get hasModuleRegistrationIssues {
    return moduleRegistrationIssues.isNotEmpty;
  }

  bool get hasContributorRegistrationIssues {
    return contributorRegistrationIssues.isNotEmpty;
  }

  bool get hasDuplicateDimensions => duplicateDimensions.isNotEmpty;

  int get enabledActionEventCount {
    return actions.fold(0, (total, action) => total + action.enabledEventCount);
  }

  int get disabledActionEventCount {
    return actions.fold(
      0,
      (total, action) => total + action.disabledEventCount,
    );
  }

  String get summaryLabel {
    return '${_countLabel(triageDimensions.length, 'dimension')} / '
        '${_countLabel(actionContributorCount, 'action contributor')}';
  }

  String get moduleSummaryLabel {
    return '${_countLabel(moduleCount, 'module')} / '
        '$readyModuleCount ready';
  }

  factory OmniChannelActivityRegistryDiagnostics.fromFeed({
    required OmniChannelActivityFeed feed,
    required OmniChannelActivityActionRegistry actionRegistry,
    required Iterable<OmniChannelActivityTriageDimensionDefinition>
    triageDimensions,
    Iterable<OmniChannelActivityModuleManifest> moduleManifests = const [],
  }) {
    return const OmniChannelActivityRegistryDiagnosticsBuilder().build(
      feed: feed,
      actionRegistry: actionRegistry,
      triageDimensions: triageDimensions,
      moduleManifests: moduleManifests,
    );
  }
}

/// Resolved coverage for one registered activity action contributor.
class OmniChannelActivityActionContributorDiagnostic {
  final String id;
  final String label;
  final String description;
  final int matchedEntryCount;
  final int actionCount;

  const OmniChannelActivityActionContributorDiagnostic({
    required this.id,
    required this.label,
    required this.description,
    required this.matchedEntryCount,
    required this.actionCount,
  });

  bool get hasResolvedActions => actionCount > 0;
}

/// Duplicate action identity emitted by more than one action contributor.
class OmniChannelActivityActionDuplicateDiagnostic {
  final String identity;
  final String label;
  final List<String> contributorLabels;
  final int contributorCount;
  final int eventCount;

  OmniChannelActivityActionDuplicateDiagnostic({
    required this.identity,
    required this.label,
    Iterable<String> contributorLabels = const [],
    int? contributorCount,
    required this.eventCount,
  }) : contributorLabels = List.unmodifiable(contributorLabels),
       contributorCount = contributorCount ?? contributorLabels.length;

  String get contributorLabel => contributorLabels.join(' / ');
}

/// Duplicate triage dimension key emitted by more than one definition.
class OmniChannelActivityTriageDimensionDuplicateDiagnostic {
  final String key;
  final List<String> labels;
  final int definitionCount;

  OmniChannelActivityTriageDimensionDuplicateDiagnostic({
    required this.key,
    Iterable<String> labels = const [],
    required this.definitionCount,
  }) : labels = List.unmodifiable(labels);

  String get label => labels.join(' / ');
}

/// Coverage and queue volume for one registered triage dimension.
class OmniChannelActivityTriageDimensionDiagnostic {
  final OmniChannelActivityTriageDimension dimension;
  final int queueCount;
  final int attentionCount;
  final int reviewCount;
  final String? topQueueLabel;

  const OmniChannelActivityTriageDimensionDiagnostic({
    required this.dimension,
    required this.queueCount,
    required this.attentionCount,
    required this.reviewCount,
    this.topQueueLabel,
  });

  bool get hasResolvedQueues => queueCount > 0;
}

/// Resolved action coverage for one unique activity action identity.
class OmniChannelActivityActionDiagnostic {
  final String identity;
  final String label;
  final String location;
  final OmniChannelActivityActionIntent intent;
  final int priority;
  final int eventCount;
  final int primaryEventCount;
  final int enabledEventCount;
  final int disabledEventCount;

  const OmniChannelActivityActionDiagnostic({
    required this.identity,
    required this.label,
    required this.location,
    required this.intent,
    required this.priority,
    required this.eventCount,
    required this.primaryEventCount,
    required this.enabledEventCount,
    required this.disabledEventCount,
  });

  bool get hasDisabledEvents => disabledEventCount > 0;
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
