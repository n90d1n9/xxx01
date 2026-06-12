import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_canvas_containment_action_service.dart';
import '../services/layout_canvas_placement_action_service.dart';
import '../services/layout_canvas_size_action_service.dart';
import '../services/layout_canvas_view_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';
import 'device_preview_toggle.dart';
import 'dialog_utils.dart';
import 'editor_command_palette.dart';

class EditorToolbar extends ConsumerWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final viewportState = ref.watch(canvasViewportProvider);
    final previewState = ref.watch(responsivePreviewProvider);
    final selected = layoutState.selectedComponent;
    final selectedComponents = layoutState.selectedComponents;
    final componentCount = layoutState.components.length;
    final visibleCount =
        layoutState.components.where((component) => component.isVisible).length;
    final hiddenCount = componentCount - visibleCount;
    final lockedCount =
        layoutState.components.where((component) => component.isLocked).length;
    final unlockedCount = componentCount - lockedCount;
    final selectionCount = selectedComponents.length;
    final clipboardCount = layoutState.clipboard.length;
    final hasSelection = selectionCount > 0;
    final hasMultiSelection = selectionCount > 1;
    final isSingleGroupSelection = _isSingleGroupSelection(selectedComponents);
    final gridGap = layoutState.gridSettings.gridSize.toDouble();
    final notifier = ref.read(layoutStateProvider.notifier);
    final previewNotifier = ref.read(responsivePreviewProvider.notifier);
    final isAutoGrid =
        layoutState.config.layoutMechanism == LayoutMechanism.autoGrid;
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: hasSelection,
      preview: notifier.selectedConflictResolutionPreview(),
    );
    final autoGridConflictCount =
        isAutoGrid ? notifier.visibleAutoGridConflictComponentIds().length : 0;
    final autoGridMovableVisibleCount =
        isAutoGrid
            ? layoutState.components
                .where(
                  (component) => component.isVisible && !component.isLocked,
                )
                .length
            : 0;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: SizedBox(
        height: 56,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final showFullFileActions = width >= 1500;
            final showFullCanvasActions = width >= 1250;
            final showCoordinates = width >= 1040;
            final showFullSelectionActions = width >= 2200;
            final showSelectionQuickActions = width >= 1120;
            final showSelectionBadge = width >= 1350;
            final showPreviewButtons = width >= 980;
            final showDevicePreview = width >= 1180;
            final scrollFallback = width < 1720;

            final toolbar = Row(
              mainAxisSize:
                  scrollFallback ? MainAxisSize.min : MainAxisSize.max,
              children: [
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.save_outlined,
                  tooltip: 'Save layout',
                  onPressed: notifier.saveLayout,
                ),
                if (showFullFileActions) ...[
                  _ToolbarButton(
                    icon: Icons.save_as_outlined,
                    tooltip: 'Save as template',
                    onPressed: () => showSaveTemplateDialog(context, ref),
                  ),
                  _ToolbarButton(
                    icon: Icons.folder_open,
                    tooltip: 'Load template',
                    onPressed: () => showLoadTemplateDialog(context, ref),
                  ),
                  _LayoutTransferMenu(ref: ref),
                ] else
                  _FileActionsMenu(ref: ref),
                _ToolbarButton(
                  icon: Icons.manage_search,
                  tooltip: 'Command palette',
                  onPressed: () => showEditorCommandPalette(context, ref),
                ),
                const VerticalDivider(),
                _ToolbarButton(
                  icon: Icons.undo,
                  tooltip: 'Undo',
                  onPressed: layoutState.canUndo ? notifier.undo : null,
                ),
                _ToolbarButton(
                  icon: Icons.redo,
                  tooltip: 'Redo',
                  onPressed: layoutState.canRedo ? notifier.redo : null,
                ),
                const VerticalDivider(),
                _LayoutMechanismMenu(
                  current: layoutState.config.layoutMechanism,
                  onSelected: notifier.updateLayoutMechanism,
                  onConvert: notifier.convertLayoutMechanism,
                ),
                if (showFullCanvasActions) ...[
                  _ToolbarButton(
                    icon:
                        layoutState.gridSettings.enabled
                            ? Icons.grid_on
                            : Icons.grid_off,
                    tooltip: 'Toggle grid',
                    selected: layoutState.gridSettings.enabled,
                    onPressed: notifier.toggleGrid,
                  ),
                  _ToolbarButton(
                    icon: Icons.grid_4x4,
                    tooltip: 'Toggle snap',
                    selected: layoutState.gridSettings.snapToGrid,
                    onPressed: notifier.toggleSnapToGrid,
                  ),
                  _ToolbarButton(
                    icon: Icons.tune,
                    tooltip: 'Layout rules',
                    onPressed: () => showGridSettingsDialog(context, ref),
                  ),
                  _CanvasSizeMenu(
                    currentSize: layoutState.config.canvasSize,
                    canFitContent: visibleCount > 0,
                    canFitSelection: selectedComponents.any(
                      (component) => component.isVisible,
                    ),
                    onSelected: notifier.updateCanvasSize,
                    onCustom: () => showCanvasSizeDialog(context, ref),
                    onRotate:
                        () => layoutCanvasSizeActionService.rotateCanvasSize(
                          context,
                          ref,
                        ),
                    onFitContent:
                        () => layoutCanvasSizeActionService.fitCanvasToContent(
                          context,
                          ref,
                        ),
                    onTrimContent:
                        () => layoutCanvasSizeActionService.trimCanvasToContent(
                          context,
                          ref,
                        ),
                    onFitSelection:
                        () => layoutCanvasSizeActionService
                            .fitCanvasToSelection(context, ref),
                  ),
                  _ToolbarButton(
                    icon: Icons.straighten,
                    tooltip: 'Toggle precision guides',
                    selected: viewportState.showPrecisionGuides,
                    onPressed:
                        () => layoutCanvasViewActionService
                            .togglePrecisionGuides(context, ref),
                  ),
                  if (isAutoGrid) ...[
                    _ToolbarButton(
                      icon: Icons.dashboard_customize_outlined,
                      tooltip: 'Toggle Auto Grid occupancy',
                      selected: viewportState.showAutoGridOccupancy,
                      onPressed:
                          () => layoutCanvasViewActionService
                              .toggleAutoGridOccupancy(context, ref),
                    ),
                    _ToolbarButton(
                      icon: Icons.auto_fix_high_outlined,
                      tooltip: _autoGridConflictActionTooltip(
                        autoGridConflictCount,
                      ),
                      onPressed:
                          autoGridConflictCount > 0
                              ? () => layoutAutoGridActionService
                                  .resolveVisibleConflicts(context, ref)
                              : null,
                    ),
                    _ToolbarButton(
                      icon: Icons.view_module_outlined,
                      tooltip: _autoGridCompactActionTooltip(
                        autoGridMovableVisibleCount,
                      ),
                      onPressed:
                          autoGridMovableVisibleCount > 0
                              ? () => layoutAutoGridActionService
                                  .compactVisible(context, ref)
                              : null,
                    ),
                  ],
                ] else ...[
                  _CanvasActionsMenu(
                    gridEnabled: layoutState.gridSettings.enabled,
                    snapEnabled: layoutState.gridSettings.snapToGrid,
                    precisionGuidesEnabled: viewportState.showPrecisionGuides,
                    showAutoGridOccupancyAction: isAutoGrid,
                    autoGridOccupancyEnabled:
                        viewportState.showAutoGridOccupancy,
                    autoGridConflictCount: autoGridConflictCount,
                    autoGridMovableVisibleCount: autoGridMovableVisibleCount,
                    onSelected: (action) {
                      switch (action) {
                        case _CanvasToolbarAction.toggleGrid:
                          notifier.toggleGrid();
                          break;
                        case _CanvasToolbarAction.toggleSnap:
                          notifier.toggleSnapToGrid();
                          break;
                        case _CanvasToolbarAction.gridSettings:
                          showGridSettingsDialog(context, ref);
                          break;
                        case _CanvasToolbarAction.togglePrecisionGuides:
                          layoutCanvasViewActionService.togglePrecisionGuides(
                            context,
                            ref,
                          );
                          break;
                        case _CanvasToolbarAction.toggleAutoGridOccupancy:
                          layoutCanvasViewActionService.toggleAutoGridOccupancy(
                            context,
                            ref,
                          );
                          break;
                        case _CanvasToolbarAction.resolveAutoGridConflicts:
                          layoutAutoGridActionService.resolveVisibleConflicts(
                            context,
                            ref,
                          );
                          break;
                        case _CanvasToolbarAction.compactAutoGrid:
                          layoutAutoGridActionService.compactVisible(
                            context,
                            ref,
                          );
                          break;
                      }
                    },
                  ),
                  _CanvasSizeMenu(
                    currentSize: layoutState.config.canvasSize,
                    canFitContent: visibleCount > 0,
                    canFitSelection: selectedComponents.any(
                      (component) => component.isVisible,
                    ),
                    onSelected: notifier.updateCanvasSize,
                    onCustom: () => showCanvasSizeDialog(context, ref),
                    onRotate:
                        () => layoutCanvasSizeActionService.rotateCanvasSize(
                          context,
                          ref,
                        ),
                    onFitContent:
                        () => layoutCanvasSizeActionService.fitCanvasToContent(
                          context,
                          ref,
                        ),
                    onTrimContent:
                        () => layoutCanvasSizeActionService.trimCanvasToContent(
                          context,
                          ref,
                        ),
                    onFitSelection:
                        () => layoutCanvasSizeActionService
                            .fitCanvasToSelection(context, ref),
                  ),
                ],
                _ToolbarZoomMenu(
                  viewportState: viewportState,
                  hasSelection: hasSelection,
                  onSelected: (action) {
                    if (action is double) {
                      layoutCanvasViewActionService.setZoom(
                        context,
                        ref,
                        action,
                        rememberRecent: true,
                      );
                      return;
                    }

                    if (action is! _ToolbarZoomAction) return;

                    final presetZoom = _zoomPresetForToolbarAction(action);
                    if (presetZoom != null) {
                      layoutCanvasViewActionService.setZoom(
                        context,
                        ref,
                        presetZoom,
                      );
                      return;
                    }

                    switch (action) {
                      case _ToolbarZoomAction.zoomOut:
                        layoutCanvasViewActionService.zoomOut(context, ref);
                        break;
                      case _ToolbarZoomAction.zoomIn:
                        layoutCanvasViewActionService.zoomIn(context, ref);
                        break;
                      case _ToolbarZoomAction.reset:
                        layoutCanvasViewActionService.resetZoom(context, ref);
                        break;
                      case _ToolbarZoomAction.custom:
                        showCanvasZoomDialog(context, ref);
                        break;
                      case _ToolbarZoomAction.clearRecent:
                        layoutCanvasViewActionService.clearRecentZooms(context);
                        break;
                      case _ToolbarZoomAction.fitCanvas:
                        layoutCanvasViewActionService.fitCanvas(context, ref);
                        break;
                      case _ToolbarZoomAction.fitSelection:
                        layoutCanvasViewActionService.fitSelection(
                          context,
                          ref,
                        );
                        break;
                      case _ToolbarZoomAction.zoom50:
                      case _ToolbarZoomAction.zoom75:
                      case _ToolbarZoomAction.zoom100:
                      case _ToolbarZoomAction.zoom125:
                      case _ToolbarZoomAction.zoom150:
                      case _ToolbarZoomAction.zoom200:
                        break;
                    }
                  },
                ),
                if (showCoordinates)
                  _ToolbarCoordinateReadout(
                    position: viewportState.pointerCanvasPosition,
                  ),
                const VerticalDivider(),
                if (showFullSelectionActions) ...[
                  _ToolbarButton(
                    icon: Icons.content_copy,
                    tooltip:
                        selectionCount > 1
                            ? 'Copy selection'
                            : 'Copy component',
                    onPressed:
                        selected == null
                            ? null
                            : notifier.copySelectedComponent,
                  ),
                  _ToolbarButton(
                    icon: Icons.content_paste,
                    tooltip:
                        clipboardCount > 1
                            ? 'Paste $clipboardCount components'
                            : 'Paste',
                    onPressed:
                        clipboardCount == 0 ? null : () => _pasteAtCursor(ref),
                  ),
                  _ToolbarButton(
                    icon: Icons.control_point_duplicate,
                    tooltip: 'Duplicate',
                    onPressed:
                        hasSelection
                            ? notifier.duplicateSelectedComponent
                            : null,
                  ),
                  _ToolbarButton(
                    icon: Icons.grid_4x4,
                    tooltip: 'Snap selection to layout rules',
                    onPressed:
                        hasSelection
                            ? () => layoutSelectionGeometryActionService
                                .snapSelectionToLayoutRules(context, ref)
                            : null,
                  ),
                  _ToolbarButton(
                    icon: Icons.aspect_ratio,
                    tooltip: 'Snap selection size to layout rules',
                    onPressed:
                        hasSelection
                            ? () => layoutSelectionGeometryActionService
                                .snapSelectionSizeToLayoutRules(context, ref)
                            : null,
                  ),
                  _ToolbarButton(
                    icon: Icons.near_me_outlined,
                    tooltip: clearSpotAction.moveTooltipLabel(),
                    onPressed:
                        clearSpotAction.isAvailable
                            ? () => layoutClearSpotActionService
                                .moveSelectionToClearSpot(context, ref)
                            : null,
                  ),
                  _SelectionFilterMenu(
                    componentCount: componentCount,
                    visibleCount: visibleCount,
                    hiddenCount: hiddenCount,
                    lockedCount: lockedCount,
                    unlockedCount: unlockedCount,
                    hasSelection: hasSelection,
                    onSelected: (action) {
                      switch (action) {
                        case _SelectionFilterAction.selectAll:
                          notifier.selectAllComponents();
                          break;
                        case _SelectionFilterAction.invertSelection:
                          notifier.invertSelection();
                          break;
                        case _SelectionFilterAction.selectVisible:
                          notifier.selectComponentsByVisibility(true);
                          break;
                        case _SelectionFilterAction.selectHidden:
                          notifier.selectComponentsByVisibility(false);
                          break;
                        case _SelectionFilterAction.selectLocked:
                          notifier.selectComponentsByLockState(true);
                          break;
                        case _SelectionFilterAction.selectUnlocked:
                          notifier.selectComponentsByLockState(false);
                          break;
                        case _SelectionFilterAction.clearSelection:
                          notifier.clearSelection();
                          break;
                      }
                    },
                  ),
                  _ToolbarButton(
                    icon:
                        isSingleGroupSelection
                            ? Icons.call_split_outlined
                            : Icons.group_work_outlined,
                    tooltip:
                        isSingleGroupSelection
                            ? 'Ungroup selection'
                            : 'Group selection',
                    onPressed:
                        !hasMultiSelection
                            ? null
                            : isSingleGroupSelection
                            ? notifier.ungroupSelectedComponents
                            : notifier.groupSelectedComponents,
                  ),
                  _ToolbarButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete',
                    onPressed:
                        hasSelection ? notifier.removeSelectedComponent : null,
                  ),
                  const VerticalDivider(),
                  _ToolbarButton(
                    icon:
                        selected?.isLocked == true
                            ? Icons.lock
                            : Icons.lock_open_outlined,
                    tooltip: 'Lock component',
                    selected: selected?.isLocked == true,
                    onPressed:
                        hasSelection
                            ? notifier.toggleSelectedComponentLock
                            : null,
                  ),
                  _ToolbarButton(
                    icon:
                        selected?.isVisible == false
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                    tooltip: 'Toggle visibility',
                    selected: selected?.isVisible == true,
                    onPressed:
                        hasSelection
                            ? notifier.toggleSelectedComponentVisibility
                            : null,
                  ),
                  _ArrangeMenu(
                    enabled: hasSelection,
                    onSelected: (action) {
                      switch (action) {
                        case _ArrangeAction.bringForward:
                          notifier.bringSelectedForward();
                          break;
                        case _ArrangeAction.bringToFront:
                          notifier.bringSelectedToFront();
                          break;
                        case _ArrangeAction.sendBackward:
                          notifier.sendSelectedBackward();
                          break;
                        case _ArrangeAction.sendToBack:
                          notifier.sendSelectedToBack();
                          break;
                      }
                    },
                  ),
                  _AlignmentMenu(
                    enabled: hasSelection,
                    onSelected:
                        (alignment) => layoutSelectionGeometryActionService
                            .alignSelection(context, ref, alignment),
                  ),
                  _CanvasPlacementMenu(
                    enabled: hasSelection,
                    onSelected: (action) {
                      switch (action) {
                        case _CanvasPlacementAction.origin:
                          layoutCanvasPlacementActionService
                              .moveSelectionToOrigin(context, ref);
                          break;
                        case _CanvasPlacementAction.topRight:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.topRight,
                              );
                          break;
                        case _CanvasPlacementAction.bottomLeft:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.bottomLeft,
                              );
                          break;
                        case _CanvasPlacementAction.bottomRight:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.bottomRight,
                              );
                          break;
                        case _CanvasPlacementAction.topEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.top,
                              );
                          break;
                        case _CanvasPlacementAction.rightEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.right,
                              );
                          break;
                        case _CanvasPlacementAction.bottomEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.bottom,
                              );
                          break;
                        case _CanvasPlacementAction.leftEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.left,
                              );
                          break;
                        case _CanvasPlacementAction.pinTop:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.top,
                          );
                          break;
                        case _CanvasPlacementAction.pinRight:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.right,
                          );
                          break;
                        case _CanvasPlacementAction.pinBottom:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.bottom,
                          );
                          break;
                        case _CanvasPlacementAction.pinLeft:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.left,
                          );
                          break;
                        case _CanvasPlacementAction.insideCanvas:
                          layoutCanvasContainmentActionService
                              .moveSelectionInsideCanvas(context, ref);
                          break;
                        case _CanvasPlacementAction.fitCanvas:
                          layoutCanvasContainmentActionService
                              .fitSelectionInsideCanvas(context, ref);
                          break;
                        case _CanvasPlacementAction.canvas:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(context, ref);
                          break;
                        case _CanvasPlacementAction.horizontal:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(
                                context,
                                ref,
                                vertical: false,
                              );
                          break;
                        case _CanvasPlacementAction.vertical:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(
                                context,
                                ref,
                                horizontal: false,
                              );
                          break;
                      }
                    },
                  ),
                  _MatchSizeMenu(
                    enabled: hasMultiSelection,
                    onSelected: (action) {
                      switch (action) {
                        case _MatchSizeAction.width:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(
                                context,
                                ref,
                                matchHeight: false,
                              );
                          break;
                        case _MatchSizeAction.height:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(
                                context,
                                ref,
                                matchWidth: false,
                              );
                          break;
                        case _MatchSizeAction.size:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(context, ref);
                          break;
                      }
                    },
                  ),
                  _StackMenu(
                    enabled: hasMultiSelection,
                    onSelected:
                        (direction) => layoutSelectionGeometryActionService
                            .stackSelection(context, ref, direction),
                  ),
                  _SpacingMenu(
                    enabled: hasMultiSelection,
                    gap: gridGap,
                    onSelected: (action) {
                      switch (action) {
                        case _SpacingAction.horizontalGrid:
                          layoutSelectionGeometryActionService.spaceSelection(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                            gridGap,
                          );
                          break;
                        case _SpacingAction.verticalGrid:
                          layoutSelectionGeometryActionService.spaceSelection(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                            gridGap,
                          );
                          break;
                        case _SpacingAction.horizontalCustom:
                          showSelectionSpacingDialog(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                          );
                          break;
                        case _SpacingAction.verticalCustom:
                          showSelectionSpacingDialog(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                          );
                          break;
                      }
                    },
                  ),
                  _DistributionMenu(
                    enabled: selectionCount > 2,
                    onSelected:
                        (direction) => layoutSelectionGeometryActionService
                            .distributeSelection(context, ref, direction),
                  ),
                ] else ...[
                  if (showSelectionQuickActions) ...[
                    _ToolbarButton(
                      icon: Icons.content_copy,
                      tooltip:
                          selectionCount > 1
                              ? 'Copy selection'
                              : 'Copy component',
                      onPressed:
                          selected == null
                              ? null
                              : notifier.copySelectedComponent,
                    ),
                    _ToolbarButton(
                      icon: Icons.content_paste,
                      tooltip:
                          clipboardCount > 1
                              ? 'Paste $clipboardCount components'
                              : 'Paste',
                      onPressed:
                          clipboardCount == 0
                              ? null
                              : () => _pasteAtCursor(ref),
                    ),
                    _ToolbarButton(
                      icon: Icons.control_point_duplicate,
                      tooltip: 'Duplicate',
                      onPressed:
                          hasSelection
                              ? notifier.duplicateSelectedComponent
                              : null,
                    ),
                  ],
                  _SelectionOverflowMenu(
                    componentCount: componentCount,
                    visibleCount: visibleCount,
                    hiddenCount: hiddenCount,
                    lockedCount: lockedCount,
                    unlockedCount: unlockedCount,
                    hasSelection: hasSelection,
                    hasClipboard: clipboardCount > 0,
                    hasMultiSelection: hasMultiSelection,
                    clearSpotAction: clearSpotAction,
                    canDistribute: selectionCount > 2,
                    isSingleGroupSelection: isSingleGroupSelection,
                    selectedLocked: selected?.isLocked == true,
                    selectedVisible: selected?.isVisible != false,
                    gridGap: gridGap,
                    onSelected: (action) {
                      switch (action) {
                        case _SelectionOverflowAction.copy:
                          notifier.copySelectedComponent();
                          break;
                        case _SelectionOverflowAction.paste:
                          _pasteAtCursor(ref);
                          break;
                        case _SelectionOverflowAction.duplicate:
                          notifier.duplicateSelectedComponent();
                          break;
                        case _SelectionOverflowAction.selectAll:
                          notifier.selectAllComponents();
                          break;
                        case _SelectionOverflowAction.invertSelection:
                          notifier.invertSelection();
                          break;
                        case _SelectionOverflowAction.selectVisible:
                          notifier.selectComponentsByVisibility(true);
                          break;
                        case _SelectionOverflowAction.selectHidden:
                          notifier.selectComponentsByVisibility(false);
                          break;
                        case _SelectionOverflowAction.selectLocked:
                          notifier.selectComponentsByLockState(true);
                          break;
                        case _SelectionOverflowAction.selectUnlocked:
                          notifier.selectComponentsByLockState(false);
                          break;
                        case _SelectionOverflowAction.clearSelection:
                          notifier.clearSelection();
                          break;
                        case _SelectionOverflowAction.snapToGrid:
                          layoutSelectionGeometryActionService
                              .snapSelectionToLayoutRules(context, ref);
                          break;
                        case _SelectionOverflowAction.snapSizeToGrid:
                          layoutSelectionGeometryActionService
                              .snapSelectionSizeToLayoutRules(context, ref);
                          break;
                        case _SelectionOverflowAction.moveToClearSpot:
                          layoutClearSpotActionService.moveSelectionToClearSpot(
                            context,
                            ref,
                          );
                          break;
                        case _SelectionOverflowAction.group:
                          notifier.groupSelectedComponents();
                          break;
                        case _SelectionOverflowAction.ungroup:
                          notifier.ungroupSelectedComponents();
                          break;
                        case _SelectionOverflowAction.delete:
                          notifier.removeSelectedComponent();
                          break;
                        case _SelectionOverflowAction.toggleLock:
                          notifier.toggleSelectedComponentLock();
                          break;
                        case _SelectionOverflowAction.toggleVisibility:
                          notifier.toggleSelectedComponentVisibility();
                          break;
                        case _SelectionOverflowAction.showOnlySelection:
                          notifier.showOnlySelectedComponents();
                          break;
                        case _SelectionOverflowAction.bringForward:
                          notifier.bringSelectedForward();
                          break;
                        case _SelectionOverflowAction.bringToFront:
                          notifier.bringSelectedToFront();
                          break;
                        case _SelectionOverflowAction.sendBackward:
                          notifier.sendSelectedBackward();
                          break;
                        case _SelectionOverflowAction.sendToBack:
                          notifier.sendSelectedToBack();
                          break;
                        case _SelectionOverflowAction.alignLeft:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.left,
                          );
                          break;
                        case _SelectionOverflowAction.alignCenter:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.center,
                          );
                          break;
                        case _SelectionOverflowAction.alignRight:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.right,
                          );
                          break;
                        case _SelectionOverflowAction.alignTop:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.top,
                          );
                          break;
                        case _SelectionOverflowAction.alignMiddle:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.middle,
                          );
                          break;
                        case _SelectionOverflowAction.alignBottom:
                          layoutSelectionGeometryActionService.alignSelection(
                            context,
                            ref,
                            ComponentAlignment.bottom,
                          );
                          break;
                        case _SelectionOverflowAction.moveToCanvasOrigin:
                          layoutCanvasPlacementActionService
                              .moveSelectionToOrigin(context, ref);
                          break;
                        case _SelectionOverflowAction.moveToCanvasTopRight:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.topRight,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasBottomLeft:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.bottomLeft,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasBottomRight:
                          layoutCanvasPlacementActionService
                              .moveSelectionToCorner(
                                context,
                                ref,
                                CanvasCorner.bottomRight,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasTopEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.top,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasRightEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.right,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasBottomEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.bottom,
                              );
                          break;
                        case _SelectionOverflowAction.moveToCanvasLeftEdge:
                          layoutCanvasPlacementActionService
                              .moveSelectionToEdge(
                                context,
                                ref,
                                CanvasEdge.left,
                              );
                          break;
                        case _SelectionOverflowAction.pinToCanvasTopEdge:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.top,
                          );
                          break;
                        case _SelectionOverflowAction.pinToCanvasRightEdge:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.right,
                          );
                          break;
                        case _SelectionOverflowAction.pinToCanvasBottomEdge:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.bottom,
                          );
                          break;
                        case _SelectionOverflowAction.pinToCanvasLeftEdge:
                          layoutCanvasPlacementActionService.pinSelectionToEdge(
                            context,
                            ref,
                            CanvasEdge.left,
                          );
                          break;
                        case _SelectionOverflowAction.moveInsideCanvas:
                          layoutCanvasContainmentActionService
                              .moveSelectionInsideCanvas(context, ref);
                          break;
                        case _SelectionOverflowAction.fitInsideCanvas:
                          layoutCanvasContainmentActionService
                              .fitSelectionInsideCanvas(context, ref);
                          break;
                        case _SelectionOverflowAction.centerOnCanvas:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(context, ref);
                          break;
                        case _SelectionOverflowAction.centerHorizontally:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(
                                context,
                                ref,
                                vertical: false,
                              );
                          break;
                        case _SelectionOverflowAction.centerVertically:
                          layoutCanvasPlacementActionService
                              .centerSelectionOnCanvas(
                                context,
                                ref,
                                horizontal: false,
                              );
                          break;
                        case _SelectionOverflowAction.matchWidth:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(
                                context,
                                ref,
                                matchHeight: false,
                              );
                          break;
                        case _SelectionOverflowAction.matchHeight:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(
                                context,
                                ref,
                                matchWidth: false,
                              );
                          break;
                        case _SelectionOverflowAction.matchSize:
                          layoutSelectionGeometryActionService
                              .matchSelectionSize(context, ref);
                          break;
                        case _SelectionOverflowAction.stackHorizontal:
                          layoutSelectionGeometryActionService.stackSelection(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                          );
                          break;
                        case _SelectionOverflowAction.stackVertical:
                          layoutSelectionGeometryActionService.stackSelection(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                          );
                          break;
                        case _SelectionOverflowAction.spaceHorizontal:
                          layoutSelectionGeometryActionService.spaceSelection(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                            gridGap,
                          );
                          break;
                        case _SelectionOverflowAction.spaceVertical:
                          layoutSelectionGeometryActionService.spaceSelection(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                            gridGap,
                          );
                          break;
                        case _SelectionOverflowAction.customSpaceHorizontal:
                          showSelectionSpacingDialog(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                          );
                          break;
                        case _SelectionOverflowAction.customSpaceVertical:
                          showSelectionSpacingDialog(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                          );
                          break;
                        case _SelectionOverflowAction.distributeHorizontally:
                          layoutSelectionGeometryActionService
                              .distributeSelection(
                                context,
                                ref,
                                ComponentDistribution.horizontal,
                              );
                          break;
                        case _SelectionOverflowAction.distributeVertically:
                          layoutSelectionGeometryActionService
                              .distributeSelection(
                                context,
                                ref,
                                ComponentDistribution.vertical,
                              );
                          break;
                      }
                    },
                  ),
                ],
                if (selectionCount > 1 && showSelectionBadge) ...[
                  const SizedBox(width: 8),
                  _SelectionCountBadge(count: selectionCount),
                ],
                if (scrollFallback)
                  const SizedBox(width: 8)
                else
                  const Spacer(),
                if (showPreviewButtons) ...[
                  _ToolbarButton(
                    icon:
                        previewState.isPreviewMode
                            ? Icons.edit_outlined
                            : Icons.preview_outlined,
                    tooltip:
                        previewState.isPreviewMode
                            ? 'Edit canvas'
                            : 'Preview layout',
                    selected: previewState.isPreviewMode,
                    onPressed: previewNotifier.togglePreviewMode,
                  ),
                  _ToolbarButton(
                    icon: Icons.splitscreen_outlined,
                    tooltip: 'Toggle breakpoints',
                    selected: previewState.showBreakpoints,
                    onPressed:
                        previewState.isPreviewMode
                            ? previewNotifier.toggleBreakpoints
                            : null,
                  ),
                  if (showDevicePreview)
                    const DevicePreviewToggle()
                  else
                    _PreviewActionsMenu(
                      previewState: previewState,
                      onSelected: (action) {
                        switch (action) {
                          case _PreviewToolbarAction.toggleMode:
                            previewNotifier.togglePreviewMode();
                            break;
                          case _PreviewToolbarAction.toggleBreakpoints:
                            previewNotifier.toggleBreakpoints();
                            break;
                          case _PreviewToolbarAction.desktop:
                            previewNotifier.setDevice(DeviceType.desktop);
                            break;
                          case _PreviewToolbarAction.tablet:
                            previewNotifier.setDevice(DeviceType.tablet);
                            break;
                          case _PreviewToolbarAction.mobile:
                            previewNotifier.setDevice(DeviceType.mobile);
                            break;
                          case _PreviewToolbarAction.custom:
                            showCustomPreviewSizeDialog(context, ref);
                            break;
                          case _PreviewToolbarAction.rotate:
                            rememberRotatedPreviewSize(previewState);
                            previewNotifier.rotateCurrentSize();
                            break;
                        }
                      },
                    ),
                ] else
                  _PreviewActionsMenu(
                    previewState: previewState,
                    onSelected: (action) {
                      switch (action) {
                        case _PreviewToolbarAction.toggleMode:
                          previewNotifier.togglePreviewMode();
                          break;
                        case _PreviewToolbarAction.toggleBreakpoints:
                          previewNotifier.toggleBreakpoints();
                          break;
                        case _PreviewToolbarAction.desktop:
                          previewNotifier.setDevice(DeviceType.desktop);
                          break;
                        case _PreviewToolbarAction.tablet:
                          previewNotifier.setDevice(DeviceType.tablet);
                          break;
                        case _PreviewToolbarAction.mobile:
                          previewNotifier.setDevice(DeviceType.mobile);
                          break;
                        case _PreviewToolbarAction.custom:
                          showCustomPreviewSizeDialog(context, ref);
                          break;
                        case _PreviewToolbarAction.rotate:
                          rememberRotatedPreviewSize(previewState);
                          previewNotifier.rotateCurrentSize();
                          break;
                      }
                    },
                  ),
                const SizedBox(width: 12),
              ],
            );

            if (scrollFallback) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: toolbar,
              );
            }

            return toolbar;
          },
        ),
      ),
    );
  }
}

