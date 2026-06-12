import 'package:flutter/widgets.dart';

import '../models/class_member.dart';
import '../models/class_node.dart';
import '../models/diagram_edge.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';

import 'base_parser.dart';

class ClassDiagramParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('class');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final classes = <ClassNode>[];
    final edges = <DiagramEdge>[];
    ClassNode? currentClass;

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (_parseClassDefinition(line, classes)) {
        currentClass = classes.last;
        continue;
      }

      if (_parseRelationship(line, edges)) {
        continue;
      }

      if (currentClass != null) {
        _parseClassMember(line, currentClass, classes);
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

  bool _parseClassDefinition(String line, List<ClassNode> classes) {
    final match = RegExp(r'class\s+(\w+)(?:\s*<<(\w+)>>)?').firstMatch(line);
    if (match != null) {
      classes.add(
        ClassNode(
          id: match.group(1)!,
          label: match.group(1)!,
          annotation: match.group(2),
        ),
      );
      return true;
    }
    return false;
  }

  bool _parseRelationship(String line, List<DiagramEdge> edges) {
    final patterns = [
      RegExp(
        r'(\w+)\s*(<\|--|\|--|--\|>|--\*|\*--|--o|o--|-->|<--|\.\.\|>|<\.\.)\s*(\w+)',
      ),
      RegExp(r'(\w+)\s*"([^"]+)"\s*(-->|<--)\s*(\w+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        edges.add(
          DiagramEdge(
            from: match.group(1)!,
            to: match.group(match.groupCount == 3 ? 3 : 4)!,
            label: match.groupCount == 4 ? match.group(2) : null,
            type: _getRelationshipType(match.group(2)!),
          ),
        );
        return true;
      }
    }
    return false;
  }

  void _parseClassMember(
    String line,
    ClassNode currentClass,
    List<ClassNode> classes,
  ) {
    final pattern = RegExp(
      r'([+\-#~])\s*([\w<>]+)(?:\s*:\s*([\w<>]+))?(?:\s*\(([^)]*)\))?',
    );
    final match = pattern.firstMatch(line);

    if (match != null) {
      final member = ClassMember(
        name: match.group(2)!,
        type: match.group(3) ?? '',
        isMethod: match.group(4) != null,
        visibility: match.group(1)!,
        parameters: match.group(4) ?? '',
      );

      final index = classes.indexWhere((c) => c.id == currentClass.id);
      if (index != -1) {
        final updatedClass = _updateClassWithMember(classes[index], member);
        classes[index] = updatedClass;
      }
    }
  }

  ClassNode _updateClassWithMember(ClassNode classNode, ClassMember member) {
    if (member.isMethod) {
      return classNode.copyWith(methods: [...classNode.methods, member]);
    } else {
      return classNode.copyWith(attributes: [...classNode.attributes, member]);
    }
  }

  EdgeType _getRelationshipType(String arrow) {
    switch (arrow) {
      case '<|--':
      case '--|>':
        return EdgeType.inheritance;
      case '|--':
        return EdgeType.composition;
      case '--*':
      case '*--':
        return EdgeType.aggregation;
      case '--o':
      case 'o--':
        return EdgeType.association;
      case '-->':
      case '<--':
        return EdgeType.dependency;
      case '..|>':
      case '<..':
        return EdgeType.implementation;
      default:
        return EdgeType.solid;
    }
  }

  void _layoutClassNodes(List<ClassNode> classes) {
    if (classes.isEmpty) return;

    final rows = <int, List<ClassNode>>{};
    var row = 0;
    var col = 0;
    const itemsPerRow = 2;
    const spacingX = 350.0;
    const spacingY = 400.0;
    const startY = 50.0;

    // Group classes into rows
    for (final classNode in classes) {
      rows.putIfAbsent(row, () => []).add(classNode);
      col++;
      if (col >= itemsPerRow) {
        row++;
        col = 0;
      }
    }

    // Position classes in grid
    for (final entry in rows.entries) {
      final rowIndex = entry.key;
      final rowClasses = entry.value;
      final rowWidth = rowClasses.length * spacingX;
      final startX = (1000 - rowWidth) / 2;

      for (var i = 0; i < rowClasses.length; i++) {
        final classNode = rowClasses[i];
        final index = classes.indexWhere((c) => c.id == classNode.id);
        if (index != -1) {
          classes[index] = classNode.copyWith(
            position: Offset(
              startX + i * spacingX,
              rowIndex * spacingY + startY,
            ),
          );
        }
      }
    }
  }
}
