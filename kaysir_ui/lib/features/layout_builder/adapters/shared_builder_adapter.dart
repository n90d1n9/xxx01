import 'package:ky_builder_shared/ky_builder_shared.dart' as shared;

import '../models/component.dart';
import '../models/component_properties.dart';
import '../models/layout_config.dart';
import '../models/layout_state.dart';

extension LayoutStateSharedBuilderAdapter on LayoutState {
  shared.BuilderSharedSnapshot toSharedBuilderSnapshot() {
    return shared.BuilderSharedSnapshot(
      id: id,
      name: name,
      canvasConfig: config.toSharedBuilderCanvasConfig(),
      selectedComponentId: selectedComponentId,
      components: [
        for (var index = 0; index < components.length; index += 1)
          components[index].toSharedBuilderGeometry(zIndex: index),
      ],
    );
  }
}

extension LayoutConfigSharedBuilderAdapter on LayoutConfig {
  shared.BuilderCanvasConfig toSharedBuilderCanvasConfig() {
    return shared.BuilderCanvasConfig(
      gridSize: gridSize,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      minComponentWidth: minComponentWidth,
      minComponentHeight: minComponentHeight,
      snapToGrid: snapToGrid,
      showGrid: showGrid,
      layoutMechanism: layoutMechanism.toSharedBuilderLayoutMechanism(),
      tabularColumnCount: tabularColumnCount,
      tabularColumnGap: tabularColumnGap,
      tabularRowHeight: tabularRowHeight,
      autoGridColumnCount: autoGridColumnCount,
      autoGridGap: autoGridGap,
      autoGridRowHeight: autoGridRowHeight,
    );
  }
}

extension SharedBuilderCanvasConfigLayoutAdapter on shared.BuilderCanvasConfig {
  LayoutConfig toLayoutConfig() {
    return LayoutConfig(
      gridSize: gridSize,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      minComponentWidth: minComponentWidth,
      minComponentHeight: minComponentHeight,
      snapToGrid: snapToGrid,
      showGrid: showGrid,
      layoutMechanism: layoutMechanism.toLayoutMechanism(),
      tabularColumnCount: tabularColumnCount,
      tabularColumnGap: tabularColumnGap,
      tabularRowHeight: tabularRowHeight,
      autoGridColumnCount: autoGridColumnCount,
      autoGridGap: autoGridGap,
      autoGridRowHeight: autoGridRowHeight,
    );
  }
}

extension LayoutMechanismSharedBuilderAdapter on LayoutMechanism {
  shared.BuilderLayoutMechanism toSharedBuilderLayoutMechanism() {
    return switch (this) {
      LayoutMechanism.freeform => shared.BuilderLayoutMechanism.freeform,
      LayoutMechanism.grid => shared.BuilderLayoutMechanism.grid,
      LayoutMechanism.tabularColumns =>
        shared.BuilderLayoutMechanism.tabularColumns,
      LayoutMechanism.autoGrid => shared.BuilderLayoutMechanism.autoGrid,
    };
  }
}

extension SharedBuilderLayoutMechanismLayoutAdapter
    on shared.BuilderLayoutMechanism {
  LayoutMechanism toLayoutMechanism() {
    return switch (this) {
      shared.BuilderLayoutMechanism.freeform => LayoutMechanism.freeform,
      shared.BuilderLayoutMechanism.grid => LayoutMechanism.grid,
      shared.BuilderLayoutMechanism.tabularColumns =>
        LayoutMechanism.tabularColumns,
      shared.BuilderLayoutMechanism.autoGrid => LayoutMechanism.autoGrid,
      shared.BuilderLayoutMechanism.flexFlow => LayoutMechanism.freeform,
    };
  }
}

extension ComponentDataSharedBuilderAdapter on ComponentData {
  shared.BuilderComponentGeometry toSharedBuilderGeometry({int zIndex = 0}) {
    return shared.BuilderComponentGeometry(
      id: id,
      kindKey: type.key,
      position: position,
      size: size,
      constraints: constraints.toSharedBuilderConstraints(),
      responsiveOverrides: responsiveProperties.map(
        (key, value) => MapEntry(key, value.toSharedBuilderOverride()),
      ),
      zIndex: zIndex,
      isLocked: isLocked,
      isVisible: isVisible,
    );
  }
}

