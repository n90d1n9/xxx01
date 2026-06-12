import 'dart:math' as math;
import 'dart:ui';

import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';

const _conflictResolutionSearchRingLimit = 8;

/// Describes how a conflict-free placement suggestion was discovered.
enum LayoutConflictResolutionSource { direct, nearbySearch }

extension LayoutConflictResolutionSourceX on LayoutConflictResolutionSource {
  String get label {
    switch (this) {
      case LayoutConflictResolutionSource.direct:
        return 'direct';
      case LayoutConflictResolutionSource.nearbySearch:
        return 'nearby';
    }
  }
}

/// A canvas edge that can be crossed by a drag or drop placement preview.
enum LayoutCanvasEdge { left, top, right, bottom }

extension LayoutCanvasEdgeX on LayoutCanvasEdge {
  String get label {
    switch (this) {
      case LayoutCanvasEdge.left:
        return 'left';
      case LayoutCanvasEdge.top:
        return 'top';
      case LayoutCanvasEdge.right:
        return 'right';
      case LayoutCanvasEdge.bottom:
        return 'bottom';
    }
  }
}

/// Describes how far a previewed placement extends beyond one canvas edge.
class LayoutCanvasOverflow {
  final LayoutCanvasEdge edge;
  final double distance;

  const LayoutCanvasOverflow({required this.edge, required this.distance});

  String get label => '${edge.label} ${distance.round()}px';

  bool isSameOverflow(LayoutCanvasOverflow other) {
    return edge == other.edge && (distance - other.distance).abs() < 0.5;
  }
}

/// Describes one existing component that blocks a preview landing area.
class LayoutConflictBlocker {
  final Rect bounds;
  final String label;

  const LayoutConflictBlocker({required this.bounds, required this.label});

  bool isSameBlocker(LayoutConflictBlocker other) {
    return label == other.label && _isSameRect(bounds, other.bounds);
  }
}

/// Describes the exact clipped overlap region inside a preview target.
class LayoutConflictPatch {
  final Rect bounds;
  final String label;

  const LayoutConflictPatch({required this.bounds, required this.label});

  bool isSamePatch(LayoutConflictPatch other) {
    return label == other.label && _isSameRect(bounds, other.bounds);
  }
}

/// Describes a valid placement that avoids the current conflict.
class LayoutConflictResolution {
  final Rect bounds;
  final LayoutConflictResolutionSource source;

  const LayoutConflictResolution({required this.bounds, required this.source});

  bool isSameResolution(LayoutConflictResolution other) {
    return source == other.source && _isSameRect(bounds, other.bounds);
  }
}

/// Describes the rule-aware landing area for one component during a drag.
class LayoutDragPreviewItem {
  final String componentId;
  final Rect currentBounds;
  final Rect ruleBounds;
  final String ruleLabel;
  final bool hasConflict;
  final int conflictCount;
  final double conflictCoverage;
  final String conflictSourceSummary;
  final List<LayoutConflictBlocker> conflictBlockers;
  final List<LayoutConflictPatch> conflictPatches;
  final LayoutConflictResolution? conflictResolution;
  final String conflictResolvedRuleLabel;
  final bool isOutsideCanvas;
  final List<LayoutCanvasEdge> outsideCanvasEdges;
  final List<LayoutCanvasOverflow> canvasOverflow;
  final Offset canvasCorrectionOffset;
  final Rect? canvasCorrectedBounds;

  LayoutDragPreviewItem({
    required this.componentId,
    required this.currentBounds,
    required this.ruleBounds,
    required this.ruleLabel,
    required this.hasConflict,
    this.conflictCount = 0,
    this.conflictCoverage = 0,
    this.conflictSourceSummary = '',
    this.conflictBlockers = const <LayoutConflictBlocker>[],
    this.conflictPatches = const <LayoutConflictPatch>[],
    LayoutConflictResolution? conflictResolution,
    Rect? conflictResolvedBounds,
    LayoutConflictResolutionSource conflictResolutionSource =
        LayoutConflictResolutionSource.direct,
    this.conflictResolvedRuleLabel = '',
    this.isOutsideCanvas = false,
    this.outsideCanvasEdges = const <LayoutCanvasEdge>[],
    this.canvasOverflow = const <LayoutCanvasOverflow>[],
    this.canvasCorrectionOffset = Offset.zero,
    this.canvasCorrectedBounds,
  }) : conflictResolution =
           conflictResolution ??
           (conflictResolvedBounds == null
               ? null
               : LayoutConflictResolution(
                 bounds: conflictResolvedBounds,
                 source: conflictResolutionSource,
               ));

