import 'package:flutter/widgets.dart';

import '../models/mermaid_diagram.dart';

class MermaidState {
  final String code;
  final MermaidDiagram diagram;
  final String? error;
  final double zoom;
  final Offset pan;

  MermaidState({
    required this.code,
    required this.diagram,
    this.error,
    this.zoom = 1.0,
    this.pan = Offset.zero,
  });

  MermaidState copyWith({
    String? code,
    MermaidDiagram? diagram,
    String? error,
    double? zoom,
    Offset? pan,
  }) {
    return MermaidState(
      code: code ?? this.code,
      diagram: diagram ?? this.diagram,
      error: error,
      zoom: zoom ?? this.zoom,
      pan: pan ?? this.pan,
    );
  }
}
