import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/layout_config.dart';
import '../models/layout_drag_preview.dart';

/// Paints rule-aware landing indicators for the active component drag.
class LayoutDragPreviewOverlay extends StatefulWidget {
  final LayoutDragPreview? preview;

  const LayoutDragPreviewOverlay({super.key, required this.preview});

  @override
  State<LayoutDragPreviewOverlay> createState() =>
      _LayoutDragPreviewOverlayState();
}

/// Owns short-lived layout measurement cache for active drag preview badges.
class _LayoutDragPreviewOverlayState extends State<LayoutDragPreviewOverlay> {
  final _measurementCache = _PreviewBadgeMeasurementCache();

  @override
  Widget build(BuildContext context) {
    final items = widget.preview?.items ?? const <LayoutDragPreviewItem>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final willApplyRulesOnDrop = widget.preview?.willApplyRulesOnDrop ?? true;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = _previewOverlaySize(constraints, items);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final item in items)
                if (_isUsableBounds(item.ruleBounds))
                  _LayoutDragPreviewIndicator(
                    item: item,
                    canvasSize: canvasSize,
                    measurementCache: _measurementCache,
                    willApplyRulesOnDrop: willApplyRulesOnDrop,
                  ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _measurementCache.clear();
    super.dispose();
  }
}

/// Positions a single landing indicator and its rule label.
class _LayoutDragPreviewIndicator extends StatelessWidget {
  final LayoutDragPreviewItem item;
  final Size canvasSize;
  final _PreviewBadgeMeasurementCache measurementCache;
  final bool willApplyRulesOnDrop;

  const _LayoutDragPreviewIndicator({
    required this.item,
    required this.canvasSize,
    required this.measurementCache,
    required this.willApplyRulesOnDrop,
  });

