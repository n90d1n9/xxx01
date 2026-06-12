import 'pos_capability_module_binding.dart';
import 'pos_experience.dart';
import 'pos_experience_action_policy.dart';
import 'pos_feature_module.dart';

enum POSExperienceRegistryIssueType {
  emptyRegistry,
  blankExperienceId,
  duplicateExperienceId,
  duplicateModuleId,
  enabledCapabilityMissingModule,
  disabledCapabilityHasModule,
  blankManifestProductLine,
  blankManifestArchetypeKey,
  blankManifestArchetypeLabel,
  emptyManifestFormFactors,
  blankManifestTrait,
  blankModuleId,
}

class POSExperienceRegistryIssue {
  final POSExperienceRegistryIssueType type;
  final String message;
  final String? experienceId;

  const POSExperienceRegistryIssue({
    required this.type,
    required this.message,
    this.experienceId,
  });
}

class POSExperienceResolution {
  final String requestedId;
  final POSExperience experience;
  final bool usedFallback;
  final String? fallbackReason;

  const POSExperienceResolution({
    required this.requestedId,
    required this.experience,
    required this.usedFallback,
    this.fallbackReason,
  });
}

class POSExperienceRegistry {
  final List<POSExperience> experiences;

  const POSExperienceRegistry({required this.experiences});

  List<String> get experienceIds {
    return List.unmodifiable(experiences.map((experience) => experience.id));
  }

  POSExperience get defaultExperience {
    if (experiences.isEmpty) {
      throw StateError('POS experience registry is empty');
    }

    return experiences.first;
  }

  POSExperience? findById(String id) {
    final normalizedId = id.trim();
    for (final experience in experiences) {
      if (experience.id == normalizedId) {
        return experience;
      }
    }

    return null;
  }

  POSExperienceResolution resolveDetailed(String id) {
    final normalizedId = id.trim();
    final experience = findById(normalizedId);
    if (experience != null) {
      return POSExperienceResolution(
        requestedId: normalizedId,
        experience: experience,
        usedFallback: false,
      );
    }

    return POSExperienceResolution(
      requestedId: normalizedId,
      experience: defaultExperience,
      usedFallback: true,
      fallbackReason:
          normalizedId.isEmpty
              ? 'No POS experience id was selected'
              : 'POS experience "$normalizedId" is not registered',
    );
  }

  POSExperience resolve(String id) {
    return resolveDetailed(id).experience;
  }

  bool isRegistered(String id) {
    return findById(id) != null;
  }

