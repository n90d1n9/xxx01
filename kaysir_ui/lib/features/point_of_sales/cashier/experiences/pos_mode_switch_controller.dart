import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/pos_layout_provider.dart';
import 'pos_experience.dart';
import 'pos_experience_provider.dart';
import 'pos_mode_switch_policy.dart';
import 'pos_product_profile.dart';

class POSModeSwitchOption {
  final POSExperience experience;
  final POSProductProfile? productProfile;
  final POSModeSwitchDecision decision;
  final bool selected;

  const POSModeSwitchOption({
    required this.experience,
    required this.productProfile,
    required this.decision,
    required this.selected,
  });

  String get id => experience.id;

  bool get canSwitch => decision.canSwitch;
}

class POSModeSwitchSection {
  final String productLine;
  final List<POSModeSwitchOption> options;

  POSModeSwitchSection({
    required this.productLine,
    required Iterable<POSModeSwitchOption> options,
  }) : options = List.unmodifiable(options);

  int get optionCount => options.length;
}

class POSModeSwitchState {
  final POSExperience currentExperience;
  final List<POSModeSwitchSection> sections;

  POSModeSwitchState({
    required this.currentExperience,
    required Iterable<POSModeSwitchSection> sections,
  }) : sections = List.unmodifiable(sections);

  Iterable<POSModeSwitchOption> get options {
    return sections.expand((section) => section.options);
  }

  bool get isSingleOption => options.length <= 1;

  POSModeSwitchOption? findOption(String experienceId) {
    final normalizedId = experienceId.trim();
    for (final option in options) {
      if (option.id == normalizedId) return option;
    }

    return null;
  }
}

class POSModeSwitchController {
  final Ref _ref;
  final POSModeSwitchState state;

  POSModeSwitchController({required Ref ref, required this.state}) : _ref = ref;

  POSModeSwitchOption optionFor(String experienceId) {
    final option = state.findOption(experienceId);
    if (option == null) {
      throw StateError('POS mode "$experienceId" is not available.');
    }

    return option;
  }

  void apply(POSModeSwitchOption option) {
    final decision = option.decision;
    if (decision.isBlocked) {
      throw StateError(decision.message);
    }

    _ref.read(selectedPOSExperienceIdProvider.notifier).state =
        option.experience.id;
    _ref.read(posLayoutPreferenceProvider.notifier).state =
        option.experience.preferredLayout;
  }
}

final posModeSwitchStateProvider = Provider.family<POSModeSwitchState, double>((
  ref,
  viewportWidth,
) {
  final catalog = ref.watch(posExperienceCatalogProvider);
  final profileCatalog = ref.watch(posProductProfileCatalogProvider);
  final currentExperience = ref.watch(posExperienceProvider);

  return POSModeSwitchState(
    currentExperience: currentExperience,
    sections: catalog.sections.map((section) {
      return POSModeSwitchSection(
        productLine: section.productLine,
        options: section.experiences.map((experience) {
          final productProfile = profileCatalog.findByModeId(experience.id);

          return POSModeSwitchOption(
            experience: experience,
            productProfile: productProfile,
            decision: POSModeSwitchPolicy.evaluate(
              experience: experience,
              viewportWidth: viewportWidth,
              productProfile: productProfile,
            ),
            selected: experience.id == currentExperience.id,
          );
        }),
      );
    }),
  );
});

final posModeSwitchControllerProvider =
    Provider.family<POSModeSwitchController, double>((ref, viewportWidth) {
      return POSModeSwitchController(
        ref: ref,
        state: ref.watch(posModeSwitchStateProvider(viewportWidth)),
      );
    });
