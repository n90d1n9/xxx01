import 'product_workspace_setup_action.dart';
import 'product_workspace_setup_target.dart';

class ProductWorkspaceSetupPlan {
  ProductWorkspaceSetupPlan._({
    required this.sections,
    required this.targetCount,
    required this.estimatedMinutes,
  }) : requirementCount = sections.fold<int>(
         0,
         (total, section) => total + section.requirementCount,
       );

  factory ProductWorkspaceSetupPlan.fromPrompts(
    Iterable<ProductWorkspaceSetupPrompt> prompts,
  ) {
    final builders =
        <ProductWorkspaceSetupRequirementType, _PlanSectionBuilder>{
          for (final type in ProductWorkspaceSetupRequirementType.values)
            type: _PlanSectionBuilder(type),
        };
    final targetIds = <String>{};
    var estimatedMinutes = 0;

    for (final prompt in prompts) {
      final requirements = prompt.target.requirements
          .where((requirement) => requirement.required)
          .toList(growable: false);
      if (requirements.isEmpty) continue;

      targetIds.add(prompt.targetId);
      estimatedMinutes += _normalizedMinutes(prompt.target.estimatedMinutes);

      for (final requirement in requirements) {
        builders[requirement.type]?.add(prompt, requirement);
      }
    }

    final sections = <ProductWorkspaceSetupPlanSection>[];
    for (final type in ProductWorkspaceSetupRequirementType.values) {
      final builder = builders[type];
      if (builder == null || !builder.isNotEmpty) continue;

      sections.add(builder.build());
    }
    sections.sort((left, right) {
      final countComparison = right.requirementCount.compareTo(
        left.requirementCount,
      );
      if (countComparison != 0) return countComparison;

      return _typeRank(left.type).compareTo(_typeRank(right.type));
    });

    return ProductWorkspaceSetupPlan._(
      sections: List.unmodifiable(sections),
      targetCount: targetIds.length,
      estimatedMinutes: estimatedMinutes,
    );
  }

  static final empty = ProductWorkspaceSetupPlan.fromPrompts(const []);

  final List<ProductWorkspaceSetupPlanSection> sections;
  final int targetCount;
  final int requirementCount;
  final int estimatedMinutes;

  bool get isEmpty => sections.isEmpty;
  bool get isNotEmpty => sections.isNotEmpty;

  ProductWorkspaceSetupPlanSection? get primarySection {
    if (sections.isEmpty) return null;

    return sections.first;
  }

  String get requirementCountLabel {
    return _countLabel(requirementCount, 'requirement');
  }

  String get targetCountLabel {
    return _countLabel(targetCount, 'target');
  }

  String get sectionCountLabel {
    return _countLabel(sections.length, 'area');
  }

  String get estimatedEffortLabel {
    return _estimatedEffortLabel(estimatedMinutes);
  }

  String get summaryLabel {
    if (isEmpty) return 'No setup requirements';

    return '$requirementCountLabel across $targetCountLabel';
  }
}

class ProductWorkspaceSetupPlanSection {
  ProductWorkspaceSetupPlanSection({
    required this.type,
    required List<ProductWorkspaceSetupPlanRequirement> requirements,
  }) : requirements = List.unmodifiable(requirements),
       targetGroups = List.unmodifiable(_targetGroupsFor(requirements)),
       targetCount = requirements.map((item) => item.targetId).toSet().length;

  final ProductWorkspaceSetupRequirementType type;
  final List<ProductWorkspaceSetupPlanRequirement> requirements;
  final List<ProductWorkspaceSetupPlanTargetGroup> targetGroups;
  final int targetCount;

  int get requirementCount => requirements.length;
  String get title => type.planTitle;
  String get requirementCountLabel {
    return _countLabel(requirementCount, 'requirement');
  }

  String get targetCountLabel {
    return _countLabel(targetCount, 'target');
  }

  String get detailLabel {
    return '$requirementCountLabel across $targetCountLabel';
  }

  ProductWorkspaceSetupPlanRequirement? get primaryRequirement {
    if (requirements.isEmpty) return null;

    return requirements.first;
  }

  ProductWorkspaceSetupPrompt? get primaryPrompt {
    return primaryRequirement?.prompt;
  }

