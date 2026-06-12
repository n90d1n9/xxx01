import 'sales_channel_profile.dart';

/// Overview of how sales-channel profile packs compose the active registry.
class ProductSalesChannelProfilePackOverview {
  const ProductSalesChannelProfilePackOverview({
    required this.packs,
    required this.selectedProfile,
    required this.fallbackProfile,
    required this.registryProfileCount,
  });

  final List<ProductSalesChannelProfilePackSummary> packs;
  final ProductSalesChannelProfile selectedProfile;
  final ProductSalesChannelProfile fallbackProfile;
  final int registryProfileCount;

  bool get hasPacks => packs.isNotEmpty;

  bool get hasPackComposition => packs.length > 1;

  ProductSalesChannelProfilePackSummary? get selectedSourcePack {
    for (final pack in packs) {
      if (pack.isSelectedSource) return pack;
    }

    return null;
  }

  ProductSalesChannelProfilePackSummary? get fallbackSourcePack {
    for (final pack in packs) {
      if (pack.isFallbackSource) return pack;
    }

    return null;
  }

  String get statusLabel {
    if (!hasPacks) return 'Registry override';

    return hasPackComposition ? 'Composable' : 'Single pack';
  }

  String get packCountLabel => _countLabel(packs.length, 'pack');

  String get profileCountLabel => _countLabel(registryProfileCount, 'profile');

  String get selectedSourceLabel {
    return selectedSourcePack?.title ?? 'Custom registry';
  }

  String get fallbackLabel => 'Fallback: ${fallbackProfile.title}';

  String get subtitleLabel {
    if (!hasPacks) {
      return 'Custom registry supplies $profileCountLabel';
    }
    if (hasPackComposition) {
      return '$packCountLabel active, $profileCountLabel available';
    }

    return '$selectedSourceLabel supplies $profileCountLabel';
  }
}

/// Summary of one pack contributing sales-channel profiles.
class ProductSalesChannelProfilePackSummary {
  const ProductSalesChannelProfilePackSummary({
    required this.id,
    required this.title,
    required this.profileCount,
    required this.profileTitles,
    required this.isSelectedSource,
    required this.isFallbackSource,
  });

  final String id;
  final String title;
  final int profileCount;
  final List<String> profileTitles;
  final bool isSelectedSource;
  final bool isFallbackSource;

  String get profileCountLabel => _countLabel(profileCount, 'profile');

  String get profilePreviewLabel {
    if (profileTitles.isEmpty) return 'No profiles';
    if (profileTitles.length <= 2) return profileTitles.join(', ');

    return '${profileTitles.first}, ${profileTitles[1]} + '
        '${profileTitles.length - 2} more';
  }

  String get statusLabel {
    if (isSelectedSource && isFallbackSource) return 'Current fallback';
    if (isSelectedSource) return 'Current';
    if (isFallbackSource) return 'Fallback';

    return 'Available';
  }
}

/// Builds a pack-source overview for the selected sales-channel profile.
ProductSalesChannelProfilePackOverview
buildProductSalesChannelProfilePackOverview({
  required List<ProductSalesChannelProfilePack> packs,
  required ProductSalesChannelProfileRegistry registry,
  required ProductSalesChannelProfile selectedProfile,
}) {
  final fallbackProfile = registry.fallbackProfile;
  final selectedSourceIndex = _lastPackIndexContainingProfile(
    packs,
    selectedProfile.id,
  );
  final fallbackSourceIndex = _lastPackIndexContainingProfile(
    packs,
    fallbackProfile.id,
  );

  return ProductSalesChannelProfilePackOverview(
    packs: List.unmodifiable([
      for (var index = 0; index < packs.length; index += 1)
        ProductSalesChannelProfilePackSummary(
          id: packs[index].id,
          title: packs[index].title,
          profileCount: packs[index].profiles.length,
          profileTitles: [
            for (final profile in packs[index].profiles) profile.title,
          ],
          isSelectedSource: index == selectedSourceIndex,
          isFallbackSource: index == fallbackSourceIndex,
        ),
    ]),
    selectedProfile: selectedProfile,
    fallbackProfile: fallbackProfile,
    registryProfileCount: registry.profiles.length,
  );
}

int? _lastPackIndexContainingProfile(
  List<ProductSalesChannelProfilePack> packs,
  ProductSalesChannelProfileId profileId,
) {
  for (var index = packs.length - 1; index >= 0; index -= 1) {
    final pack = packs[index];
    for (final profile in pack.profiles) {
      if (profile.id == profileId) return index;
    }
  }

  return null;
}

String _countLabel(int count, String noun) {
  if (count == 1) return '1 $noun';

  return '$count ${noun}s';
}
