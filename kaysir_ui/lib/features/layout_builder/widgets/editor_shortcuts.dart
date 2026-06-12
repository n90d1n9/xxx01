import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layout_config.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_canvas_containment_action_service.dart';
import '../services/layout_canvas_placement_action_service.dart';
import '../services/layout_canvas_view_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../utils/selection_bounds.dart';
import 'editor_command_palette.dart';
import 'keyboard_shortcuts_dialog.dart';

class EditorShortcutScope extends ConsumerStatefulWidget {
  final Widget child;

  const EditorShortcutScope({super.key, required this.child});

  @override
  ConsumerState<EditorShortcutScope> createState() =>
      _EditorShortcutScopeState();
}

class _EditorShortcutScopeState extends ConsumerState<EditorShortcutScope> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Layout builder canvas');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutStateProvider);
    final notifier = ref.read(layoutStateProvider.notifier);
    final previewNotifier = ref.read(responsivePreviewProvider.notifier);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeSelectionIntent(
          Offset(-1, 0),
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeSelectionIntent(
          Offset(1, 0),
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeSelectionIntent(
          Offset(0, -1),
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeSelectionIntent(
          Offset(0, 1),
        ),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          shift: true,
        ): _NudgeSelectionIntent(Offset(-1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          shift: true,
        ): _NudgeSelectionIntent(Offset(1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          shift: true,
        ): _NudgeSelectionIntent(Offset(0, -1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          shift: true,
        ): _NudgeSelectionIntent(Offset(0, 1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          control: true,
        ): _ResizeSelectionIntent(Offset(-1, 0)),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          control: true,
        ): _ResizeSelectionIntent(Offset(1, 0)),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          control: true,
        ): _ResizeSelectionIntent(Offset(0, -1)),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          control: true,
        ): _ResizeSelectionIntent(Offset(0, 1)),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          meta: true,
        ): _ResizeSelectionIntent(Offset(-1, 0)),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          meta: true,
        ): _ResizeSelectionIntent(Offset(1, 0)),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          meta: true,
        ): _ResizeSelectionIntent(Offset(0, -1)),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          meta: true,
        ): _ResizeSelectionIntent(Offset(0, 1)),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          control: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(-1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          control: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          control: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(0, -1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          control: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(0, 1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          meta: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(-1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          meta: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(1, 0), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          meta: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(0, -1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          meta: true,
          shift: true,
        ): _ResizeSelectionIntent(Offset(0, 1), large: true),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          alt: true,
          control: true,
        ): _LayoutRuleNudgeSelectionIntent(columns: -1),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          alt: true,
          control: true,
        ): _LayoutRuleNudgeSelectionIntent(columns: 1),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          alt: true,
          control: true,
        ): _LayoutRuleNudgeSelectionIntent(rows: -1),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          alt: true,
          control: true,
        ): _LayoutRuleNudgeSelectionIntent(rows: 1),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          alt: true,
          meta: true,
        ): _LayoutRuleNudgeSelectionIntent(columns: -1),
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          alt: true,
          meta: true,
        ): _LayoutRuleNudgeSelectionIntent(columns: 1),
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
          alt: true,
          meta: true,
        ): _LayoutRuleNudgeSelectionIntent(rows: -1),
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
          alt: true,
          meta: true,
        ): _LayoutRuleNudgeSelectionIntent(rows: 1),
        SingleActivator(LogicalKeyboardKey.delete): _DeleteSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.backspace): _DeleteSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyD, control: true):
            _DuplicateSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyD, meta: true):
            _DuplicateSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, control: true):
            _CopySelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, meta: true):
            _CopySelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, control: true, shift: true):
            _CopySelectionBoundsIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, meta: true, shift: true):
            _CopySelectionBoundsIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, control: true):
            _PasteSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, meta: true):
            _PasteSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): _UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, meta: true): _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.slash, control: true):
            _OpenKeyboardShortcutsIntent(),
        SingleActivator(LogicalKeyboardKey.slash, meta: true):
            _OpenKeyboardShortcutsIntent(),
        SingleActivator(LogicalKeyboardKey.keyA, control: true):
            _SelectAllIntent(),
        SingleActivator(LogicalKeyboardKey.keyA, meta: true):
            _SelectAllIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, control: true, shift: true):
            _InvertSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, meta: true, shift: true):
            _InvertSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyG, control: true):
            _GroupSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyG, meta: true):
            _GroupSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyG, control: true, shift: true):
            _UngroupSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyG, meta: true, shift: true):
            _UngroupSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.keyG, alt: true):
            _ToggleGridIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, alt: true):
            _ToggleSnapIntent(),
        SingleActivator(LogicalKeyboardKey.keyP, alt: true):
            _TogglePrecisionGuidesIntent(),
        SingleActivator(LogicalKeyboardKey.keyO, alt: true):
            _ToggleAutoGridOccupancyIntent(),
        SingleActivator(LogicalKeyboardKey.keyM, alt: true):
            _MoveSelectionToClearSpotIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, alt: true):
            _MoveSelectionToFreeAutoGridCellsIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, alt: true, shift: true):
            _ResolveVisibleAutoGridConflictsIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, alt: true, shift: true):
            _CompactVisibleAutoGridIntent(),
        SingleActivator(LogicalKeyboardKey.keyL, alt: true):
            _ToggleSelectionLockIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, alt: true):
            _ToggleSelectionVisibilityIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, alt: true):
            _CenterSelectionOnCanvasIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, alt: true):
            _MoveSelectionInsideCanvasIntent(),
        SingleActivator(LogicalKeyboardKey.keyH, alt: true, shift: true):
            _CenterSelectionHorizontallyIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, alt: true, shift: true):
            _CenterSelectionVerticallyIntent(),
        SingleActivator(LogicalKeyboardKey.keyR, alt: true):
            _TogglePreviewModeIntent(),
        SingleActivator(
          LogicalKeyboardKey.digit1,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.desktop),
        SingleActivator(
          LogicalKeyboardKey.digit2,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.tablet),
        SingleActivator(
          LogicalKeyboardKey.digit3,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.mobile),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          alt: true,
        ): _CyclePreviewDeviceIntent(reverse: true),
        SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            _CyclePreviewDeviceIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            _SelectLayerAboveIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            _SelectLayerBelowIntent(),
        SingleActivator(LogicalKeyboardKey.escape): _ClearSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.bracketRight, control: true):
            _BringForwardIntent(),
        SingleActivator(LogicalKeyboardKey.bracketRight, meta: true):
            _BringForwardIntent(),
        SingleActivator(
              LogicalKeyboardKey.bracketRight,
              control: true,
              shift: true,
            ):
            _BringToFrontIntent(),
        SingleActivator(
              LogicalKeyboardKey.bracketRight,
              meta: true,
              shift: true,
            ):
            _BringToFrontIntent(),
        SingleActivator(LogicalKeyboardKey.bracketLeft, control: true):
            _SendBackwardIntent(),
        SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true):
            _SendBackwardIntent(),
        SingleActivator(
              LogicalKeyboardKey.bracketLeft,
              control: true,
              shift: true,
            ):
            _SendToBackIntent(),
        SingleActivator(
              LogicalKeyboardKey.bracketLeft,
              meta: true,
              shift: true,
            ):
            _SendToBackIntent(),
        SingleActivator(LogicalKeyboardKey.equal, control: true):
            _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.equal, meta: true): _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.minus, control: true):
            _ZoomOutIntent(),
        SingleActivator(LogicalKeyboardKey.minus, meta: true): _ZoomOutIntent(),
        SingleActivator(LogicalKeyboardKey.digit0, control: true):
            _ResetZoomIntent(),
        SingleActivator(LogicalKeyboardKey.digit0, meta: true):
            _ResetZoomIntent(),
        SingleActivator(LogicalKeyboardKey.digit1, control: true):
            _FitCanvasIntent(),
        SingleActivator(LogicalKeyboardKey.digit1, meta: true):
            _FitCanvasIntent(),
        SingleActivator(LogicalKeyboardKey.digit2, control: true):
            _FitSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.digit2, meta: true):
            _FitSelectionIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NudgeSelectionIntent: CallbackAction<_NudgeSelectionIntent>(
            onInvoke: (intent) {
              final step =
                  layoutState.gridSettings.snapToGrid
                      ? layoutState.gridSettings.gridSize
                      : 1.0;
              final multiplier = intent.large ? 5.0 : 1.0;
              notifier.nudgeSelectedComponent(
                intent.direction * step * multiplier,
              );
              return null;
            },
          ),
          _ResizeSelectionIntent: CallbackAction<_ResizeSelectionIntent>(
            onInvoke: (intent) {
              final step =
                  layoutState.gridSettings.snapToGrid
                      ? layoutState.gridSettings.gridSize
                      : 1.0;
              final multiplier = intent.large ? 5.0 : 1.0;
              notifier.resizeSelectedComponentsBy(
                intent.delta * step * multiplier,
              );
              return null;
            },
          ),
          _LayoutRuleNudgeSelectionIntent:
              CallbackAction<_LayoutRuleNudgeSelectionIntent>(
                onInvoke: (intent) {
                  switch (layoutState.config.layoutMechanism) {
                    case LayoutMechanism.tabularColumns:
                      if (intent.columns != 0) {
                        notifier.nudgeSelectedByTabularColumns(intent.columns);
                      }
                      if (intent.rows != 0) {
                        notifier.nudgeSelectedByTabularRows(intent.rows);
                      }
                      break;
                    case LayoutMechanism.autoGrid:
                      if (intent.columns != 0) {
                        notifier.nudgeSelectedByAutoGridColumns(intent.columns);
                      }
                      if (intent.rows != 0) {
                        notifier.nudgeSelectedByAutoGridRows(intent.rows);
                      }
                      break;
                    case LayoutMechanism.freeform:
                    case LayoutMechanism.grid:
                      break;
                  }
                  return null;
                },
              ),
          _DeleteSelectionIntent: CallbackAction<_DeleteSelectionIntent>(
            onInvoke: (_) {
              notifier.removeSelectedComponent();
              return null;
            },
          ),
          _DuplicateSelectionIntent: CallbackAction<_DuplicateSelectionIntent>(
            onInvoke: (_) {
              notifier.duplicateSelectedComponent();
              return null;
            },
          ),
          _CopySelectionIntent: CallbackAction<_CopySelectionIntent>(
            onInvoke: (_) {
              notifier.copySelectedComponent();
              return null;
            },
          ),
          _CopySelectionBoundsIntent:
              CallbackAction<_CopySelectionBoundsIntent>(
                onInvoke: (_) {
                  copyLayoutSelectionBounds(
                    context,
                    layoutState.selectedComponents,
                  );
                  return null;
                },
              ),
          _PasteSelectionIntent: CallbackAction<_PasteSelectionIntent>(
            onInvoke: (_) {
              final pointerPosition =
                  ref.read(canvasViewportProvider).pointerCanvasPosition;
              if (pointerPosition == null) {
                notifier.pasteComponent();
              } else {
                notifier.pasteComponentAt(pointerPosition);
              }
              return null;
            },
          ),
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              notifier.undo();
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              notifier.redo();
              return null;
            },
          ),
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              notifier.saveLayout();
              return null;
            },
          ),
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (_) {
              showEditorCommandPalette(context, ref);
              return null;
            },
          ),
          _OpenKeyboardShortcutsIntent:
              CallbackAction<_OpenKeyboardShortcutsIntent>(
                onInvoke: (_) {
                  showKeyboardShortcutsDialog(context);
                  return null;
                },
              ),
          _SelectAllIntent: CallbackAction<_SelectAllIntent>(
            onInvoke: (_) {
              notifier.selectAllComponents();
              return null;
            },
          ),
          _InvertSelectionIntent: CallbackAction<_InvertSelectionIntent>(
            onInvoke: (_) {
              notifier.invertSelection();
              return null;
            },
          ),
          _GroupSelectionIntent: CallbackAction<_GroupSelectionIntent>(
            onInvoke: (_) {
              notifier.groupSelectedComponents();
              return null;
            },
          ),
          _UngroupSelectionIntent: CallbackAction<_UngroupSelectionIntent>(
            onInvoke: (_) {
              notifier.ungroupSelectedComponents();
              return null;
            },
          ),
          _ToggleGridIntent: CallbackAction<_ToggleGridIntent>(
            onInvoke: (_) {
              notifier.toggleGrid();
              return null;
            },
          ),
          _ToggleSnapIntent: CallbackAction<_ToggleSnapIntent>(
            onInvoke: (_) {
              notifier.toggleSnapToGrid();
              return null;
            },
          ),
          _TogglePrecisionGuidesIntent:
              CallbackAction<_TogglePrecisionGuidesIntent>(
                onInvoke: (_) {
                  layoutCanvasViewActionService.togglePrecisionGuides(
                    context,
                    ref,
                  );
                  return null;
                },
              ),
          _ToggleAutoGridOccupancyIntent:
              CallbackAction<_ToggleAutoGridOccupancyIntent>(
                onInvoke: (_) {
                  if (layoutState.config.layoutMechanism ==
                      LayoutMechanism.autoGrid) {
                    layoutCanvasViewActionService.toggleAutoGridOccupancy(
                      context,
                      ref,
                    );
                  }
                  return null;
                },
              ),
          _MoveSelectionToFreeAutoGridCellsIntent:
              CallbackAction<_MoveSelectionToFreeAutoGridCellsIntent>(
                onInvoke: (_) {
                  if (layoutState.config.layoutMechanism ==
                      LayoutMechanism.autoGrid) {
                    layoutAutoGridActionService.moveSelectionToFreeCells(
                      context,
                      ref,
                    );
                  }
                  return null;
                },
              ),
          _MoveSelectionToClearSpotIntent:
              CallbackAction<_MoveSelectionToClearSpotIntent>(
                onInvoke: (_) {
                  layoutClearSpotActionService.moveSelectionToClearSpot(
                    context,
                    ref,
                  );
                  return null;
                },
              ),
          _ResolveVisibleAutoGridConflictsIntent:
              CallbackAction<_ResolveVisibleAutoGridConflictsIntent>(
                onInvoke: (_) {
                  if (layoutState.config.layoutMechanism ==
                      LayoutMechanism.autoGrid) {
                    layoutAutoGridActionService.resolveVisibleConflicts(
                      context,
                      ref,
                    );
                  }
                  return null;
                },
              ),
          _CompactVisibleAutoGridIntent:
              CallbackAction<_CompactVisibleAutoGridIntent>(
                onInvoke: (_) {
                  if (layoutState.config.layoutMechanism ==
                      LayoutMechanism.autoGrid) {
                    layoutAutoGridActionService.compactVisible(context, ref);
                  }
                  return null;
                },
              ),
          _ToggleSelectionLockIntent:
              CallbackAction<_ToggleSelectionLockIntent>(
                onInvoke: (_) {
                  notifier.toggleSelectedComponentLock();
                  return null;
                },
              ),
          _ToggleSelectionVisibilityIntent:
              CallbackAction<_ToggleSelectionVisibilityIntent>(
                onInvoke: (_) {
                  notifier.toggleSelectedComponentVisibility();
                  return null;
                },
              ),
          _CenterSelectionOnCanvasIntent:
              CallbackAction<_CenterSelectionOnCanvasIntent>(
                onInvoke: (_) {
                  layoutCanvasPlacementActionService.centerSelectionOnCanvas(
                    context,
                    ref,
                  );
                  return null;
                },
              ),
          _MoveSelectionInsideCanvasIntent:
              CallbackAction<_MoveSelectionInsideCanvasIntent>(
                onInvoke: (_) {
                  layoutCanvasContainmentActionService
                      .moveSelectionInsideCanvas(context, ref);
                  return null;
                },
              ),
          _CenterSelectionHorizontallyIntent:
              CallbackAction<_CenterSelectionHorizontallyIntent>(
                onInvoke: (_) {
                  layoutCanvasPlacementActionService.centerSelectionOnCanvas(
                    context,
                    ref,
                    vertical: false,
                  );
                  return null;
                },
              ),
          _CenterSelectionVerticallyIntent:
              CallbackAction<_CenterSelectionVerticallyIntent>(
                onInvoke: (_) {
                  layoutCanvasPlacementActionService.centerSelectionOnCanvas(
                    context,
                    ref,
                    horizontal: false,
                  );
                  return null;
                },
              ),
          _TogglePreviewModeIntent: CallbackAction<_TogglePreviewModeIntent>(
            onInvoke: (_) {
              previewNotifier.togglePreviewMode();
              return null;
            },
          ),
          _SetPreviewDeviceIntent: CallbackAction<_SetPreviewDeviceIntent>(
            onInvoke: (intent) {
              previewNotifier.setDevice(intent.device);
              return null;
            },
          ),
          _CyclePreviewDeviceIntent: CallbackAction<_CyclePreviewDeviceIntent>(
            onInvoke: (intent) {
              previewNotifier.cycleDevice(reverse: intent.reverse);
              return null;
            },
          ),
          _SelectLayerAboveIntent: CallbackAction<_SelectLayerAboveIntent>(
            onInvoke: (_) {
              notifier.selectAdjacentLayer(towardFront: true);
              return null;
            },
          ),
          _SelectLayerBelowIntent: CallbackAction<_SelectLayerBelowIntent>(
            onInvoke: (_) {
              notifier.selectAdjacentLayer(towardFront: false);
              return null;
            },
          ),
          _ClearSelectionIntent: CallbackAction<_ClearSelectionIntent>(
            onInvoke: (_) {
              notifier.clearSelection();
              return null;
            },
          ),
          _BringForwardIntent: CallbackAction<_BringForwardIntent>(
            onInvoke: (_) {
              notifier.bringSelectedForward();
              return null;
            },
          ),
          _BringToFrontIntent: CallbackAction<_BringToFrontIntent>(
            onInvoke: (_) {
              notifier.bringSelectedToFront();
              return null;
            },
          ),
          _SendBackwardIntent: CallbackAction<_SendBackwardIntent>(
            onInvoke: (_) {
              notifier.sendSelectedBackward();
              return null;
            },
          ),
          _SendToBackIntent: CallbackAction<_SendToBackIntent>(
            onInvoke: (_) {
              notifier.sendSelectedToBack();
              return null;
            },
          ),
          _ZoomInIntent: CallbackAction<_ZoomInIntent>(
            onInvoke: (_) {
              layoutCanvasViewActionService.zoomIn(context, ref);
              return null;
            },
          ),
          _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
            onInvoke: (_) {
              layoutCanvasViewActionService.zoomOut(context, ref);
              return null;
            },
          ),
          _ResetZoomIntent: CallbackAction<_ResetZoomIntent>(
            onInvoke: (_) {
              layoutCanvasViewActionService.resetZoom(context, ref);
              return null;
            },
          ),
          _FitCanvasIntent: CallbackAction<_FitCanvasIntent>(
            onInvoke: (_) {
              layoutCanvasViewActionService.fitCanvas(context, ref);
              return null;
            },
          ),
          _FitSelectionIntent: CallbackAction<_FitSelectionIntent>(
            onInvoke: (_) {
              layoutCanvasViewActionService.fitSelection(context, ref);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class PreviewShortcutScope extends ConsumerStatefulWidget {
  final Widget child;

  const PreviewShortcutScope({super.key, required this.child});

  @override
  ConsumerState<PreviewShortcutScope> createState() =>
      _PreviewShortcutScopeState();
}

class _PreviewShortcutScopeState extends ConsumerState<PreviewShortcutScope> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Layout builder preview');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewNotifier = ref.read(responsivePreviewProvider.notifier);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyR, alt: true):
            _TogglePreviewModeIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, alt: true):
            _TogglePreviewBreakpointsIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.slash, control: true):
            _OpenKeyboardShortcutsIntent(),
        SingleActivator(LogicalKeyboardKey.slash, meta: true):
            _OpenKeyboardShortcutsIntent(),
        SingleActivator(
          LogicalKeyboardKey.digit1,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.desktop),
        SingleActivator(
          LogicalKeyboardKey.digit2,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.tablet),
        SingleActivator(
          LogicalKeyboardKey.digit3,
          alt: true,
        ): _SetPreviewDeviceIntent(DeviceType.mobile),
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          alt: true,
        ): _CyclePreviewDeviceIntent(reverse: true),
        SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            _CyclePreviewDeviceIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _TogglePreviewModeIntent: CallbackAction<_TogglePreviewModeIntent>(
            onInvoke: (_) {
              previewNotifier.togglePreviewMode();
              return null;
            },
          ),
          _TogglePreviewBreakpointsIntent:
              CallbackAction<_TogglePreviewBreakpointsIntent>(
                onInvoke: (_) {
                  previewNotifier.toggleBreakpoints();
                  return null;
                },
              ),
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (_) {
              showEditorCommandPalette(context, ref);
              return null;
            },
          ),
          _OpenKeyboardShortcutsIntent:
              CallbackAction<_OpenKeyboardShortcutsIntent>(
                onInvoke: (_) {
                  showKeyboardShortcutsDialog(context);
                  return null;
                },
              ),
          _SetPreviewDeviceIntent: CallbackAction<_SetPreviewDeviceIntent>(
            onInvoke: (intent) {
              previewNotifier.setDevice(intent.device);
              return null;
            },
          ),
          _CyclePreviewDeviceIntent: CallbackAction<_CyclePreviewDeviceIntent>(
            onInvoke: (intent) {
              previewNotifier.cycleDevice(reverse: intent.reverse);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _NudgeSelectionIntent extends Intent {
  final Offset direction;
  final bool large;

  const _NudgeSelectionIntent(this.direction, {this.large = false});
}

class _ResizeSelectionIntent extends Intent {
  final Offset delta;
  final bool large;

  const _ResizeSelectionIntent(this.delta, {this.large = false});
}

class _LayoutRuleNudgeSelectionIntent extends Intent {
  final int columns;
  final int rows;

  const _LayoutRuleNudgeSelectionIntent({this.columns = 0, this.rows = 0});
}

class _DeleteSelectionIntent extends Intent {
  const _DeleteSelectionIntent();
}

class _DuplicateSelectionIntent extends Intent {
  const _DuplicateSelectionIntent();
}

class _CopySelectionIntent extends Intent {
  const _CopySelectionIntent();
}

class _CopySelectionBoundsIntent extends Intent {
  const _CopySelectionBoundsIntent();
}

class _PasteSelectionIntent extends Intent {
  const _PasteSelectionIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

class _OpenKeyboardShortcutsIntent extends Intent {
  const _OpenKeyboardShortcutsIntent();
}

class _SelectAllIntent extends Intent {
  const _SelectAllIntent();
}

class _InvertSelectionIntent extends Intent {
  const _InvertSelectionIntent();
}

class _GroupSelectionIntent extends Intent {
  const _GroupSelectionIntent();
}

class _UngroupSelectionIntent extends Intent {
  const _UngroupSelectionIntent();
}

class _ToggleGridIntent extends Intent {
  const _ToggleGridIntent();
}

class _ToggleSnapIntent extends Intent {
  const _ToggleSnapIntent();
}

class _TogglePrecisionGuidesIntent extends Intent {
  const _TogglePrecisionGuidesIntent();
}

class _ToggleAutoGridOccupancyIntent extends Intent {
  const _ToggleAutoGridOccupancyIntent();
}

class _MoveSelectionToFreeAutoGridCellsIntent extends Intent {
  const _MoveSelectionToFreeAutoGridCellsIntent();
}

class _MoveSelectionToClearSpotIntent extends Intent {
  const _MoveSelectionToClearSpotIntent();
}

class _ResolveVisibleAutoGridConflictsIntent extends Intent {
  const _ResolveVisibleAutoGridConflictsIntent();
}

class _CompactVisibleAutoGridIntent extends Intent {
  const _CompactVisibleAutoGridIntent();
}

class _ToggleSelectionLockIntent extends Intent {
  const _ToggleSelectionLockIntent();
}

class _ToggleSelectionVisibilityIntent extends Intent {
  const _ToggleSelectionVisibilityIntent();
}

class _CenterSelectionOnCanvasIntent extends Intent {
  const _CenterSelectionOnCanvasIntent();
}

class _MoveSelectionInsideCanvasIntent extends Intent {
  const _MoveSelectionInsideCanvasIntent();
}

class _CenterSelectionHorizontallyIntent extends Intent {
  const _CenterSelectionHorizontallyIntent();
}

class _CenterSelectionVerticallyIntent extends Intent {
  const _CenterSelectionVerticallyIntent();
}

class _TogglePreviewModeIntent extends Intent {
  const _TogglePreviewModeIntent();
}

class _TogglePreviewBreakpointsIntent extends Intent {
  const _TogglePreviewBreakpointsIntent();
}

class _SetPreviewDeviceIntent extends Intent {
  final DeviceType device;

  const _SetPreviewDeviceIntent(this.device);
}

class _CyclePreviewDeviceIntent extends Intent {
  final bool reverse;

  const _CyclePreviewDeviceIntent({this.reverse = false});
}

class _SelectLayerAboveIntent extends Intent {
  const _SelectLayerAboveIntent();
}

class _SelectLayerBelowIntent extends Intent {
  const _SelectLayerBelowIntent();
}

class _ClearSelectionIntent extends Intent {
  const _ClearSelectionIntent();
}

class _BringForwardIntent extends Intent {
  const _BringForwardIntent();
}

class _BringToFrontIntent extends Intent {
  const _BringToFrontIntent();
}

class _SendBackwardIntent extends Intent {
  const _SendBackwardIntent();
}

class _SendToBackIntent extends Intent {
  const _SendToBackIntent();
}

class _ZoomInIntent extends Intent {
  const _ZoomInIntent();
}

class _ZoomOutIntent extends Intent {
  const _ZoomOutIntent();
}

class _ResetZoomIntent extends Intent {
  const _ResetZoomIntent();
}

class _FitCanvasIntent extends Intent {
  const _FitCanvasIntent();
}

class _FitSelectionIntent extends Intent {
  const _FitSelectionIntent();
}
