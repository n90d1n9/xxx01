import 'pos_experience.dart';
import 'pos_experience_action_policy.dart';
import 'pos_data_contract.dart';
import 'pos_data_trait.dart';
import 'pos_experience_manifest.dart';
import 'pos_experience_recipe.dart';
import 'pos_experience_registry.dart';
import 'pos_feature_module.dart';

enum POSLaunchCheckStatus { passed, warning, failed }

enum POSLaunchCheckArea {
  identity,
  manifest,
  registry,
  screens,
  modules,
  data,
  actions,
  checkout,
  payment,
  release,
}

class POSExperienceLaunchCheckItem {
  final String id;
  final String label;
  final String detail;
  final POSLaunchCheckStatus status;
  final POSLaunchCheckArea area;

  const POSExperienceLaunchCheckItem({
    required this.id,
    required this.label,
    required this.detail,
    required this.status,
    required this.area,
  });

  bool get blocksLaunch => status == POSLaunchCheckStatus.failed;
}

class POSExperienceLaunchChecklist {
  final POSExperience experience;
  final List<POSExperienceLaunchCheckItem> items;

  const POSExperienceLaunchChecklist({
    required this.experience,
    required this.items,
  });

  factory POSExperienceLaunchChecklist.evaluate({
    required POSExperience experience,
    Iterable<POSFeatureModule> requiredModules = const [],
    Iterable<POSExperienceFormFactor> requiredFormFactors = const [],
    Iterable<String> requiredDataTraits = const [],
    Iterable<POSDataTraitAdapter> dataAdapters = const [],
    Iterable<POSDataTraitContract> extraDataContracts = const [],
  }) {
    final items = <POSExperienceLaunchCheckItem>[
      _identityCheck(experience),
      _manifestCheck(experience),
      _registryCheck(experience),
      _requiredModuleCheck(experience, requiredModules),
      _requiredFormFactorCheck(experience, requiredFormFactors),
      _requiredDataTraitCheck(experience, requiredDataTraits),
      _dataContractCheck(experience, dataAdapters, extraDataContracts),
      _actionAvailabilityCheck(experience),
      _checkoutBehaviorCheck(experience),
      _paymentBehaviorCheck(experience),
      _releaseStageCheck(experience),
    ];

    return POSExperienceLaunchChecklist(
      experience: experience,
      items: List.unmodifiable(items),
    );
  }

  factory POSExperienceLaunchChecklist.fromRecipe(
    POSExperienceRecipe recipe, {
    Iterable<POSFeatureModule> requiredModules = const [],
    Iterable<POSExperienceFormFactor> requiredFormFactors = const [],
    Iterable<String> requiredDataTraits = const [],
    Iterable<POSDataTraitAdapter> dataAdapters = const [],
    Iterable<POSDataTraitContract> extraDataContracts = const [],
  }) {
    return POSExperienceLaunchChecklist.evaluate(
      experience: recipe.toExperience(),
      requiredModules: requiredModules,
      requiredFormFactors: requiredFormFactors,
      requiredDataTraits: requiredDataTraits,
      dataAdapters: dataAdapters,
      extraDataContracts: extraDataContracts,
    );
  }

  Iterable<POSExperienceLaunchCheckItem> get failures {
    return items.where((item) => item.status == POSLaunchCheckStatus.failed);
  }

  Iterable<POSExperienceLaunchCheckItem> get warnings {
    return items.where((item) => item.status == POSLaunchCheckStatus.warning);
  }

  int get failureCount => failures.length;

  int get warningCount => warnings.length;

  bool get canLaunch => failureCount == 0;

  bool get fullyReady => canLaunch && warningCount == 0;

  String get statusLabel {
    if (failureCount > 0) return 'Blocked';
    if (warningCount > 0) return 'Needs review';
    return 'Ready';
  }
}

POSExperienceLaunchCheckItem _identityCheck(POSExperience experience) {
  final missing = <String>[
    if (experience.id.trim().isEmpty) 'id',
    if (experience.label.trim().isEmpty) 'label',
    if (experience.description.trim().isEmpty) 'description',
  ];

  return POSExperienceLaunchCheckItem(
    id: 'identity',
    label: 'Mode identity',
    detail:
        missing.isEmpty
            ? 'Mode has an id, label, and description.'
            : 'Missing ${missing.join(', ')}.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.identity,
  );
}

POSExperienceLaunchCheckItem _manifestCheck(POSExperience experience) {
  final manifest = experience.manifest;
  final missing = <String>[
    if (manifest.productLine.trim().isEmpty) 'product line',
    if (manifest.archetypeKey.trim().isEmpty) 'archetype key',
    if (manifest.archetypeLabel.trim().isEmpty) 'archetype label',
    if (manifest.supportedFormFactors.isEmpty) 'supported screens',
  ];

  return POSExperienceLaunchCheckItem(
    id: 'manifest',
    label: 'Launch manifest',
    detail:
        missing.isEmpty
            ? 'Manifest includes product line, archetype, and screens.'
            : 'Missing ${missing.join(', ')}.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.manifest,
  );
}

