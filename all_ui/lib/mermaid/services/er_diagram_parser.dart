import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/er_entity.dart';
import '../models/er_relationship.dart';
import '../models/mermaid_diagram.dart';
import 'base_parser.dart';

class ERDiagramParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('er');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final entities = <EREntity>[];
    final relationships = <ERRelationship>[];
    final entityMap = <String, EREntity>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseLine(line, entities, relationships, entityMap);
    }

    _layoutEntities(entities);
    return MermaidDiagram(
      type: DiagramType.erDiagram,
      entities: entities,
      erRelationships: relationships,
      rawCode: code,
    );
  }

  void _parseLine(
    String line,
    List<EREntity> entities,
    List<ERRelationship> relationships,
    Map<String, EREntity> entityMap,
  ) {
    // Entity definitions
    if (_parseEntityDefinition(line, entities, entityMap)) return;

    // Relationships
    if (_parseRelationship(line, relationships, entities, entityMap)) return;

    // Entity attributes
    _parseEntityAttributes(line, entities, entityMap);
  }

  bool _parseEntityDefinition(
    String line,
    List<EREntity> entities,
    Map<String, EREntity> entityMap,
  ) {
    final entityMatch = RegExp(
      r'entity\s+"?([^"\s]+)"?\s*\{?',
    ).firstMatch(line);
    if (entityMatch != null) {
      final name = entityMatch.group(1)!;
      if (!entityMap.containsKey(name)) {
        final entity = EREntity(name: name);
        entities.add(entity);
        entityMap[name] = entity;
      }
      return true;
    }
    return false;
  }

  bool _parseRelationship(
    String line,
    List<ERRelationship> relationships,
    List<EREntity> entities,
    Map<String, EREntity> entityMap,
  ) {
    final relMatch = RegExp(
      r'(\w+)\s*(\|\||o\||\}\||\|o|\|}\}|\})\s*--\s*(\|\||o\||\}\||\|o|\|}\}|\})\s*(\w+)(?:\s*:\s*"([^"]+)")?',
    ).firstMatch(line);

    if (relMatch != null) {
      final from = relMatch.group(1)!;
      final fromType = relMatch.group(2)!;
      final toType = relMatch.group(3)!;
      final to = relMatch.group(4)!;
      final label = relMatch.group(5);

      _ensureEntityExists(from, entities, entityMap);
      _ensureEntityExists(to, entities, entityMap);

      relationships.add(
        ERRelationship(
          from: from,
          to: to,
          fromCardinality: fromType,
          toCardinality: toType,
          label: label ?? '',
        ),
      );
      return true;
    }
    return false;
  }

  void _parseEntityAttributes(
    String line,
    List<EREntity> entities,
    Map<String, EREntity> entityMap,
  ) {
    // Look for attribute definitions within braces
    if (line.contains('{') && line.contains('}')) {
      final entityMatch = RegExp(r'(\w+)\s*\{([^}]+)\}').firstMatch(line);
      if (entityMatch != null) {
        final entityName = entityMatch.group(1)!;
        final attributesStr = entityMatch.group(2)!;

        final attributes =
            attributesStr
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

        final existingIndex = entities.indexWhere((e) => e.name == entityName);
        if (existingIndex >= 0) {
          entities[existingIndex] = entities[existingIndex].copyWith(
            attributes: attributes,
          );
        } else {
          // Create entity if it doesn't exist
          final entity = EREntity(name: entityName, attributes: attributes);
          entities.add(entity);
          entityMap[entityName] = entity;
        }
      }
    }
  }

  void _ensureEntityExists(
    String name,
    List<EREntity> entities,
    Map<String, EREntity> entityMap,
  ) {
    if (!entityMap.containsKey(name)) {
      final entity = EREntity(name: name);
      entities.add(entity);
      entityMap[name] = entity;
    }
  }

  void _layoutEntities(List<EREntity> entities) {
    if (entities.isEmpty) return;

    const itemsPerRow = 2;
    const spacingX = 320.0;
    const spacingY = 200.0;
    const startY = 100.0;

    // Group entities into rows
    final rows = <int, List<EREntity>>{};
    for (var i = 0; i < entities.length; i++) {
      final rowIndex = i ~/ itemsPerRow;
      rows.putIfAbsent(rowIndex, () => []).add(entities[i]);
    }

    // Position entities in grid
    for (final entry in rows.entries) {
      final rowIndex = entry.key;
      final rowEntities = entry.value;
      final rowWidth = rowEntities.length * spacingX;
      final startX = (1000 - rowWidth) / 2;

      for (var i = 0; i < rowEntities.length; i++) {
        final entity = rowEntities[i];
        final index = entities.indexWhere((e) => e.name == entity.name);
        if (index != -1) {
          entities[index] = entity.copyWith(
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
