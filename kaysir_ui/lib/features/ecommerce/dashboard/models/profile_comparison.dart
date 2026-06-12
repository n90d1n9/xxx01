import 'profile_business_motion.dart';
import 'product_profile.dart';

enum ProfileLaunchComplexity { lean, standard, advanced }

extension ProfileLaunchComplexityLabel on ProfileLaunchComplexity {
  String get label {
    return switch (this) {
      ProfileLaunchComplexity.lean => 'Lean launch',
      ProfileLaunchComplexity.standard => 'Standard launch',
      ProfileLaunchComplexity.advanced => 'Advanced launch',
    };
  }
}

class ProfileComparisonRow {
  final String profileId;
  final String label;
  final String presentationLabel;
  final int salesChannelCount;
  final int capabilityCount;
  final int moduleCount;
  final int actionRuleCount;
  final int searchKeywordCount;
  final int launchComplexityScore;
  final ProfileLaunchComplexity launchComplexity;
  final ProfileBusinessMotion businessMotion;

  const ProfileComparisonRow({
    required this.profileId,
    required this.label,
    required this.presentationLabel,
    required this.salesChannelCount,
    required this.capabilityCount,
    required this.moduleCount,
    required this.actionRuleCount,
    required this.searchKeywordCount,
    required this.launchComplexityScore,
    required this.launchComplexity,
    required this.businessMotion,
  }) : assert(salesChannelCount >= 0),
       assert(capabilityCount >= 0),
       assert(moduleCount >= 0),
       assert(actionRuleCount >= 0),
       assert(searchKeywordCount >= 0),
       assert(launchComplexityScore >= 0);

  factory ProfileComparisonRow.fromProfile(ProductProfile profile) {
    final salesChannelCount = profile.salesChannels.length;
    final capabilityCount = profile.capabilities.length;
    final moduleCount = profile.modules.length;
    final actionRuleCount = profile.actionRules.length;
    final launchComplexityScore = profileLaunchComplexityScoreForProfile(
      profile,
    );

    return ProfileComparisonRow(
      profileId: profile.id,
      label: profile.label,
      presentationLabel: profile.presentationProfile.label,
      salesChannelCount: salesChannelCount,
      capabilityCount: capabilityCount,
      moduleCount: moduleCount,
      actionRuleCount: actionRuleCount,
      searchKeywordCount: profile.searchKeywords.length,
      launchComplexityScore: launchComplexityScore,
      launchComplexity: profileLaunchComplexityFor(launchComplexityScore),
      businessMotion: profileBusinessMotionForProfile(profile),
    );
  }
}

List<ProfileComparisonRow> profileComparisonRows(
  Iterable<ProductProfile> profiles,
) {
  return List.unmodifiable(profiles.map(ProfileComparisonRow.fromProfile));
}

int profileLaunchComplexityScore({
  required int salesChannelCount,
  required int capabilityCount,
  required int moduleCount,
  required int actionRuleCount,
}) {
  assert(salesChannelCount >= 0);
  assert(capabilityCount >= 0);
  assert(moduleCount >= 0);
  assert(actionRuleCount >= 0);

  return salesChannelCount + capabilityCount + moduleCount + actionRuleCount;
}

int profileLaunchComplexityScoreForProfile(ProductProfile profile) {
  return profileLaunchComplexityScore(
    salesChannelCount: profile.salesChannels.length,
    capabilityCount: profile.capabilities.length,
    moduleCount: profile.modules.length,
    actionRuleCount: profile.actionRules.length,
  );
}

ProfileLaunchComplexity profileLaunchComplexityFor(int score) {
  assert(score >= 0);

  if (score <= 17) return ProfileLaunchComplexity.lean;
  if (score <= 20) return ProfileLaunchComplexity.standard;

  return ProfileLaunchComplexity.advanced;
}

ProfileLaunchComplexity profileLaunchComplexityForProfile(
  ProductProfile profile,
) {
  return profileLaunchComplexityFor(
    profileLaunchComplexityScoreForProfile(profile),
  );
}