  String get primaryActionLabel {
    return primaryPrompt?.actionLabel ?? 'Review setup';
  }
}

class ProductWorkspaceSetupPlanTargetGroup {
  ProductWorkspaceSetupPlanTargetGroup({
    required this.prompt,
    required this.targetId,
    required this.targetTitle,
    required List<ProductWorkspaceSetupPlanRequirement> requirements,
  }) : requirements = List.unmodifiable(requirements);

  final ProductWorkspaceSetupPrompt prompt;
  final String targetId;
  final String targetTitle;
  final List<ProductWorkspaceSetupPlanRequirement> requirements;

  int get requirementCount => requirements.length;
  String get requirementCountLabel {
    return _countLabel(requirementCount, 'requirement');
  }

  String get actionLabel => prompt.actionLabel;
  String get statusLabel => prompt.statusLabel;
}

class ProductWorkspaceSetupPlanRequirement {
  const ProductWorkspaceSetupPlanRequirement({
    required this.prompt,
    required this.targetId,
    required this.targetTitle,
    required this.requirement,
  });

  final ProductWorkspaceSetupPrompt prompt;
  final String targetId;
  final String targetTitle;
  final ProductWorkspaceSetupRequirement requirement;

  String get label => requirement.label;
  String get typeLabel => requirement.typeLabel;
  String get actionLabel => prompt.actionLabel;
}

List<ProductWorkspaceSetupPlanTargetGroup> _targetGroupsFor(
  List<ProductWorkspaceSetupPlanRequirement> requirements,
) {
  final groupedRequirements =
      <String, List<ProductWorkspaceSetupPlanRequirement>>{};
  final prompts = <String, ProductWorkspaceSetupPrompt>{};
  final titles = <String, String>{};

  for (final requirement in requirements) {
    groupedRequirements.putIfAbsent(requirement.targetId, () => []);
    groupedRequirements[requirement.targetId]!.add(requirement);
    prompts[requirement.targetId] = requirement.prompt;
    titles[requirement.targetId] = requirement.targetTitle;
  }

  return [
    for (final entry in groupedRequirements.entries)
      ProductWorkspaceSetupPlanTargetGroup(
        prompt: prompts[entry.key]!,
        targetId: entry.key,
        targetTitle: titles[entry.key]!,
        requirements: entry.value,
      ),
  ];
}

class _PlanSectionBuilder {
  _PlanSectionBuilder(this.type);

  final ProductWorkspaceSetupRequirementType type;
  final List<ProductWorkspaceSetupPlanRequirement> requirements = [];
  final Set<String> seenKeys = {};

  bool get isNotEmpty => requirements.isNotEmpty;

  void add(
    ProductWorkspaceSetupPrompt prompt,
    ProductWorkspaceSetupRequirement requirement,
  ) {
    final key = '${prompt.targetId}:${requirement.id}';
    if (seenKeys.contains(key)) return;

    seenKeys.add(key);
    requirements.add(
      ProductWorkspaceSetupPlanRequirement(
        prompt: prompt,
        targetId: prompt.targetId,
        targetTitle: prompt.target.title,
        requirement: requirement,
      ),
    );
  }

  ProductWorkspaceSetupPlanSection build() {
    return ProductWorkspaceSetupPlanSection(
      type: type,
      requirements: requirements,
    );
  }
}

int _normalizedMinutes(int minutes) {
  return minutes < 0 ? 0 : minutes;
}

int _typeRank(ProductWorkspaceSetupRequirementType type) {
  return switch (type) {
    ProductWorkspaceSetupRequirementType.data => 0,
    ProductWorkspaceSetupRequirementType.workflow => 1,
    ProductWorkspaceSetupRequirementType.channel => 2,
    ProductWorkspaceSetupRequirementType.integration => 3,
  };
}

String _estimatedEffortLabel(int estimatedMinutes) {
  if (estimatedMinutes <= 0) return 'Quick setup';
  if (estimatedMinutes < 60) return '$estimatedMinutes min';

  final hours = estimatedMinutes / 60;
  if (hours == hours.roundToDouble()) return '${hours.round()} hr';

  return '${hours.toStringAsFixed(1)} hr';
}

String _countLabel(int count, String singular) {
  return count == 1 ? '1 $singular' : '$count ${singular}s';
}
