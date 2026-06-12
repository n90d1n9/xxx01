import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';

/// Runs selection geometry actions and reports consistent editing feedback.
class LayoutSelectionGeometryActionService {
  const LayoutSelectionGeometryActionService();

  bool alignSelection(
    BuildContext context,
    WidgetRef ref,
    ComponentAlignment alignment, {
    String subject = 'selection',
  }) {
    final label = _alignmentLabel(alignment);

    return _runGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.alignSelected(alignment),
      successMessage: 'Aligned $subject $label',
      noChangeMessage: '${_capitalize(subject)} is already aligned $label',
    );
  }

  bool snapSelectionToLayoutRules(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    return _runGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.snapSelectedToGrid(),
      successMessage: 'Snapped $subject to layout rules',
      noChangeMessage:
          '${_capitalize(subject)} already matches layout position rules',
    );
  }

  bool snapSelectionSizeToLayoutRules(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    return _runGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.snapSelectedSizeToGrid(),
      successMessage: 'Snapped $subject size to layout rules',
      noChangeMessage:
          '${_capitalize(subject)} size already matches layout rules',
    );
  }

  bool snapSelectionGeometryToLayoutRules(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    return _runGeometryAction(
      context,
      ref,
      action: (notifier) {
        notifier.snapSelectedToGrid();
        notifier.snapSelectedSizeToGrid();
      },
      successMessage: 'Snapped $subject to layout rules',
      noChangeMessage: '${_capitalize(subject)} already matches layout rules',
    );
  }

  bool matchSelectionSize(
    BuildContext context,
    WidgetRef ref, {
    bool matchWidth = true,
    bool matchHeight = true,
    String subject = 'selection',
  }) {
    if (!matchWidth && !matchHeight) return false;

    final label = _sizeMatchLabel(
      matchWidth: matchWidth,
      matchHeight: matchHeight,
    );

    return _runGeometryAction(
      context,
      ref,
      minSelectedCount: 2,
      minSelectionMessage: 'Select at least two components',
      action:
          (notifier) => notifier.matchSelectedComponentSize(
            matchWidth: matchWidth,
            matchHeight: matchHeight,
          ),
      successMessage: 'Matched $subject $label',
      noChangeMessage: '${_capitalize(subject)} already shares $label',
    );
  }

  bool stackSelection(
    BuildContext context,
    WidgetRef ref,
    ComponentDistribution direction, {
    String subject = 'selection',
  }) {
    final directionLabel = _directionAdverb(direction);

    return _runGeometryAction(
      context,
      ref,
      minSelectedCount: 2,
      minMovableCount: 2,
      minSelectionMessage: 'Select at least two components',
      minMovableMessage: 'Select at least two unlocked components',
      action: (notifier) => notifier.stackSelectedComponents(direction),
      successMessage: 'Stacked $subject $directionLabel',
      noChangeMessage:
          '${_capitalize(subject)} is already stacked $directionLabel',
    );
  }

  bool spaceSelection(
    BuildContext context,
    WidgetRef ref,
    ComponentDistribution direction,
    double gap, {
    String subject = 'selection',
  }) {
    final directionLabel = _directionAdverb(direction);

    return _runGeometryAction(
      context,
      ref,
      minSelectedCount: 2,
      minMovableCount: 2,
      minSelectionMessage: 'Select at least two components',
      minMovableMessage: 'Select at least two unlocked components',
      action: (notifier) => notifier.spaceSelectedComponents(direction, gap),
      successMessage: 'Spaced $subject $directionLabel',
      noChangeMessage:
          '${_capitalize(subject)} already uses that $directionLabel spacing',
    );
  }

  bool distributeSelection(
    BuildContext context,
    WidgetRef ref,
    ComponentDistribution direction, {
    String subject = 'selection',
  }) {
    final directionLabel = _directionAdverb(direction);

    return _runGeometryAction(
      context,
      ref,
      minSelectedCount: 3,
      minMovableCount: 3,
      minSelectionMessage: 'Select at least three components',
      minMovableMessage: 'Select at least three unlocked components',
      action: (notifier) => notifier.distributeSelected(direction),
      successMessage: 'Distributed $subject $directionLabel',
      noChangeMessage:
          '${_capitalize(subject)} is already distributed $directionLabel',
    );
  }

  bool snapVisibleComponentsToLayoutRules(BuildContext context, WidgetRef ref) {
    return _runVisibleGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.snapVisibleComponentsToLayoutRules(),
      successMessage: 'Snapped visible components to layout rules',
      noChangeMessage: 'Visible components already match layout position rules',
    );
  }

  bool snapVisibleComponentSizesToLayoutRules(
    BuildContext context,
    WidgetRef ref,
  ) {
    return _runVisibleGeometryAction(
      context,
      ref,
      action: (notifier) => notifier.snapVisibleComponentSizesToLayoutRules(),
      successMessage: 'Snapped visible component sizes to layout rules',
      noChangeMessage: 'Visible component sizes already match layout rules',
    );
  }

  bool _runVisibleGeometryAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(LayoutStateNotifier notifier) action,
    required String successMessage,
    required String noChangeMessage,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    final visibleComponents = layoutState.components.where(
      (component) => component.isVisible,
    );
    final movableComponents =
        visibleComponents.where((component) => !component.isLocked).toList();

    if (visibleComponents.isEmpty) {
      _showStatus(context, 'No visible components');
      return false;
    }

    if (movableComponents.isEmpty) {
      _showStatus(context, 'No unlocked visible components');
      return false;
    }

    final beforeGeometry = _geometryById(movableComponents);
    action(ref.read(layoutStateProvider.notifier));
    final afterGeometry = _geometryById(
      ref
          .read(layoutStateProvider)
          .components
          .where((component) => component.isVisible && !component.isLocked),
    );
    final changed = _hasGeometryChange(beforeGeometry, afterGeometry);

    _showStatus(context, changed ? successMessage : noChangeMessage);
    return changed;
  }

  bool _runGeometryAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(LayoutStateNotifier notifier) action,
    required String successMessage,
    required String noChangeMessage,
    int minSelectedCount = 1,
    int minMovableCount = 1,
    String? minSelectionMessage,
    String? minMovableMessage,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    final selectedComponents = layoutState.selectedComponents;
    final movableComponents =
        selectedComponents.where((component) => !component.isLocked).toList();

    if (selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    if (selectedComponents.length < minSelectedCount) {
      _showStatus(context, minSelectionMessage ?? 'Select more components');
      return false;
    }

    if (movableComponents.isEmpty) {
      _showStatus(context, 'Selected components are locked');
      return false;
    }

    if (movableComponents.length < minMovableCount) {
      _showStatus(
        context,
        minMovableMessage ?? 'Select more unlocked components',
      );
      return false;
    }

    final beforeGeometry = _geometryById(movableComponents);
    action(ref.read(layoutStateProvider.notifier));

    final afterComponents = ref.read(layoutStateProvider).selectedComponents;
    final afterGeometry = _geometryById(afterComponents);
    final changed = _hasGeometryChange(beforeGeometry, afterGeometry);

    _showStatus(context, changed ? successMessage : noChangeMessage);
    return changed;
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

  String _alignmentLabel(ComponentAlignment alignment) {
    return switch (alignment) {
      ComponentAlignment.left => 'left',
      ComponentAlignment.center => 'center',
      ComponentAlignment.right => 'right',
      ComponentAlignment.top => 'top',
      ComponentAlignment.middle => 'middle',
      ComponentAlignment.bottom => 'bottom',
    };
  }

  String _sizeMatchLabel({
    required bool matchWidth,
    required bool matchHeight,
  }) {
    if (matchWidth && matchHeight) return 'size';
    if (matchWidth) return 'width';
    return 'height';
  }

  String _directionAdverb(ComponentDistribution direction) {
    return switch (direction) {
      ComponentDistribution.horizontal => 'horizontally',
      ComponentDistribution.vertical => 'vertically',
    };
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

const layoutSelectionGeometryActionService =
    LayoutSelectionGeometryActionService();

/// Captures selected component geometry for lightweight change detection.
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
