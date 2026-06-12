import '../states/pos_layout_provider.dart';
import 'pos_behavior_set.dart';
import 'pos_data_trait.dart';
import 'pos_experience.dart';
import 'pos_experience_manifest.dart';
import 'pos_feature_module.dart';

enum POSExperienceRecipeArchetype {
  standardCashier,
  quickCheckout,
  assistedService,
  custom,
}

class POSExperienceRecipe {
  final POSExperienceRecipeArchetype archetype;
  final String id;
  final String label;
  final String description;
  final String productLine;
  final String archetypeKey;
  final String archetypeLabel;
  final POSExperienceReleaseStage releaseStage;
  final List<POSExperienceFormFactor> supportedFormFactors;
  final List<String> traits;
  final List<String> dataTraits;
  final POSLayoutPreference preferredLayout;
  final POSExperienceCapabilities capabilities;
  final List<POSFeatureModule> modules;
  final POSBehaviorSet behaviors;

  const POSExperienceRecipe._({
    required this.archetype,
    required this.id,
    required this.label,
    required this.description,
    required this.productLine,
    required this.archetypeKey,
    required this.archetypeLabel,
    required this.releaseStage,
    required this.supportedFormFactors,
    required this.traits,
    required this.dataTraits,
    required this.preferredLayout,
    required this.capabilities,
    required this.modules,
    required this.behaviors,
  });

  factory POSExperienceRecipe.standardCashier({
    required String id,
    required String label,
    required String description,
    required String productLine,
    required String archetypeKey,
    required String archetypeLabel,
    POSExperienceReleaseStage releaseStage = POSExperienceReleaseStage.preview,
    List<POSExperienceFormFactor> supportedFormFactors = const [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
    ],
    List<String> traits = const ['operator-led', 'full-service'],
    List<String> dataTraits = POSDataTraitKeys.standardCommerce,
    POSLayoutPreference preferredLayout = POSLayoutPreference.auto,
    POSExperienceCapabilities capabilities = const POSExperienceCapabilities(),
    List<POSFeatureModule> modules = POSFeatureModules.standardCashier,
    POSBehaviorSet behaviors = POSBehaviorSet.standard,
  }) {
    return POSExperienceRecipe._(
      archetype: POSExperienceRecipeArchetype.standardCashier,
      id: id,
      label: label,
      description: description,
      productLine: productLine,
      archetypeKey: archetypeKey,
      archetypeLabel: archetypeLabel,
      releaseStage: releaseStage,
      supportedFormFactors: supportedFormFactors,
      traits: traits,
      dataTraits: dataTraits,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
    );
  }

  factory POSExperienceRecipe.quickCheckout({
    required String id,
    required String label,
    required String description,
    required String productLine,
    required String archetypeKey,
    required String archetypeLabel,
    POSExperienceReleaseStage releaseStage = POSExperienceReleaseStage.preview,
    List<POSExperienceFormFactor> supportedFormFactors = const [
      POSExperienceFormFactor.kiosk,
      POSExperienceFormFactor.tablet,
      POSExperienceFormFactor.mobile,
    ],
    List<String> traits = const ['touch-first', 'fast-tender'],
    List<String> dataTraits = POSDataTraitKeys.quickCheckout,
    POSLayoutPreference preferredLayout = POSLayoutPreference.checkout,
    POSExperienceCapabilities capabilities = const POSExperienceCapabilities(
      customerSelection: false,
      heldOrders: false,
      promotions: false,
      newOrders: false,
      layoutSwitching: false,
    ),
    List<POSFeatureModule> modules = POSFeatureModules.quickCheckout,
    POSBehaviorSet behaviors = POSBehaviorSet.quickCheckout,
  }) {
    return POSExperienceRecipe._(
      archetype: POSExperienceRecipeArchetype.quickCheckout,
      id: id,
      label: label,
      description: description,
      productLine: productLine,
      archetypeKey: archetypeKey,
      archetypeLabel: archetypeLabel,
      releaseStage: releaseStage,
      supportedFormFactors: supportedFormFactors,
      traits: traits,
      dataTraits: dataTraits,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
    );
  }

