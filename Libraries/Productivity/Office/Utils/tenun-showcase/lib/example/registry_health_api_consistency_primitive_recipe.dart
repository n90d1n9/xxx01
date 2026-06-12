class RegistryHealthApiConsistencyPrimitiveRecipe {
  final String primitiveKey;
  final String targetLabel;
  final String implementationLabel;
  final String foundationLabel;
  final String testLabel;
  final List<String> acceptanceCriteria;

  const RegistryHealthApiConsistencyPrimitiveRecipe({
    required this.primitiveKey,
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
    'primitiveKey': primitiveKey,
    'targetLabel': targetLabel,
    'implementationLabel': implementationLabel,
    'foundationLabel': foundationLabel,
    'testLabel': testLabel,
    'acceptanceCriteria': List<String>.from(acceptanceCriteria),
    'acceptanceLabel': acceptanceLabel,
  };
}

RegistryHealthApiConsistencyPrimitiveRecipe
registryHealthApiConsistencyPrimitiveRecipe(String primitiveKey) {
  switch (primitiveKey) {
    case 'accessibility':
      return const RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: 'accessibility',
        targetLabel: 'Shared accessibility contract',
        implementationLabel:
            'Centralize semantic labels and semantics opt-out behavior for '
            'widget chart APIs.',
        foundationLabel: 'Chart semantics options',
        testLabel: 'Semantics labels and opt-out coverage',
        acceptanceCriteria: [
          'Widget APIs expose semantic labels and opt-out consistently.',
          'Defaults preserve existing semantics behavior.',
          'Showcase samples cover labeled and hidden semantic states.',
        ],
      );
    case 'animation':
      return const RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: 'animation',
        targetLabel: 'Shared animation contract',
        implementationLabel:
            'Centralize duration and curve controls for animated chart '
            'transitions.',
        foundationLabel: 'Chart animation options',
        testLabel: 'Animation duration, curve, and default behavior',
        acceptanceCriteria: [
          'Widget APIs expose duration and curve controls consistently.',
          'Defaults preserve current animation timing.',
          'Showcase samples include enabled and disabled animation states.',
        ],
      );
    case 'display':
      return const RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: 'display',
        targetLabel: 'Shared display contract',
        implementationLabel:
            'Centralize empty state, legend, theme, palette, and display '
            'toggles for chart widgets.',
        foundationLabel: 'Chart display options',
        testLabel: 'Display toggles, empty states, and palette coverage',
        acceptanceCriteria: [
          'Widget APIs expose display controls consistently.',
          'Empty-state builders render before chart marks when data is empty.',
          'Showcase samples cover empty, themed, and legend states.',
        ],
      );
    case 'formatting':
      return const RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: 'formatting',
        targetLabel: 'Shared formatter contract',
        implementationLabel:
            'Centralize value, label, axis, and tooltip formatter adapters.',
        foundationLabel: 'Chart formatter options',
        testLabel: 'Formatter forwarding and fallback labels',
        acceptanceCriteria: [
          'Formatter hooks receive the expected value/context shape.',
          'Defaults preserve existing labels when no formatter is supplied.',
          'Showcase samples cover value, label, and axis formatting.',
        ],
      );
    case 'interaction':
      return const RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: 'interaction',
        targetLabel: 'Shared interaction contract',
        implementationLabel:
            'Centralize tap, selection, active-element, and tooltip behavior '
            'for interactive chart widgets.',
        foundationLabel: 'Chart interaction options',
        testLabel: 'Callbacks, selection state, and active element coverage',
        acceptanceCriteria: [
          'Widget APIs expose tap, selection, and active-element hooks.',
          'Callbacks are optional and do not change non-interactive defaults.',
          'Showcase samples cover enabled and disabled interaction states.',
        ],
      );
    default:
      return RegistryHealthApiConsistencyPrimitiveRecipe(
        primitiveKey: primitiveKey,
        targetLabel:
            'Shared ${primitiveKey.isEmpty ? 'unknown' : primitiveKey} contract',
        implementationLabel:
            'Define a reusable chart API primitive before applying it to '
            'individual chart families.',
        foundationLabel: 'Chart primitive options',
        testLabel: 'Primitive forwarding and default behavior',
        acceptanceCriteria: const [
          'Shared options are reusable across chart families.',
          'Defaults preserve existing chart behavior.',
          'Showcase samples cover the new primitive.',
        ],
      );
  }
}
