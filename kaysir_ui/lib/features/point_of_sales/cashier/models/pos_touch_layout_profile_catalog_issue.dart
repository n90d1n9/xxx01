/// Validation issue categories for touch layout profile catalogs.
enum POSTouchLayoutProfileCatalogIssueType {
  emptyCatalog,
  missingDefaultProfile,
  blankProfileId,
  duplicateProfileId,
  blankProfileLabel,
  blankProfileDescription,
  noButtonGroups,
  blankGroupId,
  duplicateGroupId,
  blankGroupLabel,
  emptyButtonGroup,
  blankButtonId,
  duplicateButtonId,
  blankButtonLabel,
  incompleteButtonIntent,
}

/// A diagnostic produced while validating touch layout profile registrations.
class POSTouchLayoutProfileCatalogIssue {
  final POSTouchLayoutProfileCatalogIssueType type;
  final String profileId;
  final String groupId;
  final String buttonId;
  final String message;

  const POSTouchLayoutProfileCatalogIssue({
    required this.type,
    required this.message,
    this.profileId = '',
    this.groupId = '',
    this.buttonId = '',
  });

  @override
  String toString() => message;
}
