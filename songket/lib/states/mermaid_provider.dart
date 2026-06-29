import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/mermaid_parser.dart';
import 'mermaid_state.dart';

class MermaidNotifier extends StateNotifier<MermaidState> {
  MermaidNotifier()
    : super(
        MermaidState(
          code: '''graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> B
    C --> E[End]''',
          diagram: MermaidParser.parse('''graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> B
    C --> E[End]'''),
        ),
      );

  void updateCode(String newCode) {
    try {
      final diagram = MermaidParser.parse(newCode);
      state = MermaidState(code: newCode, diagram: diagram);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void loadTemplate(String template) {
    updateCode(template);
  }

  void updateZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }

  void updatePan(Offset pan) {
    state = state.copyWith(pan: pan);
  }
}

final mermaidProvider = StateNotifierProvider<MermaidNotifier, MermaidState>((
  ref,
) {
  return MermaidNotifier();
});

final isEditModeProvider = StateProvider<bool>((ref) => true);
