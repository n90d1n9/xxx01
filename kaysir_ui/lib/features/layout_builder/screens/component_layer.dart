import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_canvas_containment_action_service.dart';
import '../services/layout_canvas_placement_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';
import '../utils/selection_bounds.dart';
import '../widgets/dialog_utils.dart';
import '../widgets/draggable_component.dart';

class ComponentLayer extends ConsumerWidget {
  final List<ComponentData> components;
  final Size canvasSize;

  const ComponentLayer({
    super.key,
    required this.components,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponents = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponents),
    );
    final showPrecisionGuides = ref.watch(
      canvasViewportProvider.select((state) => state.showPrecisionGuides),
    );
    final layoutConfig = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );
    final selectedIds =
        selectedComponents.map((component) => component.id).toSet();
    final autoGridConflictSummary = _autoGridSelectionConflictSummary(
      components,
      selectedIds,
      layoutConfig,
    );

    return Stack(
      children: [
        for (final component in components)
          DraggableComponent(
            key: ValueKey(component.id),
            component: component,
            isSelected: selectedIds.contains(component.id),
            showResizeHandles:
                selectedIds.length == 1 && selectedIds.contains(component.id),
          ),
        if (selectedComponents.length == 1)
          _SingleSelectionMetricsBadge(
            component: selectedComponents.single,
            canvasSize: canvasSize,
            config: layoutConfig,
          ),
        if (selectedComponents.length > 1)
          _MultiSelectionOutline(components: selectedComponents),
        if (showPrecisionGuides && selectedComponents.isNotEmpty)
          _SelectionEdgeDistanceGuides(
            components: selectedComponents,
            canvasSize: canvasSize,
          ),
        if (showPrecisionGuides && selectedComponents.isNotEmpty)
          _SelectionCenterOffsetGuide(
            components: selectedComponents,
            canvasSize: canvasSize,
          ),
        if (selectedComponents.isNotEmpty)
          _SelectionQuickToolbar(
            components: selectedComponents,
            canvasSize: canvasSize,
          ),
        if (autoGridConflictSummary != null && selectedComponents.isNotEmpty)
          _AutoGridConflictNotice(
            components: selectedComponents,
            canvasSize: canvasSize,
            summary: autoGridConflictSummary,
          ),
      ],
    );
  }
}

class _SingleSelectionMetricsBadge extends StatelessWidget {
  static const _badgeWidth = 360.0;
  static const _badgeHeight = 28.0;
  static const _ruleLabelMinWidth = 330.0;
  static const _gap = 8.0;

  final ComponentData component;
  final Size canvasSize;
  final LayoutConfig config;

