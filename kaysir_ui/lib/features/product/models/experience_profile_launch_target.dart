import '../product_routes.dart';
import 'experience_profile.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

/// Source used to decide which route mode a profile launch should apply.
enum ProductExperienceProfileLaunchModeSource {
  current,
  profile,
  mixed,
  edition,
}

/// Navigation target produced from an experience profile and mode defaults.
class ProductExperienceProfileLaunchTarget {
  const ProductExperienceProfileLaunchTarget({
    required this.profile,
    this.packId,
    this.channelProfileId,
    this.modeSource,
  });

  factory ProductExperienceProfileLaunchTarget.forProfile(
    ProductExperienceProfile profile, {
    ProductManagementPackId? fallbackPackId,
    ProductSalesChannelProfileId? fallbackChannelProfileId,
  }) {
    return ProductExperienceProfileLaunchTarget(
      profile: profile,
      packId: profile.defaultPackId ?? fallbackPackId,
      channelProfileId:
          profile.defaultChannelProfileId ?? fallbackChannelProfileId,
      modeSource: _modeSourceForProfile(profile),
    );
  }

  final ProductExperienceProfile profile;
  final ProductManagementPackId? packId;
  final ProductSalesChannelProfileId? channelProfileId;
  final ProductExperienceProfileLaunchModeSource? modeSource;

  String get title {
    final value = profile.workspaceTitle.trim();
    return value.isEmpty ? profile.id.value : value;
  }

  String get subtitle {
    final value = profile.workspaceSubtitle.trim();
    return value.isEmpty ? 'Product workspace' : value;
  }

  String get actionLabel => 'Open workspace';

  String get uri {
    return ProductRoutes.workspaceUri(
      experience: profile.id.value,
      pack: packId,
      profile: channelProfileId,
    );
  }

  String get modeSourceLabel {
    switch (modeSource ?? _modeSourceForProfile(profile)) {
      case ProductExperienceProfileLaunchModeSource.current:
        return 'Current mode';
      case ProductExperienceProfileLaunchModeSource.profile:
        return 'Profile mode';
      case ProductExperienceProfileLaunchModeSource.mixed:
        return 'Mixed mode';
      case ProductExperienceProfileLaunchModeSource.edition:
        return 'Edition mode';
    }
  }
}

ProductExperienceProfileLaunchModeSource _modeSourceForProfile(
  ProductExperienceProfile profile,
) {
  final hasProfilePack = profile.defaultPackId != null;
  final hasProfileChannel = profile.defaultChannelProfileId != null;

  if (hasProfilePack && hasProfileChannel) {
    return ProductExperienceProfileLaunchModeSource.profile;
  }
  if (hasProfilePack || hasProfileChannel) {
    return ProductExperienceProfileLaunchModeSource.mixed;
  }

  return ProductExperienceProfileLaunchModeSource.current;
}

/// Builds launch targets for all profiles in a registry.
List<ProductExperienceProfileLaunchTarget>
productExperienceProfileLaunchTargetsForRegistry(
  ProductExperienceProfileRegistry registry, {
  ProductManagementPackId? fallbackPackId,
  ProductSalesChannelProfileId? fallbackChannelProfileId,
}) {
  return [
    for (final profile in registry.profiles)
      ProductExperienceProfileLaunchTarget.forProfile(
        profile,
        fallbackPackId: fallbackPackId,
        fallbackChannelProfileId: fallbackChannelProfileId,
      ),
  ];
}
