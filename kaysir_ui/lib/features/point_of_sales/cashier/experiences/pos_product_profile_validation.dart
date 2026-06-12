import 'pos_experience_launch_checklist.dart';
import 'pos_experience_registry.dart';
import 'pos_product_profile_model.dart';

enum POSProductProfileIssueType {
  emptyCatalog,
  blankProfileId,
  duplicateProfileId,
  duplicateModeId,
  blankProfileLabel,
  blankProfileDescription,
  blockedLaunch,
  registryIssue,
}

class POSProductProfileIssue {
  final POSProductProfileIssueType type;
  final String message;
  final String? profileId;
  final String? modeId;
  final POSLaunchCheckArea? launchArea;
  final POSExperienceRegistryIssue? registryIssue;

  const POSProductProfileIssue({
    required this.type,
    required this.message,
    this.profileId,
    this.modeId,
    this.launchArea,
    this.registryIssue,
  });
}

class POSProductProfileValidationReport {
  final List<POSProductProfileIssue> issues;
  final int profileCount;
  final int launchableCount;
  final int blockedCount;

  const POSProductProfileValidationReport({
    required this.issues,
    required this.profileCount,
    required this.launchableCount,
    required this.blockedCount,
  });

  bool get isValid => issues.isEmpty;

  bool get hasBlockedProfiles => blockedCount > 0;

  String get statusLabel {
    if (profileCount == 0) return 'Empty';
    if (issues.isNotEmpty) return 'Needs attention';
    return 'Ready';
  }

  void throwIfInvalid() {
    if (isValid) return;

    throw StateError(
      'Invalid POS product profile catalog: '
      '${issues.map((issue) => issue.message).join('; ')}',
    );
  }
}

extension POSProductProfileCatalogValidation on POSProductProfileCatalog {
  POSProductProfileValidationReport get validationReport {
    return POSProductProfileValidator.validate(this);
  }

  bool get isValid => validationReport.isValid;
}

abstract final class POSProductProfileValidator {
  static POSProductProfileValidationReport validate(
    POSProductProfileCatalog catalog,
  ) {
    final issues = <POSProductProfileIssue>[];
    final profiles = catalog.profiles;

    if (profiles.isEmpty) {
      issues.add(
        const POSProductProfileIssue(
          type: POSProductProfileIssueType.emptyCatalog,
          message:
              'POS product profile catalog must contain at least one profile',
        ),
      );
    }

    final seenProfileIds = <String>{};
    final reportedProfileIds = <String>{};
    final seenModeIds = <String>{};
    final reportedModeIds = <String>{};
    var launchableCount = 0;
    var blockedCount = 0;

    for (final profile in profiles) {
      final profileId = profile.id.trim();
      final modeId = profile.recipe.id.trim();

      _validateProfileIdentity(
        profile: profile,
        profileId: profileId,
        modeId: modeId,
        seenProfileIds: seenProfileIds,
        reportedProfileIds: reportedProfileIds,
        seenModeIds: seenModeIds,
        reportedModeIds: reportedModeIds,
        issues: issues,
      );

      final checklist = profile.launchChecklist;
      if (checklist.canLaunch) {
        launchableCount += 1;
      } else {
        blockedCount += 1;
        _addLaunchBlockers(profileId, modeId, checklist, issues);
      }
    }

    _addRegistryIssues(catalog, issues);

    return POSProductProfileValidationReport(
      issues: List.unmodifiable(issues),
      profileCount: profiles.length,
      launchableCount: launchableCount,
      blockedCount: blockedCount,
    );
  }

  static void _validateProfileIdentity({
    required POSProductProfile profile,
    required String profileId,
    required String modeId,
    required Set<String> seenProfileIds,
    required Set<String> reportedProfileIds,
    required Set<String> seenModeIds,
    required Set<String> reportedModeIds,
    required List<POSProductProfileIssue> issues,
  }) {
    if (profileId.isEmpty) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.blankProfileId,
          modeId: modeId,
          message: 'POS product profile id cannot be blank',
        ),
      );
    } else if (!seenProfileIds.add(profileId) &&
        reportedProfileIds.add(profileId)) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.duplicateProfileId,
          profileId: profileId,
          modeId: modeId,
          message: 'Duplicate POS product profile id "$profileId" found',
        ),
      );
    }

    if (modeId.isNotEmpty &&
        !seenModeIds.add(modeId) &&
        reportedModeIds.add(modeId)) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.duplicateModeId,
          profileId: profileId,
          modeId: modeId,
          message: 'Duplicate POS mode id "$modeId" found in product profiles',
        ),
      );
    }

    if (profile.label.trim().isEmpty) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.blankProfileLabel,
          profileId: profileId,
          modeId: modeId,
          message: 'POS product profile "$profileId" must have a display label',
        ),
      );
    }

    if (profile.description.trim().isEmpty) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.blankProfileDescription,
          profileId: profileId,
          modeId: modeId,
          message: 'POS product profile "$profileId" must have a description',
        ),
      );
    }
  }

  static void _addLaunchBlockers(
    String profileId,
    String modeId,
    POSExperienceLaunchChecklist checklist,
    List<POSProductProfileIssue> issues,
  ) {
    for (final failure in checklist.failures) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.blockedLaunch,
          profileId: profileId,
          modeId: modeId,
          launchArea: failure.area,
          message:
              'POS product profile "$profileId" is blocked by ${failure.label}: ${failure.detail}',
        ),
      );
    }
  }

  static void _addRegistryIssues(
    POSProductProfileCatalog catalog,
    List<POSProductProfileIssue> issues,
  ) {
    for (final registryIssue in catalog.experienceRegistry.validate()) {
      issues.add(
        POSProductProfileIssue(
          type: POSProductProfileIssueType.registryIssue,
          profileId: catalog.findByModeId(registryIssue.experienceId ?? '')?.id,
          modeId: registryIssue.experienceId,
          registryIssue: registryIssue,
          message: registryIssue.message,
        ),
      );
    }
  }
}