  bool get isRuleAligned => _isSameRect(currentBounds, ruleBounds);

  bool get hasCanvasCorrection => !_isSameRect(ruleBounds, correctedRuleBounds);

  bool get hasConflictResolution {
    return hasConflict &&
        conflictResolution != null &&
        !_isSameRect(ruleBounds, conflictResolution!.bounds);
  }

  bool get hasUnresolvedConflict {
    return hasConflict && conflictBlockers.isNotEmpty && !hasConflictResolution;
  }

  Rect? get conflictResolvedBounds => conflictResolution?.bounds;

  bool get usesNearbyConflictResolution {
    return conflictResolution?.source ==
        LayoutConflictResolutionSource.nearbySearch;
  }

  Offset get conflictResolutionOffset {
    final resolvedBounds = conflictResolvedBounds;
    if (resolvedBounds == null) return Offset.zero;

    return resolvedBounds.topLeft - ruleBounds.topLeft;
  }

  Rect get correctedRuleBounds {
    return canvasCorrectedBounds ?? ruleBounds.shift(canvasCorrectionOffset);
  }

  bool isSamePlacement(LayoutDragPreviewItem other) {
    return componentId == other.componentId &&
        ruleLabel == other.ruleLabel &&
        hasConflict == other.hasConflict &&
        conflictCount == other.conflictCount &&
        _isSameDouble(conflictCoverage, other.conflictCoverage) &&
        conflictSourceSummary == other.conflictSourceSummary &&
        _sameConflictBlockers(conflictBlockers, other.conflictBlockers) &&
        _sameConflictPatches(conflictPatches, other.conflictPatches) &&
        _isSameConflictResolution(
          conflictResolution,
          other.conflictResolution,
        ) &&
        conflictResolvedRuleLabel == other.conflictResolvedRuleLabel &&
        isOutsideCanvas == other.isOutsideCanvas &&
        _sameCanvasEdges(outsideCanvasEdges, other.outsideCanvasEdges) &&
        _sameCanvasOverflow(canvasOverflow, other.canvasOverflow) &&
        _isSameOffset(canvasCorrectionOffset, other.canvasCorrectionOffset) &&
        _isSameNullableRect(
          canvasCorrectedBounds,
          other.canvasCorrectedBounds,
        ) &&
        _isSameRect(currentBounds, other.currentBounds) &&
        _isSameRect(ruleBounds, other.ruleBounds);
  }
}

/// Summarizes the active drag placement preview for the canvas overlay.
class LayoutDragPreview {
  final LayoutMechanism mechanism;
  final List<LayoutDragPreviewItem> items;
  final bool willApplyRulesOnDrop;

  const LayoutDragPreview({
    required this.mechanism,
    required this.items,
    this.willApplyRulesOnDrop = true,
  });

  bool get isEmpty => items.isEmpty;

  Set<String> get componentIds {
    return items.map((item) => item.componentId).toSet();
  }
}

