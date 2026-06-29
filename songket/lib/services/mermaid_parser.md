import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/class_member.dart';
import '../models/class_node.dart';
import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/er_entity.dart';
import '../models/gantt_task.dart';
import '../models/journey_task.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';
import '../models/pie_slice.dart';
import '../models/state_node.dart';
import '../models/timeline_event.dart';

class MermaidParser {
  static MermaidDiagram parse(String code) {
    try {
      final lines =
          code
              .trim()
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      if (lines.isEmpty) {
        return MermaidDiagram(type: DiagramType.flowchart, rawCode: code);
      }

      final firstLine = lines[0].toLowerCase();

      // Enhanced diagram type detection with better pattern matching
      if (firstLine.startsWith('pie')) return _parsePieChart(lines, code);
      if (firstLine.startsWith('sequence'))
        return _parseSequenceDiagram(lines, code);
      if (firstLine.startsWith('class')) return _parseClassDiagram(lines, code);
      if (firstLine.startsWith('state')) return _parseStateDiagram(lines, code);
      if (firstLine.startsWith('er')) return _parseERDiagram(lines, code);
      if (firstLine.startsWith('gantt')) return _parseGantt(lines, code);
      if (firstLine.startsWith('journey')) return _parseJourney(lines, code);
      if (firstLine.startsWith('timeline')) return _parseTimeline(lines, code);
      if (firstLine.startsWith('mindmap')) return _parseMindmap(lines, code);
      if (firstLine.startsWith('git')) return _parseGitGraph(lines, code);
      if (firstLine.startsWith('quadrant'))
        return _parseQuadrantChart(lines, code);
      if (firstLine.startsWith('graph') || firstLine.startsWith('flowchart')) {
        return _parseFlowchart(lines, code);
      }

      // Default to flowchart for unknown types
      return MermaidDiagram(type: DiagramType.flowchart, rawCode: code);
    } catch (e) {
      // Return a basic diagram with error information
      return MermaidDiagram(
        type: DiagramType.flowchart,
        rawCode: code,
        parseError: e.toString(),
      );
    }
  }

