// services/component_service.dart
import 'package:flutter/material.dart';

import '../models/component_animation.dart';
import '../models/component_style.dart';
import '../models/component_type.dart';
import '../models/design_component.dart';

class ComponentService {
  int _idCounter = 0;
  int _groupCounter = 0;

  String generateId() =>
      'comp_${_idCounter++}_${DateTime.now().millisecondsSinceEpoch}';
  String generateGroupId() => 'group_${_groupCounter++}';

  // services/component_service.dart - update createComponent method
  DesignComponent createComponent(ComponentType type, {Offset? position}) {
    return DesignComponent(
      id: generateId(),
      type: type,
      name: '${type.name}_${_idCounter}',
      position: position ?? const Offset(100, 100),
      size: _getDefaultSize(type),
      properties: _getDefaultProperties(type),
      style: _getDefaultStyle(type),
      animation: ComponentAnimation(),
      zIndex: 0,
      lastModified: DateTime.now(),
      modifiedBy: 'current_user',
      // Add the missing required fields
      rotation: 0.0,
      locked: false,
      visible: true,
      childrenIds: const [],
      children: const [],
    );
  }

  // Update duplicateComponents method
  List<DesignComponent> duplicateComponents(List<DesignComponent> components) {
    return components.map((component) {
      return component.copyWith(
        id: generateId(),
        position: Offset(
          component.position.dx + 20,
          component.position.dy + 20,
        ),
        lastModified: DateTime.now(),
        modifiedBy: 'current_user',
      );
    }).toList();
  }

  List<DesignComponent> copyComponents(List<DesignComponent> components) {
    return components.map((c) => c.copyWith()).toList();
  }

  Size _getDefaultSize(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return const Size(400, 300);
      case ComponentType.card:
        return const Size(280, 200);
      case ComponentType.button:
        return const Size(120, 45);
      case ComponentType.text:
        return const Size(150, 40);
      default:
        return const Size(200, 150);
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return {
          'title': 'Hero Section',
          'subtitle': 'Amazing tagline here',
          'ctaText': 'Get Started',
        };
      case ComponentType.text:
        return {'text': 'Text Component', 'editable': true};
      default:
        return {};
    }
  }

  ComponentStyle _getDefaultStyle(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return ComponentStyle(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
        );
      default:
        return const ComponentStyle(
          backgroundColor: Colors.white,
          borderRadius: 8.0,
        );
    }
  }
}
