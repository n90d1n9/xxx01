enum JsonRenderSafetyScenario {
  unknownType,
  unregisteredCustomType,
  invalidSamplingPolicy,
}

enum JsonRenderSafetyFallbackPreset { defaults, compact, quiet, production }

class JsonRenderSafetyScenarioDefinition {
  const JsonRenderSafetyScenarioDefinition({
    required this.label,
    required this.summary,
    required this.payload,
  });

  final String label;
  final String summary;
  final Map<String, dynamic> payload;
}

const jsonRenderSafetyScenarioDefinitions =
    <JsonRenderSafetyScenario, JsonRenderSafetyScenarioDefinition>{
      JsonRenderSafetyScenario.unknownType: JsonRenderSafetyScenarioDefinition(
        label: 'Unknown type',
        summary: 'Mistyped chart type with otherwise chart-like data.',
        payload: {
          'type': 'linee',
          'title': {'text': 'Weekly activation'},
          'series': [
            {
              'name': 'Activated',
              'data': [42, 48, 53, 61],
            },
          ],
        },
      ),
      JsonRenderSafetyScenario
          .unregisteredCustomType: JsonRenderSafetyScenarioDefinition(
        label: 'Unregistered custom type',
        summary: 'A custom chart key before its chart bundle is registered.',
        payload: {
          'type': 'customRevenueBridge',
          'title': {'text': 'Revenue bridge'},
          'series': [
            {
              'name': 'Bridge',
              'data': [
                {'name': 'Start', 'value': 120},
                {'name': 'Expansion', 'value': 38},
                {'name': 'Churn', 'value': -12},
                {'name': 'End', 'value': 146},
              ],
            },
          ],
        },
      ),
      JsonRenderSafetyScenario
          .invalidSamplingPolicy: JsonRenderSafetyScenarioDefinition(
        label: 'Invalid sampling policy',
        summary: 'Registered chart type with invalid runtime policy fields.',
        payload: {
          'type': 'line',
          'dataMode': 'turbo',
          'sampling': {'enabled': 'yes', 'threshold': 0, 'strategy': 'fastest'},
          'series': [
            {
              'name': 'Latency',
              'data': [20, 24, 18, 29, 23],
            },
          ],
        },
      ),
    };

JsonRenderSafetyScenarioDefinition jsonRenderSafetyScenarioDefinition(
  JsonRenderSafetyScenario scenario,
) {
  return jsonRenderSafetyScenarioDefinitions[scenario] ??
      jsonRenderSafetyScenarioDefinitions[JsonRenderSafetyScenario
          .unknownType]!;
}
