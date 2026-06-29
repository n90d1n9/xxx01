import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import 'class_diagram_painter.dart';
import 'er_diagram_painter.dart';
import 'flow_charat_painter.dart';
import 'gantt_chart_diagram.dart';
import 'git_graph_painter.dart';
import 'journey_painter.dart';
import 'mindmap_painter.dart';
import 'pie_chart_painter.dart';
import 'quadrant_painter.dart';
import 'sequence_diagram_painter.dart';
import 'state_diagram_painter.dart';
import 'timeline_painter.dart';

class DiagramViewer extends StatelessWidget {
  final MermaidDiagram diagram;

  const DiagramViewer({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 4.0,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: switch (diagram.type) {
                DiagramType.flowchart => FlowchartPainter(diagram: diagram),
                DiagramType.sequence => SequenceDiagramPainter(
                  diagram: diagram,
                ),
                DiagramType.classDiagram => ClassDiagramPainter(
                  diagram: diagram,
                ),
                DiagramType.stateDiagram => StateDiagramPainter(
                  diagram: diagram,
                ),
                DiagramType.erDiagram => ERDiagramPainter(diagram: diagram),
                DiagramType.gantt => GanttChartPainter(diagram: diagram),
                DiagramType.pie => PieChartPainter(diagram: diagram),
                DiagramType.timeline => TimelinePainter(diagram: diagram),
                DiagramType.journey => JourneyPainter(diagram: diagram),
                DiagramType.mindmap => MindmapPainter(diagram: diagram),
                DiagramType.gitGraph => GitGraphPainter(diagram: diagram),
                DiagramType.quadrant => QuadrantPainter(diagram: diagram),
              },
            ),
          ),
        ),
      ),
    );
  }
}
