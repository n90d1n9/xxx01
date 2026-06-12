import 'product_workspace_setup_action.dart';
import 'product_workspace_setup_target.dart';

enum ProductWorkspaceSetupRequirementStatus {
  ready,
  missing,
  blocked,
  optional,
}

extension ProductWorkspaceSetupRequirementStatusLabels
    on ProductWorkspaceSetupRequirementStatus {
  String get label {
    return switch (this) {
      ProductWorkspaceSetupRequirementStatus.ready => 'Ready',
      ProductWorkspaceSetupRequirementStatus.missing => 'Missing',
      ProductWorkspaceSetupRequirementStatus.blocked => 'Blocked',
      ProductWorkspaceSetupRequirementStatus.optional => 'Optional',
    };
  }
}

class ProductWorkspaceSetupRequirementEvaluationContext {
  const ProductWorkspaceSetupRequirementEvaluationContext({
    required this.prompt,
    required this.requirement,
  });

  final ProductWorkspaceSetupPrompt prompt;
  final ProductWorkspaceSetupRequirement requirement;

  String get targetId => prompt.targetId;
  ProductWorkspaceSetupTarget get target => prompt.target;
}

class ProductWorkspaceSetupRequirementEvaluation {
  const ProductWorkspaceSetupRequirementEvaluation({
    required this.prompt,
    required this.targetId,
    required this.targetTitle,
    required this.requirement,
    required this.status,
    required this.reason,
  });

  factory ProductWorkspaceSetupRequirementEvaluation.fromContext({
    required ProductWorkspaceSetupRequirementEvaluationContext context,
    required ProductWorkspaceSetupRequirementStatus status,
    required String reason,
  }) {
    return ProductWorkspaceSetupRequirementEvaluation(
      prompt: context.prompt,
      targetId: context.targetId,
      targetTitle: context.target.title,
      requirement: context.requirement,
      status: status,
      reason: reason,
    );
  }

  final ProductWorkspaceSetupPrompt prompt;
  final String targetId;
  final String targetTitle;
  final ProductWorkspaceSetupRequirement requirement;
  final ProductWorkspaceSetupRequirementStatus status;
  final String reason;

  String get label => requirement.label;
  String get typeLabel => requirement.typeLabel;
  String get statusLabel => status.label;
  String get actionLabel => prompt.actionLabel;
  ProductWorkspaceSetupRequirementType get type => requirement.type;

  bool get isReady => status == ProductWorkspaceSetupRequirementStatus.ready;
  bool get isMissing =>
      status == ProductWorkspaceSetupRequirementStatus.missing;
  bool get isBlocked =>
      status == ProductWorkspaceSetupRequirementStatus.blocked;
  bool get isOptional =>
      status == ProductWorkspaceSetupRequirementStatus.optional;
  bool get isActionable => isMissing || isBlocked;
}

typedef ProductWorkspaceSetupRequirementEvaluator =
    ProductWorkspaceSetupRequirementEvaluation Function(
      ProductWorkspaceSetupRequirementEvaluationContext context,
    );

class ProductWorkspaceSetupReadinessEvaluatorRegistry {
  const ProductWorkspaceSetupReadinessEvaluatorRegistry({
    this.targetRequirementEvaluators = const {},
    this.requirementEvaluators = const {},
    this.typeEvaluators = const {},
    this.fallbackEvaluator = defaultProductWorkspaceSetupRequirementEvaluator,
  });

  factory ProductWorkspaceSetupReadinessEvaluatorRegistry.combine(
    Iterable<ProductWorkspaceSetupReadinessEvaluatorRegistry> registries, {
    ProductWorkspaceSetupRequirementEvaluator fallbackEvaluator =
        defaultProductWorkspaceSetupRequirementEvaluator,
  }) {
    final targetRequirementEvaluators =
        <String, ProductWorkspaceSetupRequirementEvaluator>{};
    final requirementEvaluators =
        <String, ProductWorkspaceSetupRequirementEvaluator>{};
    final typeEvaluators =
        <
          ProductWorkspaceSetupRequirementType,
          ProductWorkspaceSetupRequirementEvaluator
        >{};

    for (final registry in registries) {
      targetRequirementEvaluators.addAll(registry.targetRequirementEvaluators);
      requirementEvaluators.addAll(registry.requirementEvaluators);
      typeEvaluators.addAll(registry.typeEvaluators);
    }

    return ProductWorkspaceSetupReadinessEvaluatorRegistry(
      targetRequirementEvaluators: Map.unmodifiable(
        targetRequirementEvaluators,
      ),
      requirementEvaluators: Map.unmodifiable(requirementEvaluators),
      typeEvaluators: Map.unmodifiable(typeEvaluators),
      fallbackEvaluator: fallbackEvaluator,
    );
  }

