/// Types of registry metadata issues that can make module ownership ambiguous.
enum OmniChannelActivityActionContributorRegistrationIssueType {
  duplicateId,
  missingId,
  missingLabel,
}

/// Operator-readable issue emitted when an action contributor is misregistered.
class OmniChannelActivityActionContributorRegistrationIssue {
  final OmniChannelActivityActionContributorRegistrationIssueType type;
  final String key;
  final String id;
  final int? contributorIndex;
  final List<String> labels;
  final int contributorCount;

  OmniChannelActivityActionContributorRegistrationIssue({
    required this.type,
    required this.key,
    this.id = '',
    this.contributorIndex,
    Iterable<String> labels = const [],
    required this.contributorCount,
  }) : labels = List.unmodifiable(labels);

  String get title {
    switch (type) {
      case OmniChannelActivityActionContributorRegistrationIssueType
          .duplicateId:
        return 'Duplicate contributor id';
      case OmniChannelActivityActionContributorRegistrationIssueType.missingId:
        return 'Missing contributor id';
      case OmniChannelActivityActionContributorRegistrationIssueType
          .missingLabel:
        return 'Missing contributor label';
    }
  }

  String get label {
    final normalizedLabels = labels.where((label) => label.trim().isNotEmpty);
    if (normalizedLabels.isNotEmpty) return normalizedLabels.join(' / ');

    final normalizedId = id.trim();
    if (normalizedId.isNotEmpty) return normalizedId;

    final index = contributorIndex;
    return index == null ? 'Action contributor' : 'Contributor ${index + 1}';
  }

  String get detail {
    switch (type) {
      case OmniChannelActivityActionContributorRegistrationIssueType
          .duplicateId:
        return 'ID "$id" is shared by $label.';
      case OmniChannelActivityActionContributorRegistrationIssueType.missingId:
        return '$label needs a stable contributor id.';
      case OmniChannelActivityActionContributorRegistrationIssueType
          .missingLabel:
        return '$label needs a readable contributor label.';
    }
  }
}