  factory POSExperienceRecipe.assistedService({
    required String id,
    required String label,
    required String description,
    required String productLine,
    required String archetypeKey,
    required String archetypeLabel,
    POSExperienceReleaseStage releaseStage = POSExperienceReleaseStage.preview,
    List<POSExperienceFormFactor> supportedFormFactors = const [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
    ],
    List<String> traits = const ['customer-led', 'guided-closeout'],
    List<String> dataTraits = POSDataTraitKeys.assistedService,
    POSLayoutPreference preferredLayout = POSLayoutPreference.auto,
    POSExperienceCapabilities capabilities = const POSExperienceCapabilities(
      barcodeScanning: false,
      promotions: false,
    ),
    List<POSFeatureModule> modules = POSFeatureModules.assistedService,
    POSBehaviorSet behaviors = POSBehaviorSet.assistedService,
  }) {
    return POSExperienceRecipe._(
      archetype: POSExperienceRecipeArchetype.assistedService,
      id: id,
      label: label,
      description: description,
      productLine: productLine,
      archetypeKey: archetypeKey,
      archetypeLabel: archetypeLabel,
      releaseStage: releaseStage,
      supportedFormFactors: supportedFormFactors,
      traits: traits,
      dataTraits: dataTraits,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
    );
  }

  factory POSExperienceRecipe.custom({
    required String id,
    required String label,
    required String description,
    required String productLine,
    required String archetypeKey,
    required String archetypeLabel,
    required POSLayoutPreference preferredLayout,
    required POSExperienceCapabilities capabilities,
    required List<POSFeatureModule> modules,
    required POSBehaviorSet behaviors,
    POSExperienceReleaseStage releaseStage = POSExperienceReleaseStage.preview,
    List<POSExperienceFormFactor> supportedFormFactors = const [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
    ],
    List<String> traits = const [],
    List<String> dataTraits = const [],
  }) {
    return POSExperienceRecipe._(
      archetype: POSExperienceRecipeArchetype.custom,
      id: id,
      label: label,
      description: description,
      productLine: productLine,
      archetypeKey: archetypeKey,
      archetypeLabel: archetypeLabel,
      releaseStage: releaseStage,
      supportedFormFactors: supportedFormFactors,
      traits: traits,
      dataTraits: dataTraits,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
    );
  }

  factory POSExperienceRecipe.fromExperience(
    POSExperience experience, {
    POSExperienceRecipeArchetype archetype =
        POSExperienceRecipeArchetype.custom,
  }) {
    final manifest = experience.manifest;
    return POSExperienceRecipe._(
      archetype: archetype,
      id: experience.id,
      label: experience.label,
      description: experience.description,
      productLine: manifest.productLine,
      archetypeKey: manifest.archetypeKey,
      archetypeLabel: manifest.archetypeLabel,
      releaseStage: manifest.releaseStage,
      supportedFormFactors: List.unmodifiable(manifest.supportedFormFactors),
      traits: List.unmodifiable(manifest.traits),
      dataTraits: List.unmodifiable(manifest.dataTraits),
      preferredLayout: experience.preferredLayout,
      capabilities: experience.capabilities,
      modules: List.unmodifiable(experience.modules),
      behaviors: experience.behaviors,
    );
  }

  POSExperienceManifest get manifest {
    return POSExperienceManifest(
      productLine: productLine,
      archetypeKey: archetypeKey,
      archetypeLabel: archetypeLabel,
      releaseStage: releaseStage,
      supportedFormFactors: List.unmodifiable(supportedFormFactors),
      traits: List.unmodifiable(traits),
      dataTraits: List.unmodifiable(dataTraits),
    );
  }

  POSExperience toExperience() {
    return POSExperience(
      id: id,
      label: label,
      description: description,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: List.unmodifiable(modules),
      behaviors: behaviors,
      manifest: manifest,
    );
  }

  bool requiresDataTrait(String dataTrait) {
    return dataTraits.any((trait) => trait == dataTrait);
  }

  POSExperienceRecipe copyWith({
    String? id,
    String? label,
    String? description,
    String? productLine,
    String? archetypeKey,
    String? archetypeLabel,
    POSExperienceReleaseStage? releaseStage,
    List<POSExperienceFormFactor>? supportedFormFactors,
    List<String>? traits,
    List<String>? dataTraits,
    POSLayoutPreference? preferredLayout,
    POSExperienceCapabilities? capabilities,
    List<POSFeatureModule>? modules,
    POSBehaviorSet? behaviors,
  }) {
    return POSExperienceRecipe._(
      archetype: archetype,
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      productLine: productLine ?? this.productLine,
      archetypeKey: archetypeKey ?? this.archetypeKey,
      archetypeLabel: archetypeLabel ?? this.archetypeLabel,
      releaseStage: releaseStage ?? this.releaseStage,
      supportedFormFactors: supportedFormFactors ?? this.supportedFormFactors,
      traits: traits ?? this.traits,
      dataTraits: dataTraits ?? this.dataTraits,
      preferredLayout: preferredLayout ?? this.preferredLayout,
      capabilities: capabilities ?? this.capabilities,
      modules: modules ?? this.modules,
      behaviors: behaviors ?? this.behaviors,
    );
  }
}
