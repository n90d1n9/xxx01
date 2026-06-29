import '../services/mermaid_parser.dart';

void main() {
  final stateDiagramCode = '''
stateDiagram-v2
    [*] --> Still
    Still --> [*]
    Still --> Moving
    Moving --> Still
    Moving --> Crash
    Crash --> [*]
    
    state Still {
        [*] --> Stationary
        Stationary --> Moving
        Moving --> Stationary
    }
''';

  final diagram = MermaidParser.parse(stateDiagramCode);
  print('State Diagram type: ${diagram.type}');
  print('States: ${diagram.states.length}');
  print('Edges: ${diagram.edges.length}');

  for (final state in diagram.states) {
    print(
      'State: ${state.label} (${state.id}) - Initial: ${state.isInitial}, Final: ${state.isFinal}',
    );
    if (state.description != null) {
      print('  Description: ${state.description}');
    }
  }
}
