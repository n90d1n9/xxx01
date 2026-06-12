const productWorkspaceFreshnessSetupTargetId = 'freshness';

/// Setup target that a product module can publish into the workspace.
class ProductWorkspaceSetupTarget {
  const ProductWorkspaceSetupTarget({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.recommendationId,
    this.priority = ProductWorkspaceSetupPriority.medium,
    this.estimatedMinutes = 10,
    this.requirements = const [],
    this.isCustom = false,
  });

  factory ProductWorkspaceSetupTarget.custom(String id) {
    final normalizedId = id.trim();
    final label = _labelFromId(normalizedId);

    return ProductWorkspaceSetupTarget(
      id: normalizedId,
      title: '$label setup',
      subtitle: 'Review the product workspace setup tasks for $label.',
      actionLabel: 'Open catalog review',
      priority: ProductWorkspaceSetupPriority.medium,
      estimatedMinutes: 12,
      requirements: [
        ProductWorkspaceSetupRequirement(
          id: '${normalizedId}_owner',
          label: 'Module owner',
          type: ProductWorkspaceSetupRequirementType.integration,
        ),
        ProductWorkspaceSetupRequirement(
          id: '${normalizedId}_workflow',
          label: 'Workflow route',
          type: ProductWorkspaceSetupRequirementType.workflow,
        ),
      ],
      isCustom: true,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String? recommendationId;
  final ProductWorkspaceSetupPriority priority;
  final int estimatedMinutes;
  final List<ProductWorkspaceSetupRequirement> requirements;
  final bool isCustom;

  String get normalizedId => id.trim();

  bool get hasRecommendation {
    final normalizedRecommendationId = recommendationId?.trim();
    return normalizedRecommendationId != null &&
        normalizedRecommendationId.isNotEmpty;
  }

  bool get hasRequirements => requirements.isNotEmpty;

  int get requiredRequirementCount {
    return requirements.where((requirement) => requirement.required).length;
  }

  String get priorityLabel => priority.label;

  String get estimatedEffortLabel {
    if (estimatedMinutes <= 0) return 'Quick setup';
    if (estimatedMinutes < 60) return '$estimatedMinutes min';

    final hours = estimatedMinutes / 60;
    if (hours == hours.roundToDouble()) return '${hours.round()} hr';

    return '${hours.toStringAsFixed(1)} hr';
  }

  String get requirementCountLabel {
    final count = requiredRequirementCount;
    if (count == 0) return 'No requirements';
    if (count == 1) return '1 requirement';

    return '$count requirements';
  }

  static const freshness = ProductWorkspaceSetupTarget(
    id: productWorkspaceFreshnessSetupTargetId,
    title: 'Freshness control setup',
    subtitle:
        'Connect expiry, batch, and pull-from-shelf workflows before enabling the freshness queue.',
    actionLabel: 'Review freshness data',
    recommendationId: 'freshness_data_setup',
    priority: ProductWorkspaceSetupPriority.high,
    estimatedMinutes: 18,
    requirements: [
      ProductWorkspaceSetupRequirement(
        id: 'expiry_date_data',
        label: 'Expiry date data',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'batch_traceability',
        label: 'Batch traceability',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'pull_from_shelf_workflow',
        label: 'Pull-from-shelf workflow',
        type: ProductWorkspaceSetupRequirementType.workflow,
      ),
    ],
  );

  static const builtInTargets = [freshness];

  static ProductWorkspaceSetupTarget? fromQuery(String? value) {
    return const ProductWorkspaceSetupTargetRegistry(
      builtInTargets,
    ).resolve(value);
  }
}

/// Business priority used to order and highlight setup targets.
enum ProductWorkspaceSetupPriority { low, medium, high, critical }

extension ProductWorkspaceSetupPriorityLabels on ProductWorkspaceSetupPriority {
  String get label {
    return switch (this) {
      ProductWorkspaceSetupPriority.low => 'Low priority',
      ProductWorkspaceSetupPriority.medium => 'Medium priority',
      ProductWorkspaceSetupPriority.high => 'High priority',
      ProductWorkspaceSetupPriority.critical => 'Critical priority',
    };
  }
}

/// Requirement category used to group setup work into operator-friendly plans.
enum ProductWorkspaceSetupRequirementType {
  data,
  workflow,
  channel,
  integration,
}

extension ProductWorkspaceSetupRequirementTypeLabels
    on ProductWorkspaceSetupRequirementType {
  String get label {
    return switch (this) {
      ProductWorkspaceSetupRequirementType.data => 'Data',
      ProductWorkspaceSetupRequirementType.workflow => 'Workflow',
      ProductWorkspaceSetupRequirementType.channel => 'Channel',
      ProductWorkspaceSetupRequirementType.integration => 'Integration',
    };
  }

  String get planTitle {
    return switch (this) {
      ProductWorkspaceSetupRequirementType.data => 'Data setup',
      ProductWorkspaceSetupRequirementType.workflow => 'Workflow setup',
      ProductWorkspaceSetupRequirementType.channel => 'Channel setup',
      ProductWorkspaceSetupRequirementType.integration => 'Integration setup',
    };
  }
}

/// Required setup item that must be ready before a target is complete.
class ProductWorkspaceSetupRequirement {
  const ProductWorkspaceSetupRequirement({
    required this.id,
    required this.label,
    required this.type,
    this.required = true,
  });

  final String id;
  final String label;
  final ProductWorkspaceSetupRequirementType type;
  final bool required;

  String get typeLabel {
    return type.label;
  }
}

/// Registry that resolves built-in, contributed, and custom setup targets.
class ProductWorkspaceSetupTargetRegistry {
  const ProductWorkspaceSetupTargetRegistry(
    this.targets, {
    this.activeTargetIds = const {},
    this.tracksAvailability = false,
  });

  final List<ProductWorkspaceSetupTarget> targets;
  final Set<String> activeTargetIds;
  final bool tracksAvailability;

  ProductWorkspaceSetupTarget? resolve(String? value) {
    return resolveWithAvailability(value)?.target;
  }

  ProductWorkspaceSetupTargetResolution? resolveWithAvailability(
    String? value,
  ) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) return null;

    for (final target in targets) {
      if (target.normalizedId == normalizedValue) {
        return ProductWorkspaceSetupTargetResolution(
          target: target,
          availability: _availabilityFor(target),
        );
      }
    }

    return ProductWorkspaceSetupTargetResolution(
      target: ProductWorkspaceSetupTarget.custom(normalizedValue),
      availability: ProductWorkspaceSetupTargetAvailability.custom,
    );
  }