  List<POSExperienceRegistryIssue> validate() {
    final issues = <POSExperienceRegistryIssue>[];
    if (experiences.isEmpty) {
      return const [
        POSExperienceRegistryIssue(
          type: POSExperienceRegistryIssueType.emptyRegistry,
          message: 'POS experience registry must contain at least one mode',
        ),
      ];
    }

    final seenExperienceIds = <String>{};
    final reportedDuplicateExperienceIds = <String>{};

    for (final experience in experiences) {
      final normalizedExperienceId = experience.id.trim();
      if (normalizedExperienceId.isEmpty) {
        issues.add(
          const POSExperienceRegistryIssue(
            type: POSExperienceRegistryIssueType.blankExperienceId,
            message: 'POS experience id cannot be blank',
          ),
        );
      } else if (!seenExperienceIds.add(normalizedExperienceId) &&
          reportedDuplicateExperienceIds.add(normalizedExperienceId)) {
        issues.add(
          POSExperienceRegistryIssue(
            type: POSExperienceRegistryIssueType.duplicateExperienceId,
            experienceId: normalizedExperienceId,
            message:
                'Duplicate POS experience id "$normalizedExperienceId" found',
          ),
        );
      }

      final seenModuleIds = <String>{};
      final reportedDuplicateModuleIds = <String>{};
      for (final module in experience.modules) {
        final normalizedModuleId = module.id.trim();
        if (normalizedModuleId.isEmpty) {
          issues.add(
            POSExperienceRegistryIssue(
              type: POSExperienceRegistryIssueType.blankModuleId,
              experienceId: normalizedExperienceId,
              message:
                  'POS experience "$normalizedExperienceId" has a module with a blank id',
            ),
          );
        } else if (!seenModuleIds.add(normalizedModuleId) &&
            reportedDuplicateModuleIds.add(normalizedModuleId)) {
          issues.add(
            POSExperienceRegistryIssue(
              type: POSExperienceRegistryIssueType.duplicateModuleId,
              experienceId: normalizedExperienceId,
              message:
                  'POS experience "$normalizedExperienceId" has duplicate module id "$normalizedModuleId"',
            ),
          );
        }
      }

      issues.addAll(
        _validateCapabilityModuleAlignment(
          experienceId: normalizedExperienceId,
          experience: experience,
        ),
      );

      issues.addAll(
        _validateManifest(
          experienceId: normalizedExperienceId,
          experience: experience,
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  List<POSExperienceRegistryIssue> _validateCapabilityModuleAlignment({
    required String experienceId,
    required POSExperience experience,
  }) {
    final issues = <POSExperienceRegistryIssue>[];
    final policy = POSExperienceActionPolicy(experience: experience);
    final moduleIds =
        experience.modules.map((module) => module.id.trim()).toSet();

    for (final binding in POSCapabilityModuleBindings.all) {
      final hasModule = moduleIds.contains(binding.module.id);
      final allowsAction = policy.capabilityAllows(binding.action);

      if (allowsAction && !hasModule) {
        issues.add(
          POSExperienceRegistryIssue(
            type: POSExperienceRegistryIssueType.enabledCapabilityMissingModule,
            experienceId: experienceId,
            message:
                'POS experience "$experienceId" enables ${binding.capabilityLabel} but is missing module "${binding.module.id}"',
          ),
        );
      }

      if (!allowsAction && hasModule) {
        issues.add(
          POSExperienceRegistryIssue(
            type: POSExperienceRegistryIssueType.disabledCapabilityHasModule,
            experienceId: experienceId,
            message:
                'POS experience "$experienceId" registers module "${binding.module.id}" but disables ${binding.capabilityLabel}',
          ),
        );
      }
    }

    return issues;
  }

  List<POSExperienceRegistryIssue> _validateManifest({
    required String experienceId,
    required POSExperience experience,
  }) {
    final issues = <POSExperienceRegistryIssue>[];
    final manifest = experience.manifest;

    if (manifest.productLine.trim().isEmpty) {
      issues.add(
        POSExperienceRegistryIssue(
          type: POSExperienceRegistryIssueType.blankManifestProductLine,
          experienceId: experienceId,
          message:
              'POS experience "$experienceId" product line cannot be blank',
        ),
      );
    }

    if (manifest.archetypeKey.trim().isEmpty) {
      issues.add(
        POSExperienceRegistryIssue(
          type: POSExperienceRegistryIssueType.blankManifestArchetypeKey,
          experienceId: experienceId,
          message:
              'POS experience "$experienceId" manifest archetype key cannot be blank',
        ),
      );
    }

    if (manifest.archetypeLabel.trim().isEmpty) {
      issues.add(
        POSExperienceRegistryIssue(
          type: POSExperienceRegistryIssueType.blankManifestArchetypeLabel,
          experienceId: experienceId,
          message:
              'POS experience "$experienceId" manifest archetype label cannot be blank',
        ),
      );
    }

    if (manifest.supportedFormFactors.isEmpty) {
      issues.add(
        POSExperienceRegistryIssue(
          type: POSExperienceRegistryIssueType.emptyManifestFormFactors,
          experienceId: experienceId,
          message:
              'POS experience "$experienceId" must declare at least one supported form factor',
        ),
      );
    }

    for (final trait in [...manifest.traits, ...manifest.dataTraits]) {
      if (trait.trim().isEmpty) {
        issues.add(
          POSExperienceRegistryIssue(
            type: POSExperienceRegistryIssueType.blankManifestTrait,
            experienceId: experienceId,
            message:
                'POS experience "$experienceId" manifest traits cannot contain blank values',
          ),
        );
        break;
      }
    }

    return issues;
  }

  bool get isValid => validate().isEmpty;

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(
      'Invalid POS experience registry: '
      '${issues.map((issue) => issue.message).join('; ')}',
    );
  }

  List<POSFeatureModule> get modules {
    final modulesById = <String, POSFeatureModule>{};
    for (final experience in experiences) {
      for (final module in experience.modules) {
        modulesById[module.id] = module;
      }
    }

    return List.unmodifiable(modulesById.values);
  }
}