  static MermaidDiagram _parseFlowchart(List<String> lines, String code) {
    final nodes = <String, DiagramNode>{};
    final edges = <DiagramEdge>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Enhanced edge parsing with better pattern matching
      final edgePatterns = [
        // Standard edges: A --> B, A -- label --> B, A -->|label| B
        RegExp(
          r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>|<-->|<-\.->|<-=>)\s*(\w+)',
        ),
        RegExp(
          r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>)\s*\|\s*([^|]+)\s*\|\s*(\w+)',
        ),
        RegExp(r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>)\s*(\w+)\s*:\s*(.+)'),
      ];

      bool edgeFound = false;
      for (final pattern in edgePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final from = match.group(1)!;
          final arrow = match.group(2)!;
          final to = match.group(match.groupCount == 3 ? 3 : 4)!;
          final label = match.groupCount == 3 ? null : match.group(3);

          // Ensure nodes exist
          if (!nodes.containsKey(from)) {
            nodes[from] = DiagramNode(id: from, label: from);
          }
          if (!nodes.containsKey(to)) {
            nodes[to] = DiagramNode(id: to, label: to);
          }

          // Determine edge type
          EdgeType edgeType = EdgeType.solid;
          if (arrow.contains('.')) edgeType = EdgeType.dotted;
          if (arrow.contains('==')) edgeType = EdgeType.thick;
          if (arrow.contains('x')) edgeType = EdgeType.cross;
          if (arrow.contains('o')) edgeType = EdgeType.circle;

          edges.add(
            DiagramEdge(
              from: from,
              to: to,
              label: label?.trim(),
              type: edgeType,
              bidirectional: arrow.contains('<') && arrow.contains('>'),
            ),
          );
          edgeFound = true;
          break;
        }
      }
      if (edgeFound) continue;

      // Node definitions with shapes
      final nodePatterns = [
        RegExp(r'(\w+)\[([^\]]+)\]'), // Rectangle [text]
        RegExp(r'(\w+)\(([^)]+)\)'), // Rounded (text)
        RegExp(r'(\w+)\(\[([^\]]+)\]\)'), // Stadium ([text])
        RegExp(r'(\w+)\[\[([^\]]+)\]\]'), // Subroutine [[text]]
        RegExp(r'(\w+)\[\(([^)]+)\)\]'), // Cylindrical [(text)]
        RegExp(r'(\w+)\(\(([^)]+)\)\)'), // Circle ((text))
        RegExp(r'(\w+)>([^>]+)\]'), // Asymmetric >text]
        RegExp(r'(\w+)\{([^}]+)\}'), // Rhombus {text}
        RegExp(r'(\w+)\{\{([^}]+)\}\}'), // Hexagon {{text}}
        RegExp(r'(\w+)\[\/([^\/]+)\/\]'), // Parallelogram [/text/]
        RegExp(r'(\w+)\[\\([^\\]+)\\\]'), // Trapezoid [\text\]
        RegExp(r'(\w+)\(\(\(([^)]+)\)\)\)'), // Double circle (((text)))
      ];

      for (var j = 0; j < nodePatterns.length; j++) {
        final match = nodePatterns[j].firstMatch(line);
        if (match != null) {
          final id = match.group(1)!;
          final label = match.group(2)!;
          final shapes = [
            NodeShape.rectangle,
            NodeShape.rounded,
            NodeShape.stadium,
            NodeShape.subroutine,
            NodeShape.cylindrical,
            NodeShape.circle,
            NodeShape.asymmetric,
            NodeShape.rhombus,
            NodeShape.hexagon,
            NodeShape.parallelogram,
            NodeShape.trapezoid,
            NodeShape.doubleCircle,
          ];

          nodes[id] = DiagramNode(id: id, label: label, shape: shapes[j]);
          break;
        }
      }

      // Handle node styling
      final styleMatch = RegExp(
        r'style\s+(\w+)\s+fill:?#?(\w+),?stroke:?#?(\w+)',
      ).firstMatch(line);
      if (styleMatch != null) {
        final nodeId = styleMatch.group(1)!;
        final fillColor = styleMatch.group(2);
        final strokeColor = styleMatch.group(3);

        if (nodes.containsKey(nodeId)) {
          final node = nodes[nodeId]!;
          nodes[nodeId] = node.copyWith(
            fillColor: _parseColor(fillColor),
            strokeColor: _parseColor(strokeColor),
          );
        }
      }
    }

    _layoutNodes(nodes, edges);
    return MermaidDiagram(
      type: DiagramType.flowchart,
      nodes: nodes.values.toList(),
      edges: edges,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseClassDiagram(List<String> lines, String code) {
    final classes = <ClassNode>[];
    final edges = <DiagramEdge>[];
    ClassNode? currentClass;
    final classMap = <String, ClassNode>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Class definition with optional annotations
      if (line.startsWith('class ')) {
        final match = RegExp(
          r'class\s+(\w+)(?:\s*<<(\w+)>>)?',
        ).firstMatch(line);
        if (match != null) {
          currentClass = ClassNode(
            id: match.group(1)!,
            label: match.group(1)!,
            annotation: match.group(2),
          );
          classes.add(currentClass);
          classMap[currentClass.id] = currentClass;
        }
        continue;
      }

      // Enhanced relationship parsing
      final relPatterns = [
        RegExp(
          r'(\w+)\s*(<\|--|\|--|--\|>|--\*|\*--|--o|o--|-->|<--|\.\.\|>|<\.\.)\s*(\w+)',
        ),
        RegExp(r'(\w+)\s*("([^"]+)"\s*)?(-->|<--)\s*(\w+)'),
      ];

      for (final pattern in relPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final from = match.group(1)!;
          final arrow = match.group(2)!;
          final label = match.group(3);
          final to = match.group(match.groupCount == 3 ? 3 : 5)!;

          edges.add(
            DiagramEdge(
              from: from,
              to: to,
              label: label,
              type: _getClassRelationshipType(arrow),
            ),
          );
          break;
        }
      }

      // Parse class members with better pattern matching
      if (currentClass != null) {
        final memberPattern = RegExp(
          r'([+\-#~])\s*([\w<>]+)(?:\s*:\s*([\w<>]+))?(?:\s*\(([^)]*)\))?',
        );
        final match = memberPattern.firstMatch(line);

        if (match != null) {
          final visibility = match.group(1)!;
          final name = match.group(2)!;
          final type = match.group(3);
          final params = match.group(4);
          final isMethod = params != null;

          final member = ClassMember(
            name: name,
            type: type ?? '',
            isMethod: isMethod,
            visibility: visibility,
            parameters: params ?? '',
          );

          if (isMethod) {
            currentClass = currentClass.copyWith(
              methods: [...currentClass.methods, member],
            );
          } else {
            currentClass = currentClass.copyWith(
              attributes: [...currentClass.attributes, member],
            );
          }

          // Update the class in both lists
          final index = classes.indexWhere((c) => c.id == currentClass!.id);
          if (index != -1) {
            classes[index] = currentClass!;
            classMap[currentClass!.id] = currentClass!;
          }
        }
      }
    }

    _layoutClassNodes(classes);
    return MermaidDiagram(
      type: DiagramType.classDiagram,
      classes: classes,
      edges: edges,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseStateDiagram(List<String> lines, String code) {
    final states = <StateNode>[];
    final edges = <DiagramEdge>[];
    final stateMap = <String, StateNode>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // State definitions
      final stateDefMatch = RegExp(
        r'state\s+"?([^"]+)"?\s*\{',
      ).firstMatch(line);
      if (stateDefMatch != null) {
        final stateName = stateDefMatch.group(1)!;
        if (!stateMap.containsKey(stateName)) {
          final state = StateNode(id: stateName, label: stateName);
          states.add(state);
          stateMap[stateName] = state;
        }
        continue;
      }

      // State transitions with better pattern matching
      final transMatch = RegExp(
        r'(\w+|\[\*\])\s*-->\s*(\w+|\[\*\])(?:\s*:\s*([^:]+))?',
      ).firstMatch(line);
      if (transMatch != null) {
        final from = transMatch.group(1)!;
        final to = transMatch.group(2)!;
        final label = transMatch.group(3)?.trim();

        edges.add(DiagramEdge(from: from, to: to, label: label));

        // Create state nodes if they don't exist
        if (!stateMap.containsKey(from) && from != '[*]') {
          final state = StateNode(
            id: from,
            label: from,
            isInitial: from == '[*]',
          );
          states.add(state);
          stateMap[from] = state;
        }
        if (!stateMap.containsKey(to) && to != '[*]') {
          final state = StateNode(id: to, label: to, isFinal: to == '[*]');
          states.add(state);
          stateMap[to] = state;
        }
      }

      // State descriptions
      final descMatch = RegExp(r':([^:]+):').firstMatch(line);
      if (descMatch != null && stateMap.isNotEmpty) {
        final lastState = states.last;
        states[states.length - 1] = lastState.copyWith(
          description: descMatch.group(1),
        );
      }
    }

    _layoutStateNodes(states, edges);
    return MermaidDiagram(
      type: DiagramType.stateDiagram,
      states: states,
      edges: edges,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseERDiagram(List<String> lines, String code) {
    final entities = <EREntity>[];
    final relationships = <ERRelationship>[];
    final entityMap = <String, EREntity>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Entity definitions
      final entityMatch = RegExp(r'entity\s+"?([^"]+)"?\s*\{').firstMatch(line);
      if (entityMatch != null) {
        final name = entityMatch.group(1)!;
        if (!entityMap.containsKey(name)) {
          final entity = EREntity(name: name);
          entities.add(entity);
          entityMap[name] = entity;
        }
        continue;
      }

      // Enhanced ER Relationships
      final relMatch = RegExp(
        r'(\w+)\s*(\|\||o\||\}\||\|o|\|}|\}|\})\s*--\s*(\|\||o\||\}\||\|o|\|}|\}|\})\s*(\w+)(?:\s*:\s*"([^"]+)")?',
      ).firstMatch(line);

      if (relMatch != null) {
        final from = relMatch.group(1)!;
        final fromType = relMatch.group(2)!;
        final toType = relMatch.group(3)!;
        final to = relMatch.group(4)!;
        final label = relMatch.group(5);

        if (!entityMap.containsKey(from)) {
          final entity = EREntity(name: from);
          entities.add(entity);
          entityMap[from] = entity;
        }
        if (!entityMap.containsKey(to)) {
          final entity = EREntity(name: to);
          entities.add(entity);
          entityMap[to] = entity;
        }

        relationships.add(
          ERRelationship(
            from: from,
            to: to,
            fromCardinality: fromType,
            toCardinality: toType,
            label: label ?? '',
          ),
        );
      }

      // Entity attributes with types
      final attrMatch = RegExp(
        r'\s*(\w+)(?:\s+(\w+))?(?:\s+(\w+))?',
      ).firstMatch(line);
      if (attrMatch != null && line.contains('{') && line.contains('}')) {
        // Extract attributes from within braces
        final braceContent = line.substring(
          line.indexOf('{') + 1,
          line.lastIndexOf('}'),
        );
        final attrs =
            braceContent
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

        // Find the entity name
        final entityNameMatch = RegExp(r'(\w+)\s*\{').firstMatch(line);
        if (entityNameMatch != null) {
          final entityName = entityNameMatch.group(1)!;
          final existingIndex = entities.indexWhere(
            (e) => e.name == entityName,
          );
          if (existingIndex >= 0) {
            entities[existingIndex] = entities[existingIndex].copyWith(
              attributes: attrs,
            );
          }
        }
      }
    }

    _layoutEREntities(entities);
    return MermaidDiagram(
      type: DiagramType.erDiagram,
      entities: entities,
      erRelationships: relationships,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseGantt(List<String> lines, String code) {
    final tasks = <GanttTask>[];
    String currentSection = 'General';
    DateTime? baseDate;
    final dateFormat = RegExp(r'\d{4}-\d{2}-\d{2}');

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Parse date format
      if (line.startsWith('dateFormat')) {
        // We'll use the default DateTime parsing
        continue;
      }

      // Parse start date
      if (line.startsWith('startDate')) {
        final dateMatch = dateFormat.firstMatch(line);
        if (dateMatch != null) {
          try {
            baseDate = DateTime.parse(dateMatch.group(0)!);
          } catch (_) {}
        }
        continue;
      }

      if (line.startsWith('section ')) {
        currentSection = line.substring(8).trim();
        continue;
      }

      // Enhanced task parsing
      final taskMatch = RegExp(
        r'(\w[\w\s]*)\s*:\s*(?:(crit|active|done)\s*,?\s*)?(?:(\d{4}-\d{2}-\d{2})\s*,?\s*)?(?:(\d+d)\s*,?\s*)?(?:(\d{4}-\d{2}-\d{2}))?',
      ).firstMatch(line);

      if (taskMatch != null) {
        final name = taskMatch.group(1)!.trim();
        final status = taskMatch.group(2) ?? '';
        final startStr = taskMatch.group(3);
        final durationStr = taskMatch.group(4);
        final endStr = taskMatch.group(5);

        DateTime startDate = baseDate ?? DateTime(2024, 1, 1);
        if (startStr != null) {
          try {
            startDate = DateTime.parse(startStr);
          } catch (_) {}
        }

        DateTime endDate;
        if (endStr != null) {
          try {
            endDate = DateTime.parse(endStr);
          } catch (_) {
            endDate = startDate.add(const Duration(days: 5));
          }
        } else if (durationStr != null) {
          final days = int.tryParse(durationStr.replaceAll('d', '')) ?? 5;
          endDate = startDate.add(Duration(days: days));
        } else {
          endDate = startDate.add(const Duration(days: 5));
        }

        tasks.add(
          GanttTask(
            id: 'task_${tasks.length}',
            name: name,
            section: currentSection,
            startDate: startDate,
            endDate: endDate,
            status: status,
          ),
        );
      }
    }

    return MermaidDiagram(
      type: DiagramType.gantt,
      ganttTasks: tasks,
      rawCode: code,
    );
  }

  static MermaidDiagram _parsePieChart(List<String> lines, String code) {
    final slices = <PieSlice>[];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      final match = RegExp(r'"([^"]+)"\s*:\s*(\d+(?:\.\d+)?)').firstMatch(line);
      if (match != null) {
        slices.add(
          PieSlice(
            label: match.group(1)!,
            value: double.parse(match.group(2)!),
            color: colors[slices.length % colors.length],
          ),
        );
      }
    }

    // Calculate percentages
    final total = slices.fold(0.0, (sum, slice) => sum + slice.value);
    for (final slice in slices) {
      slice.percentage = (slice.value / total * 100).round();
    }

    return MermaidDiagram(
      type: DiagramType.pie,
      pieSlices: slices,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseSequenceDiagram(List<String> lines, String code) {
    final participants = <String, DiagramNode>{};
    final edges = <DiagramEdge>[];
    var participantIndex = 0;
    final participantOrder = <String>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Participant definitions
      final participantMatch = RegExp(
        r'(participant|actor)\s+(\w+)(?:\s+as\s+(.+))?',
      ).firstMatch(line);
      if (participantMatch != null) {
        final id = participantMatch.group(2)!;
        final label = participantMatch.group(3) ?? id;
        final isActor = participantMatch.group(1) == 'actor';

        participants[id] = DiagramNode(
          id: id,
          label: label,
          position: Offset(participantIndex * 150.0, 0),
          shape: isActor ? NodeShape.actor : NodeShape.rectangle,
        );
        participantOrder.add(id);
        participantIndex++;
        continue;
      }

      // Messages between participants
      final messageMatch = RegExp(
        r'(\w+)\s*(->>|-->>|->|-->|-x|--x|->>|-->>)\s*(\w+)\s*:\s*(.+)',
      ).firstMatch(line);
      if (messageMatch != null) {
        final from = messageMatch.group(1)!;
        final arrow = messageMatch.group(2)!;
        final to = messageMatch.group(3)!;
        final message = messageMatch.group(4)!;

        // Ensure participants exist
        if (!participants.containsKey(from)) {
          participants[from] = DiagramNode(
            id: from,
            label: from,
            position: Offset(participantIndex * 150.0, 0),
          );
          participantOrder.add(from);
          participantIndex++;
        }
        if (!participants.containsKey(to)) {
          participants[to] = DiagramNode(
            id: to,
            label: to,
            position: Offset(participantIndex * 150.0, 0),
          );
          participantOrder.add(to);
          participantIndex++;
        }

        EdgeType type = EdgeType.solid;
        if (arrow.contains('--')) type = EdgeType.dotted;
        if (arrow.contains('x')) type = EdgeType.cross;
        if (arrow.contains('>>')) type = EdgeType.thick;

        edges.add(DiagramEdge(from: from, to: to, label: message, type: type));
      }

      // Notes
      final noteMatch = RegExp(
        r'Note\s+(over|left of|right of)\s+(\w+)\s*:\s*(.+)',
      ).firstMatch(line);
      if (noteMatch != null) {
        // Handle notes - could be stored as special nodes
        final position = noteMatch.group(1)!;
        final target = noteMatch.group(2)!;
        final text = noteMatch.group(3)!;

        // Create a note node
        final noteId = 'note_${edges.length}';
        participants[noteId] = DiagramNode(
          id: noteId,
          label: text,
          shape: NodeShape.note,
        );
      }
    }

    // Reorder participants based on appearance
    final orderedParticipants =
        participantOrder.map((id) => participants[id]!).toList();

    return MermaidDiagram(
      type: DiagramType.sequence,
      nodes: orderedParticipants,
      edges: edges,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseTimeline(List<String> lines, String code) {
    final events = <TimelineEvent>[];
    String? currentPeriod;
    String? currentTitle;
    List<String> currentEvents = [];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('%%')) continue;

      if (!line.startsWith('    ') && !line.startsWith(':')) {
        // New period
        if (currentPeriod != null) {
          events.add(
            TimelineEvent(
              period: currentPeriod,
              title: currentTitle ?? '',
              events: List.from(currentEvents),
            ),
          );
        }
        currentPeriod = line;
        currentTitle = null;
        currentEvents = [];
      } else if (line.startsWith(':')) {
        final content = line.substring(1).trim();
        if (currentTitle == null) {
          currentTitle = content;
        } else {
          currentEvents.add(content);
        }
      }
    }

    // Add the last event
    if (currentPeriod != null) {
      events.add(
        TimelineEvent(
          period: currentPeriod,
          title: currentTitle ?? '',
          events: currentEvents,
        ),
      );
    }

    return MermaidDiagram(
      type: DiagramType.timeline,
      timelineEvents: events,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseJourney(List<String> lines, String code) {
    final tasks = <JourneyTask>[];
    var currentSection = '';

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('%%')) continue;

      if (line.startsWith('title ')) {
        // Handle title
        continue;
      }

      if (line.startsWith('section ')) {
        currentSection = line.substring(8).trim();
        continue;
      }

      final match = RegExp(
        r'(\d+)\s*:\s*(\w[\w\s]*)\s*:\s*(\d+)',
      ).firstMatch(line);
      if (match != null) {
        final score = int.parse(match.group(1)!);
        final label = match.group(2)!.trim();
        final value = int.parse(match.group(3)!);

        tasks.add(
          JourneyTask(
            id: 'journey_${tasks.length}',
            label: label,
            score: score,
            value: value,
            section: currentSection,
            task: '',
          ),
        );
      }
    }

    return MermaidDiagram(
      type: DiagramType.journey,
      journeyTasks: tasks,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseMindmap(List<String> lines, String code) {
    final nodes = <DiagramNode>[];
    final edges = <DiagramEdge>[];
    final nodeMap = <String, DiagramNode>{};
    var rootId = '';

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Remove leading asterisks and trim
      final content = line.replaceAll(RegExp(r'^\*+'), '').trim();
      final level = line.indexOf(content) - line.indexOf('*');

      if (level == 1) {
        // Root node
        rootId = 'root_${nodes.length}';
        final rootNode = DiagramNode(
          id: rootId,
          label: content,
          shape: NodeShape.ellipse,
        );
        nodes.add(rootNode);
        nodeMap[rootId] = rootNode;
      } else if (level > 1) {
        // Child node
        final parentId = nodeMap.keys.lastWhere(
          (id) => nodeMap[id]!.label.length < level,
        );
        final childId = 'node_${nodes.length}';
        final childNode = DiagramNode(
          id: childId,
          label: content,
          shape: NodeShape.rectangle,
        );
        nodes.add(childNode);
        nodeMap[childId] = childNode;

        edges.add(
          DiagramEdge(from: parentId, to: childId, type: EdgeType.solid),
        );
      }
    }

    _layoutMindmap(nodes, edges, rootId);
    return MermaidDiagram(
      type: DiagramType.mindmap,
      nodes: nodes,
      edges: edges,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseGitGraph(List<String> lines, String code) {
    final commits = <GitCommit>[];
    final branches = <String, String>{}; // branch name -> commit id
    String currentBranch = 'main';
    var commitCount = 0;

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('%%')) continue;

      if (line.startsWith('branch ')) {
        final branchName = line.substring(7).trim();
        branches[branchName] = commits.isNotEmpty ? commits.last.id : 'initial';
        currentBranch = branchName;
        continue;
      }

      if (line.startsWith('commit ')) {
        commitCount++;
        final commitId = 'commit_$commitCount';
        final message = line.substring(7).trim().replaceAll('"', '');

        commits.add(
          GitCommit(
            id: commitId,
            message: message,
            branch: currentBranch,
            timestamp: DateTime.now().subtract(Duration(days: commitCount)),
          ),
        );

        // Update branch pointer
        branches[currentBranch] = commitId;
      }

      if (line.startsWith('merge ')) {
        final branchName = line.substring(6).trim();
        // Handle merge - could create a special commit
        commitCount++;
        final mergeCommitId = 'merge_$commitCount';
        commits.add(
          GitCommit(
            id: mergeCommitId,
            message: 'Merge $branchName into $currentBranch',
            branch: currentBranch,
            timestamp: DateTime.now().subtract(Duration(days: commitCount)),
            isMerge: true,
            mergedBranch: branchName,
          ),
        );
        branches[currentBranch] = mergeCommitId;
      }
    }

    return MermaidDiagram(
      type: DiagramType.gitGraph,
      gitCommits: commits,
      rawCode: code,
    );
  }

  static MermaidDiagram _parseQuadrantChart(List<String> lines, String code) {
    final nodes = <DiagramNode>[];
    final quadrantTitles = <String>['', '', '', ''];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('%%')) continue;

      // Quadrant titles
      if (line.startsWith('quadrant')) {
        final match = RegExp(r'quadrant\s*(\d)\s*:\s*(.+)').firstMatch(line);
        if (match != null) {
          final quadrant = int.parse(match.group(1)!);
          final title = match.group(2)!;
          if (quadrant >= 1 && quadrant <= 4) {
            quadrantTitles[quadrant - 1] = title;
          }
        }
        continue;
      }

      // Data points
      final match = RegExp(
        r'([^:]+):\s*\[(\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?)\]',
      ).firstMatch(line);
      if (match != null) {
        final label = match.group(1)!.trim();
        final x = double.parse(match.group(2)!);
        final y = double.parse(match.group(3)!);

        nodes.add(
          DiagramNode(
            id: 'point_${nodes.length}',
            label: label,
            shape: NodeShape.circle,
            position: Offset(x * 100 + 200, 400 - y * 100),
          ),
        );
      }
    }

    return MermaidDiagram(
      type: DiagramType.quadrant,
      nodes: nodes,
      rawCode: code,
    );
  }

  // Helper methods
  static Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;

    try {
      // Handle hex colors
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }

      // Handle named colors
      switch (colorStr.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'teal':
          return Colors.teal;
        case 'cyan':
          return Colors.cyan;
        case 'amber':
          return Colors.amber;
        case 'grey':
          return Colors.grey;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static EdgeType _getClassRelationshipType(String arrow) {
    switch (arrow) {
      case '<|--':
        return EdgeType.inheritance;
      case '|--':
        return EdgeType.composition;
      case '--|>':
        return EdgeType.inheritance;
      case '--*':
        return EdgeType.aggregation;
      case '*--':
        return EdgeType.aggregation;
      case '--o':
        return EdgeType.association;
      case 'o--':
        return EdgeType.association;
      case '-->':
        return EdgeType.dependency;
      case '<--':
        return EdgeType.dependency;
      case '..|>':
        return EdgeType.implementation;
      case '<..':
        return EdgeType.implementation;
      default:
        return EdgeType.solid;
    }
  }

  // Layout helpers
  static void _layoutNodes(
    Map<String, DiagramNode> nodes,
    List<DiagramEdge> edges,
  ) {
    if (nodes.isEmpty) return;

    final levels = <String, int>{};
    final visited = <String>{};

    void assignLevel(String nodeId, int level) {
      if (visited.contains(nodeId)) return;
      visited.add(nodeId);
      levels[nodeId] = math.max(levels[nodeId] ?? 0, level);

      for (final edge in edges.where((e) => e.from == nodeId)) {
        assignLevel(edge.to, level + 1);
      }
    }

    final hasIncoming = edges.map((e) => e.to).toSet();
    final roots = nodes.keys.where((id) => !hasIncoming.contains(id)).toList();

    if (roots.isEmpty && nodes.isNotEmpty) {
      assignLevel(nodes.keys.first, 0);
    } else {
      for (final root in roots) {
        assignLevel(root, 0);
      }
    }

    final nodesByLevel = <int, List<String>>{};
    for (final entry in levels.entries) {
      nodesByLevel.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    for (final entry in nodesByLevel.entries) {
      final level = entry.key;
      final nodesInLevel = entry.value;
      final levelWidth = nodesInLevel.length * 250.0;
      final startX = (800 - levelWidth) / 2;

      for (var i = 0; i < nodesInLevel.length; i++) {
        final nodeId = nodesInLevel[i];
        nodes[nodeId] = nodes[nodeId]!.copyWith(
          position: Offset(startX + i * 250.0, level * 180.0 + 100),
        );
      }
    }
  }

  static void _layoutClassNodes(List<ClassNode> classes) {
    final rows = <int, List<ClassNode>>{};
    var row = 0;
    var col = 0;

    for (final classNode in classes) {
      rows.putIfAbsent(row, () => []).add(classNode);
      col++;
      if (col >= 3) {
        // 3 classes per row
        row++;
        col = 0;
      }
    }

    for (final entry in rows.entries) {
      final rowIndex = entry.key;
      final rowClasses = entry.value;
      final rowWidth = rowClasses.length * 280.0;
      final startX = (1000 - rowWidth) / 2;

      for (var i = 0; i < rowClasses.length; i++) {
        final classNode = rowClasses[i];
        final index = classes.indexWhere((c) => c.id == classNode.id);
        if (index != -1) {
          classes[index] = classNode.copyWith(
            position: Offset(startX + i * 280.0, rowIndex * 300.0 + 50),
          );
        }
      }
    }
  }

  static void _layoutStateNodes(
    List<StateNode> states,
    List<DiagramEdge> edges,
  ) {
    final levels = <String, int>{};

    // Find initial states
    for (final state in states) {
      if (state.isInitial) {
        levels[state.id] = 0;
      }
    }

    // Assign levels based on transitions
    for (final edge in edges) {
      final fromLevel = levels[edge.from] ?? 0;
      levels[edge.to] = math.max(levels[edge.to] ?? 0, fromLevel + 1);
    }

    final byLevel = <int, List<StateNode>>{};
    for (final state in states) {
      final level = levels[state.id] ?? 0;
      byLevel.putIfAbsent(level, () => []).add(state);
    }

    for (final entry in byLevel.entries) {
      final level = entry.key;
      final levelStates = entry.value;
      final levelWidth = levelStates.length * 250.0;
      final startX = (800 - levelWidth) / 2;

      for (var i = 0; i < levelStates.length; i++) {
        final state = levelStates[i];
        final index = states.indexWhere((s) => s.id == state.id);
        if (index != -1) {
          states[index] = state.copyWith(
            position: Offset(startX + i * 250.0, level * 150.0 + 50),
          );
        }
      }
    }
  }

  static void _layoutEREntities(List<EREntity> entities) {
    final rows = <int, List<EREntity>>{};
    var row = 0;
    var col = 0;

    for (final entity in entities) {
      rows.putIfAbsent(row, () => []).add(entity);
      col++;
      if (col >= 2) {
        // 2 entities per row
        row++;
        col = 0;
      }
    }

    for (final entry in rows.entries) {
      final rowIndex = entry.key;
      final rowEntities = entry.value;
      final rowWidth = rowEntities.length * 320.0;
      final startX = (1000 - rowWidth) / 2;

      for (var i = 0; i < rowEntities.length; i++) {
        final entity = rowEntities[i];
        final index = entities.indexWhere((e) => e.name == entity.name);
        if (index != -1) {
          entities[index] = entity.copyWith(
            position: Offset(startX + i * 320.0, rowIndex * 200.0 + 100),
          );
        }
      }
    }
  }

  static void _layoutMindmap(
    List<DiagramNode> nodes,
    List<DiagramEdge> edges,
    String rootId,
  ) {
    if (nodes.isEmpty) return;

    final rootNode = nodes.firstWhere((n) => n.id == rootId);
    final children = <String, List<String>>{};

    for (final edge in edges) {
      children.putIfAbsent(edge.from, () => []).add(edge.to);
    }

    void layoutChildren(
      String nodeId,
      int level,
      double startAngle,
      double angleRange,
    ) {
      final childIds = children[nodeId] ?? [];
      if (childIds.isEmpty) return;

      final angleStep = angleRange / math.max(1, childIds.length - 1);
      final parentNode = nodes.firstWhere((n) => n.id == nodeId);
      final radius = 120.0 + level * 80;

      for (var i = 0; i < childIds.length; i++) {
        final childNode = nodes.firstWhere((n) => n.id == childIds[i]);
        final angle = startAngle - angleRange / 2 + angleStep * i;

        childNode.position = Offset(
          parentNode.position.dx + radius * math.cos(angle),
          parentNode.position.dy + radius * math.sin(angle),
        );

        layoutChildren(childIds[i], level + 1, angle, angleRange * 0.6);
      }
    }

    layoutChildren(rootId, 1, -math.pi / 2, math.pi);
  }
}