  bool contains(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return false;

    return targets.any((target) => target.normalizedId == normalizedId);
  }

  bool isActive(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return false;
    if (!tracksAvailability) return contains(normalizedId);

    return _hasActiveTargetId(normalizedId);
  }

  ProductWorkspaceSetupTargetAvailability _availabilityFor(
    ProductWorkspaceSetupTarget target,
  ) {
    if (!tracksAvailability) {
      return ProductWorkspaceSetupTargetAvailability.active;
    }

    return _hasActiveTargetId(target.normalizedId)
        ? ProductWorkspaceSetupTargetAvailability.active
        : ProductWorkspaceSetupTargetAvailability.inactive;
  }

  bool _hasActiveTargetId(String normalizedId) {
    return activeTargetIds.any((id) => id.trim() == normalizedId);
  }
}

/// Availability state for a setup target under the active product pack.
enum ProductWorkspaceSetupTargetAvailability { active, inactive, custom }

/// Result of resolving a setup target together with its pack availability.
class ProductWorkspaceSetupTargetResolution {
  const ProductWorkspaceSetupTargetResolution({
    required this.target,
    required this.availability,
  });

  final ProductWorkspaceSetupTarget target;
  final ProductWorkspaceSetupTargetAvailability availability;

  bool get isActive {
    return availability == ProductWorkspaceSetupTargetAvailability.active;
  }

  bool get isInactive {
    return availability == ProductWorkspaceSetupTargetAvailability.inactive;
  }

  bool get isCustom {
    return availability == ProductWorkspaceSetupTargetAvailability.custom;
  }
}

String _labelFromId(String id) {
  final words = id
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((word) => word.trim().isNotEmpty)
      .map((word) {
        final normalizedWord = word.trim().toLowerCase();
        return normalizedWord.isEmpty
            ? normalizedWord
            : '${normalizedWord[0].toUpperCase()}${normalizedWord.substring(1)}';
      })
      .toList(growable: false);

  return words.isEmpty ? 'Product workspace' : words.join(' ');
}
