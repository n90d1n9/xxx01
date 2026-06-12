import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';
import 'layout_version.dart';

enum LayoutVersionChangeType {
  baseline,
  componentAdded,
  componentRemoved,
  componentMoved,
  componentResized,
  layoutMode,
  canvas,
  rules,
}

class LayoutVersionChange {
  final LayoutVersionChangeType type;
  final String label;

  const LayoutVersionChange({required this.type, required this.label});
}

List<LayoutVersionChange> describeLayoutVersionChanges(
  LayoutVersion version,
  LayoutVersion? previous,
) {
  if (previous == null) {
    return const [
      LayoutVersionChange(
        type: LayoutVersionChangeType.baseline,
        label: 'Baseline',
      ),
    ];
  }

  final changes = <LayoutVersionChange>[];
  final previousComponents = _componentsById(previous.components);
  final nextComponents = _componentsById(version.components);
  final addedCount =
      nextComponents.keys
          .where((componentId) => !previousComponents.containsKey(componentId))
          .length;
  final removedCount =
      previousComponents.keys
          .where((componentId) => !nextComponents.containsKey(componentId))
          .length;

  if (addedCount > 0) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.componentAdded,
        label: '+${_componentCountLabel(addedCount)}',
      ),
    );
  }

  if (removedCount > 0) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.componentRemoved,
        label: '-${_componentCountLabel(removedCount)}',
      ),
    );
  }

  final movedCount = _changedComponentCount(
    previousComponents,
    nextComponents,
    (before, after) => (before.position - after.position).distance >= 0.01,
  );
  if (movedCount > 0) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.componentMoved,
        label: '${_countLabel(movedCount)} moved',
      ),
    );
  }

  final resizedCount = _changedComponentCount(
    previousComponents,
    nextComponents,
    (before, after) =>
        (before.size.width - after.size.width).abs() >= 0.01 ||
        (before.size.height - after.size.height).abs() >= 0.01,
  );
  if (resizedCount > 0) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.componentResized,
        label: '${_countLabel(resizedCount)} resized',
      ),
    );
  }

  if (previous.config.layoutMechanism != version.config.layoutMechanism) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.layoutMode,
        label: 'Mode ${version.config.layoutMechanism.label}',
      ),
    );
  }

  if (_hasDoubleChange(
        previous.config.canvasWidth,
        version.config.canvasWidth,
      ) ||
      _hasDoubleChange(
        previous.config.canvasHeight,
        version.config.canvasHeight,
      )) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.canvas,
        label: 'Canvas ${_canvasSizeLabel(version.config)}',
      ),
    );
  }

  if (_hasLayoutRuleChange(previous, version)) {
    changes.add(
      LayoutVersionChange(
        type: LayoutVersionChangeType.rules,
        label: _layoutRuleChangeLabel(version.config, version.gridSettings),
      ),
    );
  }

  return changes.isEmpty
      ? const [
        LayoutVersionChange(
          type: LayoutVersionChangeType.baseline,
          label: 'No visible change',
        ),
      ]
      : List<LayoutVersionChange>.unmodifiable(changes);
}

Map<String, ComponentData> _componentsById(List<ComponentData> components) {
  return {for (final component in components) component.id: component};
}

int _changedComponentCount(
  Map<String, ComponentData> before,
  Map<String, ComponentData> after,
  bool Function(ComponentData before, ComponentData after) hasChanged,
) {
  var count = 0;
  for (final entry in before.entries) {
    final nextComponent = after[entry.key];
    if (nextComponent != null && hasChanged(entry.value, nextComponent)) {
      count += 1;
    }
  }

  return count;
}

bool _hasLayoutRuleChange(LayoutVersion before, LayoutVersion after) {
  final beforeConfig = before.config;
  final afterConfig = after.config;
  final beforeGrid = before.gridSettings;
  final afterGrid = after.gridSettings;

  return _hasDoubleChange(beforeGrid.gridSize, afterGrid.gridSize) ||
      beforeGrid.snapToGrid != afterGrid.snapToGrid ||
      beforeGrid.enabled != afterGrid.enabled ||
      _hasDoubleChange(
        beforeConfig.tabularColumnCount.toDouble(),
        afterConfig.tabularColumnCount.toDouble(),
      ) ||
      _hasDoubleChange(
        beforeConfig.tabularColumnGap,
        afterConfig.tabularColumnGap,
      ) ||
      _hasDoubleChange(
        beforeConfig.tabularRowHeight,
        afterConfig.tabularRowHeight,
      ) ||
      _hasDoubleChange(
        beforeConfig.autoGridColumnCount.toDouble(),
        afterConfig.autoGridColumnCount.toDouble(),
      ) ||
      _hasDoubleChange(beforeConfig.autoGridGap, afterConfig.autoGridGap) ||
      _hasDoubleChange(
        beforeConfig.autoGridRowHeight,
        afterConfig.autoGridRowHeight,
      );
}

String _layoutRuleChangeLabel(LayoutConfig config, GridSettings gridSettings) {
  return switch (config.layoutMechanism) {
    LayoutMechanism.freeform =>
      gridSettings.snapToGrid
          ? '${gridSettings.gridSize.round()}px snap'
          : 'Free placement',
    LayoutMechanism.grid =>
      '${gridSettings.gridSize.round()}px '
          '${gridSettings.snapToGrid ? 'snap' : 'no snap'}',
    LayoutMechanism.tabularColumns => '${config.tabularColumnCount} cols',
    LayoutMechanism.autoGrid => '${config.autoGridColumnCount} auto cols',
  };
}

String _componentCountLabel(int count) {
  return count == 1 ? '1 component' : '$count components';
}

String _countLabel(int count) {
  return count == 1 ? '1 component' : '$count components';
}

String _canvasSizeLabel(LayoutConfig config) {
  return '${config.canvasWidth.round()} x ${config.canvasHeight.round()}';
}

bool _hasDoubleChange(double before, double after) {
  return (before - after).abs() >= 0.01;
}