void _pasteAtCursor(WidgetRef ref) {
  final pointerPosition =
      ref.read(canvasViewportProvider).pointerCanvasPosition;
  final notifier = ref.read(layoutStateProvider.notifier);

  if (pointerPosition == null) {
    notifier.pasteComponent();
  } else {
    notifier.pasteComponentAt(pointerPosition);
  }
}

bool _isSingleGroupSelection(List<ComponentData> components) {
  final groupIds =
      components
          .map((component) => component.properties.parentId)
          .whereType<String>()
          .toSet();

  return groupIds.length == 1 &&
      components.length > 1 &&
      components.every(
        (component) => component.properties.parentId == groupIds.first,
      );
}

class _ToolbarCoordinateReadout extends StatelessWidget {
  final Offset? position;

  const _ToolbarCoordinateReadout({required this.position});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPosition = position != null;
    final label =
        hasPosition
            ? 'X ${position!.dx.round()}  Y ${position!.dy.round()}'
            : 'X --  Y --';

    return Tooltip(
      message:
          hasPosition ? 'Copy canvas coordinates' : 'Pointer outside canvas',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: hasPosition ? () => _copyCoordinates(context, position!) : null,
        child: Container(
          height: 40,
          width: 112,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
            color:
                hasPosition
                    ? colorScheme.surface
                    : colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color:
                  hasPosition
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyCoordinates(BuildContext context, Offset position) async {
    final x = position.dx.round();
    final y = position.dy.round();
    await Clipboard.setData(ClipboardData(text: '$x, $y'));
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Copied X $x, Y $y'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _FileActionsMenu extends StatelessWidget {
  final WidgetRef ref;

  const _FileActionsMenu({required this.ref});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_FileToolbarAction>(
      tooltip: 'File actions',
      icon: const Icon(Icons.folder_copy_outlined),
      onSelected: (action) {
        switch (action) {
          case _FileToolbarAction.saveAsTemplate:
            showSaveTemplateDialog(context, ref);
            break;
          case _FileToolbarAction.loadTemplate:
            showLoadTemplateDialog(context, ref);
            break;
          case _FileToolbarAction.exportJson:
            showExportLayoutDialog(context, ref);
            break;
          case _FileToolbarAction.importJson:
            showImportLayoutDialog(context, ref);
            break;
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _FileToolbarAction.saveAsTemplate,
              child: _ToolbarMenuItem(
                icon: Icons.save_as_outlined,
                label: 'Save as template',
              ),
            ),
            PopupMenuItem(
              value: _FileToolbarAction.loadTemplate,
              child: _ToolbarMenuItem(
                icon: Icons.folder_open,
                label: 'Load template',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _FileToolbarAction.exportJson,
              child: _ToolbarMenuItem(
                icon: Icons.file_download_outlined,
                label: 'Export JSON',
              ),
            ),
            PopupMenuItem(
              value: _FileToolbarAction.importJson,
              child: _ToolbarMenuItem(
                icon: Icons.file_upload_outlined,
                label: 'Import JSON',
              ),
            ),
          ],
    );
  }
}

enum _FileToolbarAction { saveAsTemplate, loadTemplate, exportJson, importJson }

class _CanvasSizeMenu extends StatelessWidget {
  final Size currentSize;
  final bool canFitContent;
  final bool canFitSelection;
  final ValueChanged<Size> onSelected;
  final VoidCallback onCustom;
  final VoidCallback onRotate;
  final VoidCallback onFitContent;
  final VoidCallback onTrimContent;
  final VoidCallback onFitSelection;

  const _CanvasSizeMenu({
    required this.currentSize,
    required this.canFitContent,
    required this.canFitSelection,
    required this.onSelected,
    required this.onCustom,
    required this.onRotate,
    required this.onFitContent,
    required this.onTrimContent,
    required this.onFitSelection,
  });

  @override
  Widget build(BuildContext context) {
    final currentLabel = _canvasSizeLabel(currentSize);

    return PopupMenuButton<Object>(
      tooltip: 'Canvas size ($currentLabel)',
      icon: const Icon(Icons.aspect_ratio),
      onSelected: (value) {
        if (value is Size) {
          onSelected(value);
          return;
        }

        if (value == _CanvasSizeMenuAction.custom) {
          onCustom();
          return;
        }

        if (value == _CanvasSizeMenuAction.rotate) {
          onRotate();
          return;
        }

        if (value == _CanvasSizeMenuAction.fitContent) {
          onFitContent();
          return;
        }

        if (value == _CanvasSizeMenuAction.trimContent) {
          onTrimContent();
          return;
        }

        if (value == _CanvasSizeMenuAction.fitSelection) {
          onFitSelection();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem<Object>(
              enabled: false,
              child: _ToolbarMenuItem(
                icon: Icons.aspect_ratio,
                label: 'Current $currentLabel',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<Object>(
              value: _CanvasSizeMenuAction.custom,
              child: _ToolbarMenuItem(
                icon: Icons.edit_outlined,
                label: 'Custom size',
              ),
            ),
            PopupMenuItem<Object>(
              enabled:
                  !_isSameCanvasSize(
                    currentSize,
                    Size(currentSize.height, currentSize.width),
                  ),
              value: _CanvasSizeMenuAction.rotate,
              child: const _ToolbarMenuItem(
                icon: Icons.screen_rotation,
                label: 'Rotate size',
              ),
            ),
            PopupMenuItem<Object>(
              enabled: canFitContent,
              value: _CanvasSizeMenuAction.fitContent,
              child: const _ToolbarMenuItem(
                icon: Icons.fit_screen,
                label: 'Fit to content',
              ),
            ),
            PopupMenuItem<Object>(
              enabled: canFitContent,
              value: _CanvasSizeMenuAction.trimContent,
              child: const _ToolbarMenuItem(
                icon: Icons.crop_free,
                label: 'Trim to content',
              ),
            ),
            PopupMenuItem<Object>(
              enabled: canFitSelection,
              value: _CanvasSizeMenuAction.fitSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.select_all_outlined,
                label: 'Fit to selection',
              ),
            ),
            const PopupMenuDivider(),
            for (final preset in layoutCanvasSizePresets)
              CheckedPopupMenuItem<Object>(
                value: preset.size,
                checked: _isSameCanvasSize(currentSize, preset.size),
                child: _ToolbarMenuItem(
                  icon: _canvasSizePresetIcon(preset),
                  label: '${preset.label} (${preset.dimensionLabel})',
                ),
              ),
          ],
    );
  }
}

enum _CanvasSizeMenuAction {
  custom,
  rotate,
  fitContent,
  trimContent,
  fitSelection,
}

class _CanvasActionsMenu extends StatelessWidget {
  final bool gridEnabled;
  final bool snapEnabled;
  final bool precisionGuidesEnabled;
  final bool showAutoGridOccupancyAction;
  final bool autoGridOccupancyEnabled;
  final int autoGridConflictCount;
  final int autoGridMovableVisibleCount;
  final ValueChanged<_CanvasToolbarAction> onSelected;

  const _CanvasActionsMenu({
    required this.gridEnabled,
    required this.snapEnabled,
    required this.precisionGuidesEnabled,
    required this.showAutoGridOccupancyAction,
    required this.autoGridOccupancyEnabled,
    required this.autoGridConflictCount,
    required this.autoGridMovableVisibleCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CanvasToolbarAction>(
      tooltip: 'Canvas actions',
      icon: const Icon(Icons.grid_view_outlined),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _CanvasToolbarAction.toggleGrid,
              child: _ToolbarMenuItem(
                icon: gridEnabled ? Icons.grid_on : Icons.grid_off,
                label: gridEnabled ? 'Hide grid' : 'Show grid',
              ),
            ),
            PopupMenuItem(
              value: _CanvasToolbarAction.toggleSnap,
              child: _ToolbarMenuItem(
                icon: Icons.grid_4x4,
                label: snapEnabled ? 'Disable snap' : 'Enable snap',
              ),
            ),
            const PopupMenuItem(
              value: _CanvasToolbarAction.gridSettings,
              child: _ToolbarMenuItem(icon: Icons.tune, label: 'Layout rules'),
            ),
            PopupMenuItem(
              value: _CanvasToolbarAction.togglePrecisionGuides,
              child: _ToolbarMenuItem(
                icon: Icons.straighten,
                label:
                    precisionGuidesEnabled
                        ? 'Hide precision guides'
                        : 'Show precision guides',
              ),
            ),
            if (showAutoGridOccupancyAction)
              PopupMenuItem(
                value: _CanvasToolbarAction.toggleAutoGridOccupancy,
                child: _ToolbarMenuItem(
                  icon: Icons.dashboard_customize_outlined,
                  label:
                      autoGridOccupancyEnabled
                          ? 'Hide Auto Grid occupancy'
                          : 'Show Auto Grid occupancy',
                ),
              ),
            if (showAutoGridOccupancyAction)
              PopupMenuItem(
                enabled: autoGridConflictCount > 0,
                value: _CanvasToolbarAction.resolveAutoGridConflicts,
                child: _ToolbarMenuItem(
                  icon: Icons.auto_fix_high_outlined,
                  label: _autoGridConflictActionLabel(autoGridConflictCount),
                ),
              ),
            if (showAutoGridOccupancyAction)
              PopupMenuItem(
                enabled: autoGridMovableVisibleCount > 0,
                value: _CanvasToolbarAction.compactAutoGrid,
                child: _ToolbarMenuItem(
                  icon: Icons.view_module_outlined,
                  label: _autoGridCompactActionLabel(
                    autoGridMovableVisibleCount,
                  ),
                ),
              ),
          ],
    );
  }
}

class _LayoutMechanismMenu extends StatelessWidget {
  final LayoutMechanism current;
  final ValueChanged<LayoutMechanism> onSelected;
  final ValueChanged<LayoutMechanism> onConvert;

  const _LayoutMechanismMenu({
    required this.current,
    required this.onSelected,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LayoutMechanismMenuAction>(
      tooltip: 'Layout mechanism',
      icon: Icon(_layoutMechanismIcon(current)),
      onSelected: (action) {
        if (action.convert) {
          onConvert(action.mechanism);
          return;
        }

        onSelected(action.mechanism);
      },
      itemBuilder:
          (context) => [
            for (final mechanism in LayoutMechanism.values)
              CheckedPopupMenuItem<_LayoutMechanismMenuAction>(
                value: _LayoutMechanismMenuAction(mechanism),
                checked: mechanism == current,
                child: _ToolbarMenuItem(
                  icon: _layoutMechanismIcon(mechanism),
                  label: mechanism.label,
                ),
              ),
            const PopupMenuDivider(),
            for (final mechanism in LayoutMechanism.values.where(
              (mechanism) => mechanism != LayoutMechanism.freeform,
            ))
              PopupMenuItem<_LayoutMechanismMenuAction>(
                value: _LayoutMechanismMenuAction(mechanism, convert: true),
                child: _ToolbarMenuItem(
                  icon: Icons.auto_fix_high_outlined,
                  label: 'Convert to ${mechanism.label}',
                ),
              ),
          ],
    );
  }
}

class _LayoutMechanismMenuAction {
  final LayoutMechanism mechanism;
  final bool convert;

  const _LayoutMechanismMenuAction(this.mechanism, {this.convert = false});
}

IconData _layoutMechanismIcon(LayoutMechanism mechanism) {
  switch (mechanism) {
    case LayoutMechanism.freeform:
      return Icons.open_with;
    case LayoutMechanism.grid:
      return Icons.grid_4x4;
    case LayoutMechanism.tabularColumns:
      return Icons.view_column_outlined;
    case LayoutMechanism.autoGrid:
      return Icons.dashboard_customize_outlined;
  }
}

enum _CanvasToolbarAction {
  toggleGrid,
  toggleSnap,
  gridSettings,
  togglePrecisionGuides,
  toggleAutoGridOccupancy,
  resolveAutoGridConflicts,
  compactAutoGrid,
}

String _autoGridConflictActionLabel(int count) {
  if (count <= 0) return 'No Auto Grid conflicts';
  if (count == 1) return 'Resolve 1 Auto Grid conflict';
  return 'Resolve $count Auto Grid conflicts';
}

String _autoGridConflictActionTooltip(int count) {
  if (count <= 0) return 'No visible Auto Grid conflicts';
  if (count == 1) return 'Resolve 1 visible Auto Grid conflict';
  return 'Resolve $count visible Auto Grid conflicts';
}

String _autoGridCompactActionLabel(int count) {
  if (count <= 0) return 'No unlocked visible components';
  if (count == 1) return 'Compact 1 visible component';
  return 'Compact $count visible components';
}

String _autoGridCompactActionTooltip(int count) {
  if (count <= 0) return 'No unlocked visible Auto Grid components';
  if (count == 1) return 'Compact 1 visible Auto Grid component';
  return 'Compact $count visible Auto Grid components';
}

String _canvasSizeLabel(Size size) {
  return '${size.width.round()} x ${size.height.round()}';
}

bool _isSameCanvasSize(Size first, Size second) {
  return (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}

IconData _canvasSizePresetIcon(LayoutCanvasSizePreset preset) {
  if (preset.size.height > preset.size.width) return Icons.phone_android;
  if (preset.size.width >= 1800) return Icons.tv;
  if (preset.size.width <= 1100) return Icons.tablet_mac;
  return Icons.desktop_windows;
}

class _SelectionOverflowMenu extends StatelessWidget {
  final int componentCount;
  final int visibleCount;
  final int hiddenCount;
  final int lockedCount;
  final int unlockedCount;
  final bool hasSelection;
  final bool hasClipboard;
  final bool hasMultiSelection;
  final LayoutClearSpotActionState clearSpotAction;
  final bool canDistribute;
  final bool isSingleGroupSelection;
  final bool selectedLocked;
  final bool selectedVisible;
  final double gridGap;
  final ValueChanged<_SelectionOverflowAction> onSelected;

  const _SelectionOverflowMenu({
    required this.componentCount,
    required this.visibleCount,
    required this.hiddenCount,
    required this.lockedCount,
    required this.unlockedCount,
    required this.hasSelection,
    required this.hasClipboard,
    required this.hasMultiSelection,
    required this.clearSpotAction,
    required this.canDistribute,
    required this.isSingleGroupSelection,
    required this.selectedLocked,
    required this.selectedVisible,
    required this.gridGap,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SelectionOverflowAction>(
      tooltip: 'Selection actions',
      icon: const Icon(Icons.select_all_outlined),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.copy,
              child: const _ToolbarMenuItem(
                icon: Icons.content_copy,
                label: 'Copy selection',
              ),
            ),
            PopupMenuItem(
              enabled: hasClipboard,
              value: _SelectionOverflowAction.paste,
              child: const _ToolbarMenuItem(
                icon: Icons.content_paste,
                label: 'Paste',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.duplicate,
              child: const _ToolbarMenuItem(
                icon: Icons.control_point_duplicate,
                label: 'Duplicate',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.delete,
              child: const _ToolbarMenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: componentCount > 0,
              value: _SelectionOverflowAction.selectAll,
              child: _ToolbarMenuItem(
                icon: Icons.select_all_outlined,
                label: 'Select all ($componentCount)',
              ),
            ),
            PopupMenuItem(
              enabled: componentCount > 0,
              value: _SelectionOverflowAction.invertSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.swap_horiz,
                label: 'Invert selection',
              ),
            ),
            PopupMenuItem(
              enabled: visibleCount > 0,
              value: _SelectionOverflowAction.selectVisible,
              child: _ToolbarMenuItem(
                icon: Icons.visibility_outlined,
                label: 'Select visible ($visibleCount)',
              ),
            ),
            PopupMenuItem(
              enabled: hiddenCount > 0,
              value: _SelectionOverflowAction.selectHidden,
              child: _ToolbarMenuItem(
                icon: Icons.visibility_off_outlined,
                label: 'Select hidden ($hiddenCount)',
              ),
            ),
            PopupMenuItem(
              enabled: lockedCount > 0,
              value: _SelectionOverflowAction.selectLocked,
              child: _ToolbarMenuItem(
                icon: Icons.lock_outline,
                label: 'Select locked ($lockedCount)',
              ),
            ),
            PopupMenuItem(
              enabled: unlockedCount > 0,
              value: _SelectionOverflowAction.selectUnlocked,
              child: _ToolbarMenuItem(
                icon: Icons.lock_open_outlined,
                label: 'Select unlocked ($unlockedCount)',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.clearSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.close,
                label: 'Clear selection',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.snapToGrid,
              child: const _ToolbarMenuItem(
                icon: Icons.grid_4x4,
                label: 'Snap to layout rules',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.snapSizeToGrid,
              child: const _ToolbarMenuItem(
                icon: Icons.aspect_ratio,
                label: 'Snap size to layout rules',
              ),
            ),
            PopupMenuItem(
              enabled: clearSpotAction.isAvailable,
              value: _SelectionOverflowAction.moveToClearSpot,
              child: _ToolbarMenuItem(
                icon: Icons.near_me_outlined,
                label: clearSpotAction.menuActionLabel(prefix: 'Move to'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasMultiSelection && !isSingleGroupSelection,
              value: _SelectionOverflowAction.group,
              child: const _ToolbarMenuItem(
                icon: Icons.group_work_outlined,
                label: 'Group selection',
              ),
            ),
            PopupMenuItem(
              enabled: isSingleGroupSelection,
              value: _SelectionOverflowAction.ungroup,
              child: const _ToolbarMenuItem(
                icon: Icons.call_split_outlined,
                label: 'Ungroup selection',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.toggleLock,
              child: _ToolbarMenuItem(
                icon: selectedLocked ? Icons.lock_open_outlined : Icons.lock,
                label: selectedLocked ? 'Unlock selection' : 'Lock selection',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.toggleVisibility,
              child: _ToolbarMenuItem(
                icon:
                    selectedVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                label: selectedVisible ? 'Hide selection' : 'Show selection',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.showOnlySelection,
              child: const _ToolbarMenuItem(
                icon: Icons.visibility,
                label: 'Show only selection',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.bringForward,
              child: const _ToolbarMenuItem(
                icon: Icons.flip_to_front,
                label: 'Bring forward',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.bringToFront,
              child: const _ToolbarMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Bring to front',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.sendBackward,
              child: const _ToolbarMenuItem(
                icon: Icons.flip_to_back,
                label: 'Send backward',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.sendToBack,
              child: const _ToolbarMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Send to back',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignLeft,
              child: const _ToolbarMenuItem(
                icon: Icons.format_align_left,
                label: 'Align left',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignCenter,
              child: const _ToolbarMenuItem(
                icon: Icons.align_horizontal_center,
                label: 'Align center',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignRight,
              child: const _ToolbarMenuItem(
                icon: Icons.format_align_right,
                label: 'Align right',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignTop,
              child: const _ToolbarMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Align top',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignMiddle,
              child: const _ToolbarMenuItem(
                icon: Icons.vertical_align_center,
                label: 'Align middle',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.alignBottom,
              child: const _ToolbarMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Align bottom',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasOrigin,
              child: const _ToolbarMenuItem(
                icon: Icons.north_west,
                label: 'Move to origin',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasTopRight,
              child: const _ToolbarMenuItem(
                icon: Icons.north_east,
                label: 'Move to top-right',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasBottomLeft,
              child: const _ToolbarMenuItem(
                icon: Icons.south_west,
                label: 'Move to bottom-left',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasBottomRight,
              child: const _ToolbarMenuItem(
                icon: Icons.south_east,
                label: 'Move to bottom-right',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasTopEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.north,
                label: 'Move to top edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasRightEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.east,
                label: 'Move to right edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasBottomEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.south,
                label: 'Move to bottom edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveToCanvasLeftEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.west,
                label: 'Move to left edge',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.pinToCanvasTopEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.north,
                label: 'Pin to top edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.pinToCanvasRightEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.east,
                label: 'Pin to right edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.pinToCanvasBottomEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.south,
                label: 'Pin to bottom edge',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.pinToCanvasLeftEdge,
              child: const _ToolbarMenuItem(
                icon: Icons.west,
                label: 'Pin to left edge',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.moveInsideCanvas,
              child: const _ToolbarMenuItem(
                icon: Icons.fit_screen,
                label: 'Move inside canvas',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.fitInsideCanvas,
              child: const _ToolbarMenuItem(
                icon: Icons.zoom_out_map,
                label: 'Fit into canvas',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.centerOnCanvas,
              child: const _ToolbarMenuItem(
                icon: Icons.center_focus_weak,
                label: 'Center on canvas',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.centerHorizontally,
              child: const _ToolbarMenuItem(
                icon: Icons.align_horizontal_center,
                label: 'Center horizontally',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionOverflowAction.centerVertically,
              child: const _ToolbarMenuItem(
                icon: Icons.align_vertical_center,
                label: 'Center vertically',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.matchWidth,
              child: const _ToolbarMenuItem(
                icon: Icons.swap_horiz,
                label: 'Match width',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.matchHeight,
              child: const _ToolbarMenuItem(
                icon: Icons.swap_vert,
                label: 'Match height',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.matchSize,
              child: const _ToolbarMenuItem(
                icon: Icons.aspect_ratio,
                label: 'Match size',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.stackHorizontal,
              child: const _ToolbarMenuItem(
                icon: Icons.view_column,
                label: 'Stack as row',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.stackVertical,
              child: const _ToolbarMenuItem(
                icon: Icons.view_stream,
                label: 'Stack as column',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.spaceHorizontal,
              child: _ToolbarMenuItem(
                icon: Icons.more_horiz,
                label: 'Space horizontally (${gridGap.round()} px)',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.spaceVertical,
              child: _ToolbarMenuItem(
                icon: Icons.more_vert,
                label: 'Space vertically (${gridGap.round()} px)',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.customSpaceHorizontal,
              child: const _ToolbarMenuItem(
                icon: Icons.tune,
                label: 'Custom horizontal spacing',
              ),
            ),
            PopupMenuItem(
              enabled: hasMultiSelection,
              value: _SelectionOverflowAction.customSpaceVertical,
              child: const _ToolbarMenuItem(
                icon: Icons.tune,
                label: 'Custom vertical spacing',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: canDistribute,
              value: _SelectionOverflowAction.distributeHorizontally,
              child: const _ToolbarMenuItem(
                icon: Icons.more_horiz,
                label: 'Distribute horizontally',
              ),
            ),
            PopupMenuItem(
              enabled: canDistribute,
              value: _SelectionOverflowAction.distributeVertically,
              child: const _ToolbarMenuItem(
                icon: Icons.more_vert,
                label: 'Distribute vertically',
              ),
            ),
          ],
    );
  }
}

enum _SelectionOverflowAction {
  copy,
  paste,
  duplicate,
  delete,
  selectAll,
  invertSelection,
  selectVisible,
  selectHidden,
  selectLocked,
  selectUnlocked,
  clearSelection,
  snapToGrid,
  snapSizeToGrid,
  moveToClearSpot,
  group,
  ungroup,
  toggleLock,
  toggleVisibility,
  showOnlySelection,
  bringForward,
  bringToFront,
  sendBackward,
  sendToBack,
  alignLeft,
  alignCenter,
  alignRight,
  alignTop,
  alignMiddle,
  alignBottom,
  moveToCanvasOrigin,
  moveToCanvasTopRight,
  moveToCanvasBottomLeft,
  moveToCanvasBottomRight,
  moveToCanvasTopEdge,
  moveToCanvasRightEdge,
  moveToCanvasBottomEdge,
  moveToCanvasLeftEdge,
  pinToCanvasTopEdge,
  pinToCanvasRightEdge,
  pinToCanvasBottomEdge,
  pinToCanvasLeftEdge,
  moveInsideCanvas,
  fitInsideCanvas,
  centerOnCanvas,
  centerHorizontally,
  centerVertically,
  matchWidth,
  matchHeight,
  matchSize,
  stackHorizontal,
  stackVertical,
  spaceHorizontal,
  spaceVertical,
  customSpaceHorizontal,
  customSpaceVertical,
  distributeHorizontally,
  distributeVertically,
}

class _PreviewActionsMenu extends StatelessWidget {
  final ResponsivePreviewState previewState;
  final ValueChanged<_PreviewToolbarAction> onSelected;

  const _PreviewActionsMenu({
    required this.previewState,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final previewSize =
        '${previewState.width.round()} x ${previewState.height.round()}';

    return PopupMenuButton<_PreviewToolbarAction>(
      tooltip: 'Preview actions',
      icon: const Icon(Icons.devices_outlined),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _PreviewToolbarAction.toggleMode,
              child: _ToolbarMenuItem(
                icon:
                    previewState.isPreviewMode
                        ? Icons.edit_outlined
                        : Icons.preview_outlined,
                label:
                    previewState.isPreviewMode
                        ? 'Edit canvas'
                        : 'Preview layout',
              ),
            ),
            PopupMenuItem(
              enabled: previewState.isPreviewMode,
              value: _PreviewToolbarAction.toggleBreakpoints,
              child: _ToolbarMenuItem(
                icon: Icons.splitscreen_outlined,
                label:
                    previewState.showBreakpoints
                        ? 'Hide breakpoints'
                        : 'Show breakpoints',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _PreviewToolbarAction.desktop,
              child: _ToolbarMenuItem(
                icon:
                    previewState.currentDevice == DeviceType.desktop
                        ? Icons.check
                        : Icons.desktop_windows,
                label: 'Desktop preview',
              ),
            ),
            PopupMenuItem(
              value: _PreviewToolbarAction.tablet,
              child: _ToolbarMenuItem(
                icon:
                    previewState.currentDevice == DeviceType.tablet
                        ? Icons.check
                        : Icons.tablet,
                label: 'Tablet preview',
              ),
            ),
            PopupMenuItem(
              value: _PreviewToolbarAction.mobile,
              child: _ToolbarMenuItem(
                icon:
                    previewState.currentDevice == DeviceType.mobile
                        ? Icons.check
                        : Icons.smartphone,
                label: 'Mobile preview',
              ),
            ),
            PopupMenuItem(
              value: _PreviewToolbarAction.custom,
              child: _ToolbarMenuItem(
                icon:
                    previewState.currentDevice == DeviceType.custom
                        ? Icons.check
                        : Icons.aspect_ratio,
                label: 'Custom preview ($previewSize)',
              ),
            ),
            const PopupMenuItem(
              value: _PreviewToolbarAction.rotate,
              child: _ToolbarMenuItem(
                icon: Icons.screen_rotation,
                label: 'Rotate preview size',
              ),
            ),
          ],
    );
  }
}

enum _PreviewToolbarAction {
  toggleMode,
  toggleBreakpoints,
  desktop,
  tablet,
  mobile,
  custom,
  rotate,
}

class _LayoutTransferMenu extends StatelessWidget {
  final WidgetRef ref;

  const _LayoutTransferMenu({required this.ref});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LayoutTransferAction>(
      tooltip: 'Import or export layout',
      icon: const Icon(Icons.data_object),
      onSelected: (action) {
        switch (action) {
          case _LayoutTransferAction.exportJson:
            showExportLayoutDialog(context, ref);
            break;
          case _LayoutTransferAction.importJson:
            showImportLayoutDialog(context, ref);
            break;
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _LayoutTransferAction.exportJson,
              child: _LayoutTransferMenuItem(
                icon: Icons.file_download_outlined,
                label: 'Export JSON',
              ),
            ),
            PopupMenuItem(
              value: _LayoutTransferAction.importJson,
              child: _LayoutTransferMenuItem(
                icon: Icons.file_upload_outlined,
                label: 'Import JSON',
              ),
            ),
          ],
    );
  }
}

class _LayoutTransferMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LayoutTransferMenuItem({required this.icon, required this.label});

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

enum _LayoutTransferAction { exportJson, importJson }

class _ToolbarZoomMenu extends StatelessWidget {
  final CanvasViewportState viewportState;
  final bool hasSelection;
  final ValueChanged<Object> onSelected;

  const _ToolbarZoomMenu({
    required this.viewportState,
    required this.hasSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final zoomLabel = '${(viewportState.zoom * 100).round()}%';
    final canZoomIn =
        viewportState.zoom < CanvasViewportNotifier.maxZoom - 0.001;
    final canZoomOut =
        viewportState.zoom > CanvasViewportNotifier.minZoom + 0.001;
    final canResetZoom = (viewportState.zoom - 1).abs() >= 0.001;

    return PopupMenuButton<Object>(
      tooltip: 'Canvas zoom ($zoomLabel)',
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              enabled: canZoomOut,
              value: _ToolbarZoomAction.zoomOut,
              child: const _ToolbarMenuItem(
                icon: Icons.zoom_out,
                label: 'Zoom out',
              ),
            ),
            PopupMenuItem(
              enabled: canZoomIn,
              value: _ToolbarZoomAction.zoomIn,
              child: const _ToolbarMenuItem(
                icon: Icons.zoom_in,
                label: 'Zoom in',
              ),
            ),
            PopupMenuItem(
              enabled: canResetZoom,
              value: _ToolbarZoomAction.reset,
              child: const _ToolbarMenuItem(
                icon: Icons.restart_alt,
                label: 'Reset zoom',
              ),
            ),
            const PopupMenuItem(
              value: _ToolbarZoomAction.custom,
              child: _ToolbarMenuItem(
                icon: Icons.edit_outlined,
                label: 'Custom zoom',
              ),
            ),
            if (recentCanvasZoomPresets.isNotEmpty) ...[
              const PopupMenuDivider(),
              for (final preset in recentCanvasZoomPresets)
                PopupMenuItem<Object>(
                  enabled: (viewportState.zoom - preset).abs() >= 0.001,
                  value: preset,
                  child: _ToolbarMenuItem(
                    icon:
                        (viewportState.zoom - preset).abs() < 0.001
                            ? Icons.check
                            : Icons.history,
                    label: 'Recent ${_zoomPercentLabel(preset)}',
                  ),
                ),
              const PopupMenuItem(
                value: _ToolbarZoomAction.clearRecent,
                child: _ToolbarMenuItem(
                  icon: Icons.history_toggle_off,
                  label: 'Clear recent zooms',
                ),
              ),
            ],
            const PopupMenuDivider(),
            for (final preset in layoutCanvasZoomPresets)
              PopupMenuItem(
                enabled: (viewportState.zoom - preset).abs() >= 0.001,
                value: _toolbarActionForZoomPreset(preset),
                child: _ToolbarMenuItem(
                  icon:
                      (viewportState.zoom - preset).abs() < 0.001
                          ? Icons.check
                          : Icons.zoom_in_map,
                  label: _zoomPercentLabel(preset),
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _ToolbarZoomAction.fitCanvas,
              child: _ToolbarMenuItem(
                icon: Icons.fit_screen,
                label: 'Fit canvas',
              ),
            ),
            PopupMenuItem(
              enabled: hasSelection,
              value: _ToolbarZoomAction.fitSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.center_focus_weak,
                label: 'Fit selection',
              ),
            ),
          ],
      child: Tooltip(
        message: 'Canvas zoom ($zoomLabel)',
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.zoom_in_map, size: 20, color: colorScheme.primary),
              const SizedBox(width: 6),
              SizedBox(
                width: 42,
                child: Text(
                  zoomLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ToolbarZoomAction {
  zoomOut,
  zoomIn,
  reset,
  custom,
  clearRecent,
  fitCanvas,
  fitSelection,
  zoom50,
  zoom75,
  zoom100,
  zoom125,
  zoom150,
  zoom200,
}

_ToolbarZoomAction _toolbarActionForZoomPreset(double zoom) {
  switch ((zoom * 100).round()) {
    case 50:
      return _ToolbarZoomAction.zoom50;
    case 75:
      return _ToolbarZoomAction.zoom75;
    case 100:
      return _ToolbarZoomAction.zoom100;
    case 125:
      return _ToolbarZoomAction.zoom125;
    case 150:
      return _ToolbarZoomAction.zoom150;
    case 200:
      return _ToolbarZoomAction.zoom200;
    default:
      return _ToolbarZoomAction.zoom100;
  }
}

double? _zoomPresetForToolbarAction(_ToolbarZoomAction action) {
  switch (action) {
    case _ToolbarZoomAction.zoom50:
      return 0.5;
    case _ToolbarZoomAction.zoom75:
      return 0.75;
    case _ToolbarZoomAction.zoom100:
      return 1;
    case _ToolbarZoomAction.zoom125:
      return 1.25;
    case _ToolbarZoomAction.zoom150:
      return 1.5;
    case _ToolbarZoomAction.zoom200:
      return 2;
    case _ToolbarZoomAction.zoomOut:
    case _ToolbarZoomAction.zoomIn:
    case _ToolbarZoomAction.reset:
    case _ToolbarZoomAction.custom:
    case _ToolbarZoomAction.clearRecent:
    case _ToolbarZoomAction.fitCanvas:
    case _ToolbarZoomAction.fitSelection:
      return null;
  }
}

String _zoomPercentLabel(double zoom) {
  return '${(zoom * 100).round()}%';
}

class _SelectionFilterMenu extends StatelessWidget {
  final int componentCount;
  final int visibleCount;
  final int hiddenCount;
  final int lockedCount;
  final int unlockedCount;
  final bool hasSelection;
  final ValueChanged<_SelectionFilterAction> onSelected;

  const _SelectionFilterMenu({
    required this.componentCount,
    required this.visibleCount,
    required this.hiddenCount,
    required this.lockedCount,
    required this.unlockedCount,
    required this.hasSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SelectionFilterAction>(
      enabled: componentCount > 0,
      tooltip: 'Select components',
      icon: const Icon(Icons.filter_alt_outlined),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _SelectionFilterAction.selectAll,
              child: _ToolbarMenuItem(
                icon: Icons.select_all_outlined,
                label: 'Select all ($componentCount)',
              ),
            ),
            PopupMenuItem(
              enabled: componentCount > 0,
              value: _SelectionFilterAction.invertSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.swap_horiz,
                label: 'Invert selection',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: visibleCount > 0,
              value: _SelectionFilterAction.selectVisible,
              child: _ToolbarMenuItem(
                icon: Icons.visibility_outlined,
                label: 'Select visible ($visibleCount)',
              ),
            ),
            PopupMenuItem(
              enabled: hiddenCount > 0,
              value: _SelectionFilterAction.selectHidden,
              child: _ToolbarMenuItem(
                icon: Icons.visibility_off_outlined,
                label: 'Select hidden ($hiddenCount)',
              ),
            ),
            PopupMenuItem(
              enabled: lockedCount > 0,
              value: _SelectionFilterAction.selectLocked,
              child: _ToolbarMenuItem(
                icon: Icons.lock_outline,
                label: 'Select locked ($lockedCount)',
              ),
            ),
            PopupMenuItem(
              enabled: unlockedCount > 0,
              value: _SelectionFilterAction.selectUnlocked,
              child: _ToolbarMenuItem(
                icon: Icons.lock_open_outlined,
                label: 'Select unlocked ($unlockedCount)',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hasSelection,
              value: _SelectionFilterAction.clearSelection,
              child: const _ToolbarMenuItem(
                icon: Icons.close,
                label: 'Clear selection',
              ),
            ),
          ],
    );
  }
}

enum _SelectionFilterAction {
  selectAll,
  invertSelection,
  selectVisible,
  selectHidden,
  selectLocked,
  selectUnlocked,
  clearSelection,
}

class _SelectionCountBadge extends StatelessWidget {
  final int count;

  const _SelectionCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count selected',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ArrangeMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<_ArrangeAction> onSelected;

  const _ArrangeMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ArrangeAction>(
      enabled: enabled,
      tooltip: 'Arrange selected',
      icon: const Icon(Icons.layers_outlined),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _ArrangeAction.bringForward,
              child: _ToolbarMenuItem(
                icon: Icons.flip_to_front,
                label: 'Bring forward',
              ),
            ),
            PopupMenuItem(
              value: _ArrangeAction.bringToFront,
              child: _ToolbarMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Bring to front',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _ArrangeAction.sendBackward,
              child: _ToolbarMenuItem(
                icon: Icons.flip_to_back,
                label: 'Send backward',
              ),
            ),
            PopupMenuItem(
              value: _ArrangeAction.sendToBack,
              child: _ToolbarMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Send to back',
              ),
            ),
          ],
    );
  }
}

enum _ArrangeAction { bringForward, bringToFront, sendBackward, sendToBack }

class _MatchSizeMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<_MatchSizeAction> onSelected;

  const _MatchSizeMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MatchSizeAction>(
      enabled: enabled,
      tooltip: 'Match selected size',
      icon: const Icon(Icons.aspect_ratio),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _MatchSizeAction.width,
              child: _ToolbarMenuItem(
                icon: Icons.swap_horiz,
                label: 'Match width',
              ),
            ),
            PopupMenuItem(
              value: _MatchSizeAction.height,
              child: _ToolbarMenuItem(
                icon: Icons.swap_vert,
                label: 'Match height',
              ),
            ),
            PopupMenuItem(
              value: _MatchSizeAction.size,
              child: _ToolbarMenuItem(
                icon: Icons.aspect_ratio,
                label: 'Match size',
              ),
            ),
          ],
    );
  }
}

enum _MatchSizeAction { width, height, size }

class _StackMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<ComponentDistribution> onSelected;

  const _StackMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ComponentDistribution>(
      enabled: enabled,
      tooltip: 'Stack selected',
      icon: const Icon(Icons.view_column),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: ComponentDistribution.horizontal,
              child: _ToolbarMenuItem(
                icon: Icons.view_column,
                label: 'Stack as row',
              ),
            ),
            PopupMenuItem(
              value: ComponentDistribution.vertical,
              child: _ToolbarMenuItem(
                icon: Icons.view_stream,
                label: 'Stack as column',
              ),
            ),
          ],
    );
  }
}

class _SpacingMenu extends StatelessWidget {
  final bool enabled;
  final double gap;
  final ValueChanged<_SpacingAction> onSelected;

  const _SpacingMenu({
    required this.enabled,
    required this.gap,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gapLabel = '${gap.round()} px';

    return PopupMenuButton<_SpacingAction>(
      enabled: enabled,
      tooltip: 'Space selected by grid',
      icon: const Icon(Icons.space_bar),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _SpacingAction.horizontalGrid,
              child: _ToolbarMenuItem(
                icon: Icons.more_horiz,
                label: 'Space horizontally ($gapLabel)',
              ),
            ),
            PopupMenuItem(
              value: _SpacingAction.verticalGrid,
              child: _ToolbarMenuItem(
                icon: Icons.more_vert,
                label: 'Space vertically ($gapLabel)',
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _SpacingAction.horizontalCustom,
              child: _ToolbarMenuItem(
                icon: Icons.tune,
                label: 'Custom horizontal spacing',
              ),
            ),
            const PopupMenuItem(
              value: _SpacingAction.verticalCustom,
              child: _ToolbarMenuItem(
                icon: Icons.tune,
                label: 'Custom vertical spacing',
              ),
            ),
          ],
    );
  }
}

enum _SpacingAction {
  horizontalGrid,
  verticalGrid,
  horizontalCustom,
  verticalCustom,
}

class _DistributionMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<ComponentDistribution> onSelected;

  const _DistributionMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ComponentDistribution>(
      enabled: enabled,
      tooltip: 'Distribute selected',
      icon: const Icon(Icons.more_horiz),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: ComponentDistribution.horizontal,
              child: _ToolbarMenuItem(
                icon: Icons.more_horiz,
                label: 'Distribute horizontally',
              ),
            ),
            PopupMenuItem(
              value: ComponentDistribution.vertical,
              child: _ToolbarMenuItem(
                icon: Icons.more_vert,
                label: 'Distribute vertically',
              ),
            ),
          ],
    );
  }
}

class _AlignmentMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<ComponentAlignment> onSelected;

  const _AlignmentMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ComponentAlignment>(
      enabled: enabled,
      tooltip: 'Align selected',
      icon: const Icon(Icons.align_horizontal_center),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: ComponentAlignment.left,
              child: _ToolbarMenuItem(
                icon: Icons.format_align_left,
                label: 'Align left',
              ),
            ),
            PopupMenuItem(
              value: ComponentAlignment.center,
              child: _ToolbarMenuItem(
                icon: Icons.align_horizontal_center,
                label: 'Align center',
              ),
            ),
            PopupMenuItem(
              value: ComponentAlignment.right,
              child: _ToolbarMenuItem(
                icon: Icons.format_align_right,
                label: 'Align right',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: ComponentAlignment.top,
              child: _ToolbarMenuItem(
                icon: Icons.vertical_align_top,
                label: 'Align top',
              ),
            ),
            PopupMenuItem(
              value: ComponentAlignment.middle,
              child: _ToolbarMenuItem(
                icon: Icons.vertical_align_center,
                label: 'Align middle',
              ),
            ),
            PopupMenuItem(
              value: ComponentAlignment.bottom,
              child: _ToolbarMenuItem(
                icon: Icons.vertical_align_bottom,
                label: 'Align bottom',
              ),
            ),
          ],
    );
  }
}

enum _CanvasPlacementAction {
  origin,
  topRight,
  bottomLeft,
  bottomRight,
  topEdge,
  rightEdge,
  bottomEdge,
  leftEdge,
  pinTop,
  pinRight,
  pinBottom,
  pinLeft,
  insideCanvas,
  fitCanvas,
  canvas,
  horizontal,
  vertical,
}

class _CanvasPlacementMenu extends StatelessWidget {
  final bool enabled;
  final ValueChanged<_CanvasPlacementAction> onSelected;

  const _CanvasPlacementMenu({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CanvasPlacementAction>(
      enabled: enabled,
      tooltip: 'Canvas placement',
      icon: const Icon(Icons.center_focus_weak),
      onSelected: onSelected,
      itemBuilder:
          (context) => const [
            PopupMenuItem(
              value: _CanvasPlacementAction.origin,
              child: _ToolbarMenuItem(
                icon: Icons.north_west,
                label: 'Move to origin',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.topRight,
              child: _ToolbarMenuItem(
                icon: Icons.north_east,
                label: 'Move to top-right',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.bottomLeft,
              child: _ToolbarMenuItem(
                icon: Icons.south_west,
                label: 'Move to bottom-left',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.bottomRight,
              child: _ToolbarMenuItem(
                icon: Icons.south_east,
                label: 'Move to bottom-right',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _CanvasPlacementAction.topEdge,
              child: _ToolbarMenuItem(
                icon: Icons.north,
                label: 'Move to top edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.rightEdge,
              child: _ToolbarMenuItem(
                icon: Icons.east,
                label: 'Move to right edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.bottomEdge,
              child: _ToolbarMenuItem(
                icon: Icons.south,
                label: 'Move to bottom edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.leftEdge,
              child: _ToolbarMenuItem(
                icon: Icons.west,
                label: 'Move to left edge',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _CanvasPlacementAction.pinTop,
              child: _ToolbarMenuItem(
                icon: Icons.north,
                label: 'Pin to top edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.pinRight,
              child: _ToolbarMenuItem(
                icon: Icons.east,
                label: 'Pin to right edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.pinBottom,
              child: _ToolbarMenuItem(
                icon: Icons.south,
                label: 'Pin to bottom edge',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.pinLeft,
              child: _ToolbarMenuItem(
                icon: Icons.west,
                label: 'Pin to left edge',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _CanvasPlacementAction.insideCanvas,
              child: _ToolbarMenuItem(
                icon: Icons.fit_screen,
                label: 'Move inside canvas',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.fitCanvas,
              child: _ToolbarMenuItem(
                icon: Icons.zoom_out_map,
                label: 'Fit into canvas',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _CanvasPlacementAction.canvas,
              child: _ToolbarMenuItem(
                icon: Icons.center_focus_weak,
                label: 'Center on canvas',
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _CanvasPlacementAction.horizontal,
              child: _ToolbarMenuItem(
                icon: Icons.align_horizontal_center,
                label: 'Center horizontally',
              ),
            ),
            PopupMenuItem(
              value: _CanvasPlacementAction.vertical,
              child: _ToolbarMenuItem(
                icon: Icons.align_vertical_center,
                label: 'Center vertically',
              ),
            ),
          ],
    );
  }
}

class _ToolbarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarMenuItem({required this.icon, required this.label});

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

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        color: selected ? Theme.of(context).colorScheme.primary : null,
        onPressed: onPressed,
      ),
    );
  }
}
