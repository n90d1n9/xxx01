import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_drag_preview.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_canvas_containment_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';
import 'component_renderer.dart';

class DraggableComponent extends ConsumerWidget {
  final ComponentData component;
  final bool isSelected;
  final bool showResizeHandles;

  const DraggableComponent({
    super.key,
    required this.component,
    required this.isSelected,
    this.showResizeHandles = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!component.isVisible) return const SizedBox.shrink();

    final borderColor =
        component.isLocked
            ? Colors.red
            : isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent;
    final canDrag = !component.isLocked && component.style.isDraggable;

    return Positioned(
      left: component.position.dx,
      top: component.position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _selectFromPointer(ref);
        },
        onSecondaryTapDown:
            (details) => _showContextMenu(context, ref, details.globalPosition),
        onLongPressStart:
            (details) => _showContextMenu(context, ref, details.globalPosition),
        onPanStart:
            canDrag
                ? (_) {
                  if (!isSelected) _selectFromPointer(ref);
                  final notifier = ref.read(layoutStateProvider.notifier);
                  notifier.beginInteractionTransaction();
                  _updateLayoutDragInteractionPreview(
                    ref,
                    activeComponentId: component.id,
                  );
                }
                : null,
        onPanUpdate:
            canDrag
                ? (details) {
                  final notifier = ref.read(layoutStateProvider.notifier);
                  notifier.moveComponent(component.id, details.delta);
                  _updateLayoutDragInteractionPreview(
                    ref,
                    activeComponentId: component.id,
                  );
                }
                : null,
        onPanEnd:
            canDrag
                ? (_) {
                  final notifier = ref.read(layoutStateProvider.notifier);
                  notifier.resolveActiveDragConflict(component.id);
                  notifier.endInteractionTransaction();
                  _clearLayoutDragInteractionPreview(ref);
                }
                : null,
        onPanCancel:
            canDrag
                ? () {
                  ref
                      .read(layoutStateProvider.notifier)
                      .endInteractionTransaction();
                  _clearLayoutDragInteractionPreview(ref);
                }
                : null,
        child: SizedBox(
          width: component.size.width,
          height: component.size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IgnorePointer(
                  child: ComponentRenderer(component: component),
                ),
              ),
              if (component.isLocked) const _LockBadge(),
              if (component.properties.events.isNotEmpty)
                _ComponentEventBadge(
                  count: component.properties.events.length,
                  events: component.properties.events,
                  top: component.isLocked ? 28 : 4,
                ),
              if (showResizeHandles &&
                  component.style.isResizable &&
                  !component.isLocked)
                _ResizeHandles(component: component),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFromPointer(WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    if (_isMultiSelectModifierPressed()) {
      notifier.toggleComponentSelection(component.id);
    } else {
      notifier.selectComponent(component.id);
    }

    ref.read(selectedComponentProvider.notifier).state = component.id;
  }

  void _selectForContextMenu(WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    if (!layoutState.selectedComponentIds.contains(component.id)) {
      ref.read(layoutStateProvider.notifier).selectComponent(component.id);
    }

    ref.read(selectedComponentProvider.notifier).state = component.id;
  }

  bool _isMultiSelectModifierPressed() {
    final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
    return pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.shiftRight) ||
        pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.controlRight) ||
        pressedKeys.contains(LogicalKeyboardKey.metaLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.metaRight);
  }

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset globalPosition,
  ) async {
    _selectForContextMenu(ref);
    final notifier = ref.read(layoutStateProvider.notifier);
    final groupAction = _selectedGroupAction(ref);
    final layoutState = ref.read(layoutStateProvider);
    final selectedCount = layoutState.selectedComponents.length;
    final isAutoGrid =
        layoutState.config.layoutMechanism == LayoutMechanism.autoGrid;
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: selectedCount > 0,
      preview: notifier.selectedConflictResolutionPreview(),
    );
    final canMoveToFreeAutoGridCells =
        isAutoGrid &&
        layoutState.selectedComponents.any((component) => !component.isLocked);

    final action = await showMenu<_ComponentMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: _ComponentMenuAction.copy,
          child: _ComponentContextMenuItem(
            icon: Icons.content_copy,
            label: selectedCount > 1 ? 'Copy selection' : 'Copy',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.duplicate,
          child: _ComponentContextMenuItem(
            icon: Icons.control_point_duplicate,
            label: 'Duplicate',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.selectSameType,
          child: _ComponentContextMenuItem(
            icon: Icons.filter_alt_outlined,
            label: 'Select same type',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.invertSelection,
          child: _ComponentContextMenuItem(
            icon: Icons.swap_horiz,
            label: 'Invert selection',
          ),
        ),
        if (groupAction != null)
          PopupMenuItem(
            value: groupAction,
            child: _ComponentContextMenuItem(
              icon:
                  groupAction == _ComponentMenuAction.ungroup
                      ? Icons.call_split_outlined
                      : Icons.group_work_outlined,
              label:
                  groupAction == _ComponentMenuAction.ungroup
                      ? 'Ungroup'
                      : 'Group',
            ),
          ),
        const PopupMenuItem(
          value: _ComponentMenuAction.keepInsideCanvas,
          child: _ComponentContextMenuItem(
            icon: Icons.fit_screen,
            label: 'Keep inside canvas',
          ),
        ),
        if (clearSpotAction.isAvailable)
          PopupMenuItem(
            value: _ComponentMenuAction.moveToClearSpot,
            child: _ComponentContextMenuItem(
              icon: Icons.near_me_outlined,
              label: clearSpotAction.menuActionLabel(prefix: 'Move to'),
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: canMoveToFreeAutoGridCells,
            value: _ComponentMenuAction.moveToFreeAutoGridCells,
            child: const _ComponentContextMenuItem(
              icon: Icons.auto_fix_high_outlined,
              label: 'Move to free Auto Grid cells',
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: canMoveToFreeAutoGridCells,
            value: _ComponentMenuAction.selectAutoGridConflicts,
            child: const _ComponentContextMenuItem(
              icon: Icons.manage_search_outlined,
              label: 'Select Auto Grid conflicts',
            ),
          ),
        if (selectedCount > 1) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignLeft,
            child: _ComponentContextMenuItem(
              icon: Icons.format_align_left,
              label: 'Align left',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignCenter,
            child: _ComponentContextMenuItem(
              icon: Icons.align_horizontal_center,
              label: 'Align center',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignRight,
            child: _ComponentContextMenuItem(
              icon: Icons.format_align_right,
              label: 'Align right',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignTop,
            child: _ComponentContextMenuItem(
              icon: Icons.vertical_align_top,
              label: 'Align top',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignMiddle,
            child: _ComponentContextMenuItem(
              icon: Icons.vertical_align_center,
              label: 'Align middle',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.alignBottom,
            child: _ComponentContextMenuItem(
              icon: Icons.vertical_align_bottom,
              label: 'Align bottom',
            ),
          ),
        ],
        if (selectedCount > 2) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: _ComponentMenuAction.distributeHorizontal,
            child: _ComponentContextMenuItem(
              icon: Icons.more_horiz,
              label: 'Distribute horizontally',
            ),
          ),
          const PopupMenuItem(
            value: _ComponentMenuAction.distributeVertical,
            child: _ComponentContextMenuItem(
              icon: Icons.more_vert,
              label: 'Distribute vertically',
            ),
          ),
        ],
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _ComponentMenuAction.lock,
          child: _ComponentContextMenuItem(
            icon: component.isLocked ? Icons.lock_open : Icons.lock,
            label: component.isLocked ? 'Unlock' : 'Lock',
          ),
        ),
        PopupMenuItem(
          enabled: !component.isLocked,
          value: _ComponentMenuAction.visibility,
          child: _ComponentContextMenuItem(
            icon:
                component.isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
            label: component.isVisible ? 'Hide' : 'Show',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _ComponentMenuAction.bringForward,
          child: _ComponentContextMenuItem(
            icon: Icons.flip_to_front,
            label: 'Bring forward',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.bringToFront,
          child: _ComponentContextMenuItem(
            icon: Icons.vertical_align_top,
            label: 'Bring to front',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.sendBackward,
          child: _ComponentContextMenuItem(
            icon: Icons.flip_to_back,
            label: 'Send backward',
          ),
        ),
        const PopupMenuItem(
          value: _ComponentMenuAction.sendToBack,
          child: _ComponentContextMenuItem(
            icon: Icons.vertical_align_bottom,
            label: 'Send to back',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _ComponentMenuAction.delete,
          child: _ComponentContextMenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case _ComponentMenuAction.copy:
        notifier.copySelectedComponent();
        break;
      case _ComponentMenuAction.duplicate:
        notifier.duplicateSelectedComponent();
        break;
      case _ComponentMenuAction.selectSameType:
        notifier.selectComponentsByType(component.type);
        break;
      case _ComponentMenuAction.invertSelection:
        notifier.invertSelection();
        break;
      case _ComponentMenuAction.group:
        notifier.groupSelectedComponents();
        break;
      case _ComponentMenuAction.ungroup:
        notifier.ungroupSelectedComponents();
        break;
      case _ComponentMenuAction.keepInsideCanvas:
        layoutCanvasContainmentActionService.moveSelectionInsideCanvas(
          context,
          ref,
        );
        break;
      case _ComponentMenuAction.moveToClearSpot:
        layoutClearSpotActionService.moveSelectionToClearSpot(context, ref);
        break;
      case _ComponentMenuAction.moveToFreeAutoGridCells:
        layoutAutoGridActionService.moveSelectionToFreeCells(context, ref);
        break;
      case _ComponentMenuAction.selectAutoGridConflicts:
        layoutAutoGridActionService.selectConflictPartnersForSelection(
          context,
          ref,
        );
        break;
      case _ComponentMenuAction.alignLeft:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.left,
        );
        break;
      case _ComponentMenuAction.alignCenter:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.center,
        );
        break;
      case _ComponentMenuAction.alignRight:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.right,
        );
        break;
      case _ComponentMenuAction.alignTop:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.top,
        );
        break;
      case _ComponentMenuAction.alignMiddle:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.middle,
        );
        break;
      case _ComponentMenuAction.alignBottom:
        layoutSelectionGeometryActionService.alignSelection(
          context,
          ref,
          ComponentAlignment.bottom,
        );
        break;
      case _ComponentMenuAction.distributeHorizontal:
        layoutSelectionGeometryActionService.distributeSelection(
          context,
          ref,
          ComponentDistribution.horizontal,
        );
        break;
      case _ComponentMenuAction.distributeVertical:
        layoutSelectionGeometryActionService.distributeSelection(
          context,
          ref,
          ComponentDistribution.vertical,
        );
        break;
      case _ComponentMenuAction.delete:
        notifier.removeSelectedComponent();
        break;
      case _ComponentMenuAction.lock:
        notifier.toggleSelectedComponentLock();
        break;
      case _ComponentMenuAction.visibility:
        notifier.toggleSelectedComponentVisibility();
        break;
      case _ComponentMenuAction.bringForward:
        if (selectedCount > 1) {
          notifier.bringSelectedForward();
        } else {
          notifier.bringForward(component.id);
        }
        break;
      case _ComponentMenuAction.bringToFront:
        if (selectedCount > 1) {
          notifier.bringSelectedToFront();
        } else {
          notifier.bringToFront(component.id);
        }
        break;
      case _ComponentMenuAction.sendBackward:
        if (selectedCount > 1) {
          notifier.sendSelectedBackward();
        } else {
          notifier.sendBackward(component.id);
        }
        break;
      case _ComponentMenuAction.sendToBack:
        if (selectedCount > 1) {
          notifier.sendSelectedToBack();
        } else {
          notifier.sendToBack(component.id);
        }
        break;
    }
  }

  _ComponentMenuAction? _selectedGroupAction(WidgetRef ref) {
    final selectedComponents = ref.read(layoutStateProvider).selectedComponents;
    if (selectedComponents.length < 2) return null;

    final groupIds =
        selectedComponents
            .map((component) => component.properties.parentId)
            .whereType<String>()
            .toSet();
    final isSingleGroupSelection =
        groupIds.length == 1 &&
        selectedComponents.every(
          (component) => component.properties.parentId == groupIds.first,
        );

    return isSingleGroupSelection
        ? _ComponentMenuAction.ungroup
        : _ComponentMenuAction.group;
  }
}

void _updateLayoutDragInteractionPreview(
  WidgetRef ref, {
  required String activeComponentId,
}) {
  final layoutState = ref.read(layoutStateProvider);
  final viewportNotifier = ref.read(canvasViewportProvider.notifier);
  final preview = layoutDragPreviewFor(
    components: layoutState.components,
    selectedComponentIds: layoutState.selectedComponentIds,
    activeComponentId: activeComponentId,
    config: layoutState.config,
    gridSettings: layoutState.gridSettings,
  );

  viewportNotifier.setLayoutDragPreview(preview);
}

void _clearLayoutDragInteractionPreview(WidgetRef ref) {
  ref.read(canvasViewportProvider.notifier).clearLayoutDragPreview();
}

enum _ComponentMenuAction {
  copy,
  duplicate,
  selectSameType,
  invertSelection,
  group,
  ungroup,
  keepInsideCanvas,
  moveToClearSpot,
  moveToFreeAutoGridCells,
  selectAutoGridConflicts,
  alignLeft,
  alignCenter,
  alignRight,
  alignTop,
  alignMiddle,
  alignBottom,
  distributeHorizontal,
  distributeVertical,
  delete,
  lock,
  visibility,
  bringForward,
  bringToFront,
  sendBackward,
  sendToBack,
}

class _ComponentContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComponentContextMenuItem({required this.icon, required this.label});

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

class _ResizeHandles extends StatelessWidget {
  final ComponentData component;

  const _ResizeHandles({required this.component});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: component.size.width,
      height: component.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final direction in _ResizeHandleDirection.values)
            _ResizeHandle(
              key: ValueKey(direction),
              component: component,
              direction: direction,
            ),
        ],
      ),
    );
  }
}

