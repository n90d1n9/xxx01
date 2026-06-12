import 'pos_data_contract.dart';
import 'pos_data_trait.dart';
import 'pos_experience.dart';
import 'pos_experience_launch_checklist.dart';
import 'pos_experience_manifest.dart';
import 'pos_experience_recipe.dart';
import 'pos_experience_registry.dart';
import 'pos_feature_module.dart';

class POSProductProfile {
  final String id;
  final String label;
  final String description;
  final POSExperienceRecipe recipe;
  final POSExperience? experienceOverride;
  final List<POSFeatureModule> requiredModules;
  final List<POSExperienceFormFactor> requiredFormFactors;
  final List<String> requiredDataTraits;
  final List<POSDataTraitAdapter> dataAdapters;
  final List<POSDataTraitContract> extraDataContracts;

  POSProductProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.recipe,
    this.experienceOverride,
    Iterable<POSFeatureModule> requiredModules = const [],
    Iterable<POSExperienceFormFactor> requiredFormFactors = const [],
    Iterable<String> requiredDataTraits = const [],
    Iterable<POSDataTraitAdapter> dataAdapters = const [],
    Iterable<POSDataTraitContract> extraDataContracts = const [],
  }) : requiredModules = List.unmodifiable(requiredModules),
       requiredFormFactors = List.unmodifiable(requiredFormFactors),
       requiredDataTraits = List.unmodifiable(requiredDataTraits),
       dataAdapters = List.unmodifiable(dataAdapters),
       extraDataContracts = List.unmodifiable(extraDataContracts);

  POSExperience get experience => experienceOverride ?? recipe.toExperience();

  POSExperienceLaunchChecklist get launchChecklist {
    return POSExperienceLaunchChecklist.evaluate(
      experience: experience,
      requiredModules: requiredModules,
      requiredFormFactors: requiredFormFactors,
      requiredDataTraits: requiredDataTraits,
      dataAdapters: dataAdapters,
      extraDataContracts: extraDataContracts,
    );
  }

  bool get canLaunch => launchChecklist.canLaunch;

  bool get fullyReady => launchChecklist.fullyReady;

  List<String> get dataTraitLabels {
    return POSDataTraits.labelsFor(recipe.dataTraits);
  }

  bool requiresDataTrait(String dataTrait) {
    return requiredDataTraits.contains(dataTrait.trim());
  }

  POSProductProfile copyWith({
    String? id,
    String? label,
    String? description,
    POSExperienceRecipe? recipe,
    POSExperience? experienceOverride,
    Iterable<POSFeatureModule>? requiredModules,
    Iterable<POSExperienceFormFactor>? requiredFormFactors,
    Iterable<String>? requiredDataTraits,
    Iterable<POSDataTraitAdapter>? dataAdapters,
    Iterable<POSDataTraitContract>? extraDataContracts,
  }) {
    return POSProductProfile(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      recipe: recipe ?? this.recipe,
      experienceOverride: experienceOverride ?? this.experienceOverride,
      requiredModules: requiredModules ?? this.requiredModules,
      requiredFormFactors: requiredFormFactors ?? this.requiredFormFactors,
      requiredDataTraits: requiredDataTraits ?? this.requiredDataTraits,
      dataAdapters: dataAdapters ?? this.dataAdapters,
      extraDataContracts: extraDataContracts ?? this.extraDataContracts,
    );
  }
}

class POSProductProfileCatalog {
  final List<POSProductProfile> profiles;

  POSProductProfileCatalog({required Iterable<POSProductProfile> profiles})
    : profiles = List.unmodifiable(profiles);

  List<String> get profileIds {
    return profiles.map((profile) => profile.id).toList(growable: false);
  }

  List<POSExperience> get experiences {
    return profiles
        .map((profile) => profile.experience)
        .toList(growable: false);
  }

  POSExperienceRegistry get experienceRegistry {
    return POSExperienceRegistry(experiences: experiences);
  }

  List<POSExperienceLaunchChecklist> get launchChecklists {
    return profiles
        .map((profile) => profile.launchChecklist)
        .toList(growable: false);
  }

  List<POSProductProfile> get launchableProfiles {
    return profiles
        .where((profile) => profile.canLaunch)
        .toList(growable: false);
  }

  List<POSProductProfile> get blockedProfiles {
    return profiles
        .where((profile) => !profile.canLaunch)
        .toList(growable: false);
  }

  POSProductProfile? findById(String id) {
    final normalizedId = id.trim();
    for (final profile in profiles) {
      if (profile.id == normalizedId) return profile;
    }

    return null;
  }

  POSProductProfile? findByModeId(String modeId) {
    final normalizedId = modeId.trim();
    for (final profile in profiles) {
      if (profile.recipe.id == normalizedId) return profile;
    }

    return null;
  }
}
