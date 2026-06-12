import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_experience.dart';
import 'pos_product_runtime_pack.dart';

class POSProductRuntimePackSwitchPlan {
  final POSProductRuntimePack pack;
  final POSExperience? experience;
  final POSCommerceChannel? commerceChannel;
  final bool preservesExperience;
  final bool preservesCommerceChannel;

  const POSProductRuntimePackSwitchPlan({
    required this.pack,
    required this.experience,
    required this.commerceChannel,
    required this.preservesExperience,
    required this.preservesCommerceChannel,
  });

  factory POSProductRuntimePackSwitchPlan.resolve({
    required POSProductRuntimePack pack,
    required String currentExperienceId,
    required String currentCommerceChannelId,
    bool preserveCurrentSelections = true,
  }) {
    final experienceResolution = _resolveExperience(
      pack,
      currentExperienceId: preserveCurrentSelections ? currentExperienceId : '',
    );
    final channelResolution = _resolveCommerceChannel(
      pack,
      currentCommerceChannelId:
          preserveCurrentSelections ? currentCommerceChannelId : '',
    );

    return POSProductRuntimePackSwitchPlan(
      pack: pack,
      experience: experienceResolution.experience,
      commerceChannel: channelResolution.commerceChannel,
      preservesExperience:
          preserveCurrentSelections && experienceResolution.preserved,
      preservesCommerceChannel:
          preserveCurrentSelections && channelResolution.preserved,
    );
  }

  POSLayoutPreference? get layoutPreference {
    return commerceChannel?.preferredLayout ?? experience?.preferredLayout;
  }

  bool get preservesSelections {
    return preservesExperience && preservesCommerceChannel;
  }

  String get experienceLabel => experience?.label ?? 'No POS mode';

  String get commerceChannelLabel => commerceChannel?.label ?? 'No channel';

  String get selectionLabel => '$experienceLabel / $commerceChannelLabel';

  String get impactLabel {
    if (preservesSelections) return 'Keeps current mode and channel';
    if (preservesExperience) return 'Keeps mode, switches channel';
    if (preservesCommerceChannel) return 'Switches mode, keeps channel';
    return 'Switches mode and channel';
  }

  static _ExperienceResolution _resolveExperience(
    POSProductRuntimePack pack, {
    required String currentExperienceId,
  }) {
    final registry = pack.productProfileCatalog.experienceRegistry;
    final currentExperience = registry.findById(currentExperienceId);
    if (currentExperience != null) {
      return _ExperienceResolution(
        experience: currentExperience,
        preserved: true,
      );
    }

    final launchableProfiles = pack.productProfileCatalog.launchableProfiles;
    if (launchableProfiles.isNotEmpty) {
      return _ExperienceResolution(
        experience: launchableProfiles.first.experience,
        preserved: false,
      );
    }

    final experiences = pack.productProfileCatalog.experiences;
    return _ExperienceResolution(
      experience: experiences.isEmpty ? null : experiences.first,
      preserved: false,
    );
  }

  static _CommerceChannelResolution _resolveCommerceChannel(
    POSProductRuntimePack pack, {
    required String currentCommerceChannelId,
  }) {
    final registry = pack.commerceChannelRegistry;
    final currentChannel = registry.findById(currentCommerceChannelId);
    if (currentChannel != null) {
      return _CommerceChannelResolution(
        commerceChannel: currentChannel,
        preserved: true,
      );
    }

    final defaultChannel = registry.findById(registry.defaultChannelId);
    if (defaultChannel != null) {
      return _CommerceChannelResolution(
        commerceChannel: defaultChannel,
        preserved: false,
      );
    }

    return _CommerceChannelResolution(
      commerceChannel:
          registry.channels.isEmpty ? null : registry.channels.first,
      preserved: false,
    );
  }
}

class _ExperienceResolution {
  final POSExperience? experience;
  final bool preserved;

  const _ExperienceResolution({
    required this.experience,
    required this.preserved,
  });
}

class _CommerceChannelResolution {
  final POSCommerceChannel? commerceChannel;
  final bool preserved;

  const _CommerceChannelResolution({
    required this.commerceChannel,
    required this.preserved,
  });
}
