import 'product_workspace_setup_action.dart';
import 'product_workspace_setup_plan.dart';
import 'product_workspace_setup_readiness.dart';
import 'product_workspace_setup_target.dart';

class ProductWorkspaceSetupOverview {
  ProductWorkspaceSetupOverview._(
    List<ProductWorkspaceSetupPrompt> prompts,
    ProductWorkspaceSetupPlan plan,
    this.readiness,
  ) : prompts = List.unmodifiable(prompts),
      plan = plan,
      targetCount = prompts.length,
      activeCount = prompts.where(_isActivePrompt).length,
      inactiveCount = prompts.where((prompt) => prompt.isInactive).length,
      customCount = prompts.where((prompt) => prompt.isCustom).length,
      requiredRequirementCount = plan.requirementCount,
      urgentTargetCount = prompts.where(_isUrgentPrompt).length;

  factory ProductWorkspaceSetupOverview.fromPrompts(
    Iterable<ProductWorkspaceSetupPrompt> prompts, {
    ProductWorkspaceSetupReadinessEvaluatorRegistry readinessRegistry =
        ProductWorkspaceSetupReadinessEvaluatorRegistry.defaultRegistry,
  }) {
    final entries = prompts.toList(growable: false).asMap().entries.toList();
    entries.sort((left, right) {
      final rankComparison = _availabilityRank(
        left.value,
      ).compareTo(_availabilityRank(right.value));
      if (rankComparison != 0) return rankComparison;

      final priorityComparison = _priorityRank(
        right.value.target.priority,
      ).compareTo(_priorityRank(left.value.target.priority));
      if (priorityComparison != 0) return priorityComparison;

      return left.key.compareTo(right.key);
    });

    final sortedPrompts = entries
        .map((entry) => entry.value)
        .toList(growable: false);

    return ProductWorkspaceSetupOverview._(
      sortedPrompts,
      ProductWorkspaceSetupPlan.fromPrompts(sortedPrompts),
      ProductWorkspaceSetupReadiness.fromPrompts(
        sortedPrompts,
        registry: readinessRegistry,
      ),
    );
  }

  static final empty = ProductWorkspaceSetupOverview.fromPrompts(const []);

  final List<ProductWorkspaceSetupPrompt> prompts;
  final ProductWorkspaceSetupPlan plan;
  final ProductWorkspaceSetupReadiness readiness;
  final int targetCount;
  final int activeCount;
  final int inactiveCount;
  final int customCount;
  final int requiredRequirementCount;
  final int urgentTargetCount;

  bool get isEmpty => prompts.isEmpty;
  bool get isNotEmpty => prompts.isNotEmpty;
  bool get hasInactivePrompts => inactiveCount > 0;
  bool get hasCustomPrompts => customCount > 0;

  int get pendingCount => inactiveCount + customCount;
  bool get hasPendingPrompts => pendingCount > 0;

  String get targetCountLabel => _countLabel(targetCount, 'target');
  String get activeCountLabel => '$activeCount active';
  String get inactiveCountLabel => '$inactiveCount not in pack';
  String get customCountLabel => '$customCount custom';
  String get requiredRequirementCountLabel {
    return _countLabel(requiredRequirementCount, 'requirement');
  }

  String get urgentTargetCountLabel => '$urgentTargetCount high priority';
  String get readinessLabel =>
      isEmpty ? 'No targets' : '$activeCount/$targetCount active';

  String get pendingCountLabel {
    if (pendingCount == 1) return '1 needs attention';

    return '$pendingCount need attention';
  }
}

bool _isActivePrompt(ProductWorkspaceSetupPrompt prompt) {
  return !prompt.isInactive && !prompt.isCustom;
}

bool _isUrgentPrompt(ProductWorkspaceSetupPrompt prompt) {
  return switch (prompt.target.priority) {
    ProductWorkspaceSetupPriority.critical => true,
    ProductWorkspaceSetupPriority.high => true,
    ProductWorkspaceSetupPriority.medium => false,
    ProductWorkspaceSetupPriority.low => false,
  };
}

int _availabilityRank(ProductWorkspaceSetupPrompt prompt) {
  if (prompt.isInactive) return 0;
  if (prompt.isCustom) return 1;

  return 2;
}

int _priorityRank(ProductWorkspaceSetupPriority priority) {
  return switch (priority) {
    ProductWorkspaceSetupPriority.critical => 3,
    ProductWorkspaceSetupPriority.high => 2,
    ProductWorkspaceSetupPriority.medium => 1,
    ProductWorkspaceSetupPriority.low => 0,
  };
}

String _countLabel(int count, String singular) {
  return count == 1 ? '1 $singular' : '$count ${singular}s';
}
