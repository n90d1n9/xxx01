import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_state.dart';
import '../provider/layout_state_provider.dart';

/// Runs Auto Grid actions and reports consistent editing feedback.
class LayoutAutoGridActionService {
  const LayoutAutoGridActionService();

  bool arrangeSelection(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    return _runSelectionGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.arrangeSelectedIntoAutoGrid(),
      successMessage: 'Arranged $subject into Auto Grid',
      noChangeMessage: '${_capitalize(subject)} already fits Auto Grid',
    );
  }

  bool moveSelectionToFreeCells(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    return _runSelectionGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.moveSelectedToFreeAutoGridCells(),
      successMessage: 'Moved $subject to free Auto Grid cells',
      noChangeMessage:
          '${_capitalize(subject)} already has free Auto Grid cells',
    );
  }

  bool selectConflictPartnersForSelection(BuildContext context, WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_isAutoGrid(layoutState.config)) {
      _showStatus(context, 'Switch to Auto Grid first');
      return false;
    }

    if (layoutState.selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    final beforeSelectedIds = layoutState.selectedComponentIds;
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.selectAutoGridConflictPartnersForSelection();
    final afterSelectedIds = ref.read(layoutStateProvider).selectedComponentIds;
    final changed = !_setEquals(beforeSelectedIds, afterSelectedIds);

    _showStatus(
      context,
      changed
          ? _selectedConflictMessage(afterSelectedIds.length)
          : 'No Auto Grid conflicts for selection',
    );
    return changed;
  }

  bool selectVisibleConflicts(BuildContext context, WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_isAutoGrid(layoutState.config)) {
      _showStatus(context, 'Switch to Auto Grid first');
      return false;
    }

    final conflictIds =
        ref
            .read(layoutStateProvider.notifier)
            .visibleAutoGridConflictComponentIds();
    if (conflictIds.isEmpty) {
      _showStatus(context, 'No visible Auto Grid conflicts');
      return false;
    }

    final beforeSelectedIds = layoutState.selectedComponentIds;
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.selectVisibleAutoGridConflicts();
    final afterSelectedIds = ref.read(layoutStateProvider).selectedComponentIds;
    final changed = !_setEquals(beforeSelectedIds, afterSelectedIds);

    _showStatus(
      context,
      changed
          ? _selectedConflictMessage(afterSelectedIds.length)
          : 'Visible Auto Grid conflicts are already selected',
    );
    return changed;
  }

  bool resolveVisibleConflicts(BuildContext context, WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_isAutoGrid(layoutState.config)) {
      _showStatus(context, 'Switch to Auto Grid first');
      return false;
    }

    final notifier = ref.read(layoutStateProvider.notifier);
    final conflictIds = notifier.visibleAutoGridConflictComponentIds();
    if (conflictIds.isEmpty) {
      _showStatus(context, 'No visible Auto Grid conflicts');
      return false;
    }

    final beforeGeometry = _geometryById(
      _visibleUnlockedComponents(layoutState),
    );
    notifier.resolveVisibleAutoGridConflicts();
    final afterGeometry = _geometryById(
      _visibleUnlockedComponents(ref.read(layoutStateProvider)),
    );
    final changed = _hasGeometryChange(beforeGeometry, afterGeometry);

    _showStatus(
      context,
      changed
          ? _resolvedConflictMessage(conflictIds.length)
          : 'Visible Auto Grid conflicts are already resolved',
    );
    return changed;
  }

  bool compactVisible(BuildContext context, WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_isAutoGrid(layoutState.config)) {
      _showStatus(context, 'Switch to Auto Grid first');
      return false;
    }

    final visibleUnlocked = _visibleUnlockedComponents(layoutState);
    if (visibleUnlocked.isEmpty) {
      _showStatus(context, 'No unlocked visible components');
      return false;
    }

    final beforeGeometry = _geometryById(visibleUnlocked);
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.compactVisibleAutoGrid();
    final afterGeometry = _geometryById(
      _visibleUnlockedComponents(ref.read(layoutStateProvider)),
    );
    final changed = _hasGeometryChange(beforeGeometry, afterGeometry);

    _showStatus(
      context,
      changed
          ? 'Compacted visible Auto Grid components'
          : 'Visible Auto Grid is already compact',
    );
    return changed;
  }

  bool _runSelectionGeometryAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(LayoutStateNotifier notifier) action,
    required String successMessage,
    required String noChangeMessage,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_isAutoGrid(layoutState.config)) {
      _showStatus(context, 'Switch to Auto Grid first');
      return false;
    }

    final selectedComponents = layoutState.selectedComponents;
    if (selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    final movableComponents =
        selectedComponents
            .where((component) => _canAutoPlace(component))
            .toList();
    if (movableComponents.isEmpty) {
      _showStatus(context, 'No unlocked visible selection');
      return false;
    }

    final beforeGeometry = _geometryById(movableComponents);
    action(ref.read(layoutStateProvider.notifier));
    final afterGeometry = _geometryById(
      ref
          .read(layoutStateProvider)
          .selectedComponents
          .where((component) => _canAutoPlace(component)),
    );
    final changed = _hasGeometryChange(beforeGeometry, afterGeometry);

    _showStatus(context, changed ? successMessage : noChangeMessage);
    return changed;
  }

  bool _isAutoGrid(LayoutConfig config) {
    return config.layoutMechanism == LayoutMechanism.autoGrid;
  }

  bool _canAutoPlace(ComponentData component) {
    return component.isVisible && !component.isLocked;
  }

  List<ComponentData> _visibleUnlockedComponents(LayoutState layoutState) {
    return layoutState.components.where(_canAutoPlace).toList();
  }

  Map<String, _ComponentGeometrySnapshot> _geometryById(
    Iterable<ComponentData> components,
  ) {
    return {
      for (final component in components)
        component.id: _ComponentGeometrySnapshot(
          position: component.position,
          size: component.size,
        ),
    };
  }

  bool _hasGeometryChange(
    Map<String, _ComponentGeometrySnapshot> before,
    Map<String, _ComponentGeometrySnapshot> after,
  ) {
    return before.entries.any((entry) {
      final next = after[entry.key];
      return next != null && !entry.value.isSameAs(next);
    });
  }

  bool _setEquals(Set<String> left, Set<String> right) {
    return left.length == right.length && left.containsAll(right);
  }

  String _selectedConflictMessage(int count) {
    return count == 1
        ? 'Selected 1 Auto Grid conflict'
        : 'Selected $count Auto Grid conflicts';
  }

  String _resolvedConflictMessage(int count) {
    return count == 1
        ? 'Resolved 1 Auto Grid conflict'
        : 'Resolved $count Auto Grid conflicts';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _showStatus(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

const layoutAutoGridActionService = LayoutAutoGridActionService();

/// Captures component Auto Grid geometry for lightweight result checks.
class _ComponentGeometrySnapshot {
  const _ComponentGeometrySnapshot({
    required this.position,
    required this.size,
  });

  final Offset position;
  final Size size;

  bool isSameAs(_ComponentGeometrySnapshot other) {
    return (position - other.position).distance < 0.01 &&
        (size.width - other.size.width).abs() < 0.01 &&
        (size.height - other.size.height).abs() < 0.01;
  }
}