/// Builds rule-aware drag previews without mutating layout state.
LayoutDragPreview? layoutDragPreviewFor({
  required List<ComponentData> components,
  required Set<String> selectedComponentIds,
  required String activeComponentId,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  if (config.layoutMechanism == LayoutMechanism.freeform) return null;

  final activeIds =
      selectedComponentIds.contains(activeComponentId)
          ? selectedComponentIds
          : {activeComponentId};
  final previewComponents = components
      .where(
        (component) =>
            activeIds.contains(component.id) &&
            component.isVisible &&
            !component.isLocked,
      )
      .toList(growable: false);
  if (previewComponents.isEmpty) return null;

  final excludedIds =
      previewComponents.map((component) => component.id).toSet();
  final conflictCandidates = [
    for (final component in components)
      if (component.isVisible && !excludedIds.contains(component.id))
        LayoutConflictBlocker(
          bounds: Rect.fromLTWH(
            component.position.dx,
            component.position.dy,
            component.size.width,
            component.size.height,
          ),
          label: _componentConflictLabel(component),
        ),
  ];

  final items = [
    for (final component in previewComponents)
      _previewItemFor(
        component: component,
        config: config,
        gridSettings: gridSettings,
        conflictCandidates: conflictCandidates,
      ),
  ];

  if (items.isEmpty) return null;
  return LayoutDragPreview(
    mechanism: config.layoutMechanism,
    items: List.unmodifiable(items),
    willApplyRulesOnDrop: gridSettings.snapToGrid,
  );
}

/// Builds a rule-aware landing preview for components not yet added to state.
LayoutDragPreview? layoutDropPreviewFor({
  required List<ComponentData> existingComponents,
  required List<ComponentData> dropComponents,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  if (dropComponents.isEmpty) return null;

  final previewComponents = [
    for (var index = 0; index < dropComponents.length; index++)
      dropComponents[index].copyWith(
        id: 'drop-preview-$index',
        isLocked: false,
        isVisible: true,
      ),
  ];
  final previewIds = previewComponents.map((component) => component.id).toSet();

  return layoutDragPreviewFor(
    components: [...existingComponents, ...previewComponents],
    selectedComponentIds: previewIds,
    activeComponentId: previewComponents.first.id,
    config: config,
    gridSettings: gridSettings,
  );
}

LayoutDragPreviewItem _previewItemFor({
  required ComponentData component,
  required LayoutConfig config,
  required GridSettings gridSettings,
  required List<LayoutConflictBlocker> conflictCandidates,
}) {
  final currentBounds = Rect.fromLTWH(
    component.position.dx,
    component.position.dy,
    component.size.width,
    component.size.height,
  );
  final snappedPosition = _snapOffsetToMechanism(
    component.position,
    config,
    gridSettings,
  );
  final ruleBounds = Rect.fromLTWH(
    snappedPosition.dx,
    snappedPosition.dy,
    component.size.width,
    component.size.height,
  );
  final canvasOverflow = _canvasOverflowFor(ruleBounds, config);
  final canvasCorrectionOffset = _canvasCorrectionOffsetFor(canvasOverflow);
  final conflicts = [
    for (final candidate in conflictCandidates)
      if (candidate.bounds.overlaps(ruleBounds)) candidate,
  ];
  final conflictBounds = [for (final conflict in conflicts) conflict.bounds];
  final conflictPatches = [
    for (final conflict in conflicts)
      if (_rectIntersection(ruleBounds, conflict.bounds) case final patch?)
        LayoutConflictPatch(bounds: patch, label: conflict.label),
  ];
  final blockerBounds = [
    for (final conflictCandidate in conflictCandidates)
      conflictCandidate.bounds,
  ];
  final conflictResolution = _conflictResolutionFor(
    bounds: ruleBounds,
    conflictBounds: conflictBounds,
    blockerBounds: blockerBounds,
    config: config,
    gridSettings: gridSettings,
  );
  final conflictResolvedBounds = conflictResolution?.bounds;
  final conflictResolvedRuleLabel =
      conflictResolvedBounds == null
          ? ''
          : _ruleLabelFor(conflictResolvedBounds, config, gridSettings);
  final conflictCount = conflictBounds.length;

  return LayoutDragPreviewItem(
    componentId: component.id,
    currentBounds: currentBounds,
    ruleBounds: ruleBounds,
    ruleLabel: _ruleLabelFor(ruleBounds, config, gridSettings),
    hasConflict: conflictCount > 0,
    conflictCount: conflictCount,
    conflictSourceSummary: _conflictSourceSummaryFor(conflicts),
    conflictBlockers: List.unmodifiable(conflicts),
    conflictPatches: List.unmodifiable(conflictPatches),
    conflictResolution: conflictResolution,
    conflictResolvedRuleLabel: conflictResolvedRuleLabel,
    conflictCoverage: _conflictCoverageFor(
      bounds: ruleBounds,
      conflictBounds: conflictBounds,
    ),
    isOutsideCanvas: canvasOverflow.isNotEmpty,
    outsideCanvasEdges: [for (final overflow in canvasOverflow) overflow.edge],
    canvasOverflow: canvasOverflow,
    canvasCorrectionOffset: canvasCorrectionOffset,
    canvasCorrectedBounds: _canvasCorrectedBoundsFor(
      bounds: ruleBounds,
      config: config,
      overflow: canvasOverflow,
      correctionOffset: canvasCorrectionOffset,
    ),
  );
}

List<LayoutCanvasOverflow> _canvasOverflowFor(
  Rect bounds,
  LayoutConfig config,
) {
  return [
    if (bounds.left < 0)
      LayoutCanvasOverflow(edge: LayoutCanvasEdge.left, distance: -bounds.left),
    if (bounds.top < 0)
      LayoutCanvasOverflow(edge: LayoutCanvasEdge.top, distance: -bounds.top),
    if (bounds.right > config.canvasWidth)
      LayoutCanvasOverflow(
        edge: LayoutCanvasEdge.right,
        distance: bounds.right - config.canvasWidth,
      ),
    if (bounds.bottom > config.canvasHeight)
      LayoutCanvasOverflow(
        edge: LayoutCanvasEdge.bottom,
        distance: bounds.bottom - config.canvasHeight,
      ),
  ];
}

Offset _canvasCorrectionOffsetFor(List<LayoutCanvasOverflow> overflow) {
  final left = _overflowDistanceFor(overflow, LayoutCanvasEdge.left);
  final right = _overflowDistanceFor(overflow, LayoutCanvasEdge.right);
  final top = _overflowDistanceFor(overflow, LayoutCanvasEdge.top);
  final bottom = _overflowDistanceFor(overflow, LayoutCanvasEdge.bottom);

  final dx =
      left > 0 && right == 0
          ? left
          : right > 0 && left == 0
          ? -right
          : 0.0;
  final dy =
      top > 0 && bottom == 0
          ? top
          : bottom > 0 && top == 0
          ? -bottom
          : 0.0;

  return Offset(dx, dy);
}

Rect? _canvasCorrectedBoundsFor({
  required Rect bounds,
  required LayoutConfig config,
  required List<LayoutCanvasOverflow> overflow,
  required Offset correctionOffset,
}) {
  if (overflow.isEmpty) return null;

  final canvasWidth = math.max(0.0, config.canvasWidth);
  final canvasHeight = math.max(0.0, config.canvasHeight);
  if (canvasWidth == 0 || canvasHeight == 0) {
    final shiftedBounds = bounds.shift(correctionOffset);
    return _isSameRect(bounds, shiftedBounds) ? null : shiftedBounds;
  }

  final width = math.min(bounds.width, canvasWidth);
  final height = math.min(bounds.height, canvasHeight);
  final maximumLeft = math.max(0.0, canvasWidth - width);
  final maximumTop = math.max(0.0, canvasHeight - height);
  final correctedBounds = Rect.fromLTWH(
    (bounds.left + correctionOffset.dx).clamp(0.0, maximumLeft).toDouble(),
    (bounds.top + correctionOffset.dy).clamp(0.0, maximumTop).toDouble(),
    width,
    height,
  );

  return _isSameRect(bounds, correctedBounds) ? null : correctedBounds;
}

double _conflictCoverageFor({
  required Rect bounds,
  required List<Rect> conflictBounds,
}) {
  if (conflictBounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
    return 0;
  }

  final intersections = [
    for (final conflictBoundsItem in conflictBounds)
      _rectIntersection(bounds, conflictBoundsItem),
  ].whereType<Rect>().toList(growable: false);
  if (intersections.isEmpty) return 0;

  final coveredArea = _rectUnionArea(intersections);
  final totalArea = bounds.width * bounds.height;
  if (totalArea <= 0) return 0;

  return (coveredArea / totalArea).clamp(0.0, 1.0).toDouble();
}

LayoutConflictResolution? _conflictResolutionFor({
  required Rect bounds,
  required List<Rect> conflictBounds,
  required List<Rect> blockerBounds,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  if (conflictBounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
    return null;
  }

  final candidates = <LayoutConflictResolution>[];
  for (final conflict in conflictBounds) {
    candidates.addAll([
      _candidateConflictResolution(
        topLeft: Offset(conflict.left - bounds.width, bounds.top),
        sourceBounds: bounds,
        source: LayoutConflictResolutionSource.direct,
        config: config,
        gridSettings: gridSettings,
      ),
      _candidateConflictResolution(
        topLeft: Offset(conflict.right, bounds.top),
        sourceBounds: bounds,
        source: LayoutConflictResolutionSource.direct,
        config: config,
        gridSettings: gridSettings,
      ),
      _candidateConflictResolution(
        topLeft: Offset(bounds.left, conflict.top - bounds.height),
        sourceBounds: bounds,
        source: LayoutConflictResolutionSource.direct,
        config: config,
        gridSettings: gridSettings,
      ),
      _candidateConflictResolution(
        topLeft: Offset(bounds.left, conflict.bottom),
        sourceBounds: bounds,
        source: LayoutConflictResolutionSource.direct,
        config: config,
        gridSettings: gridSettings,
      ),
    ]);
  }
  candidates.addAll(
    _searchResolvedBoundsCandidates(
      bounds: bounds,
      config: config,
      gridSettings: gridSettings,
    ),
  );

  final validCandidates = candidates
      .where((candidate) => !_isSameRect(candidate.bounds, bounds))
      .where(
        (candidate) => _canvasOverflowFor(candidate.bounds, config).isEmpty,
      )
      .where(
        (candidate) =>
            !blockerBounds.any((blocker) => blocker.overlaps(candidate.bounds)),
      )
      .fold<List<LayoutConflictResolution>>(<LayoutConflictResolution>[], (
        uniqueCandidates,
        candidate,
      ) {
        if (!uniqueCandidates.any(
          (item) => _isSameRect(item.bounds, candidate.bounds),
        )) {
          uniqueCandidates.add(candidate);
        }

        return uniqueCandidates;
      });
  if (validCandidates.isEmpty) return null;

  validCandidates.sort((first, second) {
    final distanceCompare = _boundsDistanceScore(
      bounds,
      first.bounds,
    ).compareTo(_boundsDistanceScore(bounds, second.bounds));
    if (distanceCompare != 0) return distanceCompare;

    final verticalCompare = (first.bounds.top - bounds.top).abs().compareTo(
      (second.bounds.top - bounds.top).abs(),
    );
    if (verticalCompare != 0) return verticalCompare;

    return (first.bounds.left - bounds.left).abs().compareTo(
      (second.bounds.left - bounds.left).abs(),
    );
  });

  return validCandidates.first;
}

LayoutConflictResolution _candidateConflictResolution({
  required Offset topLeft,
  required Rect sourceBounds,
  required LayoutConflictResolutionSource source,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  final snappedTopLeft = _snapOffsetToMechanism(topLeft, config, gridSettings);

  return LayoutConflictResolution(
    bounds: Rect.fromLTWH(
      snappedTopLeft.dx,
      snappedTopLeft.dy,
      sourceBounds.width,
      sourceBounds.height,
    ),
    source: source,
  );
}

List<LayoutConflictResolution> _searchResolvedBoundsCandidates({
  required Rect bounds,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  final step = _resolutionSearchStepFor(config, gridSettings);
  if (step.dx <= 0 || step.dy <= 0) return const [];

  return [
    for (var ring = 1; ring <= _conflictResolutionSearchRingLimit; ring++)
      for (var x = -ring; x <= ring; x++)
        for (var y = -ring; y <= ring; y++)
          if (x.abs() == ring || y.abs() == ring)
            _candidateConflictResolution(
              topLeft: Offset(
                bounds.left + (x * step.dx),
                bounds.top + (y * step.dy),
              ),
              sourceBounds: bounds,
              source: LayoutConflictResolutionSource.nearbySearch,
              config: config,
              gridSettings: gridSettings,
            ),
  ];
}

Offset _resolutionSearchStepFor(
  LayoutConfig config,
  GridSettings gridSettings,
) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
    case LayoutMechanism.grid:
      final gridSize =
          gridSettings.gridSize > 0
              ? gridSettings.gridSize
              : math.max(1.0, config.gridSize);
      return Offset(gridSize, gridSize);
    case LayoutMechanism.tabularColumns:
      return Offset(
        math.max(1.0, config.tabularColumnWidth + config.tabularColumnGap),
        math.max(1.0, config.tabularRowHeight),
      );
    case LayoutMechanism.autoGrid:
      return Offset(
        math.max(1.0, config.autoGridColumnWidth + config.autoGridGap),
        math.max(1.0, config.autoGridRowHeight + config.autoGridGap),
      );
  }
}

double _boundsDistanceScore(Rect source, Rect candidate) {
  final offset = candidate.topLeft - source.topLeft;

  return (offset.dx * offset.dx) + (offset.dy * offset.dy);
}

String _conflictSourceSummaryFor(List<LayoutConflictBlocker> conflicts) {
  if (conflicts.isEmpty) return '';

  final counts = <String, int>{};
  for (final conflict in conflicts) {
    counts.update(conflict.label, (count) => count + 1, ifAbsent: () => 1);
  }

  final labels = [
    for (final entry in counts.entries)
      entry.value == 1 ? entry.key : '${entry.value} ${_pluralize(entry.key)}',
  ];
  if (labels.length <= 2) return labels.join(', ');

  return '${labels.take(2).join(', ')} +${labels.length - 2}';
}

String _componentConflictLabel(ComponentData component) {
  final attributes = component.properties.attributes;
  final namedLabel =
      _stringAttribute(attributes['name']) ??
      _stringAttribute(attributes['label']) ??
      _stringAttribute(attributes['text']) ??
      _stringAttribute(attributes['title']);

  return namedLabel ?? component.type.label;
}

String? _stringAttribute(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

String _pluralize(String label) {
  if (label.endsWith('s')) return label;

  return '${label}s';
}

Rect? _rectIntersection(Rect first, Rect second) {
  final left = math.max(first.left, second.left);
  final top = math.max(first.top, second.top);
  final right = math.min(first.right, second.right);
  final bottom = math.min(first.bottom, second.bottom);
  if (right <= left || bottom <= top) return null;

  return Rect.fromLTRB(left, top, right, bottom);
}

double _rectUnionArea(List<Rect> rects) {
  final xEdges =
      {
          for (final rect in rects) ...[rect.left, rect.right],
        }.where((value) => value.isFinite).toList()
        ..sort();
  if (xEdges.length < 2) return 0;

  var area = 0.0;
  for (var index = 0; index < xEdges.length - 1; index++) {
    final left = xEdges[index];
    final right = xEdges[index + 1];
    final width = right - left;
    if (width <= 0) continue;

    final yIntervals = [
      for (final rect in rects)
        if (rect.left < right && rect.right > left) (rect.top, rect.bottom),
    ]..sort((first, second) => first.$1.compareTo(second.$1));
    area += width * _mergedIntervalLength(yIntervals);
  }

  return area;
}

double _mergedIntervalLength(List<(double start, double end)> intervals) {
  if (intervals.isEmpty) return 0;

  var total = 0.0;
  var activeStart = intervals.first.$1;
  var activeEnd = intervals.first.$2;

  for (var index = 1; index < intervals.length; index++) {
    final (start, end) = intervals[index];
    if (start <= activeEnd) {
      activeEnd = math.max(activeEnd, end);
      continue;
    }

    total += activeEnd - activeStart;
    activeStart = start;
    activeEnd = end;
  }

  return total + activeEnd - activeStart;
}

double _overflowDistanceFor(
  List<LayoutCanvasOverflow> overflow,
  LayoutCanvasEdge edge,
) {
  for (final item in overflow) {
    if (item.edge == edge) return item.distance;
  }

  return 0;
}

Offset _snapOffsetToMechanism(
  Offset offset,
  LayoutConfig config,
  GridSettings gridSettings,
) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return offset;
    case LayoutMechanism.grid:
      return _snapOffsetToGrid(offset, gridSettings.gridSize);
    case LayoutMechanism.tabularColumns:
      return _snapOffsetToTabularColumns(offset, config);
    case LayoutMechanism.autoGrid:
      return _snapOffsetToAutoGrid(offset, config);
  }
}

Offset _snapOffsetToGrid(Offset offset, double gridSize) {
  if (gridSize <= 0) return offset;
  return Offset(
    (offset.dx / gridSize).round() * gridSize,
    (offset.dy / gridSize).round() * gridSize,
  );
}

Offset _snapOffsetToTabularColumns(Offset offset, LayoutConfig config) {
  final columnWidth = config.tabularColumnWidth;
  final trackWidth = columnWidth + config.tabularColumnGap;
  final column =
      trackWidth <= 0
          ? 0
          : (offset.dx / trackWidth)
              .round()
              .clamp(0, config.tabularColumnCount - 1)
              .toInt();
  final rowHeight = math.max(1.0, config.tabularRowHeight);
  final row = math.max(0, (offset.dy / rowHeight).round());

  return Offset(column * trackWidth, row * rowHeight);
}

Offset _snapOffsetToAutoGrid(Offset offset, LayoutConfig config) {
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final column =
      trackWidth <= 0
          ? 0
          : (offset.dx / trackWidth)
              .round()
              .clamp(0, config.autoGridColumnCount - 1)
              .toInt();
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  final row =
      rowTrackHeight <= 0
          ? 0
          : math.max(0, (offset.dy / rowTrackHeight).round());

  return Offset(column * trackWidth, row * rowTrackHeight);
}

String _ruleLabelFor(
  Rect bounds,
  LayoutConfig config,
  GridSettings gridSettings,
) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return 'Freeform';
    case LayoutMechanism.grid:
      final gridSize = gridSettings.gridSize <= 0 ? 1.0 : gridSettings.gridSize;
      final column = (bounds.left / gridSize).round() + 1;
      final row = (bounds.top / gridSize).round() + 1;
      return 'Grid c$column r$row';
    case LayoutMechanism.tabularColumns:
      final geometry = _tabularGeometryFor(bounds, config);
      return 'Tabular c${geometry.column} r${geometry.row} '
          '${geometry.columnSpan}x${geometry.rowSpan}';
    case LayoutMechanism.autoGrid:
      final geometry = _autoGridGeometryFor(bounds, config);
      return 'Auto Grid c${geometry.column} r${geometry.row} '
          '${geometry.columnSpan}x${geometry.rowSpan}';
  }
}