  static const defaultRegistry =
      ProductWorkspaceSetupReadinessEvaluatorRegistry();

  final Map<String, ProductWorkspaceSetupRequirementEvaluator>
  targetRequirementEvaluators;
  final Map<String, ProductWorkspaceSetupRequirementEvaluator>
  requirementEvaluators;
  final Map<
    ProductWorkspaceSetupRequirementType,
    ProductWorkspaceSetupRequirementEvaluator
  >
  typeEvaluators;
  final ProductWorkspaceSetupRequirementEvaluator fallbackEvaluator;

  ProductWorkspaceSetupRequirementEvaluation evaluate(
    ProductWorkspaceSetupRequirementEvaluationContext context,
  ) {
    final evaluator =
        targetRequirementEvaluators[targetRequirementKey(
          context.targetId,
          context.requirement.id,
        )] ??
        requirementEvaluators[context.requirement.id] ??
        typeEvaluators[context.requirement.type] ??
        fallbackEvaluator;

    return evaluator(context);
  }

  ProductWorkspaceSetupReadiness evaluatePrompts(
    Iterable<ProductWorkspaceSetupPrompt> prompts,
  ) {
    final evaluations = <ProductWorkspaceSetupRequirementEvaluation>[];

    for (final prompt in prompts) {
      for (final requirement in prompt.target.requirements) {
        evaluations.add(
          evaluate(
            ProductWorkspaceSetupRequirementEvaluationContext(
              prompt: prompt,
              requirement: requirement,
            ),
          ),
        );
      }
    }

    return ProductWorkspaceSetupReadiness.fromEvaluations(evaluations);
  }

  static String targetRequirementKey(String targetId, String requirementId) {
    return '${targetId.trim()}:${requirementId.trim()}';
  }
}

ProductWorkspaceSetupRequirementEvaluation
defaultProductWorkspaceSetupRequirementEvaluator(
  ProductWorkspaceSetupRequirementEvaluationContext context,
) {
  final requirement = context.requirement;

  if (!requirement.required) {
    return ProductWorkspaceSetupRequirementEvaluation.fromContext(
      context: context,
      status: ProductWorkspaceSetupRequirementStatus.optional,
      reason: 'Optional setup requirement',
    );
  }

  final prompt = context.prompt;
  if (prompt.isInactive) {
    return ProductWorkspaceSetupRequirementEvaluation.fromContext(
      context: context,
      status: ProductWorkspaceSetupRequirementStatus.blocked,
      reason: 'Switch product pack to activate this setup target',
    );
  }

  if (prompt.isCustom) {
    return ProductWorkspaceSetupRequirementEvaluation.fromContext(
      context: context,
      status: ProductWorkspaceSetupRequirementStatus.blocked,
      reason: 'Custom setup target needs module wiring',
    );
  }

  return ProductWorkspaceSetupRequirementEvaluation.fromContext(
    context: context,
    status: ProductWorkspaceSetupRequirementStatus.missing,
    reason: 'Requirement needs a module evaluator',
  );
}

class ProductWorkspaceSetupReadiness {
  ProductWorkspaceSetupReadiness._({
    required this.evaluations,
    required this.totalCount,
    required this.readyCount,
    required this.missingCount,
    required this.blockedCount,
    required this.optionalCount,
  });

  factory ProductWorkspaceSetupReadiness.fromEvaluations(
    Iterable<ProductWorkspaceSetupRequirementEvaluation> evaluations,
  ) {
    final items = evaluations.toList(growable: false);

    return ProductWorkspaceSetupReadiness._(
      evaluations: List.unmodifiable(items),
      totalCount: items.length,
      readyCount: items.where((item) => item.isReady).length,
      missingCount: items.where((item) => item.isMissing).length,
      blockedCount: items.where((item) => item.isBlocked).length,
      optionalCount: items.where((item) => item.isOptional).length,
    );
  }

