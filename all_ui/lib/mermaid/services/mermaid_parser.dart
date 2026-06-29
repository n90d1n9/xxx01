import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import 'base_parser.dart';
import 'flowchart_parser.dart';
import 'class_diagram_parser.dart';
import 'git_grap_parser.dart';
import 'sequence_diagram_parser.dart';
import 'state_diagram_parser.dart';
import 'er_diagram_parser.dart';
import 'gantt_parser.dart';
import 'pie_chart_parser.dart';
import 'timeline_parser.dart';
import 'journey_parser.dart';
import 'mindmap_parser.dart';
import 'quadrant_parser.dart';

class MermaidParser {
  static final List<DiagramParser> _parsers = [
    FlowchartParser(),
    ClassDiagramParser(),
    SequenceDiagramParser(),
    StateDiagramParser(),
    ERDiagramParser(),
    GanttParser(),
    PieChartParser(),
    TimelineParser(),
    JourneyParser(),
    MindmapParser(),
    GitGraphParser(),
    QuadrantParser(),
  ];

  static MermaidDiagram parse(String code) {
    try {
      final lines = _preprocessCode(code);
      if (lines.isEmpty) {
        return MermaidDiagram(type: DiagramType.flowchart, rawCode: code);
      }

      // Find the first parser that can handle this diagram
      for (final parser in _parsers) {
        if (parser.canParse(lines)) {
          return parser.parse(lines, code);
        }
      }

      // Default to flowchart
      return FlowchartParser().parse(lines, code);
    } catch (e) {
      return MermaidDiagram(
        type: DiagramType.flowchart,
        rawCode: code,
        parseError: e.toString(),
      );
    }
  }

  static List<String> _preprocessCode(String code) {
    return code
        .trim()
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('%%'))
        .toList();
  }

  // Method to register custom parsers
  static void registerParser(DiagramParser parser) {
    _parsers.insert(0, parser); // Insert at beginning for priority
  }
}
