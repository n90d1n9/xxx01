import '../states/pos_layout_provider.dart';
import 'pos_behavior_set.dart';
import 'pos_experience.dart';
import 'pos_experience_manifest.dart';
import 'pos_experience_recipe.dart';
import 'pos_feature_module.dart';

abstract final class POSExperienceFactory {
  static POSExperience standardCashier({
    required String id,
    required String label,
    required String description,
    required POSExperienceManifest manifest,
    POSLayoutPreference preferredLayout = POSLayoutPreference.auto,
    POSExperienceCapabilities capabilities = const POSExperienceCapabilities(),
    List<POSFeatureModule> modules = POSFeatureModules.standardCashier,
    POSBehaviorSet behaviors = POSBehaviorSet.standard,
  }) {
    return custom(
      id: id,
      label: label,
      description: description,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
      manifest: manifest,
    );
  }

  static POSExperience quickCheckout({
    required String id,
    required String label,
    required String description,
    required POSExperienceManifest manifest,
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
    return custom(
      id: id,
      label: label,
      description: description,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
      manifest: manifest,
    );
  }

  static POSExperience assistedService({
    required String id,
    required String label,
    required String description,
    required POSExperienceManifest manifest,
    POSLayoutPreference preferredLayout = POSLayoutPreference.auto,
    POSExperienceCapabilities capabilities = const POSExperienceCapabilities(
      barcodeScanning: false,
      promotions: false,
    ),
    List<POSFeatureModule> modules = POSFeatureModules.assistedService,
    POSBehaviorSet behaviors = POSBehaviorSet.assistedService,
  }) {
    return custom(
      id: id,
      label: label,
      description: description,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules,
      behaviors: behaviors,
      manifest: manifest,
    );
  }

  static POSExperience fromBase({
    required POSExperience base,
    String? id,
    String? label,
    String? description,
    POSLayoutPreference? preferredLayout,
    POSExperienceCapabilities? capabilities,
    List<POSFeatureModule>? modules,
    POSBehaviorSet? behaviors,
    POSExperienceManifest? manifest,
  }) {
    return base.copyWith(
      id: id,
      label: label,
      description: description,
      preferredLayout: preferredLayout,
      capabilities: capabilities,
      modules: modules == null ? null : List.unmodifiable(modules),
      behaviors: behaviors,
      manifest: manifest,
    );
  }

  static POSExperience fromRecipe(POSExperienceRecipe recipe) {
    return recipe.toExperience();
  }

  static POSExperience custom({
    required String id,
    required String label,
    required String description,
    required POSLayoutPreference preferredLayout,
    required POSExperienceCapabilities capabilities,
    required List<POSFeatureModule> modules,
    required POSBehaviorSet behaviors,
    required POSExperienceManifest manifest,
  }) {
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
}