  const _SingleSelectionMetricsBadge({
    required this.component,
    required this.canvasSize,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (!component.isVisible) return const SizedBox.shrink();

    final bounds = Rect.fromLTWH(
      component.position.dx,
      component.position.dy,
      component.size.width,
      component.size.height,
    );
    final badgeWidth = math.min(_badgeWidth, math.max(0.0, canvasSize.width));
    if (badgeWidth <= 0) return const SizedBox.shrink();

    final left = bounds.left.clamp(
      0.0,
      math.max(0.0, canvasSize.width - badgeWidth),
    );
    final preferredTop = bounds.bottom + _gap;
    final fallbackTop = bounds.top - _badgeHeight - _gap;
    final top = (preferredTop + _badgeHeight <= canvasSize.height
            ? preferredTop
            : fallbackTop)
        .clamp(0.0, math.max(0.0, canvasSize.height - _badgeHeight));
    final colorScheme = Theme.of(context).colorScheme;
    final name = _componentDisplayName(component);
    final ruleLabel = _layoutRuleMetricsLabel(component, config);
    final showRuleLabel = ruleLabel != null && badgeWidth >= _ruleLabelMinWidth;

    return Positioned(
      left: left.toDouble(),
      top: top.toDouble(),
      child: Tooltip(
        message: ruleLabel == null ? 'Copy bounds' : 'Copy bounds - $ruleLabel',
        child: Material(
          elevation: 2,
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => copyLayoutSelectionBounds(context, [component]),
            child: SizedBox(
              width: badgeWidth,
              height: _badgeHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      component.type.icon,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showRuleLabel) ...[
                      const SizedBox(width: 8),
                      _SelectionRuleMetricPill(label: ruleLabel),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      layoutBoundsLabel(bounds),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
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
}

class _SelectionRuleMetricPill extends StatelessWidget {
  final String label;

  const _SelectionRuleMetricPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AutoGridConflictNotice extends ConsumerWidget {
  static const _noticeWidth = 292.0;
  static const _noticeHeight = 34.0;
  static const _gap = 10.0;

  final List<ComponentData> components;
  final Size canvasSize;
  final _AutoGridConflictSummary summary;

  const _AutoGridConflictNotice({
    required this.components,
    required this.canvasSize,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return const SizedBox.shrink();

    final bounds = _componentBounds(visibleComponents);
    final noticeWidth = math.min(_noticeWidth, math.max(0.0, canvasSize.width));
    if (noticeWidth <= 0) return const SizedBox.shrink();

    final left = bounds.left.clamp(
      0.0,
      math.max(0.0, canvasSize.width - noticeWidth),
    );
    final preferredTop = bounds.bottom + 42;
    final fallbackTop = bounds.top - _noticeHeight - _gap;
    final top = (preferredTop + _noticeHeight <= canvasSize.height
            ? preferredTop
            : fallbackTop)
        .clamp(0.0, math.max(0.0, canvasSize.height - _noticeHeight));
    final colorScheme = Theme.of(context).colorScheme;
    final cellLabel =
        summary.cellCount == 1
            ? '1 cell overlap'
            : '${summary.cellCount} cell overlaps';
    final conflictLabel =
        summary.componentNames.isEmpty
            ? cellLabel
            : '$cellLabel: ${summary.compactNameLabel}';

    return Positioned(
      left: left.toDouble(),
      top: top.toDouble(),
      child: Tooltip(
        message: summary.tooltipLabel,
        child: Material(
          elevation: 3,
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: noticeWidth,
            height: _noticeHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      conflictLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _AutoGridConflictNoticeAction(
                    icon: Icons.manage_search_outlined,
                    tooltip: 'Select Auto Grid conflicts',
                    onPressed:
                        () => layoutAutoGridActionService
                            .selectConflictPartnersForSelection(context, ref),
                  ),
                  const SizedBox(width: 4),
                  _AutoGridConflictNoticeAction(
                    icon: Icons.auto_fix_high_outlined,
                    tooltip: 'Move selection to free Auto Grid cells',
                    onPressed:
                        () => layoutAutoGridActionService
                            .moveSelectionToFreeCells(context, ref),
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

class _AutoGridConflictNoticeAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AutoGridConflictNoticeAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 24,
          child: Center(
            child: Icon(icon, size: 15, color: colorScheme.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

class _SelectionQuickToolbar extends ConsumerWidget {
  static const _toolbarHeight = 40.0;
  static const _toolbarWidth = 484.0;
  static const _compactToolbarWidth = 260.0;
  static const _gap = 10.0;

  final List<ComponentData> components;
  final Size canvasSize;

  const _SelectionQuickToolbar({
    required this.components,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return const SizedBox.shrink();

    final bounds = _componentBounds(visibleComponents);
    final useCompactToolbar = canvasSize.width < _toolbarWidth;
    final toolbarWidth =
        useCompactToolbar
            ? math.min(canvasSize.width, _compactToolbarWidth)
            : _toolbarWidth;
    final left = bounds.left.clamp(
      0,
      math.max(0, canvasSize.width - toolbarWidth),
    );
    final preferredTop = bounds.top - _toolbarHeight - _gap;
    final fallbackTop = bounds.bottom + _gap;
    final top = (preferredTop >= 0 ? preferredTop : fallbackTop).clamp(
      0,
      math.max(0, canvasSize.height - _toolbarHeight),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final matchingType = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponent?.type),
    );
    final gridSize = ref.watch(
      layoutStateProvider.select((state) => state.gridSettings.gridSize),
    );
    final layoutConfig = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );
    final notifier = ref.read(layoutStateProvider.notifier);
    final viewportNotifier = ref.read(canvasViewportProvider.notifier);
    final selectedComponent = components.length == 1 ? components.single : null;
    final shouldLock = components.any((component) => !component.isLocked);
    final shouldShow = components.any((component) => !component.isVisible);
    final copyTooltip =
        components.length == 1 ? 'Copy component' : 'Copy selection';
    final resetPositionReason = _resetPositionDisabledReason(selectedComponent);
    final resetSizeReason = _resetSizeDisabledReason(selectedComponent);
    final canSnapPosition = components.any(
      (component) =>
          !component.isLocked &&
          _needsLayoutRulePositionSnap(component, gridSize, layoutConfig),
    );
    final canSnapSize = components.any(
      (component) =>
          !component.isLocked &&
          _needsLayoutRuleSizeSnap(component, gridSize, layoutConfig),
    );
    final canMoveToOrigin = _canMoveSelectionToOrigin(components);
    final canSpaceSelection =
        components.where((component) => !component.isLocked).length > 1;
    final showAutoGridActions =
        layoutConfig.layoutMechanism == LayoutMechanism.autoGrid;
    final canArrangeIntoAutoGrid =
        showAutoGridActions &&
        components.any((component) => !component.isLocked);
    final canMoveToFreeAutoGridCells = canArrangeIntoAutoGrid;
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: components.isNotEmpty,
      preview: notifier.selectedConflictResolutionPreview(),
    );
    final groupIds =
        components
            .map((component) => component.properties.parentId)
            .whereType<String>()
            .toSet();
    final isSingleGroupSelection =
        groupIds.length == 1 &&
        components.length > 1 &&
        components.every(
          (component) => component.properties.parentId == groupIds.first,
        );

    void handleLayoutAction(_SelectionLayoutAction action) {
      switch (action) {
        case _SelectionLayoutAction.alignLeft:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.left,
          );
          break;
        case _SelectionLayoutAction.alignCenter:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.center,
          );
          break;
        case _SelectionLayoutAction.alignRight:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.right,
          );
          break;
        case _SelectionLayoutAction.alignTop:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.top,
          );
          break;
        case _SelectionLayoutAction.alignMiddle:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.middle,
          );
          break;
        case _SelectionLayoutAction.alignBottom:
          layoutSelectionGeometryActionService.alignSelection(
            context,
            ref,
            ComponentAlignment.bottom,
          );
          break;
        case _SelectionLayoutAction.snapPosition:
          layoutSelectionGeometryActionService.snapSelectionToLayoutRules(
            context,
            ref,
          );
          break;
        case _SelectionLayoutAction.snapSize:
          layoutSelectionGeometryActionService.snapSelectionSizeToLayoutRules(
            context,
            ref,
          );
          break;
        case _SelectionLayoutAction.moveToOrigin:
          layoutCanvasPlacementActionService.moveSelectionToOrigin(
            context,
            ref,
          );
          break;
        case _SelectionLayoutAction.moveToClearSpot:
          layoutClearSpotActionService.moveSelectionToClearSpot(context, ref);
          break;
        case _SelectionLayoutAction.arrangeIntoAutoGrid:
          layoutAutoGridActionService.arrangeSelection(context, ref);
          break;
        case _SelectionLayoutAction.moveToFreeAutoGridCells:
          layoutAutoGridActionService.moveSelectionToFreeCells(context, ref);
          break;
        case _SelectionLayoutAction.selectAutoGridConflicts:
          layoutAutoGridActionService.selectConflictPartnersForSelection(
            context,
            ref,
          );
          break;
        case _SelectionLayoutAction.spaceHorizontalByGrid:
          layoutSelectionGeometryActionService.spaceSelection(
            context,
            ref,
            ComponentDistribution.horizontal,
            gridSize,
          );
          break;
        case _SelectionLayoutAction.spaceVerticalByGrid:
          layoutSelectionGeometryActionService.spaceSelection(
            context,
            ref,
            ComponentDistribution.vertical,
            gridSize,
          );
          break;
        case _SelectionLayoutAction.centerCanvasHorizontal:
          layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            context,
            ref,
            vertical: false,
            canvasSize: canvasSize,
          );
          break;
        case _SelectionLayoutAction.centerCanvasVertical:
          layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            context,
            ref,
            horizontal: false,
            canvasSize: canvasSize,
          );
          break;
        case _SelectionLayoutAction.centerCanvas:
          layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            context,
            ref,
            canvasSize: canvasSize,
          );
          break;
        case _SelectionLayoutAction.distributeHorizontal:
          layoutSelectionGeometryActionService.distributeSelection(
            context,
            ref,
            ComponentDistribution.horizontal,
          );
          break;
        case _SelectionLayoutAction.distributeVertical:
          layoutSelectionGeometryActionService.distributeSelection(
            context,
            ref,
            ComponentDistribution.vertical,
          );
          break;
        case _SelectionLayoutAction.stackHorizontal:
          layoutSelectionGeometryActionService.stackSelection(
            context,
            ref,
            ComponentDistribution.horizontal,
          );
          break;
        case _SelectionLayoutAction.stackVertical:
          layoutSelectionGeometryActionService.stackSelection(
            context,
            ref,
            ComponentDistribution.vertical,
          );
          break;
      }
    }

    void handleArrangeAction(_SelectionArrangeAction action) {
      switch (action) {
        case _SelectionArrangeAction.bringForward:
          notifier.bringSelectedForward();
          break;
        case _SelectionArrangeAction.bringToFront:
          notifier.bringSelectedToFront();
          break;
        case _SelectionArrangeAction.sendBackward:
          notifier.sendSelectedBackward();
          break;
        case _SelectionArrangeAction.sendToBack:
          notifier.sendSelectedToBack();
          break;
      }
    }

    void handleMoreAction(_SelectionMoreAction action) {
      switch (action) {
        case _SelectionMoreAction.selectMatchingType:
          notifier.selectComponentsByType(
            matchingType ?? visibleComponents.first.type,
          );
          break;
        case _SelectionMoreAction.keepInsideCanvas:
          layoutCanvasContainmentActionService.moveSelectionInsideCanvas(
            context,
            ref,
          );
          break;
        case _SelectionMoreAction.fitSelection:
          viewportNotifier.fitSelection();
          break;
        case _SelectionMoreAction.resetPosition:
          final component = selectedComponent;
          if (component == null) return;
          notifier.updateComponentPosition(component.id, Offset.zero);
          break;
        case _SelectionMoreAction.resetSize:
          final component = selectedComponent;
          if (component == null) return;
          notifier.updateComponentSize(
            component.id,
            component.type.defaultSize,
          );
          break;
        case _SelectionMoreAction.savePreset:
          showSaveSelectionPresetDialog(context, ref, visibleComponents);
          break;
        case _SelectionMoreAction.group:
          notifier.groupSelectedComponents();
          break;
        case _SelectionMoreAction.ungroup:
          notifier.ungroupSelectedComponents();
          break;
        case _SelectionMoreAction.toggleLock:
          notifier.toggleSelectedComponentLock();
          break;
        case _SelectionMoreAction.toggleVisibility:
          notifier.toggleSelectedComponentVisibility();
          break;
      }
    }

    final toolbarChildren =
        useCompactToolbar
            ? <Widget>[
              _SelectionToolbarButton(
                icon: Icons.content_copy,
                tooltip: copyTooltip,
                onPressed: notifier.copySelectedComponent,
              ),
              _SelectionBoundsCopyMenu(components: visibleComponents),
              _SelectionToolbarButton(
                icon: Icons.control_point_duplicate,
                tooltip: 'Duplicate selection',
                onPressed: notifier.duplicateSelectedComponent,
              ),
              _SelectionLayoutMenu(
                canDistribute: components.length > 2,
                canSnapPosition: canSnapPosition,
                canSnapSize: canSnapSize,
                canMoveToOrigin: canMoveToOrigin,
                clearSpotAction: clearSpotAction,
                canSpaceSelection: canSpaceSelection,
                showAutoGridActions: showAutoGridActions,
                canArrangeIntoAutoGrid: canArrangeIntoAutoGrid,
                canMoveToFreeAutoGridCells: canMoveToFreeAutoGridCells,
                onSelected: handleLayoutAction,
              ),
              _SelectionArrangeMenu(onSelected: handleArrangeAction),
              _SelectionMoreMenu(
                showGroupAction: components.length > 1,
                showSingleComponentActions: selectedComponent != null,
                canResetPosition: resetPositionReason == null,
                canResetSize: resetSizeReason == null,
                isSingleGroupSelection: isSingleGroupSelection,
                shouldLock: shouldLock,
                shouldShow: shouldShow,
                onSelected: handleMoreAction,
              ),
              _SelectionToolbarButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete selection',
                color: colorScheme.error,
                onPressed: notifier.removeSelectedComponent,
              ),
            ]
            : <Widget>[
              _SelectionToolbarButton(
                icon: Icons.content_copy,
                tooltip: copyTooltip,
                onPressed: notifier.copySelectedComponent,
              ),
              _SelectionBoundsCopyMenu(components: visibleComponents),
              _SelectionToolbarButton(
                icon: Icons.control_point_duplicate,
                tooltip: 'Duplicate selection',
                onPressed: notifier.duplicateSelectedComponent,
              ),
              if (selectedComponent != null) ...[
                _SelectionToolbarButton(
                  icon: Icons.restart_alt,
                  tooltip: resetPositionReason ?? 'Reset position',
                  onPressed:
                      resetPositionReason == null
                          ? () => notifier.updateComponentPosition(
                            selectedComponent.id,
                            Offset.zero,
                          )
                          : null,
                ),
                _SelectionToolbarButton(
                  icon: Icons.aspect_ratio,
                  tooltip: resetSizeReason ?? 'Reset size',
                  onPressed:
                      resetSizeReason == null
                          ? () => notifier.updateComponentSize(
                            selectedComponent.id,
                            selectedComponent.type.defaultSize,
                          )
                          : null,
                ),
              ],
              _SelectionToolbarButton(
                icon: Icons.bookmark_add_outlined,
                tooltip: 'Save selection as preset',
                onPressed:
                    () => showSaveSelectionPresetDialog(
                      context,
                      ref,
                      visibleComponents,
                    ),
              ),
              _SelectionToolbarButton(
                icon: Icons.filter_alt_outlined,
                tooltip: 'Select matching type',
                onPressed:
                    () => notifier.selectComponentsByType(
                      matchingType ?? visibleComponents.first.type,
                    ),
              ),
              _SelectionLayoutMenu(
                canDistribute: components.length > 2,
                canSnapPosition: canSnapPosition,
                canSnapSize: canSnapSize,
                canMoveToOrigin: canMoveToOrigin,
                clearSpotAction: clearSpotAction,
                canSpaceSelection: canSpaceSelection,
                showAutoGridActions: showAutoGridActions,
                canArrangeIntoAutoGrid: canArrangeIntoAutoGrid,
                canMoveToFreeAutoGridCells: canMoveToFreeAutoGridCells,
                onSelected: handleLayoutAction,
              ),
              _SelectionArrangeMenu(onSelected: handleArrangeAction),
              _SelectionToolbarButton(
                icon: Icons.fit_screen,
                tooltip: 'Keep selection inside canvas',
                onPressed:
                    () => layoutCanvasContainmentActionService
                        .moveSelectionInsideCanvas(context, ref),
              ),
              _SelectionToolbarButton(
                icon: Icons.center_focus_weak,
                tooltip: 'Fit selection',
                onPressed: viewportNotifier.fitSelection,
              ),
              if (components.length > 1)
                _SelectionToolbarButton(
                  icon:
                      isSingleGroupSelection
                          ? Icons.call_split_outlined
                          : Icons.group_work_outlined,
                  tooltip:
                      isSingleGroupSelection
                          ? 'Ungroup selection'
                          : 'Group selection',
                  onPressed:
                      isSingleGroupSelection
                          ? notifier.ungroupSelectedComponents
                          : notifier.groupSelectedComponents,
                ),
              _SelectionToolbarButton(
                icon: shouldLock ? Icons.lock : Icons.lock_open_outlined,
                tooltip: shouldLock ? 'Lock selection' : 'Unlock selection',
                onPressed: notifier.toggleSelectedComponentLock,
              ),
              _SelectionToolbarButton(
                icon:
                    shouldShow
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                tooltip: shouldShow ? 'Show selection' : 'Hide selection',
                onPressed: notifier.toggleSelectedComponentVisibility,
              ),
              _SelectionToolbarButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete selection',
                color: colorScheme.error,
                onPressed: notifier.removeSelectedComponent,
              ),
            ];

    return Positioned(
      left: left.toDouble(),
      top: top.toDouble(),
      child: Material(
        elevation: 4,
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: toolbarWidth,
            height: _toolbarHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: toolbarChildren,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _SelectionLayoutAction {
  snapPosition,
  snapSize,
  moveToOrigin,
  moveToClearSpot,
  arrangeIntoAutoGrid,
  moveToFreeAutoGridCells,
  selectAutoGridConflicts,
  spaceHorizontalByGrid,
  spaceVerticalByGrid,
  alignLeft,
  alignCenter,
  alignRight,
  alignTop,
  alignMiddle,
  alignBottom,
  centerCanvasHorizontal,
  centerCanvasVertical,
  centerCanvas,
  distributeHorizontal,
  distributeVertical,
  stackHorizontal,
  stackVertical,
}

class _SelectionLayoutMenu extends StatelessWidget {
  final bool canDistribute;
  final bool canSnapPosition;
  final bool canSnapSize;
  final bool canMoveToOrigin;
  final LayoutClearSpotActionState clearSpotAction;
  final bool canSpaceSelection;
  final bool showAutoGridActions;
  final bool canArrangeIntoAutoGrid;
  final bool canMoveToFreeAutoGridCells;
  final ValueChanged<_SelectionLayoutAction> onSelected;

  const _SelectionLayoutMenu({
    required this.canDistribute,
    required this.canSnapPosition,
    required this.canSnapSize,
    required this.canMoveToOrigin,
    required this.clearSpotAction,
    required this.canSpaceSelection,
    required this.showAutoGridActions,
    required this.canArrangeIntoAutoGrid,
    required this.canMoveToFreeAutoGridCells,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectionToolbarMenuButton<_SelectionLayoutAction>(
      icon: Icons.align_horizontal_center,
      tooltip: 'Align or distribute selection',
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              enabled: canSnapPosition,
              value: _SelectionLayoutAction.snapPosition,
              child: const _SelectionMenuItem(
                icon: Icons.grid_4x4,
                label: 'Snap position to layout rules',
              ),
            ),
            PopupMenuItem(
              enabled: canSnapSize,
              value: _SelectionLayoutAction.snapSize,
              child: const _SelectionMenuItem(
                icon: Icons.aspect_ratio,
                label: 'Snap size to layout rules',
              ),
            ),
            PopupMenuItem(
              enabled: canMoveToOrigin,
              value: _SelectionLayoutAction.moveToOrigin,
              child: const _SelectionMenuItem(
                icon: Icons.north_west,
                label: 'Move to origin',
              ),
            ),
            PopupMenuItem(
              enabled: clearSpotAction.isAvailable,
              value: _SelectionLayoutAction.moveToClearSpot,
              child: _SelectionMenuItem(
                icon: Icons.near_me_outlined,
                label: clearSpotAction.menuActionLabel(prefix: 'Move to'),
              ),
            ),
            if (showAutoGridActions)
              PopupMenuItem(
                enabled: canArrangeIntoAutoGrid,
                value: _SelectionLayoutAction.arrangeIntoAutoGrid,
                child: const _SelectionMenuItem(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Arrange into Auto Grid',
                ),
              ),
            if (showAutoGridActions)
              PopupMenuItem(
                enabled: canMoveToFreeAutoGridCells,
                value: _SelectionLayoutAction.moveToFreeAutoGridCells,
                child: const _SelectionMenuItem(
                  icon: Icons.auto_fix_high_outlined,
                  label: 'Move to free Auto Grid cells',
                ),
              ),
            if (showAutoGridActions)
              PopupMenuItem(
                enabled: canMoveToFreeAutoGridCells,
                value: _SelectionLayoutAction.selectAutoGridConflicts,
                child: const _SelectionMenuItem(
                  icon: Icons.manage_search_outlined,
                  label: 'Select Auto Grid conflicts',
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignLeft,
              child: _SelectionMenuItem(
                icon: Icons.format_align_left,
                label: 'Align left',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignCenter,
              child: _SelectionMenuItem(
                icon: Icons.align_horizontal_center,
                label: 'Align center',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignRight,
              child: _SelectionMenuItem(
                icon: Icons.format_align_right,
                label: 'Align right',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignTop,
              child: _SelectionMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Align top',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignMiddle,
              child: _SelectionMenuItem(
                icon: Icons.vertical_align_center,
                label: 'Align middle',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.alignBottom,
              child: _SelectionMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Align bottom',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SelectionLayoutAction.centerCanvasHorizontal,
              child: _SelectionMenuItem(
                icon: Icons.horizontal_distribute,
                label: 'Center selection horizontally',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.centerCanvasVertical,
              child: _SelectionMenuItem(
                icon: Icons.vertical_distribute,
                label: 'Center selection vertically',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.centerCanvas,
              child: _SelectionMenuItem(
                icon: Icons.center_focus_weak,
                label: 'Center selection on canvas',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: canDistribute,
              value: _SelectionLayoutAction.distributeHorizontal,
              child: const _SelectionMenuItem(
                icon: Icons.more_horiz,
                label: 'Distribute horizontally',
              ),
            ),
            PopupMenuItem(
              enabled: canDistribute,
              value: _SelectionLayoutAction.distributeVertical,
              child: const _SelectionMenuItem(
                icon: Icons.more_vert,
                label: 'Distribute vertically',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SelectionLayoutAction.stackHorizontal,
              child: _SelectionMenuItem(
                icon: Icons.view_column,
                label: 'Stack as row',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionLayoutAction.stackVertical,
              child: _SelectionMenuItem(
                icon: Icons.view_stream,
                label: 'Stack as column',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: canSpaceSelection,
              value: _SelectionLayoutAction.spaceHorizontalByGrid,
              child: const _SelectionMenuItem(
                icon: Icons.more_horiz,
                label: 'Space row by grid',
              ),
            ),
            PopupMenuItem(
              enabled: canSpaceSelection,
              value: _SelectionLayoutAction.spaceVerticalByGrid,
              child: const _SelectionMenuItem(
                icon: Icons.more_vert,
                label: 'Space column by grid',
              ),
            ),
          ],
    );
  }
}

enum _SelectionArrangeAction {
  bringForward,
  bringToFront,
  sendBackward,
  sendToBack,
}

class _SelectionArrangeMenu extends StatelessWidget {
  final ValueChanged<_SelectionArrangeAction> onSelected;

  const _SelectionArrangeMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _SelectionToolbarMenuButton<_SelectionArrangeAction>(
      icon: Icons.layers_outlined,
      tooltip: 'Arrange selection',
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _SelectionArrangeAction.bringForward,
              child: _SelectionMenuItem(
                icon: Icons.flip_to_front,
                label: 'Bring forward',
              ),
            ),
            PopupMenuItem(
              value: _SelectionArrangeAction.bringToFront,
              child: _SelectionMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Bring to front',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _SelectionArrangeAction.sendBackward,
              child: _SelectionMenuItem(
                icon: Icons.flip_to_back,
                label: 'Send backward',
              ),
            ),
            PopupMenuItem(
              value: _SelectionArrangeAction.sendToBack,
              child: _SelectionMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Send to back',
              ),
            ),
          ],
    );
  }
}

enum _SelectionMoreAction {
  selectMatchingType,
  keepInsideCanvas,
  fitSelection,
  resetPosition,
  resetSize,
  savePreset,
  group,
  ungroup,
  toggleLock,
  toggleVisibility,
}

class _SelectionMoreMenu extends StatelessWidget {
  final bool showGroupAction;
  final bool showSingleComponentActions;
  final bool canResetPosition;
  final bool canResetSize;
  final bool isSingleGroupSelection;
  final bool shouldLock;
  final bool shouldShow;
  final ValueChanged<_SelectionMoreAction> onSelected;

  const _SelectionMoreMenu({
    required this.showGroupAction,
    required this.showSingleComponentActions,
    required this.canResetPosition,
    required this.canResetSize,
    required this.isSingleGroupSelection,
    required this.shouldLock,
    required this.shouldShow,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectionToolbarMenuButton<_SelectionMoreAction>(
      icon: Icons.more_horiz,
      tooltip: 'More selection actions',
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: _SelectionMoreAction.selectMatchingType,
              child: _SelectionMenuItem(
                icon: Icons.filter_alt_outlined,
                label: 'Select matching type',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SelectionMoreAction.keepInsideCanvas,
              child: _SelectionMenuItem(
                icon: Icons.fit_screen,
                label: 'Keep inside canvas',
              ),
            ),
            const PopupMenuItem(
              value: _SelectionMoreAction.fitSelection,
              child: _SelectionMenuItem(
                icon: Icons.center_focus_weak,
                label: 'Fit selection',
              ),
            ),
            if (showSingleComponentActions) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: canResetPosition,
                value: _SelectionMoreAction.resetPosition,
                child: const _SelectionMenuItem(
                  icon: Icons.restart_alt,
                  label: 'Reset position',
                ),
              ),
              PopupMenuItem(
                enabled: canResetSize,
                value: _SelectionMoreAction.resetSize,
                child: const _SelectionMenuItem(
                  icon: Icons.aspect_ratio,
                  label: 'Reset size',
                ),
              ),
            ],
            const PopupMenuItem(
              value: _SelectionMoreAction.savePreset,
              child: _SelectionMenuItem(
                icon: Icons.bookmark_add_outlined,
                label: 'Save preset',
              ),
            ),
            if (showGroupAction) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                value:
                    isSingleGroupSelection
                        ? _SelectionMoreAction.ungroup
                        : _SelectionMoreAction.group,
                child: _SelectionMenuItem(
                  icon:
                      isSingleGroupSelection
                          ? Icons.call_split_outlined
                          : Icons.group_work_outlined,
                  label:
                      isSingleGroupSelection
                          ? 'Ungroup selection'
                          : 'Group selection',
                ),
              ),
            ],
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _SelectionMoreAction.toggleLock,
              child: _SelectionMenuItem(
                icon: shouldLock ? Icons.lock : Icons.lock_open_outlined,
                label: shouldLock ? 'Lock selection' : 'Unlock selection',
              ),
            ),
            PopupMenuItem(
              value: _SelectionMoreAction.toggleVisibility,
              child: _SelectionMenuItem(
                icon:
                    shouldShow
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                label: shouldShow ? 'Show selection' : 'Hide selection',
              ),
            ),
          ],
    );
  }
}

class _SelectionBoundsCopyMenu extends StatelessWidget {
  final List<ComponentData> components;

  const _SelectionBoundsCopyMenu({required this.components});

  @override
  Widget build(BuildContext context) {
    return _SelectionToolbarMenuButton<LayoutBoundsCopyFormat>(
      icon: Icons.straighten,
      tooltip: 'Copy bounds',
      onSelected:
          (format) =>
              copyLayoutSelectionBounds(context, components, format: format),
      itemBuilder:
          (context) => [
            for (final format in LayoutBoundsCopyFormat.values)
              PopupMenuItem(
                value: format,
                child: _SelectionMenuItem(
                  icon: _copyFormatIcon(format),
                  label: format.label,
                ),
              ),
          ],
    );
  }
}

class _SelectionToolbarMenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final ValueChanged<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  const _SelectionToolbarMenuButton({
    required this.icon,
    required this.tooltip,
    required this.onSelected,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PopupMenuButton<T>(
        padding: EdgeInsets.zero,
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        child: SizedBox(width: 36, height: 34, child: Icon(icon, size: 18)),
      ),
    );
  }
}

class _SelectionMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SelectionMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _SelectionToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _SelectionToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 36, height: 34),
        onPressed: onPressed,
      ),
    );
  }
}

String? _resetPositionDisabledReason(ComponentData? component) {
  if (component == null) return 'Select one component first';
  if (component.isLocked) return 'Selected component is locked';
  if (component.position == Offset.zero) return 'Position is already 0, 0';
  return null;
}

String? _resetSizeDisabledReason(ComponentData? component) {
  if (component == null) return 'Select one component first';
  if (component.isLocked) return 'Selected component is locked';
  if (_isSameSize(component.size, component.type.defaultSize)) {
    return 'Size is already the component default';
  }
  return null;
}

bool _isSameSize(Size first, Size second) {
  return (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}

bool _needsLayoutRulePositionSnap(
  ComponentData component,
  double gridSize,
  LayoutConfig config,
) {
  final snappedPosition = _snapPositionForLayoutRules(
    component.position,
    gridSize,
    config,
  );

  return (snappedPosition - component.position).distance >= 0.01;
}

bool _needsLayoutRuleSizeSnap(
  ComponentData component,
  double gridSize,
  LayoutConfig config,
) {
  final snappedSize = _snapSizeForLayoutRules(component.size, gridSize, config);

  return (snappedSize.width - component.size.width).abs() >= 0.01 ||
      (snappedSize.height - component.size.height).abs() >= 0.01;
}

Offset _snapPositionForLayoutRules(
  Offset position,
  double gridSize,
  LayoutConfig config,
) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return position;
    case LayoutMechanism.grid:
      final safeGridSize = math.max(1.0, gridSize);

      return Offset(
        (position.dx / safeGridSize).round() * safeGridSize,
        (position.dy / safeGridSize).round() * safeGridSize,
      );
    case LayoutMechanism.tabularColumns:
      final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
      final column =
          trackWidth <= 0
              ? 0
              : (position.dx / trackWidth)
                  .round()
                  .clamp(0, config.tabularColumnCount - 1)
                  .toInt();
      final rowHeight = math.max(1.0, config.tabularRowHeight);
      final row = (position.dy / rowHeight).round();

      return Offset(column * trackWidth, row * rowHeight);
    case LayoutMechanism.autoGrid:
      final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
      final column =
          trackWidth <= 0
              ? 0
              : (position.dx / trackWidth)
                  .round()
                  .clamp(0, config.autoGridColumnCount - 1)
                  .toInt();
      final rowTrackHeight =
          math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
      final row =
          rowTrackHeight <= 0 ? 0 : (position.dy / rowTrackHeight).round();

      return Offset(column * trackWidth, row * rowTrackHeight);
  }
}

Size _snapSizeForLayoutRules(Size size, double gridSize, LayoutConfig config) {
  final constrained = Size(
    size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
    size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
  );

  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return constrained;
    case LayoutMechanism.grid:
      final safeGridSize = math.max(1.0, gridSize);

      return Size(
        (constrained.width / safeGridSize).round() * safeGridSize,
        (constrained.height / safeGridSize).round() * safeGridSize,
      );
    case LayoutMechanism.tabularColumns:
      final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
      if (trackWidth <= 0) return constrained;

      final columnSpan =
          ((constrained.width + config.tabularColumnGap) / trackWidth)
              .round()
              .clamp(1, config.tabularColumnCount)
              .toInt();
      final rowHeight = math.max(1.0, config.tabularRowHeight);
      final rowSpan = math.max(1, (constrained.height / rowHeight).round());

      return Size(
        columnSpan * config.tabularColumnWidth +
            math.max(0, columnSpan - 1) * config.tabularColumnGap,
        rowSpan * rowHeight,
      );
    case LayoutMechanism.autoGrid:
      final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
      if (trackWidth <= 0) return constrained;

      final columnSpan =
          ((constrained.width + config.autoGridGap) / trackWidth)
              .round()
              .clamp(1, config.autoGridColumnCount)
              .toInt();
      final rowTrackHeight =
          math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
      final rowSpan = math.max(
        1,
        ((constrained.height + config.autoGridGap) / rowTrackHeight).round(),
      );

      return Size(
        columnSpan * config.autoGridColumnWidth +
            math.max(0, columnSpan - 1) * config.autoGridGap,
        rowSpan * math.max(24.0, config.autoGridRowHeight) +
            math.max(0, rowSpan - 1) * config.autoGridGap,
      );
  }
}

String? _layoutRuleMetricsLabel(ComponentData component, LayoutConfig config) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.tabularColumns:
      final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
      if (trackWidth <= 0) return null;