_RuleGeometry _tabularGeometryFor(Rect bounds, LayoutConfig config) {
  final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
  final rowHeight = math.max(1.0, config.tabularRowHeight);
  final column =
      trackWidth <= 0
          ? 1
          : (bounds.left / trackWidth)
                  .round()
                  .clamp(0, config.tabularColumnCount - 1)
                  .toInt() +
              1;
  final row = (bounds.top / rowHeight).round() + 1;
  final columnSpan =
      trackWidth <= 0
          ? 1
          : ((bounds.width + config.tabularColumnGap) / trackWidth)
              .round()
              .clamp(1, config.tabularColumnCount)
              .toInt();
  final rowSpan = math.max(1, (bounds.height / rowHeight).round());

  return _RuleGeometry(
    column: column,
    row: row,
    columnSpan: columnSpan,
    rowSpan: rowSpan,
  );
}

_RuleGeometry _autoGridGeometryFor(Rect bounds, LayoutConfig config) {
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  final column =
      trackWidth <= 0
          ? 1
          : (bounds.left / trackWidth)
                  .round()
                  .clamp(0, config.autoGridColumnCount - 1)
                  .toInt() +
              1;
  final row =
      rowTrackHeight <= 0 ? 1 : (bounds.top / rowTrackHeight).round() + 1;
  final columnSpan =
      trackWidth <= 0
          ? 1
          : ((bounds.width + config.autoGridGap) / trackWidth)
              .round()
              .clamp(1, config.autoGridColumnCount)
              .toInt();
  final rowSpan =
      rowTrackHeight <= 0
          ? 1
          : math.max(
            1,
            ((bounds.height + config.autoGridGap) / rowTrackHeight).round(),
          );

  return _RuleGeometry(
    column: column,
    row: row,
    columnSpan: columnSpan,
    rowSpan: rowSpan,
  );
}

