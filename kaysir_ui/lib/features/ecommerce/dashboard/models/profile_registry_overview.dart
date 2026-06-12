import 'product_profile.dart';

class ProfileRegistryOverview {
  final int profileCount;
  final int salesChannelCount;
  final int capabilityCount;
  final int moduleCount;
  final int actionRuleCount;
  final int searchKeywordCount;

  const ProfileRegistryOverview({
    required this.profileCount,
    required this.salesChannelCount,
    required this.capabilityCount,
    required this.moduleCount,
    required this.actionRuleCount,
    required this.searchKeywordCount,
  }) : assert(profileCount >= 0),
       assert(salesChannelCount >= 0),
       assert(capabilityCount >= 0),
       assert(moduleCount >= 0),
       assert(actionRuleCount >= 0),
       assert(searchKeywordCount >= 0);

  static const empty = ProfileRegistryOverview(
    profileCount: 0,
    salesChannelCount: 0,
    capabilityCount: 0,
    moduleCount: 0,
    actionRuleCount: 0,
    searchKeywordCount: 0,
  );

  factory ProfileRegistryOverview.fromProfiles(
    Iterable<ProductProfile> profiles,
  ) {
    final profileList = profiles.toList(growable: false);
    if (profileList.isEmpty) return empty;

    final salesChannelIds = <String>{};
    final capabilities = <ProductCapability>{};
    final moduleIds = <String>{};
    final actionRuleIds = <String>{};
    final searchKeywords = <String>{};

    for (final profile in profileList) {
      salesChannelIds.addAll(
        profile.salesChannels
            .map((channel) => channel.id.trim())
            .where((id) => id.isNotEmpty),
      );
      capabilities.addAll(profile.capabilities);
      moduleIds.addAll(
        profile.modules
            .map((module) => module.id.trim())
            .where((id) => id.isNotEmpty),
      );
      actionRuleIds.addAll(
        profile.actionRules
            .map((rule) => rule.id.trim())
            .where((id) => id.isNotEmpty),
      );
      searchKeywords.addAll(
        profile.searchKeywords
            .map(_normalizeKeyword)
            .where((keyword) => keyword.isNotEmpty),
      );
    }

    return ProfileRegistryOverview(
      profileCount: profileList.length,
      salesChannelCount: salesChannelIds.length,
      capabilityCount: capabilities.length,
      moduleCount: moduleIds.length,
      actionRuleCount: actionRuleIds.length,
      searchKeywordCount: searchKeywords.length,
    );
  }
}

String _normalizeKeyword(String keyword) {
  return keyword.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
