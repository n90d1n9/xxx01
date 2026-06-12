import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_family_remediation.dart';
import 'registry_health_api_consistency_field_remediation.dart';
import 'registry_health_api_consistency_primitive_remediation.dart';
import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyImplementationPlan {
  final RegistryHealthApiConsistencyActionPlan actionPlan;
  final RegistryHealthApiConsistencyFamilyRemediationReport familyRemediation;
  final RegistryHealthApiConsistencyPrimitiveRemediationReport
  primitiveRemediation;
  final RegistryHealthApiConsistencyFieldRemediationReport fieldRemediation;

  const RegistryHealthApiConsistencyImplementationPlan({
    required this.actionPlan,
    required this.familyRemediation,
    required this.primitiveRemediation,
    required this.fieldRemediation,
  });

  bool get isClear => actionPlan.isClear;

  int get actionCount => actionPlan.actionCount;

  int get familyCount => familyRemediation.familyCount;

  int get primitiveCount => primitiveRemediation.primitiveCount;

  int get fieldOptionCount => fieldRemediation.fieldOptionCount;

  int get requiredGapCount => actionPlan.items
      .where(
        (item) =>
            item.level == RegistryHealthApiConsistencyConcernLevel.required,
      )
      .length;

  int get advisoryGapCount => actionPlan.items
      .where(
        (item) =>
            item.level == RegistryHealthApiConsistencyConcernLevel.advisory,
      )
      .length;

  double get scoreImpactWeight => actionPlan.scoreImpactWeight;

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyStatus get status {
    if (requiredGapCount > 0) return RegistryHealthApiConsistencyStatus.blocked;
    if (advisoryGapCount > 0) return RegistryHealthApiConsistencyStatus.warning;
    return RegistryHealthApiConsistencyStatus.ready;
  }

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  RegistryHealthApiConsistencyFamilyRemediationItem? get topFamily =>
      familyRemediation.topFamily;

  RegistryHealthApiConsistencyPrimitiveRemediationItem? get topPrimitive =>
      primitiveRemediation.topPrimitive;

  RegistryHealthApiConsistencyFieldRemediationItem? get topField =>
      fieldRemediation.topField;

  String get recommendedStartLabel {
    final family = topFamily;
    if (family != null) {
      return 'Start with ${family.familyName}: ${family.recipe.targetLabel}.';
    }
    final primitive = topPrimitive;
    if (primitive != null) {
      return 'Start with ${primitive.primitiveLabel}: '
          '${primitive.recipe.targetLabel}.';
    }
    final field = topField;
    if (field != null) {
      return 'Start with ${field.fieldName}: ${field.recipe.targetLabel}.';
    }
    return 'No API implementation work is queued.';
  }

  Map<String, dynamic> toJson({
    int actionLimit = 16,
    int familyLimit = 12,
    int primitiveLimit = 12,
    int fieldLimit = 16,
  }) => {
    'actionCount': actionCount,
    'familyCount': familyCount,
    'primitiveCount': primitiveCount,
    'fieldOptionCount': fieldOptionCount,
    'requiredGapCount': requiredGapCount,
    'advisoryGapCount': advisoryGapCount,
    'status': status.name,
    'statusLabel': statusLabel,
    'scoreImpactWeight': scoreImpactWeight,
    'scoreImpactLabel': scoreImpactLabel,
    'recommendedStartLabel': recommendedStartLabel,
    'topFamilyName': topFamily?.familyName,
    'topPrimitiveKey': topPrimitive?.primitiveKey,
    'topFieldName': topField?.fieldName,
    'phaseCounts': {
      for (final phase in RegistryHealthApiConsistencyActionPhase.values)
        phase.name: actionPlan.phaseCount(phase),
    },
    'actionPlan': actionPlan.toJson(itemLimit: actionLimit),
    'familyRemediation': familyRemediation.toJson(familyLimit: familyLimit),
    'primitiveRemediation': primitiveRemediation.toJson(
      primitiveLimit: primitiveLimit,
    ),
    'fieldRemediation': fieldRemediation.toJson(fieldLimit: fieldLimit),
  };
}

RegistryHealthApiConsistencyImplementationPlan
registryHealthApiConsistencyImplementationPlan(
  RegistryHealthApiConsistencyActionPlan actionPlan,
) {
  return RegistryHealthApiConsistencyImplementationPlan(
    actionPlan: actionPlan,
    familyRemediation: registryHealthApiConsistencyFamilyRemediationReport(
      actionPlan,
    ),
    primitiveRemediation:
        registryHealthApiConsistencyPrimitiveRemediationReport(actionPlan),
    fieldRemediation: registryHealthApiConsistencyFieldRemediationReport(
      actionPlan,
    ),
  );
}

