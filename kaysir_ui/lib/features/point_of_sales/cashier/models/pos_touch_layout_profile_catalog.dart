import '../experiences/pos_experience_manifest.dart';
import '../states/pos_layout_strategy.dart';
import 'pos_touch_layout_profile.dart';
import 'pos_touch_layout_profile_catalog_issue.dart';
import 'pos_touch_layout_profile_catalog_validator.dart';

export 'pos_touch_layout_profile_catalog_issue.dart';

/// Result of resolving a selected touch layout profile with fallback metadata.
class POSTouchLayoutProfileResolution {
  final String requestedId;
  final POSTouchLayoutProfile profile;
  final bool usedFallback;
  final String? fallbackReason;

  const POSTouchLayoutProfileResolution({
    required this.requestedId,
    required this.profile,
    required this.usedFallback,
    this.fallbackReason,
  });
}

/// Registry for POS touch layout profiles available to a runtime pack.
///
/// It centralizes lookup, validation, and recommendation so different POS
/// products can reuse core behavior while shipping distinct touch layouts.
class POSTouchLayoutProfileCatalog {
  final String defaultProfileId;
  final List<POSTouchLayoutProfile> profiles;

  const POSTouchLayoutProfileCatalog({
    required this.defaultProfileId,
    required this.profiles,
  });

  List<String> get profileIds {
    return profiles.map((profile) => profile.id).toList(growable: false);
  }

  POSTouchLayoutProfile get defaultProfile {
    final profile = findById(defaultProfileId);
    if (profile != null) return profile;

    if (profiles.isEmpty) {
      throw StateError('POS touch layout profile catalog is empty.');
    }

    return profiles.first;
  }

  POSTouchLayoutProfile? findById(String id) {
    final normalizedId = id.trim();
    for (final profile in profiles) {
      if (profile.id == normalizedId) return profile;
    }

    return null;
  }

  POSTouchLayoutProfile profileForId(String id) {
    final profile = findById(id);
    if (profile != null) return profile;

    throw StateError(
      'POS touch layout profile "${id.trim()}" is not registered.',
    );
  }

  POSTouchLayoutProfileResolution resolveDetailed(String id) {
    final normalizedId = id.trim();
    final profile = findById(normalizedId);
    if (profile != null) {
      return POSTouchLayoutProfileResolution(
        requestedId: normalizedId,
        profile: profile,
        usedFallback: false,
      );
    }

    return POSTouchLayoutProfileResolution(
      requestedId: normalizedId,
      profile: defaultProfile,
      usedFallback: true,
      fallbackReason:
          normalizedId.isEmpty
              ? 'No POS touch layout profile id was selected.'
              : 'POS touch layout profile "$normalizedId" is not registered.',
    );
  }

  POSTouchLayoutProfile recommendFor({
    required String productLine,
    required POSExperienceFormFactor formFactor,
    required POSLayoutPreference preferredLayout,
    Iterable<String> traits = const [],
  }) {
    final scored =
        profiles
            .map(
              (profile) => MapEntry(
                profile,
                profile.matchScore(
                  productLine: productLine,
                  formFactor: formFactor,
                  preferredLayout: preferredLayout,
                  traits: traits,
                ),
              ),
            )
            .where((entry) => entry.value >= 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (scored.isEmpty) return defaultProfile;
    return scored.first.key;
  }

  List<POSTouchLayoutProfileCatalogIssue> validate() {
    return POSTouchLayoutProfileCatalogValidator.validate(
      defaultProfileId: defaultProfileId,
      profiles: profiles,
    );
  }

  bool get isValid => validate().isEmpty;

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(issues.map((issue) => issue.message).join('\n'));
  }
}