      final rowHeight = math.max(1.0, config.tabularRowHeight);
      final column = _trackIndex(
        component.position.dx,
        trackWidth,
        maxIndex: config.tabularColumnCount,
      );
      final row = _trackIndex(component.position.dy, rowHeight);
      final columnSpan =
          ((component.size.width + config.tabularColumnGap) / trackWidth)
              .round()
              .clamp(1, config.tabularColumnCount)
              .toInt();
      final rowSpan = math.max(1, (component.size.height / rowHeight).round());

      return 'C$column R$row ${columnSpan}x$rowSpan';
    case LayoutMechanism.autoGrid:
      final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
      if (trackWidth <= 0) return null;

      final rowTrackHeight =
          math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
      final column = _trackIndex(
        component.position.dx,
        trackWidth,
        maxIndex: config.autoGridColumnCount,
      );
      final row = _trackIndex(component.position.dy, rowTrackHeight);
      final columnSpan =
          ((component.size.width + config.autoGridGap) / trackWidth)
              .round()
              .clamp(1, config.autoGridColumnCount)
              .toInt();
      final rowSpan = math.max(
        1,
        ((component.size.height + config.autoGridGap) / rowTrackHeight).round(),
      );

      return 'C$column R$row ${columnSpan}x$rowSpan';
    case LayoutMechanism.freeform:
    case LayoutMechanism.grid:
      return null;
  }
}