bool _isSameRect(Rect first, Rect second) {
  return (first.left - second.left).abs() < 0.5 &&
      (first.top - second.top).abs() < 0.5 &&
      (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}

bool _isSameDouble(double first, double second) {
  return (first - second).abs() < 0.001;
}

bool _isSameNullableRect(Rect? first, Rect? second) {
  if (first == null || second == null) return first == second;

  return _isSameRect(first, second);
}

bool _isSameConflictResolution(
  LayoutConflictResolution? first,
  LayoutConflictResolution? second,
) {
  if (first == null || second == null) return first == second;

  return first.isSameResolution(second);
}

bool _isSameOffset(Offset first, Offset second) {
  return (first.dx - second.dx).abs() < 0.5 &&
      (first.dy - second.dy).abs() < 0.5;
}

bool _sameCanvasEdges(
  List<LayoutCanvasEdge> first,
  List<LayoutCanvasEdge> second,
) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }

  return true;
}

bool _sameCanvasOverflow(
  List<LayoutCanvasOverflow> first,
  List<LayoutCanvasOverflow> second,
) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (!first[index].isSameOverflow(second[index])) return false;
  }

  return true;
}

bool _sameConflictBlockers(
  List<LayoutConflictBlocker> first,
  List<LayoutConflictBlocker> second,
) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (!first[index].isSameBlocker(second[index])) return false;
  }

  return true;
}

bool _sameConflictPatches(
  List<LayoutConflictPatch> first,
  List<LayoutConflictPatch> second,
) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (!first[index].isSamePatch(second[index])) return false;
  }

  return true;
}

class _RuleGeometry {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;

  const _RuleGeometry({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
  });
}
