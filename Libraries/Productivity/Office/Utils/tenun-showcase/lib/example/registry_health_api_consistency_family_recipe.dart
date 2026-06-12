class RegistryHealthApiConsistencyFamilyRecipe {
  final String familyName;
  final String targetLabel;
  final String implementationLabel;
  final String foundationLabel;
  final String testLabel;
  final List<String> acceptanceCriteria;

  const RegistryHealthApiConsistencyFamilyRecipe({
    required this.familyName,
    required this.targetLabel,
    required this.implementationLabel,
    required this.foundationLabel,
    required this.testLabel,
    required this.acceptanceCriteria,
  });

  String get acceptanceLabel {
    if (acceptanceCriteria.isEmpty) return 'Accept: no criteria defined';
    return 'Accept: ${acceptanceCriteria.first}';
  }

  Map<String, dynamic> toJson() => {
    'familyName': familyName,
    'targetLabel': targetLabel,
    'implementationLabel': implementationLabel,
    'foundationLabel': foundationLabel,
    'testLabel': testLabel,
    'acceptanceCriteria': List<String>.from(acceptanceCriteria),
    'acceptanceLabel': acceptanceLabel,
  };
}

RegistryHealthApiConsistencyFamilyRecipe
registryHealthApiConsistencyFamilyRecipe(String familyName) {
  switch (familyName) {
    case 'optionConfig':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'optionConfig',
        targetLabel: 'Config-driven API parity',
        implementationLabel:
            'Bridge option config fields to shared chart primitives before '
            'adapter-specific behavior is applied.',
        foundationLabel: 'Config adapter options',
        testLabel: 'JSON parsing, defaults, and widget parity coverage',
        acceptanceCriteria: [
          'Config APIs expose shared behavior through typed options and JSON.',
          'JSON defaults match widget defaults for the same chart behavior.',
          'Showcase samples cover config and widget parity states.',
        ],
      );
    case 'simpleWidget':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'simpleWidget',
        targetLabel: 'Direct widget API baseline',
        implementationLabel:
            'Keep direct widget constructors aligned with shared primitive '
            'option objects and callback signatures.',
        foundationLabel: 'Widget option baseline',
        testLabel: 'Constructor defaults and callback forwarding coverage',
        acceptanceCriteria: [
          'Widget constructors expose the shared chart primitives consistently.',
          'Defaults keep existing direct-widget behavior stable.',
          'Showcase samples cover minimal and fully configured widgets.',
        ],
      );
    case 'cartesian':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'cartesian',
        targetLabel: 'Cartesian axis API baseline',
        implementationLabel:
            'Align axis, grid, formatter, tooltip, and selection controls '
            'across bar, line, area, scatter, and range charts.',
        foundationLabel: 'Cartesian axis options',
        testLabel: 'Axis, grid, formatter, and interaction coverage',
        acceptanceCriteria: [
          'Cartesian charts share axis, grid, and formatter controls.',
          'Selection and tooltip callbacks receive consistent point context.',
          'Showcase samples cover dense and sparse cartesian data.',
        ],
      );
    case 'polar':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'polar',
        targetLabel: 'Polar display API baseline',
        implementationLabel:
            'Align radius, label, legend, palette, tooltip, and tap controls '
            'across circular chart widgets.',
        foundationLabel: 'Polar display options',
        testLabel: 'Radius, label, palette, and tooltip coverage',
        acceptanceCriteria: [
          'Polar charts share radius, label, legend, and palette controls.',
          'Tooltip and tap callbacks receive consistent segment context.',
          'Showcase samples cover compact and labeled polar layouts.',
        ],
      );
    case 'statistical':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'statistical',
        targetLabel: 'Statistical comparison API baseline',
        implementationLabel:
            'Align distribution, uncertainty, formatter, semantic, and '
            'tooltip controls for statistical charts.',
        foundationLabel: 'Statistical display options',
        testLabel: 'Distribution labels, uncertainty, and tooltip coverage',
        acceptanceCriteria: [
          'Statistical charts share formatter, semantic, and tooltip controls.',
          'Uncertainty and distribution labels preserve current defaults.',
          'Showcase samples cover comparison and distribution states.',
        ],
      );
    case 'hierarchyFlow':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'hierarchyFlow',
        targetLabel: 'Hierarchy and flow API baseline',
        implementationLabel:
            'Align node, link, label, tooltip, palette, and drill interaction '
            'controls across hierarchy and flow charts.',
        foundationLabel: 'Hierarchy flow options',
        testLabel: 'Node, link, label, and interaction coverage',
        acceptanceCriteria: [
          'Hierarchy and flow charts share node, link, and label controls.',
          'Tap callbacks expose consistent node or edge context.',
          'Showcase samples cover overview and focused interaction states.',
        ],
      );
    case 'temporal':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'temporal',
        targetLabel: 'Temporal axis API baseline',
        implementationLabel:
            'Align time axis, label formatter, tooltip, range, and event '
            'selection controls across temporal charts.',
        foundationLabel: 'Temporal axis options',
        testLabel: 'Time labels, ranges, and event interaction coverage',
        acceptanceCriteria: [
          'Temporal charts share time axis and label formatter controls.',
          'Range and event callbacks expose consistent temporal context.',
          'Showcase samples cover short, long, and dense timelines.',
        ],
      );
    case 'financial':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'financial',
        targetLabel: 'Financial chart API baseline',
        implementationLabel:
            'Align value formatting, time axes, grid, tooltip, volume, and '
            'selection controls across trading chart widgets.',
        foundationLabel: 'Financial display options',
        testLabel: 'Price labels, volume, axes, and tooltip coverage',
        acceptanceCriteria: [
          'Financial charts share price, axis, grid, and tooltip controls.',
          'Selection callbacks expose consistent candle or interval context.',
          'Showcase samples cover price-only and price-with-volume states.',
        ],
      );
    case 'densitySpatial':
      return const RegistryHealthApiConsistencyFamilyRecipe(
        familyName: 'densitySpatial',
        targetLabel: 'Density and spatial API baseline',
        implementationLabel:
            'Align scale, palette, legend, formatter, tooltip, and cell '
            'interaction controls across density and spatial charts.',
        foundationLabel: 'Density spatial options',
        testLabel: 'Scale, legend, palette, and cell interaction coverage',
        acceptanceCriteria: [
          'Density and spatial charts share scale, palette, and legend controls.',
          'Tooltip callbacks expose consistent cell or region context.',
          'Showcase samples cover low, high, and missing-density states.',
        ],
      );
    default:
      return RegistryHealthApiConsistencyFamilyRecipe(
        familyName: familyName,
        targetLabel:
            '${familyName.isEmpty ? 'Unknown' : familyName} API baseline',
        implementationLabel:
            'Define the shared chart family API contract before applying '
            'chart-specific behavior.',
        foundationLabel: 'Chart family options',
        testLabel: 'Family defaults and shared primitive coverage',
        acceptanceCriteria: const [
          'The family exposes shared chart primitives consistently.',
          'Defaults preserve existing chart behavior.',
          'Showcase samples cover the family baseline.',
        ],
      );
  }
}