POSExperienceLaunchCheckItem _registryCheck(POSExperience experience) {
  final issues = POSExperienceRegistry(experiences: [experience]).validate();

  return POSExperienceLaunchCheckItem(
    id: 'registry',
    label: 'Registry contract',
    detail:
        issues.isEmpty
            ? 'Mode passes registry validation.'
            : '${issues.length} registry issue${issues.length == 1 ? '' : 's'} found.',
    status:
        issues.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.registry,
  );
}

POSExperienceLaunchCheckItem _requiredModuleCheck(
  POSExperience experience,
  Iterable<POSFeatureModule> requiredModules,
) {
  final moduleIds = experience.modules.map((module) => module.id).toSet();
  final missing =
      requiredModules
          .where((module) => !moduleIds.contains(module.id))
          .map((module) => module.label)
          .toList();

  return POSExperienceLaunchCheckItem(
    id: 'required_modules',
    label: 'Required modules',
    detail:
        missing.isEmpty
            ? 'Required modules are registered.'
            : 'Missing ${missing.join(', ')}.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.modules,
  );
}

POSExperienceLaunchCheckItem _requiredFormFactorCheck(
  POSExperience experience,
  Iterable<POSExperienceFormFactor> requiredFormFactors,
) {
  final missing =
      requiredFormFactors
          .where(
            (formFactor) => !experience.manifest.supportsFormFactor(formFactor),
          )
          .map((formFactor) => formFactor.label)
          .toList();

  return POSExperienceLaunchCheckItem(
    id: 'required_screens',
    label: 'Required screens',
    detail:
        missing.isEmpty
            ? 'Required screen classes are declared.'
            : 'Missing ${missing.join(', ')} support.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.screens,
  );
}

POSExperienceLaunchCheckItem _requiredDataTraitCheck(
  POSExperience experience,
  Iterable<String> requiredDataTraits,
) {
  final traitSet = experience.manifest.dataTraits.toSet();
  final missing =
      requiredDataTraits.where((trait) => !traitSet.contains(trait)).toList();
  final missingLabels = POSDataTraits.labelsFor(missing);

  return POSExperienceLaunchCheckItem(
    id: 'required_data_traits',
    label: 'Required data traits',
    detail:
        missing.isEmpty
            ? 'Required data traits are declared.'
            : 'Missing ${missingLabels.join(', ')}.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.data,
  );
}

POSExperienceLaunchCheckItem _dataContractCheck(
  POSExperience experience,
  Iterable<POSDataTraitAdapter> dataAdapters,
  Iterable<POSDataTraitContract> extraDataContracts,
) {
  final dataTraits = experience.manifest.dataTraits;
  if (dataTraits.isEmpty) {
    return const POSExperienceLaunchCheckItem(
      id: 'data_contracts',
      label: 'Data contracts',
      detail: 'No data traits declared for this mode.',
      status: POSLaunchCheckStatus.passed,
      area: POSLaunchCheckArea.data,
    );
  }

  final adapters = dataAdapters.toList(growable: false);
  final coverage = POSDataTraitContracts.evaluateCoverage(
    traitKeys: dataTraits,
    adapters: adapters,
    extraContracts: extraDataContracts,
    requireAdapters: adapters.isNotEmpty,
  );
  final unresolved = coverage.where((item) => !item.hasContract).toList();
  if (unresolved.isNotEmpty) {
    final labels = unresolved.map((item) => item.traitLabel).join(', ');
    return POSExperienceLaunchCheckItem(
      id: 'data_contracts',
      label: 'Data contracts',
      detail: 'Add contract definitions for $labels.',
      status: POSLaunchCheckStatus.warning,
      area: POSLaunchCheckArea.data,
    );
  }

  if (adapters.isEmpty) {
    return POSExperienceLaunchCheckItem(
      id: 'data_contracts',
      label: 'Data contracts',
      detail:
          '${coverage.length} data contract${coverage.length == 1 ? '' : 's'} documented.',
      status: POSLaunchCheckStatus.passed,
      area: POSLaunchCheckArea.data,
    );
  }

  final blocked = coverage.where((item) => !item.satisfied).toList();
  if (blocked.isEmpty) {
    return POSExperienceLaunchCheckItem(
      id: 'data_contracts',
      label: 'Data contracts',
      detail:
          '${adapters.length} adapter${adapters.length == 1 ? '' : 's'} satisfy declared data contracts.',
      status: POSLaunchCheckStatus.passed,
      area: POSLaunchCheckArea.data,
    );
  }

  final details = blocked
      .map((item) => '${item.traitLabel}: ${item.detail}')
      .take(2)
      .join(' ');
  return POSExperienceLaunchCheckItem(
    id: 'data_contracts',
    label: 'Data contracts',
    detail: details,
    status: POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.data,
  );
}