int _trackIndex(double value, double trackSize, {int? maxIndex}) {
  if (trackSize <= 0) return 1;

  final index = math.max(1, (value / trackSize).round() + 1);
  if (maxIndex == null) return index;

  return index.clamp(1, maxIndex).toInt();
}

class _AutoGridConflictSummary {
  final int cellCount;
  final List<String> componentNames;

  const _AutoGridConflictSummary({
    required this.cellCount,
    required this.componentNames,
  });

  String get compactNameLabel {
    if (componentNames.isEmpty) return '';
    if (componentNames.length <= 2) return componentNames.join(', ');

    return '${componentNames.take(2).join(', ')} +${componentNames.length - 2}';
  }

  String get tooltipLabel {
    final cellLabel =
        cellCount == 1
            ? '1 Auto Grid cell overlaps'
            : '$cellCount Auto Grid cells overlap';
    if (componentNames.isEmpty) return cellLabel;

    return '$cellLabel: ${componentNames.join(', ')}';
  }
}

class _AutoGridConflictPlacement {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;

  const _AutoGridConflictPlacement({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
  });
}

class _AutoGridConflictCellKey {
  final int column;
  final int row;

  const _AutoGridConflictCellKey({required this.column, required this.row});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _AutoGridConflictCellKey &&
            other.column == column &&
            other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);
}

