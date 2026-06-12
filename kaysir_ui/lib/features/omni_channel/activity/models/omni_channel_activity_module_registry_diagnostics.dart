import 'omni_channel_activity_module_manifest.dart';

/// Types of module registration issues found in the activity registry.
enum OmniChannelActivityModuleRegistrationIssueType {
  duplicateId,
  missingId,
  missingLabel,
  missingContribution,
  missingActionContributor,
  missingTriageDimension,
}

/// Operator-readable issue emitted when a module manifest is incomplete.
class OmniChannelActivityModuleRegistrationIssue {
  final OmniChannelActivityModuleRegistrationIssueType type;
  final String key;
  final String id;
  final int? moduleIndex;
  final List<String> labels;
  final int moduleCount;
  final String missingKey;

  OmniChannelActivityModuleRegistrationIssue({
    required this.type,
    required this.key,
    this.id = '',
    this.moduleIndex,
    Iterable<String> labels = const [],
    required this.moduleCount,
    this.missingKey = '',
  }) : labels = List.unmodifiable(labels);

  String get title {
    switch (type) {
      case OmniChannelActivityModuleRegistrationIssueType.duplicateId:
        return 'Duplicate module id';
      case OmniChannelActivityModuleRegistrationIssueType.missingId:
        return 'Missing module id';
      case OmniChannelActivityModuleRegistrationIssueType.missingLabel:
        return 'Missing module label';
      case OmniChannelActivityModuleRegistrationIssueType.missingContribution:
        return 'No module contributions';
      case OmniChannelActivityModuleRegistrationIssueType
          .missingActionContributor:
        return 'Missing action contributor';
      case OmniChannelActivityModuleRegistrationIssueType
          .missingTriageDimension:
        return 'Missing triage dimension';
    }
  }

  String get label {
    final normalizedLabels = labels.where((label) => label.trim().isNotEmpty);
    if (normalizedLabels.isNotEmpty) return normalizedLabels.join(' / ');

    final normalizedId = id.trim();
    if (normalizedId.isNotEmpty) return normalizedId;

    final index = moduleIndex;
    return index == null ? 'Activity module' : 'Module ${index + 1}';
  }

  String get detail {
    switch (type) {
      case OmniChannelActivityModuleRegistrationIssueType.duplicateId:
        return 'ID "$id" is shared by $label.';
      case OmniChannelActivityModuleRegistrationIssueType.missingId:
        return '$label needs a stable module id.';
      case OmniChannelActivityModuleRegistrationIssueType.missingLabel:
        return '$label needs a readable module label.';
      case OmniChannelActivityModuleRegistrationIssueType.missingContribution:
        return '$label needs at least one activity source, action contributor, '
            'or triage dimension.';
      case OmniChannelActivityModuleRegistrationIssueType
          .missingActionContributor:
        return '$label declares action contributor "$missingKey" but it is not '
            'registered.';
      case OmniChannelActivityModuleRegistrationIssueType
          .missingTriageDimension:
        return '$label declares triage dimension "$missingKey" but it is not '
            'registered.';
    }
  }
}

/// Resolved registry coverage for one omni-channel activity module.
class OmniChannelActivityModuleDiagnostic {
  final OmniChannelActivityModuleManifest manifest;
  final int activityEventCount;
  final int registeredActionContributorCount;
  final int registeredTriageDimensionCount;
  final List<String> missingActionContributorIds;
  final List<String> missingTriageDimensionKeys;

  OmniChannelActivityModuleDiagnostic({
    required this.manifest,
    required this.activityEventCount,
    required this.registeredActionContributorCount,
    required this.registeredTriageDimensionCount,
    Iterable<String> missingActionContributorIds = const [],
    Iterable<String> missingTriageDimensionKeys = const [],
  }) : missingActionContributorIds = List.unmodifiable(
         missingActionContributorIds,
       ),
       missingTriageDimensionKeys = List.unmodifiable(
         missingTriageDimensionKeys,
       );

  String get id => manifest.id;

  String get label => manifest.label;

  String get description => manifest.description;

  String get businessModelLabel => manifest.businessModelLabel;

  String get routePath => manifest.routePath;

  bool get hasActivity => activityEventCount > 0;

  bool get hasMissingContracts {
    return missingActionContributorIds.isNotEmpty ||
        missingTriageDimensionKeys.isNotEmpty;
  }

  bool get hasRegistryCoverage {
    return registeredActionContributorCount > 0 ||
        registeredTriageDimensionCount > 0;
  }

  bool get isHealthy => !hasMissingContracts && manifest.hasContributions;

  String get statusLabel {
    if (hasMissingContracts || !manifest.hasContributions) return 'Incomplete';
    if (hasActivity) return 'Active';

    return 'Ready';
  }
}
