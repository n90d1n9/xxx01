import 'package:queue_ui/mermaid/models/git_commit.dart';

import 'class_node.dart';
import 'diagram_edge.dart';
import 'diagram_node.dart';
import 'diagram_type.dart';
import 'er_entity.dart';
import 'er_relationship.dart';
import 'gantt_task.dart';
import 'journey_task.dart';
import 'pie_slice.dart';
import 'state_node.dart';
import 'timeline_event.dart';

class MermaidDiagram {
  final DiagramType type;
  final String rawCode;
  final String? parseError;

  // Flowchart, Sequence, Mindmap, Quadrant
  final List<DiagramNode> nodes;
  final List<DiagramEdge> edges;

  // Class Diagram
  final List<ClassNode> classes;

  // State Diagram
  final List<StateNode> states;

  // ER Diagram
  final List<EREntity> entities;
  final List<ERRelationship> erRelationships;

  // Gantt Chart
  final List<GanttTask> ganttTasks;

  // Pie Chart
  final List<PieSlice> pieSlices;

  // Timeline
  final List<TimelineEvent> timelineEvents;

  // Journey
  final List<JourneyTask> journeyTasks;

  // Git Graph
  final List<GitCommit> gitCommits;

  MermaidDiagram({
    required this.type,
    required this.rawCode,
    this.parseError,
    this.nodes = const [],
    this.edges = const [],
    this.classes = const [],
    this.states = const [],
    this.entities = const [],
    this.erRelationships = const [],
    this.ganttTasks = const [],
    this.pieSlices = const [],
    this.timelineEvents = const [],
    this.journeyTasks = const [],
    this.gitCommits = const [],
  });

  bool get hasError => parseError != null;

  @override
  String toString() {
    return 'MermaidDiagram(type: $type, nodes: ${nodes.length}, edges: ${edges.length}, '
        'classes: ${classes.length}, states: ${states.length}, '
        'entities: ${entities.length}, gitCommits: ${gitCommits.length})';
  }
}