class _AutoGridConflictCellDraft {
  final Set<String> groupKeys = <String>{};
  final Set<String> selectedGroupKeys = <String>{};
}

_AutoGridConflictSummary? _autoGridSelectionConflictSummary(
  List<ComponentData> components,
  Set<String> selectedIds,
  LayoutConfig config,
) {
  if (config.layoutMechanism != LayoutMechanism.autoGrid ||
      selectedIds.isEmpty) {
    return null;
  }

  final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  if (trackWidth <= 0 || rowTrackHeight <= 0) return null;

  final drafts = <_AutoGridConflictCellKey, _AutoGridConflictCellDraft>{};
  final groupNames = <String, String>{};
  for (final component in components) {
    if (!component.isVisible) continue;

    final placement = _autoGridConflictPlacementFor(
      component,
      config,
      columnCount,
      trackWidth,
      rowTrackHeight,
    );
    final groupKey = component.properties.parentId ?? component.id;
    final isSelected = selectedIds.contains(component.id);
    groupNames.putIfAbsent(groupKey, () => _componentDisplayName(component));

    for (
      var row = placement.row;
      row < placement.row + placement.rowSpan;
      row++
    ) {
      if (row < 0 || row * rowTrackHeight >= config.canvasHeight) continue;

      for (
        var column = placement.column;
        column < placement.column + placement.columnSpan;
        column++
      ) {
        if (column < 0 || column >= columnCount) continue;

        final key = _AutoGridConflictCellKey(column: column, row: row);
        final draft = drafts.putIfAbsent(
          key,
          () => _AutoGridConflictCellDraft(),
        );
        draft.groupKeys.add(groupKey);
        if (isSelected) draft.selectedGroupKeys.add(groupKey);
      }
    }
  }

  final conflictCellCount =
      drafts.values.where((draft) {
        return draft.selectedGroupKeys.isNotEmpty && draft.groupKeys.length > 1;
      }).length;
  final conflictGroupKeys = <String>{};
  for (final draft in drafts.values) {
    if (draft.selectedGroupKeys.isNotEmpty && draft.groupKeys.length > 1) {
      conflictGroupKeys.addAll(draft.groupKeys);
    }
  }
  final componentNames =
      conflictGroupKeys
          .map((groupKey) => groupNames[groupKey])
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

  return conflictCellCount == 0
      ? null
      : _AutoGridConflictSummary(
        cellCount: conflictCellCount,
        componentNames: componentNames,
      );
}