  @override
  Widget build(BuildContext context) {
    final bounds = item.ruleBounds;
    final chipLabels = _previewBadgeChipLabels(item, willApplyRulesOnDrop);
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        (item.hasConflict || item.isOutsideCanvas) && willApplyRulesOnDrop
            ? colorScheme.error
            : willApplyRulesOnDrop
            ? colorScheme.primary
            : colorScheme.tertiary;
    final foregroundColor = _previewBadgeForegroundColor(
      colorScheme,
      item,
      willApplyRulesOnDrop,
    );
    final badgeMaxWidth = _previewBadgeMaxWidth(canvasSize.width);
    final badgePlacementSize = measurementCache.measure(
      labels: chipLabels,
      primaryLabel: item.ruleLabel,
      maxWidth: badgeMaxWidth,
      textStyle: Theme.of(context).textTheme.labelSmall,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      calculate:
          () => _measurePreviewBadgeSize(
            labels: chipLabels,
            primaryLabel: item.ruleLabel,
            maxWidth: badgeMaxWidth,
            textStyle: Theme.of(context).textTheme.labelSmall,
            foregroundColor: foregroundColor,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          ),
    );
    final badgeLeft = _previewBadgeLeftOffset(
      bounds: bounds,
      canvasWidth: canvasSize.width,
      badgeWidth: badgePlacementSize.width,
    );
    final badgeTop = _previewBadgeTopOffset(
      bounds: bounds,
      canvasHeight: canvasSize.height,
      badgeHeight: badgePlacementSize.height,
    );
    final connectorGeometry = _previewBadgeConnectorGeometry(
      badgeLeft: badgeLeft,
      badgeTop: badgeTop,
      badgeSize: badgePlacementSize,
      targetSize: bounds.size,
    );
    final correctionBounds = item.correctedRuleBounds;
    final correctionLocalBounds = Rect.fromLTWH(
      correctionBounds.left - bounds.left,
      correctionBounds.top - bounds.top,
      correctionBounds.width,
      correctionBounds.height,
    );
    final correctionConnectorGeometry = _previewGuideConnectorGeometry(
      sourceRect: Offset.zero & bounds.size,
      targetRect: correctionLocalBounds,
    );
    final visibleConflictBlockers = item.conflictBlockers
        .where((blocker) => _isUsableBounds(blocker.bounds))
        .take(_kPreviewConflictBlockerOutlineLimit)
        .toList(growable: false);
    final visibleConflictPatches = item.conflictPatches
        .where((patch) => _isUsableBounds(patch.bounds))
        .take(_kPreviewConflictPatchLimit)
        .toList(growable: false);
    final conflictResolvedBounds = item.conflictResolvedBounds;
    final hasConflictResolutionGuide =
        item.hasConflictResolution &&
        conflictResolvedBounds != null &&
        _isUsableBounds(conflictResolvedBounds);
    final conflictResolutionColor =
        willApplyRulesOnDrop ? colorScheme.secondary : colorScheme.tertiary;
    final conflictResolutionLocalBounds =
        conflictResolvedBounds == null
            ? Rect.zero
            : Rect.fromLTWH(
              conflictResolvedBounds.left - bounds.left,
              conflictResolvedBounds.top - bounds.top,
              conflictResolvedBounds.width,
              conflictResolvedBounds.height,
            );
    final conflictResolutionConnectorGeometry = _previewGuideConnectorGeometry(
      sourceRect: Offset.zero & bounds.size,
      targetRect: conflictResolutionLocalBounds,
    );

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (index, blocker) in visibleConflictBlockers.indexed)
            Positioned(
              left: blocker.bounds.left - bounds.left,
              top: blocker.bounds.top - bounds.top,
              width: blocker.bounds.width,
              height: blocker.bounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-blocker-${item.componentId}-$index',
                ),
                painter: _LayoutDragConflictBlockerPainter(
                  color: color,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (hasConflictResolutionGuide &&
              conflictResolutionConnectorGeometry.shouldPaint)
            Positioned(
              left: conflictResolutionConnectorGeometry.paintBounds.left,
              top: conflictResolutionConnectorGeometry.paintBounds.top,
              width: conflictResolutionConnectorGeometry.paintBounds.width,
              height: conflictResolutionConnectorGeometry.paintBounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-conflict-resolution-connector-${item.componentId}',
                ),
                painter: _LayoutDragGuideConnectorPainter(
                  color: conflictResolutionColor,
                  sourceRect: conflictResolutionConnectorGeometry.sourceRect,
                  targetRect: conflictResolutionConnectorGeometry.targetRect,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (hasConflictResolutionGuide)
            Positioned(
              left: conflictResolutionLocalBounds.left,
              top: conflictResolutionLocalBounds.top,
              width: conflictResolutionLocalBounds.width,
              height: conflictResolutionLocalBounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-conflict-resolution-${item.componentId}',
                ),
                painter: _LayoutDragConflictResolutionPainter(
                  color: conflictResolutionColor,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (item.hasCanvasCorrection && _isUsableBounds(correctionBounds))
            Positioned(
              left: correctionLocalBounds.left,
              top: correctionLocalBounds.top,
              width: correctionLocalBounds.width,
              height: correctionLocalBounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-correction-${item.componentId}',
                ),
                painter: _LayoutDragCorrectionPreviewPainter(
                  color: color,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (item.hasCanvasCorrection &&
              _isUsableBounds(correctionBounds) &&
              correctionConnectorGeometry.shouldPaint)
            Positioned(
              left: correctionConnectorGeometry.paintBounds.left,
              top: correctionConnectorGeometry.paintBounds.top,
              width: correctionConnectorGeometry.paintBounds.width,
              height: correctionConnectorGeometry.paintBounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-correction-connector-${item.componentId}',
                ),
                painter: _LayoutDragGuideConnectorPainter(
                  color: color,
                  sourceRect: correctionConnectorGeometry.sourceRect,
                  targetRect: correctionConnectorGeometry.targetRect,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          CustomPaint(
            painter: _LayoutDragPreviewPainter(
              color: color,
              hasConflict: item.hasConflict,
              isOutsideCanvas: item.isOutsideCanvas,
              isRuleAligned: item.isRuleAligned,
              isGuideOnly: !willApplyRulesOnDrop,
            ),
            child: const SizedBox.expand(),
          ),
          for (final (index, patch) in visibleConflictPatches.indexed)
            Positioned(
              left: patch.bounds.left - bounds.left,
              top: patch.bounds.top - bounds.top,
              width: patch.bounds.width,
              height: patch.bounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-conflict-patch-${item.componentId}-$index',
                ),
                painter: _LayoutDragConflictPatchPainter(
                  color: color,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (_hasPreviewConflictCoverage(item))
            Positioned.fill(
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-conflict-meter-${item.componentId}',
                ),
                painter: _LayoutDragConflictCoveragePainter(
                  color: color,
                  coverage: _previewConflictCoverage(item),
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          if (connectorGeometry.shouldPaint)
            Positioned(
              left: connectorGeometry.paintBounds.left,
              top: connectorGeometry.paintBounds.top,
              width: connectorGeometry.paintBounds.width,
              height: connectorGeometry.paintBounds.height,
              child: CustomPaint(
                key: ValueKey(
                  'layout-drag-preview-connector-${item.componentId}',
                ),
                painter: _LayoutDragPreviewBadgeConnectorPainter(
                  color: color,
                  badgeRect: connectorGeometry.badgeRect,
                  targetRect: connectorGeometry.targetRect,
                  isGuideOnly: !willApplyRulesOnDrop,
                ),
              ),
            ),
          Positioned(
            left: badgeLeft,
            top: badgeTop,
            child: _LayoutDragPreviewBadge(
              item: item,
              color: color,
              maxWidth: badgeMaxWidth,
              willApplyRulesOnDrop: willApplyRulesOnDrop,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the compact column, row, span, and conflict status for a drag target.
class _LayoutDragPreviewBadge extends StatelessWidget {
  final LayoutDragPreviewItem item;
  final Color color;
  final double maxWidth;
  final bool willApplyRulesOnDrop;

  const _LayoutDragPreviewBadge({
    required this.item,
    required this.color,
    required this.maxWidth,
    required this.willApplyRulesOnDrop,
  });

  @override
  Widget build(BuildContext context) {
    final chipLabels = _previewBadgeChipLabels(item, willApplyRulesOnDrop);
    final label = _previewBadgeLabel(item, willApplyRulesOnDrop);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = _previewBadgeForegroundColor(
      colorScheme,
      item,
      willApplyRulesOnDrop,
    );

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: _kPreviewBadgeChipSpacing,
                runSpacing: _kPreviewBadgeRunSpacing,
                children: [
                  for (var index = 0; index < chipLabels.length; index++)
                    _LayoutDragPreviewChip(
                      label: chipLabels[index],
                      textStyle: _previewBadgeChipTextStyle(
                        textTheme.labelSmall,
                        foregroundColor,
                        chipLabels[index] == item.ruleLabel,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders one compact segment inside a placement preview badge.
class _LayoutDragPreviewChip extends StatelessWidget {
  final String label;
  final TextStyle textStyle;

  const _LayoutDragPreviewChip({required this.label, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            textStyle.color?.withValues(alpha: _chipFillOpacity) ??
            Colors.white.withValues(alpha: _chipFillOpacity),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              textStyle.color?.withValues(alpha: _chipBorderOpacity) ??
              Colors.white.withValues(alpha: _chipBorderOpacity),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kPreviewBadgeChipHorizontalInset,
          vertical: _kPreviewBadgeChipVerticalInset,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );
  }

  double get _chipFillOpacity =>
      textStyle.fontWeight == FontWeight.w800 ? 0.18 : 0.11;

  double get _chipBorderOpacity =>
      textStyle.fontWeight == FontWeight.w800 ? 0.28 : 0.16;
}

/// Describes the paint region used to connect a badge back to its target.
class _PreviewBadgeConnectorGeometry {
  final Rect paintBounds;
  final Rect badgeRect;
  final Rect targetRect;
  final bool shouldPaint;

  const _PreviewBadgeConnectorGeometry({
    required this.paintBounds,
    required this.badgeRect,
    required this.targetRect,
    required this.shouldPaint,
  });
}

/// Describes a connector between a preview target and a related guide.
class _PreviewGuideConnectorGeometry {
  final Rect paintBounds;
  final Rect sourceRect;
  final Rect targetRect;
  final bool shouldPaint;

  const _PreviewGuideConnectorGeometry({
    required this.paintBounds,
    required this.sourceRect,
    required this.targetRect,
    required this.shouldPaint,
  });
}

/// Reuses measured badge sizes while a drag preview rebuilds rapidly.
class _PreviewBadgeMeasurementCache {
  static const _capacity = 96;

  final _entries = <_PreviewBadgeMeasurementKey, Size>{};

  Size measure({
    required List<String> labels,
    required String primaryLabel,
    required double maxWidth,
    required TextStyle? textStyle,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required Size Function() calculate,
  }) {
    final key = _PreviewBadgeMeasurementKey(
      labels: labels,
      primaryLabel: primaryLabel,
      maxWidth: maxWidth,
      textStyle: textStyle,
      textDirection: textDirection,
      textScaleProbe: textScaler.scale(_kPreviewBadgeTextScaleProbe),
    );
    final cached = _entries.remove(key);
    if (cached != null) {
      _entries[key] = cached;
      return cached;
    }

    final measured = calculate();
    _entries[key] = measured;
    if (_entries.length > _capacity) {
      _entries.remove(_entries.keys.first);
    }

    return measured;
  }

  void clear() {
    _entries.clear();
  }
}

/// Identifies one badge measurement result across drag-preview rebuilds.
class _PreviewBadgeMeasurementKey {
  final List<String> labels;
  final String primaryLabel;
  final double maxWidth;
  final TextStyle? textStyle;
  final TextDirection textDirection;
  final double textScaleProbe;

  _PreviewBadgeMeasurementKey({
    required List<String> labels,
    required this.primaryLabel,
    required double maxWidth,
    required this.textStyle,
    required this.textDirection,
    required double textScaleProbe,
  }) : labels = List.unmodifiable(labels),
       maxWidth = _roundedCacheDouble(maxWidth),
       textScaleProbe = _roundedCacheDouble(textScaleProbe);

  @override
  bool operator ==(Object other) {
    return other is _PreviewBadgeMeasurementKey &&
        _sameStringList(labels, other.labels) &&
        primaryLabel == other.primaryLabel &&
        maxWidth == other.maxWidth &&
        textStyle == other.textStyle &&
        textDirection == other.textDirection &&
        textScaleProbe == other.textScaleProbe;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(labels),
      primaryLabel,
      maxWidth,
      textStyle,
      textDirection,
      textScaleProbe,
    );
  }
}

const _kPreviewBadgeGap = 6.0;
const _kPreviewBadgeMaxWidth = 360.0;
const _kPreviewBadgeMinWidth = 72.0;
const _kPreviewBadgeTopClearance = 44.0;
const _kPreviewBadgeTextScaleProbe = 12.0;
const _kPreviewBadgeConnectorPadding = 8.0;
const _kPreviewBadgeConnectorMinSeparation = 2.0;
const _kPreviewBadgeConnectorMinDisplacement = 0.5;
const _kPreviewCorrectionConnectorPadding = 6.0;
const _kPreviewCorrectionConnectorMinSeparation = 4.0;
const _kPreviewConflictBlockerOutlineLimit = 6;
const _kPreviewConflictPatchLimit = 8;
const _kPreviewConflictPatchStripeSpacing = 7.0;
const _kPreviewConflictCoverageLabelThreshold = 0.1;
const _kPreviewConflictMeterHeight = 5.0;
const _kPreviewConflictMeterInset = 7.0;
const _kPreviewBadgeChipSpacing = 4.0;
const _kPreviewBadgeRunSpacing = 4.0;
const _kPreviewBadgeChipHorizontalInset = 6.0;
const _kPreviewBadgeChipVerticalInset = 3.0;
const _kPreviewBadgeChipHorizontalPadding =
    _kPreviewBadgeChipHorizontalInset * 2;
const _kPreviewBadgeChipVerticalPadding = _kPreviewBadgeChipVerticalInset * 2;
const _kPreviewBadgeOuterHorizontalPadding = 8.0;
const _kPreviewBadgeOuterVerticalPadding = 8.0;

double _roundedCacheDouble(double value) {
  if (!value.isFinite) return value;

  return (value * 1000).roundToDouble() / 1000;
}

bool _sameStringList(List<String> first, List<String> second) {
  if (first.length != second.length) return false;

  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }

  return true;
}

List<String> _previewBadgeChipLabels(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  return [
    if (!willApplyRulesOnDrop) 'Guide',
    item.ruleLabel,
    ..._previewStatusLabels(item, willApplyRulesOnDrop),
  ];
}

List<String> _previewStatusLabels(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  return [
    if (item.hasConflict) _previewConflictStatus(item, willApplyRulesOnDrop),
    ..._previewConflictCoverageLabels(item, willApplyRulesOnDrop),
    if (item.hasConflictResolution)
      _conflictResolutionStatus(item, willApplyRulesOnDrop),
    if (item.hasConflictResolution)
      ..._conflictResolutionRuleLabels(item, willApplyRulesOnDrop),
    if (item.hasUnresolvedConflict)
      _unresolvedConflictStatus(willApplyRulesOnDrop),
    if (item.isOutsideCanvas) _outsideCanvasStatus(item),
    if (item.isOutsideCanvas) _canvasCorrectionStatus(item),
  ];
}

String _previewConflictStatus(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  final count = item.conflictCount;
  final label = count > 1 ? '$count overlaps' : 'overlap';

  return willApplyRulesOnDrop ? label : 'guide $label';
}

List<String> _previewConflictCoverageLabels(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  if (!_hasPreviewConflictCoverage(item)) return const [];

  final coverage = _previewConflictCoverage(item);
  final percent = (coverage * 100).round().clamp(1, 100).toInt();
  final label = '$percent% blocked';

  return [willApplyRulesOnDrop ? label : 'guide $label'];
}

bool _hasPreviewConflictCoverage(LayoutDragPreviewItem item) {
  return item.hasConflict &&
      _previewConflictCoverage(item) >= _kPreviewConflictCoverageLabelThreshold;
}

double _previewConflictCoverage(LayoutDragPreviewItem item) {
  return item.conflictCoverage.clamp(0.0, 1.0).toDouble();
}

String _conflictResolutionStatus(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  final movementLabel = _movementLabelForOffset(item.conflictResolutionOffset);
  final clearLabel =
      item.usesNearbyConflictResolution ? 'nearby clear' : 'clear';
  final label =
      movementLabel.isEmpty ? '$clearLabel spot' : '$clearLabel $movementLabel';

  return willApplyRulesOnDrop ? label : 'guide $label';
}

List<String> _conflictResolutionRuleLabels(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  final ruleLabel = item.conflictResolvedRuleLabel.trim();
  if (ruleLabel.isEmpty) return const [];

  final label = 'to $ruleLabel';

  return [willApplyRulesOnDrop ? label : 'guide $label'];
}

String _unresolvedConflictStatus(bool willApplyRulesOnDrop) {
  const label = 'no nearby clear spot';

  return willApplyRulesOnDrop ? label : 'guide $label';
}

String _previewBadgeLabel(
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  final statuses = [
    ..._previewStatusLabels(item, willApplyRulesOnDrop),
    ..._previewTooltipStatusLabels(item),
  ];
  final status = statuses.isEmpty ? '' : ' - ${statuses.join(', ')}';

  return willApplyRulesOnDrop
      ? '${item.ruleLabel}$status'
      : 'Guide: ${item.ruleLabel}$status';
}

List<String> _previewTooltipStatusLabels(LayoutDragPreviewItem item) {
  final sourceSummary = item.conflictSourceSummary.trim();
  if (!item.hasConflict || sourceSummary.isEmpty) return const [];

  return ['blocked by $sourceSummary'];
}

TextStyle _previewBadgeChipTextStyle(
  TextStyle? textStyle,
  Color color,
  bool isPrimary,
) {
  return (textStyle ?? const TextStyle(fontSize: 11)).copyWith(
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
    fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
  );
}

Size _previewOverlaySize(
  BoxConstraints constraints,
  List<LayoutDragPreviewItem> items,
) {
  final itemBounds = [
    for (final item in items) ..._previewItemContentBounds(item),
  ];
  final contentWidth =
      itemBounds.isEmpty
          ? 0.0
          : itemBounds
              .map((bounds) => bounds.right)
              .where((value) => value.isFinite)
              .fold<double>(0.0, math.max);
  final contentHeight =
      itemBounds.isEmpty
          ? 0.0
          : itemBounds
              .map((bounds) => bounds.bottom)
              .where((value) => value.isFinite)
              .fold<double>(0.0, math.max);
  final width =
      constraints.hasBoundedWidth ? constraints.maxWidth : contentWidth;
  final height =
      constraints.hasBoundedHeight ? constraints.maxHeight : contentHeight;

  return Size(
    width.isFinite ? math.max(0.0, width) : contentWidth,
    height.isFinite ? math.max(0.0, height) : contentHeight,
  );
}

List<Rect> _previewItemContentBounds(LayoutDragPreviewItem item) {
  return [
    item.ruleBounds,
    if (item.hasCanvasCorrection) item.correctedRuleBounds,
    if (item.hasConflictResolution && item.conflictResolvedBounds != null)
      item.conflictResolvedBounds!,
  ];
}

double _previewBadgeMaxWidth(double canvasWidth) {
  if (!canvasWidth.isFinite || canvasWidth <= 0) return _kPreviewBadgeMaxWidth;

  return math.max(
    _kPreviewBadgeMinWidth,
    math.min(_kPreviewBadgeMaxWidth, canvasWidth),
  );
}

Size _measurePreviewBadgeSize({
  required List<String> labels,
  required String primaryLabel,
  required double maxWidth,
  required TextStyle? textStyle,
  required Color foregroundColor,
  required TextDirection textDirection,
  required TextScaler textScaler,
}) {
  final chipSizes = [
    for (final label in labels)
      _measurePreviewBadgeChipSize(
        label: label,
        isPrimary: label == primaryLabel,
        maxWidth: math.max(
          _kPreviewBadgeMinWidth,
          maxWidth - _kPreviewBadgeOuterHorizontalPadding,
        ),
        textStyle: textStyle,
        foregroundColor: foregroundColor,
        textDirection: textDirection,
        textScaler: textScaler,
      ),
  ];
  final width = math.min(_measuredPreviewBadgeWidth(chipSizes), maxWidth);
  final availableWidth = math.max(
    _kPreviewBadgeMinWidth,
    width - _kPreviewBadgeOuterHorizontalPadding,
  );
  var contentHeight = 0.0;
  var contentWidth = 0.0;
  var rowWidth = 0.0;
  var rowHeight = 0.0;

  void commitRow() {
    if (rowWidth == 0) return;
    contentWidth = math.max(contentWidth, rowWidth);
    contentHeight +=
        (contentHeight == 0 ? 0.0 : _kPreviewBadgeRunSpacing) + rowHeight;
    rowWidth = 0.0;
    rowHeight = 0.0;
  }

  for (final chipSize in chipSizes) {
    final chipWidth = math.min(availableWidth, chipSize.width);
    final nextWidth =
        rowWidth == 0
            ? chipWidth
            : rowWidth + _kPreviewBadgeChipSpacing + chipWidth;
    if (rowWidth > 0 && nextWidth > availableWidth) {
      commitRow();
      rowWidth = chipWidth;
      rowHeight = chipSize.height;
      continue;
    }

    rowWidth = nextWidth;
    rowHeight = math.max(rowHeight, chipSize.height);
  }
  commitRow();

  final height =
      _kPreviewBadgeOuterVerticalPadding + math.max(0.0, contentHeight);

  return Size(
    math.max(
      _kPreviewBadgeMinWidth,
      math.min(maxWidth, contentWidth + _kPreviewBadgeOuterHorizontalPadding),
    ),
    height,
  );
}

double _measuredPreviewBadgeWidth(List<Size> chipSizes) {
  if (chipSizes.isEmpty) return _kPreviewBadgeMinWidth;

  final chipWidth = chipSizes.fold<double>(
    0,
    (width, size) => width + size.width,
  );
  final chipSpacing =
      math.max(0, chipSizes.length - 1) * _kPreviewBadgeChipSpacing;

  return math.max(
    _kPreviewBadgeMinWidth,
    math.min(
      _kPreviewBadgeMaxWidth,
      chipWidth + chipSpacing + _kPreviewBadgeOuterHorizontalPadding,
    ),
  );
}

Size _measurePreviewBadgeChipSize({
  required String label,
  required bool isPrimary,
  required double maxWidth,
  required TextStyle? textStyle,
  required Color foregroundColor,
  required TextDirection textDirection,
  required TextScaler textScaler,
}) {
  final style = _previewBadgeChipTextStyle(
    textStyle,
    foregroundColor,
    isPrimary,
  );
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
  )..layout(
    maxWidth: math.max(0.0, maxWidth - _kPreviewBadgeChipHorizontalPadding),
  );

  return Size(
    math.min(maxWidth, painter.width + _kPreviewBadgeChipHorizontalPadding),
    painter.height + _kPreviewBadgeChipVerticalPadding,
  );
}

double _previewBadgeLeftOffset({
  required Rect bounds,
  required double canvasWidth,
  required double badgeWidth,
}) {
  if (!canvasWidth.isFinite || canvasWidth <= 0 || !badgeWidth.isFinite) {
    return 0;
  }

  final maximumBadgeLeft = math.max(0.0, canvasWidth - badgeWidth);
  final clampedBadgeLeft = bounds.left.clamp(0.0, maximumBadgeLeft).toDouble();

  return clampedBadgeLeft - bounds.left;
}

double _previewBadgeTopOffset({
  required Rect bounds,
  required double canvasHeight,
  required double badgeHeight,
}) {
  if (!canvasHeight.isFinite || canvasHeight <= 0 || !badgeHeight.isFinite) {
    return bounds.top < _kPreviewBadgeTopClearance
        ? bounds.height + _kPreviewBadgeGap
        : -badgeHeight - _kPreviewBadgeGap;
  }

  final aboveTop = bounds.top - badgeHeight - _kPreviewBadgeGap;
  final belowTop = bounds.bottom + _kPreviewBadgeGap;
  final hasRoomAbove = aboveTop >= 0;
  final hasRoomBelow = belowTop + badgeHeight <= canvasHeight;
  final preferredTop =
      bounds.top < _kPreviewBadgeTopClearance
          ? hasRoomBelow || !hasRoomAbove
              ? belowTop
              : aboveTop
          : hasRoomAbove || !hasRoomBelow
          ? aboveTop
          : belowTop;
  final maximumBadgeTop = math.max(0.0, canvasHeight - badgeHeight);
  final clampedBadgeTop = preferredTop.clamp(0.0, maximumBadgeTop).toDouble();

  return clampedBadgeTop - bounds.top;
}

_PreviewBadgeConnectorGeometry _previewBadgeConnectorGeometry({
  required double badgeLeft,
  required double badgeTop,
  required Size badgeSize,
  required Size targetSize,
}) {
  final badgeRect = Rect.fromLTWH(
    badgeLeft,
    badgeTop,
    badgeSize.width,
    badgeSize.height,
  );
  final targetRect = Offset.zero & targetSize;
  final naturalBadgeRect = Rect.fromLTWH(
    0,
    -badgeSize.height - _kPreviewBadgeGap,
    badgeSize.width,
    badgeSize.height,
  );
  final wasDisplaced =
      (badgeRect.left - naturalBadgeRect.left).abs() >
          _kPreviewBadgeConnectorMinDisplacement ||
      (badgeRect.top - naturalBadgeRect.top).abs() >
          _kPreviewBadgeConnectorMinDisplacement;
  final paintBounds = badgeRect
      .expandToInclude(targetRect)
      .inflate(_kPreviewBadgeConnectorPadding);
  final shift = Offset(-paintBounds.left, -paintBounds.top);
  final badgePaintRect = badgeRect.shift(shift);
  final targetPaintRect = targetRect.shift(shift);

  return _PreviewBadgeConnectorGeometry(
    paintBounds: paintBounds,
    badgeRect: badgePaintRect,
    targetRect: targetPaintRect,
    shouldPaint:
        wasDisplaced &&
        _rectSeparation(badgeRect, targetRect) >
            _kPreviewBadgeConnectorMinSeparation,
  );
}

_PreviewGuideConnectorGeometry _previewGuideConnectorGeometry({
  required Rect sourceRect,
  required Rect targetRect,
}) {
  final paintBounds = sourceRect
      .expandToInclude(targetRect)
      .inflate(_kPreviewCorrectionConnectorPadding);
  final shift = Offset(-paintBounds.left, -paintBounds.top);

  return _PreviewGuideConnectorGeometry(
    paintBounds: paintBounds,
    sourceRect: sourceRect.shift(shift),
    targetRect: targetRect.shift(shift),
    shouldPaint:
        _rectSeparation(sourceRect, targetRect) >
        _kPreviewCorrectionConnectorMinSeparation,
  );
}

double _rectSeparation(Rect first, Rect second) {
  final horizontalGap =
      first.right < second.left
          ? second.left - first.right
          : second.right < first.left
          ? first.left - second.right
          : 0.0;
  final verticalGap =
      first.bottom < second.top
          ? second.top - first.bottom
          : second.bottom < first.top
          ? first.top - second.bottom
          : 0.0;

  return math.max(horizontalGap, verticalGap);
}

Offset _closestPointOnRect(Rect rect, Offset target) {
  return Offset(
    target.dx.clamp(rect.left, rect.right).toDouble(),
    target.dy.clamp(rect.top, rect.bottom).toDouble(),
  );
}

void _drawDashedRRect(
  Canvas canvas,
  RRect roundedRect,
  Paint paint, {
  double dash = 8,
  double gap = 5,
}) {
  final path = Path()..addRRect(roundedRect);
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = (distance + dash).clamp(0.0, metric.length).toDouble();
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance += dash + gap;
    }
  }
}

Color _previewBadgeForegroundColor(
  ColorScheme colorScheme,
  LayoutDragPreviewItem item,
  bool willApplyRulesOnDrop,
) {
  if ((item.hasConflict || item.isOutsideCanvas) && willApplyRulesOnDrop) {
    return colorScheme.onError;
  }

  return willApplyRulesOnDrop ? colorScheme.onPrimary : colorScheme.onTertiary;
}

String _outsideCanvasStatus(LayoutDragPreviewItem item) {
  if (item.canvasOverflow.isNotEmpty) {
    return 'outside ${item.canvasOverflow.map((overflow) => overflow.label).join('/')}';
  }

  final labels = item.outsideCanvasEdges.map((edge) => edge.label).toList();
  if (labels.isEmpty) return 'outside canvas';

  return 'outside ${labels.join('/')}';
}

String _canvasCorrectionStatus(LayoutDragPreviewItem item) {
  final correctedBounds = item.correctedRuleBounds;
  if ((correctedBounds.width - item.ruleBounds.width).abs() > 0.5 ||
      (correctedBounds.height - item.ruleBounds.height).abs() > 0.5) {
    return 'resize to fit';
  }

  final offset = item.canvasCorrectionOffset;
  final movementLabel = _movementLabelForOffset(offset);
  if (movementLabel.isEmpty) return 'resize to fit';

  return 'shift $movementLabel';
}

String _movementLabelForOffset(Offset offset) {
  final labels = [
    if (offset.dx > 0.5) 'right ${offset.dx.round()}px',
    if (offset.dx < -0.5) 'left ${(-offset.dx).round()}px',
    if (offset.dy > 0.5) 'down ${offset.dy.round()}px',
    if (offset.dy < -0.5) 'up ${(-offset.dy).round()}px',
  ];

  return labels.join('/');
}

/// Draws a leader line from a preview target to a related guide.
class _LayoutDragGuideConnectorPainter extends CustomPainter {
  final Color color;
  final Rect sourceRect;
  final Rect targetRect;
  final bool isGuideOnly;

  const _LayoutDragGuideConnectorPainter({
    required this.color,
    required this.sourceRect,
    required this.targetRect,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (_rectSeparation(sourceRect, targetRect) <=
        _kPreviewCorrectionConnectorMinSeparation) {
      return;
    }

    final start = _closestPointOnRect(sourceRect, targetRect.center);
    final end = _closestPointOnRect(targetRect, sourceRect.center);
    final paint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.32 : 0.44)
          ..strokeWidth = isGuideOnly ? 1.0 : 1.3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
    canvas.drawCircle(
      end,
      isGuideOnly ? 1.5 : 1.8,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LayoutDragGuideConnectorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.sourceRect != sourceRect ||
        oldDelegate.targetRect != targetRect ||
        oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws a faint outline around an existing component blocking placement.
class _LayoutDragConflictBlockerPainter extends CustomPainter {
  final Color color;
  final bool isGuideOnly;

  const _LayoutDragConflictBlockerPainter({
    required this.color,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final roundedRect = RRect.fromRectAndRadius(
      rect.deflate(2),
      const Radius.circular(7),
    );
    final fillPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.04 : 0.07)
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.36 : 0.56)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isGuideOnly ? 1.1 : 1.5;

    canvas.drawRRect(roundedRect, fillPaint);
    _drawDashedRRect(canvas, roundedRect, borderPaint, dash: 6, gap: 4);
  }

  @override
  bool shouldRepaint(_LayoutDragConflictBlockerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Paints the exact in-target region already occupied by another component.
class _LayoutDragConflictPatchPainter extends CustomPainter {
  final Color color;
  final bool isGuideOnly;

  const _LayoutDragConflictPatchPainter({
    required this.color,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final roundedRect = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(5),
    );
    final fillPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.09 : 0.16)
          ..style = PaintingStyle.fill;
    final stripePaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.26 : 0.42)
          ..strokeWidth = isGuideOnly ? 1.0 : 1.2
          ..style = PaintingStyle.stroke;

    canvas.drawRRect(roundedRect, fillPaint);
    canvas.save();
    canvas.clipRRect(roundedRect);
    for (
      var x = -size.height;
      x < size.width + size.height;
      x += _kPreviewConflictPatchStripeSpacing
    ) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LayoutDragConflictPatchPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws a compact in-target meter for conflict coverage severity.
class _LayoutDragConflictCoveragePainter extends CustomPainter {
  final Color color;
  final double coverage;
  final bool isGuideOnly;

  const _LayoutDragConflictCoveragePainter({
    required this.color,
    required this.coverage,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final clampedCoverage = coverage.clamp(0.0, 1.0).toDouble();
    if (clampedCoverage <= 0) return;

    final availableWidth = math.max(
      0.0,
      size.width - (_kPreviewConflictMeterInset * 2),
    );
    if (availableWidth <= 0) return;

    final trackWidth = availableWidth * clampedCoverage;
    final rect = Rect.fromLTWH(
      _kPreviewConflictMeterInset,
      math.max(0.0, size.height - _kPreviewConflictMeterInset),
      trackWidth,
      _kPreviewConflictMeterHeight,
    );
    final roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_kPreviewConflictMeterHeight / 2),
    );
    final paint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.36 : 0.62)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(_LayoutDragConflictCoveragePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.coverage != coverage ||
        oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws the subtle leader line between a moved badge and its landing target.
class _LayoutDragPreviewBadgeConnectorPainter extends CustomPainter {
  final Color color;
  final Rect badgeRect;
  final Rect targetRect;
  final bool isGuideOnly;

  const _LayoutDragPreviewBadgeConnectorPainter({
    required this.color,
    required this.badgeRect,
    required this.targetRect,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (_rectSeparation(badgeRect, targetRect) <=
        _kPreviewBadgeConnectorMinSeparation) {
      return;
    }

    final start = _closestPointOnRect(badgeRect, targetRect.center);
    final end = _closestPointOnRect(targetRect, badgeRect.center);
    final paint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.42 : 0.58)
          ..strokeWidth = isGuideOnly ? 1.1 : 1.4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
    canvas.drawCircle(
      end,
      isGuideOnly ? 1.6 : 2.0,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LayoutDragPreviewBadgeConnectorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.badgeRect != badgeRect ||
        oldDelegate.targetRect != targetRect ||
        oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws the translucent landing rectangle and conflict emphasis.
class _LayoutDragPreviewPainter extends CustomPainter {
  final Color color;
  final bool hasConflict;
  final bool isOutsideCanvas;
  final bool isRuleAligned;
  final bool isGuideOnly;

  const _LayoutDragPreviewPainter({
    required this.color,
    required this.hasConflict,
    required this.isOutsideCanvas,
    required this.isRuleAligned,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rect.isEmpty) return;
    final hasIssue = hasConflict || isOutsideCanvas;

    final fillPaint =
        Paint()
          ..color = color.withValues(
            alpha:
                isGuideOnly
                    ? 0.08
                    : hasIssue
                    ? 0.16
                    : 0.1,
          )
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = color.withValues(
            alpha:
                isGuideOnly
                    ? 0.58
                    : hasIssue
                    ? 0.9
                    : 0.78,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              isGuideOnly
                  ? 1.5
                  : hasIssue
                  ? 2.4
                  : 1.8;
    final roundedRect = RRect.fromRectAndRadius(
      rect.deflate(2),
      const Radius.circular(7),
    );

    canvas.drawRRect(roundedRect, fillPaint);
    _drawDashedRRect(canvas, roundedRect, borderPaint);

    if (hasIssue && !isGuideOnly) {
      _drawConflictMark(canvas, rect, borderPaint);
      return;
    }

    if (!isRuleAligned) {
      _drawLandingCorner(canvas, rect, borderPaint);
    }
  }

  void _drawConflictMark(Canvas canvas, Rect rect, Paint paint) {
    final markPaint =
        Paint()
          ..color = color.withValues(alpha: 0.84)
          ..strokeWidth = paint.strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(rect.left + 10, rect.top + 10),
      Offset(rect.right - 10, rect.bottom - 10),
      markPaint,
    );
    canvas.drawLine(
      Offset(rect.left + 10, rect.bottom - 10),
      Offset(rect.right - 10, rect.top + 10),
      markPaint,
    );
  }

  void _drawLandingCorner(Canvas canvas, Rect rect, Paint paint) {
    final cornerPaint =
        Paint()
          ..color = color.withValues(alpha: 0.84)
          ..strokeWidth = paint.strokeWidth + 0.4
          ..strokeCap = StrokeCap.round;
    const inset = 9.0;
    const length = 14.0;
    final origin = Offset(rect.left + inset, rect.top + inset);

    canvas.drawLine(origin, origin + const Offset(length, 0), cornerPaint);
    canvas.drawLine(origin, origin + const Offset(0, length), cornerPaint);
  }

  @override
  bool shouldRepaint(_LayoutDragPreviewPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.hasConflict != hasConflict ||
        oldDelegate.isOutsideCanvas != isOutsideCanvas ||
        oldDelegate.isRuleAligned != isRuleAligned ||
        oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws the corrected in-canvas landing area for an outside preview.
class _LayoutDragCorrectionPreviewPainter extends CustomPainter {
  final Color color;
  final bool isGuideOnly;

  const _LayoutDragCorrectionPreviewPainter({
    required this.color,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rect.isEmpty) return;

    final fillPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.04 : 0.07)
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.48 : 0.68)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isGuideOnly ? 1.2 : 1.6;
    final roundedRect = RRect.fromRectAndRadius(
      rect.deflate(3),
      const Radius.circular(7),
    );

    canvas.drawRRect(roundedRect, fillPaint);
    _drawDashedRRect(canvas, roundedRect, borderPaint, dash: 4, gap: 4);
    _drawCorrectionCorner(canvas, rect, borderPaint);
  }

  void _drawCorrectionCorner(Canvas canvas, Rect rect, Paint paint) {
    final cornerPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.5 : 0.72)
          ..strokeWidth = paint.strokeWidth + 0.3
          ..strokeCap = StrokeCap.round;
    const inset = 10.0;
    const length = 12.0;
    final topRight = Offset(rect.right - inset, rect.top + inset);
    final bottomLeft = Offset(rect.left + inset, rect.bottom - inset);

    canvas.drawLine(topRight, topRight - const Offset(length, 0), cornerPaint);
    canvas.drawLine(topRight, topRight + const Offset(0, length), cornerPaint);
    canvas.drawLine(
      bottomLeft,
      bottomLeft + const Offset(length, 0),
      cornerPaint,
    );
    canvas.drawLine(
      bottomLeft,
      bottomLeft - const Offset(0, length),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_LayoutDragCorrectionPreviewPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isGuideOnly != isGuideOnly;
  }
}

/// Draws a suggested collision-free landing area for a blocked preview.
class _LayoutDragConflictResolutionPainter extends CustomPainter {
  final Color color;
  final bool isGuideOnly;

  const _LayoutDragConflictResolutionPainter({
    required this.color,
    required this.isGuideOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rect.isEmpty) return;

    final fillPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.05 : 0.09)
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.52 : 0.76)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isGuideOnly ? 1.2 : 1.7;
    final roundedRect = RRect.fromRectAndRadius(
      rect.deflate(3),
      const Radius.circular(7),
    );

    canvas.drawRRect(roundedRect, fillPaint);
    _drawDashedRRect(canvas, roundedRect, borderPaint, dash: 7, gap: 4);
    _drawClearSpotCorner(canvas, rect, borderPaint);
  }

  void _drawClearSpotCorner(Canvas canvas, Rect rect, Paint paint) {
    final cornerPaint =
        Paint()
          ..color = color.withValues(alpha: isGuideOnly ? 0.56 : 0.82)
          ..strokeWidth = paint.strokeWidth + 0.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    const inset = 11.0;
    final start = Offset(rect.left + inset, rect.top + inset + 5);

    canvas.drawLine(start, start + const Offset(5, 5), cornerPaint);
    canvas.drawLine(
      start + const Offset(5, 5),
      start + const Offset(16, -7),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_LayoutDragConflictResolutionPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isGuideOnly != isGuideOnly;
  }
}

bool _isUsableBounds(Rect bounds) {
  return bounds.left.isFinite &&
      bounds.top.isFinite &&
      bounds.width.isFinite &&
      bounds.height.isFinite &&
      bounds.width > 0 &&
      bounds.height > 0;
}

@Preview(name: 'Layout drag preview overlay')
Widget layoutDragPreviewOverlayPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          height: 260,
          child: ColoredBox(
            color: Colors.white,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.tabularColumns,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'summary-card',
                    currentBounds: const Rect.fromLTWH(70, 82, 150, 82),
                    ruleBounds: const Rect.fromLTWH(80, 72, 150, 82),
                    ruleLabel: 'Tabular c2 r2 2x1',
                    hasConflict: false,
                  ),
                  LayoutDragPreviewItem(
                    componentId: 'detail-card',
                    currentBounds: const Rect.fromLTWH(238, 112, 130, 78),
                    ruleBounds: const Rect.fromLTWH(250, 112, 130, 78),
                    ruleLabel: 'Tabular c4 r3 1x1',
                    hasConflict: true,
                    conflictCount: 1,
                    conflictCoverage: 0.44,
                    conflictSourceSummary: 'Summary Card',
                    conflictBlockers: [
                      LayoutConflictBlocker(
                        bounds: const Rect.fromLTWH(238, 104, 72, 94),
                        label: 'Summary Card',
                      ),
                    ],
                    conflictPatches: [
                      LayoutConflictPatch(
                        bounds: const Rect.fromLTWH(250, 112, 60, 78),
                        label: 'Summary Card',
                      ),
                    ],
                    conflictResolvedBounds: const Rect.fromLTWH(
                      88,
                      112,
                      130,
                      78,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