POSExperienceLaunchCheckItem _actionAvailabilityCheck(
  POSExperience experience,
) {
  final policy = POSExperienceActionPolicy(experience: experience);
  final unavailable =
      POSExperienceAction.values
          .map(policy.availability)
          .where(
            (availability) =>
                availability.capabilityEnabled &&
                !availability.moduleRegistered,
          )
          .map((availability) => availability.actionLabel)
          .toList();

  return POSExperienceLaunchCheckItem(
    id: 'actions',
    label: 'Action availability',
    detail:
        unavailable.isEmpty
            ? 'Enabled actions have backing modules.'
            : 'Missing modules for ${unavailable.join(', ')}.',
    status:
        unavailable.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.actions,
  );
}

POSExperienceLaunchCheckItem _checkoutBehaviorCheck(POSExperience experience) {
  final checkout = experience.checkoutBehavior;
  final missing = <String>[
    if (checkout.paymentButtonLabel.trim().isEmpty) 'payment button',
    if (checkout.completeButtonLabel.trim().isEmpty) 'complete button',
    if (checkout.finalPaymentButtonLabel.trim().isEmpty) 'final payment',
    if (checkout.partialPaymentButtonLabel.trim().isEmpty) 'partial payment',
  ];

  return POSExperienceLaunchCheckItem(
    id: 'checkout_behavior',
    label: 'Checkout behavior',
    detail:
        missing.isEmpty
            ? 'Checkout labels and completion behavior are configured.'
            : 'Missing ${missing.join(', ')} labels.',
    status:
        missing.isEmpty
            ? POSLaunchCheckStatus.passed
            : POSLaunchCheckStatus.failed,
    area: POSLaunchCheckArea.checkout,
  );
}

POSExperienceLaunchCheckItem _paymentBehaviorCheck(POSExperience experience) {
  final payment = experience.paymentBehavior;
  if (!experience.capabilities.payments) {
    return const POSExperienceLaunchCheckItem(
      id: 'payment_behavior',
      label: 'Payment behavior',
      detail: 'Payments are disabled for this mode.',
      status: POSLaunchCheckStatus.warning,
      area: POSLaunchCheckArea.payment,
    );
  }

  if (payment.paymentMethods.isEmpty) {
    return const POSExperienceLaunchCheckItem(
      id: 'payment_behavior',
      label: 'Payment behavior',
      detail: 'At least one payment method is required.',
      status: POSLaunchCheckStatus.failed,
      area: POSLaunchCheckArea.payment,
    );
  }

  if (!payment.paymentMethods.contains(payment.defaultMethod)) {
    return POSExperienceLaunchCheckItem(
      id: 'payment_behavior',
      label: 'Payment behavior',
      detail:
          'Default method "${payment.defaultMethod}" is not in available methods.',
      status: POSLaunchCheckStatus.failed,
      area: POSLaunchCheckArea.payment,
    );
  }

  return POSExperienceLaunchCheckItem(
    id: 'payment_behavior',
    label: 'Payment behavior',
    detail:
        '${payment.paymentMethods.length} payment method${payment.paymentMethods.length == 1 ? '' : 's'} configured.',
    status: POSLaunchCheckStatus.passed,
    area: POSLaunchCheckArea.payment,
  );
}

POSExperienceLaunchCheckItem _releaseStageCheck(POSExperience experience) {
  final stage = experience.manifest.releaseStage;
  switch (stage) {
    case POSExperienceReleaseStage.stable:
      return const POSExperienceLaunchCheckItem(
        id: 'release_stage',
        label: 'Release stage',
        detail: 'Mode is marked stable.',
        status: POSLaunchCheckStatus.passed,
        area: POSLaunchCheckArea.release,
      );
    case POSExperienceReleaseStage.preview:
      return const POSExperienceLaunchCheckItem(
        id: 'release_stage',
        label: 'Release stage',
        detail: 'Mode is preview and should be validated before rollout.',
        status: POSLaunchCheckStatus.warning,
        area: POSLaunchCheckArea.release,
      );
    case POSExperienceReleaseStage.experimental:
      return const POSExperienceLaunchCheckItem(
        id: 'release_stage',
        label: 'Release stage',
        detail: 'Mode is experimental and should stay controlled.',
        status: POSLaunchCheckStatus.warning,
        area: POSLaunchCheckArea.release,
      );
  }
}
