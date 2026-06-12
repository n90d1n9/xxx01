class ProductModuleContributionActivationSummary {
  const ProductModuleContributionActivationSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.reasonLabel,
    required this.actionContributionCount,
    required this.setupReadinessContributionCount,
    required this.recommendationContributionCount,
    this.moduleBriefResolverCount = 0,
    this.availabilityTemplateContributionCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final String reasonLabel;
  final int actionContributionCount;
  final int setupReadinessContributionCount;
  final int recommendationContributionCount;
  final int moduleBriefResolverCount;
  final int availabilityTemplateContributionCount;

  int get hookCount {
    return actionContributionCount +
        setupReadinessContributionCount +
        recommendationContributionCount +
        moduleBriefResolverCount +
        availabilityTemplateContributionCount;
  }

  bool get hasHooks => hookCount > 0;
  String get statusLabel => isActive ? 'Active' : 'Inactive';
  String get hookCountLabel => _countLabel(hookCount, 'hook');

  String get mixLabel {
    final parts = [
      if (actionContributionCount > 0)
        _countLabel(actionContributionCount, 'action'),
      if (setupReadinessContributionCount > 0)
        _countLabel(setupReadinessContributionCount, 'readiness hook'),
      if (recommendationContributionCount > 0)
        _countLabel(recommendationContributionCount, 'recommendation'),
      if (moduleBriefResolverCount > 0)
        _countLabel(moduleBriefResolverCount, 'brief action'),
      if (availabilityTemplateContributionCount > 0)
        _countLabel(
          availabilityTemplateContributionCount,
          'availability template',
        ),
    ];

    if (parts.isEmpty) return 'No hooks registered';

    return parts.join(', ');
  }
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