class _ResizeHandle extends ConsumerStatefulWidget {
  final ComponentData component;
  final _ResizeHandleDirection direction;

  const _ResizeHandle({
    super.key,
    required this.component,
    required this.direction,
  });

  @override
  ConsumerState<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends ConsumerState<_ResizeHandle> {
  static const _hitSize = 18.0;
  static const _visualSize = 10.0;

  Rect? _startBounds;
  Offset _dragDelta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final direction = widget.direction;

    return Positioned(
      left:
          direction.affectsLeft
              ? -_hitSize / 2
              : direction.affectsRight
              ? null
              : widget.component.size.width / 2 - _hitSize / 2,
      right: direction.affectsRight ? -_hitSize / 2 : null,
      top:
          direction.affectsTop
              ? -_hitSize / 2
              : direction.affectsBottom
              ? null
              : widget.component.size.height / 2 - _hitSize / 2,
      bottom: direction.affectsBottom ? -_hitSize / 2 : null,
      child: MouseRegion(
        cursor: direction.cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: (_) => _finishDrag(),
          onPanCancel: _finishDrag,
          child: SizedBox(
            width: _hitSize,
            height: _hitSize,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: const SizedBox.square(dimension: _visualSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _startBounds = _componentBounds(widget.component);
    _dragDelta = Offset.zero;
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.selectComponent(widget.component.id);
    notifier.beginInteractionTransaction();
    _updateLayoutDragInteractionPreview(
      ref,
      activeComponentId: widget.component.id,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final startBounds = _startBounds;
    if (startBounds == null) return;

    _dragDelta += details.delta;
    final config = ref.read(layoutStateProvider).config;
    final nextBounds = _resizedBounds(
      startBounds: startBounds,
      direction: widget.direction,
      delta: _dragDelta,
      minSize: Size(config.minComponentWidth, config.minComponentHeight),
      preserveAspectRatio: _isShiftPressed(),
    );

    ref
        .read(layoutStateProvider.notifier)
        .resizeComponent(widget.component.id, nextBounds);
    _updateLayoutDragInteractionPreview(
      ref,
      activeComponentId: widget.component.id,
    );
  }

  void _finishDrag() {
    ref.read(layoutStateProvider.notifier).endInteractionTransaction();
    _clearLayoutDragInteractionPreview(ref);
    _clearDrag();
  }

  void _clearDrag() {
    _startBounds = null;
    _dragDelta = Offset.zero;
  }

  Rect _componentBounds(ComponentData component) {
    return Rect.fromLTWH(
      component.position.dx,
      component.position.dy,
      component.size.width,
      component.size.height,
    );
  }

  Rect _resizedBounds({
    required Rect startBounds,
    required _ResizeHandleDirection direction,
    required Offset delta,
    required Size minSize,
    required bool preserveAspectRatio,
  }) {
    var left = startBounds.left;
    var top = startBounds.top;
    var right = startBounds.right;
    var bottom = startBounds.bottom;

    if (direction.affectsLeft) left += delta.dx;
    if (direction.affectsRight) right += delta.dx;
    if (direction.affectsTop) top += delta.dy;
    if (direction.affectsBottom) bottom += delta.dy;

    final constrained = _constrainBounds(
      Rect.fromLTRB(left, top, right, bottom),
      direction,
      minSize,
    );

    if (!preserveAspectRatio || !direction.isCorner) return constrained;

    return _preserveAspectRatio(
      constrained,
      direction,
      startBounds.width / math.max(1, startBounds.height),
      minSize,
    );
  }

  Rect _constrainBounds(
    Rect bounds,
    _ResizeHandleDirection direction,
    Size minSize,
  ) {
    var left = bounds.left;
    var top = bounds.top;
    var right = bounds.right;
    var bottom = bounds.bottom;

    if (right - left < minSize.width) {
      if (direction.affectsLeft) {
        left = right - minSize.width;
      } else {
        right = left + minSize.width;
      }
    }

    if (bottom - top < minSize.height) {
      if (direction.affectsTop) {
        top = bottom - minSize.height;
      } else {
        bottom = top + minSize.height;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _preserveAspectRatio(
    Rect bounds,
    _ResizeHandleDirection direction,
    double aspectRatio,
    Size minSize,
  ) {
    var width = bounds.width;
    var height = bounds.height;

    if (width / math.max(1, height) > aspectRatio) {
      height = width / aspectRatio;
    } else {
      width = height * aspectRatio;
    }

    width = math.max(width, minSize.width);
    height = math.max(height, minSize.height);

    if ((width / math.max(1, height)) > aspectRatio) {
      height = width / aspectRatio;
    } else {
      width = height * aspectRatio;
    }

    final left = direction.affectsLeft ? bounds.right - width : bounds.left;
    final top = direction.affectsTop ? bounds.bottom - height : bounds.top;

    return Rect.fromLTWH(left, top, width, height);
  }

  bool _isShiftPressed() {
    final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
    return pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.shiftRight);
  }
}

enum _ResizeHandleDirection {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

extension _ResizeHandleDirectionX on _ResizeHandleDirection {
  bool get affectsLeft =>
      this == _ResizeHandleDirection.left ||
      this == _ResizeHandleDirection.topLeft ||
      this == _ResizeHandleDirection.bottomLeft;

  bool get affectsRight =>
      this == _ResizeHandleDirection.right ||
      this == _ResizeHandleDirection.topRight ||
      this == _ResizeHandleDirection.bottomRight;

  bool get affectsTop =>
      this == _ResizeHandleDirection.top ||
      this == _ResizeHandleDirection.topLeft ||
      this == _ResizeHandleDirection.topRight;

  bool get affectsBottom =>
      this == _ResizeHandleDirection.bottom ||
      this == _ResizeHandleDirection.bottomLeft ||
      this == _ResizeHandleDirection.bottomRight;

  bool get isCorner =>
      this == _ResizeHandleDirection.topLeft ||
      this == _ResizeHandleDirection.topRight ||
      this == _ResizeHandleDirection.bottomRight ||
      this == _ResizeHandleDirection.bottomLeft;

  SystemMouseCursor get cursor {
    switch (this) {
      case _ResizeHandleDirection.left:
      case _ResizeHandleDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case _ResizeHandleDirection.top:
      case _ResizeHandleDirection.bottom:
        return SystemMouseCursors.resizeUpDown;
      case _ResizeHandleDirection.topLeft:
      case _ResizeHandleDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case _ResizeHandleDirection.topRight:
      case _ResizeHandleDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
    }
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 4,
      top: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(3),
          child: Icon(Icons.lock, color: Colors.white, size: 12),
        ),
      ),
    );
  }
}

class _ComponentEventBadge extends StatelessWidget {
  final int count;
  final Map<String, String> events;
  final double top;

  const _ComponentEventBadge({
    required this.count,
    required this.events,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tooltip = events.entries
        .map((entry) => '${entry.key} -> ${entry.value}')
        .join('\n');

    return Positioned(
      right: 4,
      top: top,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_outlined,
                  color: colorScheme.onSecondaryContainer,
                  size: 12,
                ),
                if (count > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
