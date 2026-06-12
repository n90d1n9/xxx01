import 'pos_quick_button.dart';
import 'pos_touch_layout_profile.dart';
import 'pos_touch_layout_profile_catalog_issue.dart';

/// Validates touch layout profile catalogs and reports extension-safe issues.
class POSTouchLayoutProfileCatalogValidator {
  const POSTouchLayoutProfileCatalogValidator._();

  static List<POSTouchLayoutProfileCatalogIssue> validate({
    required String defaultProfileId,
    required List<POSTouchLayoutProfile> profiles,
  }) {
    if (profiles.isEmpty) {
      return const [
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.emptyCatalog,
          message:
              'POS touch layout profile catalog must contain at least one profile.',
        ),
      ];
    }

    final issues = <POSTouchLayoutProfileCatalogIssue>[];
    final profileIdCounts = <String, int>{};
    for (final profile in profiles) {
      final id = profile.id.trim();
      if (id.isNotEmpty) {
        profileIdCounts[id] = (profileIdCounts[id] ?? 0) + 1;
      }
    }

    if (!_containsProfileId(profiles, defaultProfileId)) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.missingDefaultProfile,
          profileId: defaultProfileId,
          message:
              'Default POS touch layout profile "$defaultProfileId" is not registered.',
        ),
      );
    }

    for (final profile in profiles) {
      issues.addAll(_validateProfile(profile));
    }

    for (final entry in profileIdCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.duplicateProfileId,
          profileId: entry.key,
          message:
              'Duplicate POS touch layout profile id "${entry.key}" found.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  static List<POSTouchLayoutProfileCatalogIssue> _validateProfile(
    POSTouchLayoutProfile profile,
  ) {
    final issues = <POSTouchLayoutProfileCatalogIssue>[];
    final profileId = profile.id.trim();

    if (profileId.isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankProfileId,
          profileId: profile.id,
          message: 'POS touch layout profile id cannot be blank.',
        ),
      );
    }
    if (profile.label.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankProfileLabel,
          profileId: profile.id,
          message:
              'POS touch layout profile "${_profileLabelForMessage(profile)}" label cannot be blank.',
        ),
      );
    }
    if (profile.description.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankProfileDescription,
          profileId: profile.id,
          message:
              'POS touch layout profile "${_profileLabelForMessage(profile)}" description cannot be blank.',
        ),
      );
    }
    if (profile.groups.isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.noButtonGroups,
          profileId: profile.id,
          message:
              'POS touch layout profile "${_profileLabelForMessage(profile)}" must declare at least one button group.',
        ),
      );
    }

    final groupIdCounts = <String, int>{};
    final buttonIdCounts = <String, int>{};
    for (final group in profile.groups) {
      final groupId = group.id.trim();
      if (groupId.isNotEmpty) {
        groupIdCounts[groupId] = (groupIdCounts[groupId] ?? 0) + 1;
      }

      for (final button in group.buttons) {
        final buttonId = button.id.trim();
        if (buttonId.isNotEmpty) {
          buttonIdCounts[buttonId] = (buttonIdCounts[buttonId] ?? 0) + 1;
        }
      }
    }

    for (final group in profile.groups) {
      issues.addAll(_validateGroup(profile: profile, group: group));
    }

    for (final entry in groupIdCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.duplicateGroupId,
          profileId: profile.id,
          groupId: entry.key,
          message:
              'Duplicate POS touch layout group id "${entry.key}" found in profile "${profile.id}".',
        ),
      );
    }

    for (final entry in buttonIdCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.duplicateButtonId,
          profileId: profile.id,
          buttonId: entry.key,
          message:
              'Duplicate POS quick button id "${entry.key}" found in profile "${profile.id}".',
        ),
      );
    }

    return issues;
  }

  static List<POSTouchLayoutProfileCatalogIssue> _validateGroup({
    required POSTouchLayoutProfile profile,
    required POSQuickButtonGroup group,
  }) {
    final issues = <POSTouchLayoutProfileCatalogIssue>[];
    if (group.id.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankGroupId,
          profileId: profile.id,
          groupId: group.id,
          message:
              'POS touch layout group id cannot be blank in profile "${profile.id}".',
        ),
      );
    }
    if (group.label.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankGroupLabel,
          profileId: profile.id,
          groupId: group.id,
          message:
              'POS touch layout group "${group.id}" label cannot be blank.',
        ),
      );
    }
    if (group.buttons.isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.emptyButtonGroup,
          profileId: profile.id,
          groupId: group.id,
          message:
              'POS touch layout group "${group.id}" must declare at least one quick button.',
        ),
      );
    }

    for (final button in group.buttons) {
      issues.addAll(
        _validateButton(profile: profile, group: group, button: button),
      );
    }

    return issues;
  }

  static List<POSTouchLayoutProfileCatalogIssue> _validateButton({
    required POSTouchLayoutProfile profile,
    required POSQuickButtonGroup group,
    required POSQuickButton button,
  }) {
    final issues = <POSTouchLayoutProfileCatalogIssue>[];
    if (button.id.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankButtonId,
          profileId: profile.id,
          groupId: group.id,
          buttonId: button.id,
          message:
              'POS quick button id cannot be blank in group "${group.id}".',
        ),
      );
    }
    if (button.label.trim().isEmpty) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.blankButtonLabel,
          profileId: profile.id,
          groupId: group.id,
          buttonId: button.id,
          message: 'POS quick button "${button.id}" label cannot be blank.',
        ),
      );
    }
    if (!button.intent.isComplete) {
      issues.add(
        POSTouchLayoutProfileCatalogIssue(
          type: POSTouchLayoutProfileCatalogIssueType.incompleteButtonIntent,
          profileId: profile.id,
          groupId: group.id,
          buttonId: button.id,
          message:
              'POS quick button "${button.id}" must declare a complete ${button.intent.kind.label.toLowerCase()} intent.',
        ),
      );
    }

    return issues;
  }

  static bool _containsProfileId(
    Iterable<POSTouchLayoutProfile> profiles,
    String profileId,
  ) {
    final normalizedId = profileId.trim();
    return profiles.any((profile) => profile.id == normalizedId);
  }

  static String _profileLabelForMessage(POSTouchLayoutProfile profile) {
    final normalized = profile.id.trim();
    return normalized.isEmpty ? '<blank>' : normalized;
  }
}
