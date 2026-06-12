import 'package:tenun/tenun_core.dart';

class RegistryHealthApiConsistencyFieldRecipe {
  final String fieldName;
  final String canonicalField;
  final String categoryLabel;
  final String valueKindLabel;
  final String adapterLabel;
  final String targetLabel;
  final String implementationLabel;
  final String testLabel;
  final List<String> acceptanceCriteria;

  const RegistryHealthApiConsistencyFieldRecipe({
    required this.fieldName,
    required this.canonicalField,
    required this.categoryLabel,
    required this.valueKindLabel,
    required this.adapterLabel,
    required this.targetLabel,
    required this.implementationLabel,
    required this.testLabel,
    required this.acceptanceCriteria,
  });

  String get acceptanceLabel {
    if (acceptanceCriteria.isEmpty) return 'Accept: no criteria defined';
    return 'Accept: ${acceptanceCriteria.first}';
  }

  Map<String, dynamic> toJson() => {
    'fieldName': fieldName,
    'canonicalField': canonicalField,
    'categoryLabel': categoryLabel,
    'valueKindLabel': valueKindLabel,
    'adapterLabel': adapterLabel,
    'targetLabel': targetLabel,
    'implementationLabel': implementationLabel,
    'testLabel': testLabel,
    'acceptanceCriteria': List<String>.from(acceptanceCriteria),
    'acceptanceLabel': acceptanceLabel,
  };
}

RegistryHealthApiConsistencyFieldRecipe registryHealthApiConsistencyFieldRecipe(
  String fieldName,
) {
  final spec = ChartApiFields.specFor(fieldName);
  final canonicalField = spec?.canonicalField ?? fieldName;
  final categoryLabel = _fieldCategoryLabel(spec?.category);
  final valueKindLabel = _fieldValueKindLabel(spec?.valueKind);
  final adapterLabel = _fieldAdapterLabel(spec);

  return RegistryHealthApiConsistencyFieldRecipe(
    fieldName: fieldName,
    canonicalField: canonicalField,
    categoryLabel: categoryLabel,
    valueKindLabel: valueKindLabel,
    adapterLabel: adapterLabel,
    targetLabel: '$canonicalField field contract',
    implementationLabel: _fieldImplementationLabel(
      canonicalField,
      spec?.valueKind,
    ),
    testLabel: '$valueKindLabel forwarding and default coverage',
    acceptanceCriteria: [
      '$canonicalField is exposed through $adapterLabel where supported.',
      'Defaults preserve existing ${categoryLabel.toLowerCase()} behavior '
          'when $canonicalField is omitted.',
      'Showcase samples cover configured and default $canonicalField states.',
    ],
  );
}

String _fieldImplementationLabel(
  String canonicalField,
  ChartApiFieldValueKind? valueKind,
) {
  switch (valueKind) {
    case ChartApiFieldValueKind.boolean:
      return 'Thread the $canonicalField toggle through shared options and '
          'centralize default resolution.';
    case ChartApiFieldValueKind.callback:
      return 'Forward the $canonicalField callback with stable chart context '
          'and keep null callbacks on the passive path.';
    case ChartApiFieldValueKind.formatter:
      return 'Adapt the $canonicalField formatter through shared value context '
          'and keep default labels when it is absent.';
    case ChartApiFieldValueKind.widgetBuilder:
      return 'Forward the $canonicalField builder through widget APIs and keep '
          'the existing fallback when it is absent.';
    case ChartApiFieldValueKind.duration:
    case ChartApiFieldValueKind.curve:
      return 'Resolve $canonicalField through shared animation options before '
          'chart-specific transitions run.';
    case ChartApiFieldValueKind.number:
      return 'Normalize $canonicalField values through shared numeric options '
          'before layout or scale calculation.';
    case ChartApiFieldValueKind.string:
      return 'Normalize $canonicalField text through shared options before '
          'rendering or semantics are built.';
    case ChartApiFieldValueKind.list:
      return 'Normalize $canonicalField collections through shared options '
          'before chart marks are built.';
    case ChartApiFieldValueKind.object:
    case null:
      return 'Map $canonicalField through a typed shared option object before '
          'chart-specific rendering is applied.';
  }
}

String _fieldAdapterLabel(ChartApiFieldSpec? spec) {
  if (spec == null) return 'the chart API';
  if (spec.configFriendly && spec.widgetFriendly) {
    return 'the config and widget APIs';
  }
  if (spec.configFriendly) return 'the config API';
  if (spec.widgetFriendly) return 'the widget API';
  return 'the internal chart API';
}

String _fieldCategoryLabel(ChartApiFieldCategory? category) {
  switch (category) {
    case ChartApiFieldCategory.structure:
      return 'Structure';
    case ChartApiFieldCategory.display:
      return 'Display';
    case ChartApiFieldCategory.interaction:
      return 'Interaction';
    case ChartApiFieldCategory.accessibility:
      return 'Accessibility';
    case ChartApiFieldCategory.animation:
      return 'Animation';
    case ChartApiFieldCategory.formatting:
      return 'Formatting';
    case ChartApiFieldCategory.layout:
      return 'Layout';
    case ChartApiFieldCategory.runtime:
      return 'Runtime';
    case null:
      return 'Unknown';
  }
}

String _fieldValueKindLabel(ChartApiFieldValueKind? valueKind) {
  switch (valueKind) {
    case ChartApiFieldValueKind.boolean:
      return 'Boolean toggle';
    case ChartApiFieldValueKind.string:
      return 'Text value';
    case ChartApiFieldValueKind.number:
      return 'Numeric value';
    case ChartApiFieldValueKind.duration:
      return 'Duration value';
    case ChartApiFieldValueKind.curve:
      return 'Curve value';
    case ChartApiFieldValueKind.formatter:
      return 'Formatter';
    case ChartApiFieldValueKind.callback:
      return 'Callback';
    case ChartApiFieldValueKind.widgetBuilder:
      return 'Widget builder';
    case ChartApiFieldValueKind.object:
      return 'Object value';
    case ChartApiFieldValueKind.list:
      return 'List value';
    case null:
      return 'Unknown value';
  }
}
