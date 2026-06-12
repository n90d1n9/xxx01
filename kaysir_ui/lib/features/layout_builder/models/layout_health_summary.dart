import 'dart:ui';

import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';
import 'layout_rules_conversion_preview.dart';

/// Summarizes layout issues that rule-based fixes can inspect or repair.
class LayoutHealthSummary {
  final int visibleComponentCount;
  final int editableComponentCount;
  final int lockedComponentCount;
  final int hiddenComponentCount;
  final int offCanvasCount;
  final int expandableOffCanvasCount;
  final int repositionOffCanvasCount;
  final int repositionableOffCanvasCount;
  final int offRulePositionCount;
  final int offRuleSizeCount;
  final int autoGridConflictCount;
  final List<String> offCanvasComponentIds;
  final List<String> expandableOffCanvasComponentIds;
  final List<String> repositionOffCanvasComponentIds;
  final List<String> offRulePositionComponentIds;
  final List<String> offRuleSizeComponentIds;
  final List<String> autoGridConflictComponentIds;
  final Size? expandedCanvasSize;
  final Offset? repositionOffset;

  const LayoutHealthSummary({
    required this.visibleComponentCount,
    required this.editableComponentCount,
    required this.lockedComponentCount,
    required this.hiddenComponentCount,
    required this.offCanvasCount,
    this.expandableOffCanvasCount = 0,
    this.repositionOffCanvasCount = 0,
    this.repositionableOffCanvasCount = 0,
    required this.offRulePositionCount,
    required this.offRuleSizeCount,
    required this.autoGridConflictCount,
    this.offCanvasComponentIds = const <String>[],
    this.expandableOffCanvasComponentIds = const <String>[],
    this.repositionOffCanvasComponentIds = const <String>[],
    this.offRulePositionComponentIds = const <String>[],
    this.offRuleSizeComponentIds = const <String>[],
    this.autoGridConflictComponentIds = const <String>[],
    this.expandedCanvasSize,
    this.repositionOffset,
  });

  bool get hasIssues =>
      offCanvasCount > 0 ||
      offRulePositionCount > 0 ||
      offRuleSizeCount > 0 ||
      autoGridConflictCount > 0;

  int get issueCount =>
      offCanvasCount +
      offRulePositionCount +
      offRuleSizeCount +
      autoGridConflictCount;

  String get statusLabel {
    if (!hasIssues) return 'Healthy layout';
    return '$issueCount ${issueCount == 1 ? 'issue' : 'issues'} detected';
  }

  bool get canExpandCanvas => expandedCanvasSize != null;

  bool get hasExpandableOffCanvas => expandableOffCanvasCount > 0;

  bool get hasRepositionOffCanvas => repositionOffCanvasCount > 0;

  bool get hasRepositionableOffCanvas => repositionableOffCanvasCount > 0;

  bool get hasSelectableOffCanvas => offCanvasComponentIds.isNotEmpty;

  bool get hasSelectableExpandableOffCanvas =>
      expandableOffCanvasComponentIds.isNotEmpty;

  bool get hasSelectableRepositionOffCanvas =>
      repositionOffCanvasComponentIds.isNotEmpty;

  bool get hasSelectableOffRulePositions =>
      offRulePositionComponentIds.isNotEmpty;

  bool get hasSelectableOffRuleSizes => offRuleSizeComponentIds.isNotEmpty;

  bool get hasSelectableAutoGridConflicts =>
      autoGridConflictComponentIds.isNotEmpty;

  int get skippedComponentCount => lockedComponentCount + hiddenComponentCount;

  int get lockedRepositionOffCanvasCount {
    final count = repositionOffCanvasCount - repositionableOffCanvasCount;
    return count < 0 ? 0 : count;
  }

  bool get hasRepairScopeNotes =>
      skippedComponentCount > 0 || lockedRepositionOffCanvasCount > 0;

  String? get expandedCanvasSizeLabel {
    final size = expandedCanvasSize;
    if (size == null) return null;
    return '${size.width.round()} x ${size.height.round()}';
  }

  String? get repositionOffsetLabel {
    final offset = repositionOffset;
    if (offset == null) return null;
    return '${_signedPx(offset.dx)}, ${_signedPx(offset.dy)}';
  }
}