_AutoGridConflictPlacement _autoGridConflictPlacementFor(
  ComponentData component,
  LayoutConfig config,
  int columnCount,
  double trackWidth,
  double rowTrackHeight,
) {
  final column =
      (component.position.dx / trackWidth)
          .round()
          .clamp(0, columnCount - 1)
          .toInt();
  final row = math.max(0, (component.position.dy / rowTrackHeight).round());
  final columnSpan =
      ((component.size.width + config.autoGridGap) / trackWidth)
          .round()
          .clamp(1, columnCount)
          .toInt();
  final rowSpan = math.max(
    1,
    ((component.size.height + config.autoGridGap) / rowTrackHeight).round(),
  );

  return _AutoGridConflictPlacement(
    column: column,
    row: row,
    columnSpan: math.min(columnSpan, columnCount - column),
    rowSpan: rowSpan,
  );
}

bool _canMoveSelectionToOrigin(List<ComponentData> components) {
  final movableComponents =
      components.where((component) => !component.isLocked).toList();
  if (movableComponents.isEmpty) return false;

  return _componentBounds(movableComponents).topLeft.distance >= 0.01;
}

IconData _copyFormatIcon(LayoutBoundsCopyFormat format) {
  return switch (format) {
    LayoutBoundsCopyFormat.text => Icons.notes,
    LayoutBoundsCopyFormat.json => Icons.data_object,
    LayoutBoundsCopyFormat.flutterRect => Icons.widgets_outlined,
    LayoutBoundsCopyFormat.css => Icons.style_outlined,
  };
}

