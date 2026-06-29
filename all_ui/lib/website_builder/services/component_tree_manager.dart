// Component Tree Manager
import 'package:flutter/material.dart';

import '../models/design_component.dart';

class ComponentTree {
  static List<DesignComponent> getRootComponents(
    List<DesignComponent> components,
  ) {
    return components.where((c) => c.parentId == null).toList();
  }

  static List<DesignComponent> getChildren(
    String parentId,
    List<DesignComponent> components,
  ) {
    return components.where((c) => c.parentId == parentId).toList();
  }

  static void addChild(
    DesignComponent parent,
    DesignComponent child,
    List<DesignComponent> components,
  ) {
    child.copyWith(id: parent.id);
    // Adjust child position relative to parent
    child.copyWith(
      position: Offset(
        child.position.dx - parent.position.dx,
        child.position.dy - parent.position.dy,
      ),
    );
  }

  static void removeFromParent(
    DesignComponent component,
    List<DesignComponent> components,
  ) {
    if (component.parentId != null) {
      final parent = components.firstWhere((c) => c.id == component.parentId);
      // Adjust position to absolute
      component.copyWith(
        position: Offset(
          component.position.dx + parent.position.dx,
          component.position.dy + parent.position.dy,
        ),
      );
      component.copyWith(parentId: null);
    }
  }
}