extension SharedBuilderGeometryComponentDataAdapter
    on shared.BuilderComponentGeometry {
  ComponentData toLayoutComponentData({
    ComponentStyle style = const ComponentStyle(),
    ComponentProperties? properties,
  }) {
    final componentType = ComponentTypeX.fromKey(kindKey);
    return ComponentData(
      id: id,
      type: componentType,
      position: position,
      size: size,
      style: style,
      properties:
          properties ??
          ComponentProperties(attributes: {'label': componentType.label}),
      constraints: constraints.toLayoutComponentConstraints(),
      responsiveProperties: responsiveOverrides.map(
        (key, value) => MapEntry(key, value.toLayoutResponsiveProperties()),
      ),
      isLocked: isLocked,
      isVisible: isVisible,
    );
  }
}

extension ComponentTypeSharedBuilderAdapter on ComponentType {
  shared.BuilderComponentKind toSharedBuilderKind() {
    return shared.posLayoutBuilderCatalog.byKey(key) ??
        shared.BuilderComponentKind(
          key: key,
          label: label,
          category: 'POS',
          defaultSize: defaultSize,
        );
  }
}

extension ComponentConstraintsSharedBuilderAdapter on ComponentConstraints {
  shared.BuilderComponentConstraints toSharedBuilderConstraints() {
    return shared.BuilderComponentConstraints(
      horizontalAnchor: horizontalAnchor.toSharedBuilderAnchorMode(),
      verticalAnchor: verticalAnchor.toSharedBuilderAnchorMode(),
      maintainAspectRatio: maintainAspectRatio,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

extension SharedBuilderConstraintsLayoutAdapter
    on shared.BuilderComponentConstraints {
  ComponentConstraints toLayoutComponentConstraints() {
    return ComponentConstraints(
      horizontalAnchor: horizontalAnchor.toLayoutAnchorMode(),
      verticalAnchor: verticalAnchor.toLayoutAnchorMode(),
      maintainAspectRatio: maintainAspectRatio,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

extension ComponentResponsivePropertiesSharedBuilderAdapter
    on ComponentResponsiveProperties {
  shared.BuilderResponsiveOverride toSharedBuilderOverride() {
    return shared.BuilderResponsiveOverride(
      position: position,
      size: size,
      isVisible: isVisible,
    );
  }
}

extension SharedBuilderResponsiveOverrideLayoutAdapter
    on shared.BuilderResponsiveOverride {
  ComponentResponsiveProperties toLayoutResponsiveProperties() {
    return ComponentResponsiveProperties(
      position: position,
      size: size,
      isVisible: isVisible,
    );
  }
}

extension ComponentAnchorModeSharedBuilderAdapter on ComponentAnchorMode {
  shared.BuilderComponentAnchorMode toSharedBuilderAnchorMode() {
    return switch (this) {
      ComponentAnchorMode.free => shared.BuilderComponentAnchorMode.free,
      ComponentAnchorMode.start => shared.BuilderComponentAnchorMode.start,
      ComponentAnchorMode.center => shared.BuilderComponentAnchorMode.center,
      ComponentAnchorMode.end => shared.BuilderComponentAnchorMode.end,
      ComponentAnchorMode.stretch => shared.BuilderComponentAnchorMode.stretch,
    };
  }
}

extension SharedBuilderAnchorModeLayoutAdapter
    on shared.BuilderComponentAnchorMode {
  ComponentAnchorMode toLayoutAnchorMode() {
    return switch (this) {
      shared.BuilderComponentAnchorMode.free => ComponentAnchorMode.free,
      shared.BuilderComponentAnchorMode.start => ComponentAnchorMode.start,
      shared.BuilderComponentAnchorMode.center => ComponentAnchorMode.center,
      shared.BuilderComponentAnchorMode.end => ComponentAnchorMode.end,
      shared.BuilderComponentAnchorMode.stretch => ComponentAnchorMode.stretch,
    };
  }
}