class _SelectionEdgeDistanceGuides extends StatelessWidget {
  static const _labelWidth = 58.0;
  static const _labelHeight = 22.0;
  static const _gap = 6.0;

  final List<ComponentData> components;
  final Size canvasSize;

  const _SelectionEdgeDistanceGuides({
    required this.components,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return const SizedBox.shrink();

    final bounds = _componentBounds(visibleComponents);
    final topDistance = bounds.top.round();
    final rightDistance = (canvasSize.width - bounds.right).round();
    final bottomDistance = (canvasSize.height - bounds.bottom).round();
    final leftDistance = bounds.left.round();
    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy;

    return IgnorePointer(
      child: Stack(
        children: [
          _EdgeDistanceBadge(
            label: 'T ${_distanceLabel(topDistance)}',
            tooltip: _distanceTooltip(topDistance, 'top'),
            left: _clampCanvasX(centerX - _labelWidth / 2),
            top: _topLabelY(bounds),
          ),
          _EdgeDistanceBadge(
            label: 'R ${_distanceLabel(rightDistance)}',
            tooltip: _distanceTooltip(rightDistance, 'right'),
            left: _rightLabelX(bounds),
            top: _clampCanvasY(centerY - _labelHeight / 2),
          ),
          _EdgeDistanceBadge(
            label: 'B ${_distanceLabel(bottomDistance)}',
            tooltip: _distanceTooltip(bottomDistance, 'bottom'),
            left: _clampCanvasX(centerX - _labelWidth / 2),
            top: _bottomLabelY(bounds),
          ),
          _EdgeDistanceBadge(
            label: 'L ${_distanceLabel(leftDistance)}',
            tooltip: _distanceTooltip(leftDistance, 'left'),
            left: _leftLabelX(bounds),
            top: _clampCanvasY(centerY - _labelHeight / 2),
          ),
        ],
      ),
    );
  }

  double _topLabelY(Rect bounds) {
    final preferred = bounds.top - _labelHeight - _gap;
    if (preferred >= 0) return preferred;
    return _clampCanvasY(bounds.top + _gap);
  }

  double _bottomLabelY(Rect bounds) {
    final preferred = bounds.bottom + _gap;
    if (preferred + _labelHeight <= canvasSize.height) return preferred;
    return _clampCanvasY(bounds.bottom - _labelHeight - _gap);
  }

  double _leftLabelX(Rect bounds) {
    final preferred = bounds.left - _labelWidth - _gap;
    if (preferred >= 0) return preferred;
    return _clampCanvasX(bounds.left + _gap);
  }

  double _rightLabelX(Rect bounds) {
    final preferred = bounds.right + _gap;
    if (preferred + _labelWidth <= canvasSize.width) return preferred;
    return _clampCanvasX(bounds.right - _labelWidth - _gap);
  }

  double _clampCanvasX(double x) {
    return x.clamp(0.0, math.max(0.0, canvasSize.width - _labelWidth));
  }

  double _clampCanvasY(double y) {
    return y.clamp(0.0, math.max(0.0, canvasSize.height - _labelHeight));
  }

  String _distanceLabel(int distance) => '${distance}px';

  String _distanceTooltip(int distance, String edge) {
    if (distance >= 0) return '$distance px from $edge edge';
    return '${distance.abs()} px outside $edge edge';
  }
}

class _EdgeDistanceBadge extends StatelessWidget {
  final String label;
  final String tooltip;
  final double left;
  final double top;