  factory ProductWorkspaceSetupReadiness.fromPrompts(
    Iterable<ProductWorkspaceSetupPrompt> prompts, {
    ProductWorkspaceSetupReadinessEvaluatorRegistry registry =
        ProductWorkspaceSetupReadinessEvaluatorRegistry.defaultRegistry,
  }) {
    return registry.evaluatePrompts(prompts);
  }

  static final empty = ProductWorkspaceSetupReadiness.fromEvaluations(const []);

  final List<ProductWorkspaceSetupRequirementEvaluation> evaluations;
  final int totalCount;
  final int readyCount;
  final int missingCount;
  final int blockedCount;
  final int optionalCount;

  bool get isEmpty => evaluations.isEmpty;
  bool get isNotEmpty => evaluations.isNotEmpty;
  bool get hasMissingRequirements => missingCount > 0;
  bool get hasBlockedRequirements => blockedCount > 0;
  bool get hasActionableRequirements => actionableCount > 0;
  bool get isReady => isNotEmpty && actionableCount == 0;

  int get requiredCount => totalCount - optionalCount;
  int get actionableCount => missingCount + blockedCount;

  double get readyPercent {
    final count = requiredCount;
    if (count <= 0) return 1;

    return readyCount / count;
  }

  List<ProductWorkspaceSetupRequirementEvaluation> get actionableEvaluations {
    return evaluations
        .where((item) => item.isActionable)
        .toList(growable: false);
  }

  ProductWorkspaceSetupRequirementEvaluation? get primaryEvaluation {
    if (evaluations.isEmpty) return null;

    final sorted = evaluations.toList(growable: false);
    sorted.sort((left, right) {
      final rankComparison = _statusRank(
        left.status,
      ).compareTo(_statusRank(right.status));
      if (rankComparison != 0) return rankComparison;

      return left.label.compareTo(right.label);
    });

    return sorted.first;
  }

  String get statusLabel {
    if (totalCount == 0) return 'No requirements';
    if (blockedCount > 0) return 'Blocked';
    if (missingCount > 0) return 'Needs setup';

    return 'Ready';
  }

  String get progressLabel {
    if (totalCount == 0) return 'No requirements';
    if (requiredCount == 0) return _countLabel(optionalCount, 'optional');

    return '$readyCount/$requiredCount ready';
  }

  String get actionableCountLabel {
    if (actionableCount == 0) return 'No actions';

    return _countLabel(actionableCount, 'action');
  }

  List<ProductWorkspaceSetupRequirementEvaluation> evaluationsForTarget(
    String targetId,
  ) {
    final normalizedTargetId = targetId.trim();

    return evaluations
        .where((item) => item.targetId == normalizedTargetId)
        .toList(growable: false);
  }

  ProductWorkspaceSetupRequirementEvaluation? evaluationForRequirement({
    required String targetId,
    required String requirementId,
  }) {
    final normalizedTargetId = targetId.trim();
    final normalizedRequirementId = requirementId.trim();

    for (final evaluation in evaluations) {
      if (evaluation.targetId == normalizedTargetId &&
          evaluation.requirement.id == normalizedRequirementId) {
        return evaluation;
      }
    }

    return null;
  }

  List<ProductWorkspaceSetupRequirementEvaluation> evaluationsForType(
    ProductWorkspaceSetupRequirementType type,
  ) {
    return evaluations
        .where((item) => item.type == type)
        .toList(growable: false);
  }
}

int _statusRank(ProductWorkspaceSetupRequirementStatus status) {
  return switch (status) {
    ProductWorkspaceSetupRequirementStatus.blocked => 0,
    ProductWorkspaceSetupRequirementStatus.missing => 1,
    ProductWorkspaceSetupRequirementStatus.optional => 2,
    ProductWorkspaceSetupRequirementStatus.ready => 3,
  };
}

String _countLabel(int count, String singular) {
  return count == 1 ? '1 $singular' : '$count ${singular}s';
}
