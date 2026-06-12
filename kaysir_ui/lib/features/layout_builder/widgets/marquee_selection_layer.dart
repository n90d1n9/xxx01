import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';

class MarqueeSelectionLayer extends ConsumerStatefulWidget {
  final List<ComponentData> components;

  const MarqueeSelectionLayer({super.key, required this.components});

  @override
  ConsumerState<MarqueeSelectionLayer> createState() =>
      _MarqueeSelectionLayerState();
}

class _MarqueeSelectionLayerState extends ConsumerState<MarqueeSelectionLayer> {
  Offset? _start;
  Offset? _current;

  bool get _isSelecting => _start != null && _current != null;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: (_) => _reset(),
        child: IgnorePointer(
          ignoring: true,
          child:
              _isSelecting
                  ? CustomPaint(painter: _MarqueePainter(rect: _rect))
                  : const SizedBox.expand(),
        ),
      ),
    );
  }

  Rect get _rect => Rect.fromPoints(_start!, _current!);

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons == kSecondaryMouseButton) {
      _showCanvasMenu(event);
      return;
    }

    if (event.buttons != kPrimaryMouseButton ||
        !_isMultiSelectModifierPressed()) {
      ref.read(layoutStateProvider.notifier).clearSelection();
      return;
    }

    ref.read(canvasViewportProvider.notifier).setMarqueeSelecting(true);
    setState(() {
      _start = event.localPosition;
      _current = event.localPosition;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isSelecting) return;
    setState(() => _current = event.localPosition);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isSelecting) return;

    final selectionRect = Rect.fromPoints(_start!, event.localPosition);
    final selectedIds = {
      for (final component in widget.components)
        if (_componentBounds(component).overlaps(selectionRect)) component.id,
    };

    ref
        .read(layoutStateProvider.notifier)
        .selectComponents(selectedIds, addToExisting: true);
    _reset();
  }

  void _reset() {
    ref.read(canvasViewportProvider.notifier).setMarqueeSelecting(false);
    if (!mounted) return;
    setState(() {
      _start = null;
      _current = null;
    });
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

  Future<void> _showCanvasMenu(PointerDownEvent event) async {
    final layoutState = ref.read(layoutStateProvider);
    final notifier = ref.read(layoutStateProvider.notifier);
    final clipboardCount = layoutState.clipboard.length;
    final componentCount = layoutState.components.length;
    final visibleCount =
        layoutState.components.where((component) => component.isVisible).length;
    final hiddenCount = componentCount - visibleCount;
    final lockedCount =
        layoutState.components.where((component) => component.isLocked).length;
    final unlockedCount = componentCount - lockedCount;
    final selectedComponents = layoutState.selectedComponents;
    final hasSelection = selectedComponents.isNotEmpty;
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: hasSelection,
      preview: notifier.selectedConflictResolutionPreview(),
    );
    final selectedUnlockedCount =
        selectedComponents.where((component) => !component.isLocked).length;
    final visibleUnlockedCount =
        layoutState.components
            .where((component) => component.isVisible && !component.isLocked)
            .length;
    final isAutoGrid =
        layoutState.config.layoutMechanism == LayoutMechanism.autoGrid;
    final autoGridConflictCount =
        isAutoGrid ? notifier.visibleAutoGridConflictComponentIds().length : 0;

    final action = await showMenu<_CanvasMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        event.position.dx,
        event.position.dy,
        event.position.dx,
        event.position.dy,
      ),
      items: [
        PopupMenuItem(
          enabled: clipboardCount > 0,
          value: _CanvasMenuAction.pasteHere,
          child: _CanvasContextMenuItem(
            icon: Icons.content_paste,
            label:
                clipboardCount > 1
                    ? 'Paste $clipboardCount components here'
                    : 'Paste here',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: componentCount > 0,
          value: _CanvasMenuAction.selectAll,
          child: _CanvasContextMenuItem(
            icon: Icons.select_all_outlined,
            label: 'Select all ($componentCount)',
          ),
        ),
        PopupMenuItem(
          enabled: componentCount > 0,
          value: _CanvasMenuAction.invertSelection,
          child: const _CanvasContextMenuItem(
            icon: Icons.swap_horiz,
            label: 'Invert selection',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: visibleCount > 0,
          value: _CanvasMenuAction.selectVisible,
          child: _CanvasContextMenuItem(
            icon: Icons.visibility_outlined,
            label: 'Select visible ($visibleCount)',
          ),
        ),
        PopupMenuItem(
          enabled: hiddenCount > 0,
          value: _CanvasMenuAction.selectHidden,
          child: _CanvasContextMenuItem(
            icon: Icons.visibility_off_outlined,
            label: 'Select hidden ($hiddenCount)',
          ),
        ),
        PopupMenuItem(
          enabled: lockedCount > 0,
          value: _CanvasMenuAction.selectLocked,
          child: _CanvasContextMenuItem(
            icon: Icons.lock_outline,
            label: 'Select locked ($lockedCount)',
          ),
        ),
        PopupMenuItem(
          enabled: unlockedCount > 0,
          value: _CanvasMenuAction.selectUnlocked,
          child: _CanvasContextMenuItem(
            icon: Icons.lock_open_outlined,
            label: 'Select unlocked ($unlockedCount)',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: selectedUnlockedCount > 0,
          value: _CanvasMenuAction.snapSelectionToLayoutRules,
          child: const _CanvasContextMenuItem(
            icon: Icons.grid_4x4,
            label: 'Snap selection to layout rules',
          ),
        ),
        PopupMenuItem(
          enabled: selectedUnlockedCount > 0,
          value: _CanvasMenuAction.snapSelectionSizeToLayoutRules,
          child: const _CanvasContextMenuItem(
            icon: Icons.aspect_ratio,
            label: 'Snap selection size to rules',
          ),
        ),
        if (clearSpotAction.isAvailable)
          PopupMenuItem(
            value: _CanvasMenuAction.moveSelectionToClearSpot,
            child: _CanvasContextMenuItem(
              icon: Icons.near_me_outlined,
              label: clearSpotAction.menuActionLabel(
                prefix: 'Move selection to',
              ),
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: selectedUnlockedCount > 0,
            value: _CanvasMenuAction.arrangeSelectionIntoAutoGrid,
            child: const _CanvasContextMenuItem(
              icon: Icons.view_module_outlined,
              label: 'Arrange selection into Auto Grid',
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: autoGridConflictCount > 0,
            value: _CanvasMenuAction.selectVisibleAutoGridConflicts,
            child: _CanvasContextMenuItem(
              icon: Icons.manage_search_outlined,
              label: _autoGridConflictSelectionLabel(autoGridConflictCount),
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: autoGridConflictCount > 0,
            value: _CanvasMenuAction.resolveVisibleAutoGridConflicts,
            child: _CanvasContextMenuItem(
              icon: Icons.auto_fix_high_outlined,
              label: _autoGridConflictResolveLabel(autoGridConflictCount),
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: visibleUnlockedCount > 0,
            value: _CanvasMenuAction.compactVisibleAutoGrid,
            child: _CanvasContextMenuItem(
              icon: Icons.view_module_outlined,
              label: _autoGridCompactLabel(visibleUnlockedCount),
            ),
          ),
        if (isAutoGrid)
          PopupMenuItem(
            enabled: visibleUnlockedCount > 0,
            value: _CanvasMenuAction.arrangeVisibleIntoAutoGrid,
            child: _CanvasContextMenuItem(
              icon: Icons.dashboard_customize_outlined,
              label: 'Arrange visible into Auto Grid ($visibleCount)',
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: hasSelection,
          value: _CanvasMenuAction.clearSelection,
          child: const _CanvasContextMenuItem(
            icon: Icons.close,
            label: 'Clear selection',
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _CanvasMenuAction.pasteHere:
        notifier.pasteComponentAt(event.localPosition);
        break;
      case _CanvasMenuAction.selectAll:
        notifier.selectAllComponents();
        break;
      case _CanvasMenuAction.invertSelection:
        notifier.invertSelection();
        break;
      case _CanvasMenuAction.selectVisible:
        notifier.selectComponentsByVisibility(true);
        break;
      case _CanvasMenuAction.selectHidden:
        notifier.selectComponentsByVisibility(false);
        break;
      case _CanvasMenuAction.selectLocked:
        notifier.selectComponentsByLockState(true);
        break;
      case _CanvasMenuAction.selectUnlocked:
        notifier.selectComponentsByLockState(false);
        break;
      case _CanvasMenuAction.snapSelectionToLayoutRules:
        layoutSelectionGeometryActionService.snapSelectionToLayoutRules(
          context,
          ref,
        );
        break;
      case _CanvasMenuAction.snapSelectionSizeToLayoutRules:
        layoutSelectionGeometryActionService.snapSelectionSizeToLayoutRules(
          context,
          ref,
        );
        break;
      case _CanvasMenuAction.moveSelectionToClearSpot:
        layoutClearSpotActionService.moveSelectionToClearSpot(context, ref);
        break;
      case _CanvasMenuAction.arrangeSelectionIntoAutoGrid:
        layoutAutoGridActionService.arrangeSelection(context, ref);
        break;
      case _CanvasMenuAction.selectVisibleAutoGridConflicts:
        layoutAutoGridActionService.selectVisibleConflicts(context, ref);
        break;
      case _CanvasMenuAction.resolveVisibleAutoGridConflicts:
        layoutAutoGridActionService.resolveVisibleConflicts(context, ref);
        break;
      case _CanvasMenuAction.compactVisibleAutoGrid:
        layoutAutoGridActionService.compactVisible(context, ref);
        break;
      case _CanvasMenuAction.arrangeVisibleIntoAutoGrid:
        notifier.arrangeVisibleIntoAutoGrid();
        break;
      case _CanvasMenuAction.clearSelection:
        notifier.clearSelection();
        break;
    }
  }
}

enum _CanvasMenuAction {
  pasteHere,
  selectAll,
  invertSelection,
  selectVisible,
  selectHidden,
  selectLocked,
  selectUnlocked,
  snapSelectionToLayoutRules,
  snapSelectionSizeToLayoutRules,
  moveSelectionToClearSpot,
  arrangeSelectionIntoAutoGrid,
  selectVisibleAutoGridConflicts,
  resolveVisibleAutoGridConflicts,
  compactVisibleAutoGrid,
  arrangeVisibleIntoAutoGrid,
  clearSelection,
}

String _autoGridConflictSelectionLabel(int count) {
  if (count == 1) return 'Select 1 Auto Grid conflict';
  return 'Select $count Auto Grid conflicts';
}

String _autoGridConflictResolveLabel(int count) {
  if (count == 1) return 'Resolve 1 Auto Grid conflict';
  return 'Resolve $count Auto Grid conflicts';
}

String _autoGridCompactLabel(int count) {
  if (count == 1) return 'Compact 1 visible component';
  return 'Compact $count visible components';
}

class _CanvasContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CanvasContextMenuItem({required this.icon, required this.label});

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

class _MarqueePainter extends CustomPainter {
  final Rect rect;

  const _MarqueePainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = Colors.blue.withValues(alpha: 0.12);
    final borderPaint =
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_MarqueePainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}

Rect _componentBounds(ComponentData component) {
  return Rect.fromLTWH(
    component.position.dx,
    component.position.dy,
    component.size.width,
    component.size.height,
  );
}