LayoutHealthSummary layoutHealthSummaryFor({
  required List<ComponentData> components,
  required GridSettings gridSettings,
  required LayoutConfig config,
}) {
  final visibleComponents =
      components.where((component) => component.isVisible).toList();
  final editableComponents =
      visibleComponents.where((component) => !component.isLocked).toList();
  final lockedComponentCount =
      visibleComponents.where((component) => component.isLocked).length;
  final hiddenComponentCount =
      components.where((component) => !component.isVisible).length;
  final expandedCanvasSize = _expandedCanvasSizeFor(
    visibleComponents,
    config.canvasSize,
  );
  final repositionOffset = _repositionOffsetFor(editableComponents);
  final offCanvasComponents =
      visibleComponents
          .where(
            (component) => _isComponentOffCanvas(component, config.canvasSize),
          )
          .toList();
  final expandableOffCanvasComponents =
      offCanvasComponents
          .where(
            (component) => _canExpandCanvasFor(component, config.canvasSize),
          )
          .toList();
  final repositionOffCanvasComponents =
      offCanvasComponents.where(_needsCanvasReposition).toList();
  final positionPreview = layoutRulesConversionPreviewFor(
    components: components,
    gridSettings: gridSettings,
    config: config,
    snapPositions: true,
    snapSizes: false,
  );
  final sizePreview = layoutRulesConversionPreviewFor(
    components: components,
    gridSettings: gridSettings,
    config: config,
    snapPositions: false,
    snapSizes: true,
  );
  final conflictPreview = layoutRulesConversionPreviewFor(
    components: components,
    gridSettings: gridSettings,
    config: config,
    snapPositions: true,
    snapSizes: true,
    resolveAutoGridConflicts:
        config.layoutMechanism == LayoutMechanism.autoGrid,
  );

  return LayoutHealthSummary(
    visibleComponentCount: visibleComponents.length,
    editableComponentCount: editableComponents.length,
    lockedComponentCount: lockedComponentCount,
    hiddenComponentCount: hiddenComponentCount,
    offCanvasCount: offCanvasComponents.length,
    expandableOffCanvasCount: expandableOffCanvasComponents.length,
    repositionOffCanvasCount: repositionOffCanvasComponents.length,
    repositionableOffCanvasCount:
        repositionOffCanvasComponents
            .where((component) => !component.isLocked)
            .length,
    offRulePositionCount: positionPreview.moveCount,
    offRuleSizeCount: sizePreview.resizeCount,
    autoGridConflictCount: conflictPreview.autoGridConflictCount,
    offCanvasComponentIds:
        offCanvasComponents.map((component) => component.id).toList(),
    expandableOffCanvasComponentIds:
        expandableOffCanvasComponents.map((component) => component.id).toList(),
    repositionOffCanvasComponentIds:
        repositionOffCanvasComponents.map((component) => component.id).toList(),
    offRulePositionComponentIds: positionPreview.moveComponentIds,
    offRuleSizeComponentIds: sizePreview.resizeComponentIds,
    autoGridConflictComponentIds: conflictPreview.autoGridConflictComponentIds,
    expandedCanvasSize: expandedCanvasSize,
    repositionOffset: repositionOffset,
  );
}

Size? _expandedCanvasSizeFor(
  List<ComponentData> visibleComponents,
  Size canvasSize,
) {
  if (visibleComponents.isEmpty) return null;

  var left = double.infinity;
  var top = double.infinity;
  var right = double.negativeInfinity;
  var bottom = double.negativeInfinity;
  for (final component in visibleComponents) {
    left = _min(left, component.position.dx);
    top = _min(top, component.position.dy);
    right = _max(right, component.position.dx + component.size.width);
    bottom = _max(bottom, component.position.dy + component.size.height);
  }

  if (right <= canvasSize.width && bottom <= canvasSize.height) return null;

  return LayoutConfig.normalizeCanvasSize(
    Size(_max(canvasSize.width, right), _max(canvasSize.height, bottom)),
  );
}

bool _isComponentOffCanvas(ComponentData component, Size canvasSize) {
  final rect = Rect.fromLTWH(
    component.position.dx,
    component.position.dy,
    component.size.width,
    component.size.height,
  );

  return rect.left < 0 ||
      rect.top < 0 ||
      rect.right > canvasSize.width ||
      rect.bottom > canvasSize.height;
}

bool _canExpandCanvasFor(ComponentData component, Size canvasSize) {
  if (_needsCanvasReposition(component)) return false;

  final right = component.position.dx + component.size.width;
  final bottom = component.position.dy + component.size.height;
  return right > canvasSize.width || bottom > canvasSize.height;
}

bool _needsCanvasReposition(ComponentData component) {
  return component.position.dx < 0 || component.position.dy < 0;
}

Offset? _repositionOffsetFor(List<ComponentData> editableComponents) {
  if (editableComponents.isEmpty) return null;

  var left = double.infinity;
  var top = double.infinity;
  for (final component in editableComponents) {
    left = _min(left, component.position.dx);
    top = _min(top, component.position.dy);
  }

  final dx = left < 0 ? -left : 0.0;
  final dy = top < 0 ? -top : 0.0;
  if (dx.abs() < 0.01 && dy.abs() < 0.01) return null;

  return Offset(dx, dy);
}

double _min(double left, double right) => left < right ? left : right;

double _max(double left, double right) => left > right ? left : right;

String _signedPx(double value) {
  final roundedValue = value.round();
  if (roundedValue >= 0) return '+${roundedValue}px';
  return '${roundedValue}px';
}