String registryHealthApiConsistencyImplementationChecklistText(
  RegistryHealthApiConsistencyImplementationPlan plan, {
  int actionLimit = 8,
  int familyLimit = 4,
  int primitiveLimit = 5,
  int fieldLimit = 6,
}) {
  final lines = <String>[
    '# API Consistency Implementation Bundle',
    '',
    'Status: ${plan.statusLabel}',
    'Actions: ${plan.actionCount}',
    'Families: ${plan.familyCount}',
    'Primitives: ${plan.primitiveCount}',
    'Fields: ${plan.fieldOptionCount}',
    'Impact: +${plan.scoreImpactLabel}',
    '',
    '## Start Here',
    '',
    '- ${plan.recommendedStartLabel}',
  ];

  final family = plan.topFamily;
  if (family != null) {
    lines.add('- Family: ${family.familyName} - ${family.recipe.targetLabel}');
  }
  final primitive = plan.topPrimitive;
  if (primitive != null) {
    lines.add(
      '- Primitive: ${primitive.primitiveLabel} - '
      '${primitive.recipe.targetLabel}',
    );
  }
  final field = plan.topField;
  if (field != null) {
    lines.add('- Field: ${field.fieldName} - ${field.recipe.targetLabel}');
  }
  lines.add('');

  _addFamilySection(lines, plan.familyRemediation, limit: familyLimit);
  _addPrimitiveSection(lines, plan.primitiveRemediation, limit: primitiveLimit);
  _addFieldSection(lines, plan.fieldRemediation, limit: fieldLimit);
  _addActionSection(lines, plan.actionPlan, limit: actionLimit);

  return lines.join('\n').trimRight();
}

void _addFamilySection(
  List<String> lines,
  RegistryHealthApiConsistencyFamilyRemediationReport report, {
  required int limit,
}) {
  final items = report.visibleItems(limit: limit);
  if (items.isEmpty) return;
  lines
    ..add('## Family Plan')
    ..add('');
  for (final item in items) {
    lines.add(
      '- [ ] ${item.familyName}: ${item.recipe.targetLabel} '
      '(${item.leadingPhaseLabel}, impact +${item.scoreImpactLabel})',
    );
  }
  _addHiddenLine(lines, report.familyCount - items.length, 'families');
}

void _addPrimitiveSection(
  List<String> lines,
  RegistryHealthApiConsistencyPrimitiveRemediationReport report, {
  required int limit,
}) {
  final items = report.visibleItems(limit: limit);
  if (items.isEmpty) return;
  lines
    ..add('')
    ..add('## Primitive Plan')
    ..add('');
  for (final item in items) {
    lines.add(
      '- [ ] ${item.primitiveLabel}: ${item.recipe.targetLabel} '
      '(${item.fieldLabel})',
    );
  }
  _addHiddenLine(lines, report.primitiveCount - items.length, 'primitives');
}

void _addFieldSection(
  List<String> lines,
  RegistryHealthApiConsistencyFieldRemediationReport report, {
  required int limit,
}) {
  final items = report.visibleItems(limit: limit);
  if (items.isEmpty) return;
  lines
    ..add('')
    ..add('## Field Plan')
    ..add('');
  for (final item in items) {
    lines.add(
      '- [ ] ${item.fieldName}: ${item.recipe.targetLabel} '
      '(${item.recipe.adapterLabel}, ${item.recipe.valueKindLabel})',
    );
  }
  _addHiddenLine(lines, report.fieldOptionCount - items.length, 'fields');
}

void _addActionSection(
  List<String> lines,
  RegistryHealthApiConsistencyActionPlan actionPlan, {
  required int limit,
}) {
  final items = actionPlan.visibleItems(limit: limit);
  if (items.isEmpty) return;
  lines
    ..add('')
    ..add('## Action Queue')
    ..add('');
  for (final item in items) {
    lines.add(
      '- [ ] ${item.contractName}: ${item.concernLabel} '
      '(${item.phaseLabel}, impact +${item.scoreImpactLabel})',
    );
  }
  _addHiddenLine(lines, actionPlan.actionCount - items.length, 'actions');
}

void _addHiddenLine(List<String> lines, int hiddenCount, String label) {
  if (hiddenCount <= 0) return;
  lines.add('+$hiddenCount more $label hidden.');
}