  const _EdgeDistanceBadge({
    required this.label,
    required this.tooltip,
    required this.left,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: left,
      top: top,
      child: Tooltip(
        message: tooltip,
        child: Material(
          elevation: 2,
          color: colorScheme.secondaryContainer.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: _SelectionEdgeDistanceGuides._labelWidth,
            height: _SelectionEdgeDistanceGuides._labelHeight,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionCenterOffsetGuide extends StatelessWidget {
  static const _badgeWidth = 118.0;
  static const _badgeHeight = 22.0;
  static const _gap = 10.0;

  final List<ComponentData> components;
  final Size canvasSize;

  const _SelectionCenterOffsetGuide({
    required this.components,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return const SizedBox.shrink();

    final bounds = _componentBounds(visibleComponents);
    final canvasCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final selectionCenter = bounds.center;
    final delta = selectionCenter - canvasCenter;
    final roundedDx = delta.dx.round();
    final roundedDy = delta.dy.round();
    final isCentered = roundedDx == 0 && roundedDy == 0;
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CenterOffsetPainter(
                canvasSize: canvasSize,
                canvasCenter: canvasCenter,
                selectionCenter: selectionCenter,
                lineColor: colorScheme.tertiary,
                isCentered: isCentered,
              ),
            ),
          ),
          Positioned(
            left: _centerBadgeX(selectionCenter.dx),
            top: _centerBadgeY(selectionCenter.dy),
            child: _CenterOffsetBadge(
              label:
                  isCentered
                      ? 'Centered'
                      : 'DX ${_signedPixels(roundedDx)}  DY ${_signedPixels(roundedDy)}',
              tooltip:
                  isCentered
                      ? 'Selection center matches canvas center'
                      : 'Selection center offset from canvas center',
            ),
          ),
        ],
      ),
    );
  }

  double _centerBadgeX(double centerX) {
    final preferred = centerX + _gap;
    if (preferred + _badgeWidth <= canvasSize.width) return preferred;
    return (centerX - _badgeWidth - _gap).clamp(
      0.0,
      math.max(0.0, canvasSize.width - _badgeWidth),
    );
  }

  double _centerBadgeY(double centerY) {
    final preferred = centerY + _gap;
    if (preferred + _badgeHeight <= canvasSize.height) return preferred;
    return (centerY - _badgeHeight - _gap).clamp(
      0.0,
      math.max(0.0, canvasSize.height - _badgeHeight),
    );
  }

  String _signedPixels(int value) {
    if (value > 0) return '+${value}px';
    return '${value}px';
  }
}

class _CenterOffsetBadge extends StatelessWidget {
  final String label;
  final String tooltip;

  const _CenterOffsetBadge({required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 2,
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: _SelectionCenterOffsetGuide._badgeWidth,
          height: _SelectionCenterOffsetGuide._badgeHeight,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterOffsetPainter extends CustomPainter {
  final Size canvasSize;
  final Offset canvasCenter;
  final Offset selectionCenter;
  final Color lineColor;
  final bool isCentered;

  const _CenterOffsetPainter({
    required this.canvasSize,
    required this.canvasCenter,
    required this.selectionCenter,
    required this.lineColor,
    required this.isCentered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerLinePaint =
        Paint()
          ..color = lineColor.withValues(alpha: 0.22)
          ..strokeWidth = 1;
    final offsetPaint =
        Paint()
          ..color = lineColor.withValues(alpha: 0.72)
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;
    final pointPaint =
        Paint()
          ..color = lineColor.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;

    _drawDashedLine(
      canvas,
      Offset(canvasCenter.dx, 0),
      Offset(canvasCenter.dx, canvasSize.height),
      centerLinePaint,
      dash: 7,
      gap: 6,
    );
    _drawDashedLine(
      canvas,
      Offset(0, canvasCenter.dy),
      Offset(canvasSize.width, canvasCenter.dy),
      centerLinePaint,
      dash: 7,
      gap: 6,
    );

    if (!isCentered) {
      final elbow = Offset(canvasCenter.dx, selectionCenter.dy);
      _drawDashedLine(canvas, selectionCenter, elbow, offsetPaint);
      _drawDashedLine(canvas, elbow, canvasCenter, offsetPaint);
    }

    canvas.drawCircle(canvasCenter, 3.5, pointPaint);
    canvas.drawCircle(selectionCenter, 3.5, pointPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = 8,
    double gap = 5,
  }) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;

    final direction = delta / distance;
    var drawn = 0.0;
    while (drawn < distance) {
      final segmentStart = start + direction * drawn;
      final segmentEnd = start + direction * math.min(drawn + dash, distance);
      canvas.drawLine(segmentStart, segmentEnd, paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _CenterOffsetPainter oldDelegate) {
    return oldDelegate.canvasSize != canvasSize ||
        oldDelegate.canvasCenter != canvasCenter ||
        oldDelegate.selectionCenter != selectionCenter ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.isCentered != isCentered;
  }
}

class _MultiSelectionOutline extends StatelessWidget {
  final List<ComponentData> components;

  const _MultiSelectionOutline({required this.components});

  @override
  Widget build(BuildContext context) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.length < 2) return const SizedBox.shrink();

    final bounds = _componentBounds(visibleComponents).inflate(6);
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fromRect(
      rect: bounds,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MultiSelectionOutlinePainter(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: _SelectionBoundsBadge(
              count: visibleComponents.length,
              components: visibleComponents,
              bounds: bounds.deflate(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBoundsBadge extends StatelessWidget {
  final int count;
  final List<ComponentData> components;
  final Rect bounds;

  const _SelectionBoundsBadge({
    required this.count,
    required this.components,
    required this.bounds,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Copy bounds',
      child: Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => copyLayoutSelectionBounds(context, components),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '$count selected - ${layoutBoundsLabel(bounds, compact: true)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiSelectionOutlinePainter extends CustomPainter {
  final Color color;

  _MultiSelectionOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outlinePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    final cornerPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    _drawDashedRect(canvas, rect.deflate(0.75), outlinePaint);
    _drawCornerHandle(canvas, rect.topLeft, cornerPaint);
    _drawCornerHandle(canvas, rect.topRight, cornerPaint);
    _drawCornerHandle(canvas, rect.bottomRight, cornerPaint);
    _drawCornerHandle(canvas, rect.bottomLeft, cornerPaint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint);
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint);
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 8.0;
    const gap = 5.0;
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;

    final direction = delta / distance;
    var drawn = 0.0;

    while (drawn < distance) {
      final segmentStart = start + direction * drawn;
      final segmentEnd = start + direction * math.min(drawn + dash, distance);
      canvas.drawLine(segmentStart, segmentEnd, paint);
      drawn += dash + gap;
    }
  }

  void _drawCornerHandle(Canvas canvas, Offset anchor, Paint paint) {
    const size = 7.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: anchor, width: size, height: size),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MultiSelectionOutlinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

Rect _componentBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    left = math.min(left, component.position.dx);
    top = math.min(top, component.position.dy);
    right = math.max(right, component.position.dx + component.size.width);
    bottom = math.max(bottom, component.position.dy + component.size.height);
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

String _componentDisplayName(ComponentData component) {
  final attributes = component.properties.attributes;
  final name = attributes['name'] ?? attributes['label'] ?? attributes['text'];
  final label = name?.toString().trim();

  return label == null || label.isEmpty ? component.type.label : label;
}
