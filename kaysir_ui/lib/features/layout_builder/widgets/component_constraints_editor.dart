import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import 'number_field.dart';

/// Edits component anchoring, aspect ratio, and min/max size constraints.
class ComponentConstraintsEditor extends ConsumerWidget {
  final ComponentData component;
  final LayoutConfig config;

  const ComponentConstraintsEditor({
    super.key,
    required this.component,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constraints = component.constraints;
    final notifier = ref.read(layoutStateProvider.notifier);
    final isLocked = component.isLocked;
    final minWidth = math.max(
      config.minComponentWidth,
      constraints.minWidth ?? 0,
    );
    final minHeight = math.max(
      config.minComponentHeight,
      constraints.minHeight ?? 0,
    );
    final hasMaxLimit =
        constraints.maxWidth != null || constraints.maxHeight != null;

    void update(ComponentConstraints nextConstraints) {
      notifier.updateComponentConstraints(component.id, nextConstraints);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConstraintsSectionHeader(
          title: 'Constraints',
          resetTooltip: 'Reset constraints',
          onReset:
              isLocked || !constraints.hasCustomRules
                  ? null
                  : () => notifier.resetComponentConstraints(component.id),
        ),
        const SizedBox(height: 8),
        _AnchorModeSelector(
          label: 'Horizontal',
          selected: constraints.horizontalAnchor,
          enabled: !isLocked,
          isHorizontal: true,
          onChanged:
              (mode) => update(constraints.copyWith(horizontalAnchor: mode)),
        ),
        const SizedBox(height: 8),
        _AnchorModeSelector(
          label: 'Vertical',
          selected: constraints.verticalAnchor,
          enabled: !isLocked,
          isHorizontal: false,
          onChanged:
              (mode) => update(constraints.copyWith(verticalAnchor: mode)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Lock aspect ratio'),
          value: constraints.maintainAspectRatio,
          onChanged:
              isLocked
                  ? null
                  : (value) =>
                      update(constraints.copyWith(maintainAspectRatio: value)),
        ),
        const SizedBox(height: 8),
        _ConstraintFieldPair(
          first: _LockedConstraintControl(
            isLocked: isLocked,
            child: NumberField(
              key: ValueKey(
                'constraint-min-w-${component.id}-${constraints.minWidth}',
              ),
              label: 'Min W',
              value: minWidth,
              min: config.minComponentWidth,
              max: constraints.maxWidth,
              step: config.gridSize,
              onChanged:
                  (value) => update(
                    constraints.copyWith(
                      minWidth: _constraintLimitOrNull(
                        value,
                        config.minComponentWidth,
                      ),
                    ),
                  ),
            ),
          ),
          second: _LockedConstraintControl(
            isLocked: isLocked,
            child: NumberField(
              key: ValueKey(
                'constraint-min-h-${component.id}-${constraints.minHeight}',
              ),
              label: 'Min H',
              value: minHeight,
              min: config.minComponentHeight,
              max: constraints.maxHeight,
              step: config.gridSize,
              onChanged:
                  (value) => update(
                    constraints.copyWith(
                      minHeight: _constraintLimitOrNull(
                        value,
                        config.minComponentHeight,
                      ),
                    ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (hasMaxLimit) ...[
          _ConstraintFieldPair(
            first: _LockedConstraintControl(
              isLocked: isLocked,
              child: NumberField(
                key: ValueKey(
                  'constraint-max-w-${component.id}-${constraints.maxWidth}',
                ),
                label: 'Max W',
                value: math.max(
                  minWidth,
                  constraints.maxWidth ?? component.size.width,
                ),
                min: minWidth,
                step: config.gridSize,
                onChanged:
                    (value) => update(constraints.copyWith(maxWidth: value)),
              ),
            ),
            second: _LockedConstraintControl(
              isLocked: isLocked,
              child: NumberField(
                key: ValueKey(
                  'constraint-max-h-${component.id}-${constraints.maxHeight}',
                ),
                label: 'Max H',
                value: math.max(
                  minHeight,
                  constraints.maxHeight ?? component.size.height,
                ),
                min: minHeight,
                step: config.gridSize,
                onChanged:
                    (value) => update(constraints.copyWith(maxHeight: value)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.layers_clear_outlined, size: 18),
              label: const Text('Clear max'),
              onPressed:
                  isLocked
                      ? null
                      : () => update(
                        constraints.copyWith(maxWidth: null, maxHeight: null),
                      ),
            ),
          ),
        ] else
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.fit_screen_outlined, size: 18),
              label: const Text('Set max size'),
              onPressed:
                  isLocked
                      ? null
                      : () => update(
                        constraints.copyWith(
                          maxWidth: component.size.width,
                          maxHeight: component.size.height,
                        ),
                      ),
            ),
          ),
      ],
    );
  }
}

/// Renders the constraints editor with sample component rules for previews.
@Preview(name: 'Component constraints editor')
Widget componentConstraintsEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-button',
    type: ComponentType.customButton,
    position: const Offset(40, 40),
    size: const Size(180, 56),
  ).copyWith(
    constraints: const ComponentConstraints(
      horizontalAnchor: ComponentAnchorMode.center,
      verticalAnchor: ComponentAnchorMode.start,
      maintainAspectRatio: true,
      minWidth: 120,
      minHeight: 48,
      maxWidth: 320,
      maxHeight: 120,
    ),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentConstraintsEditor(
                component: component,
                config: const LayoutConfig(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Selects how a component anchors on one layout axis.
class _AnchorModeSelector extends StatelessWidget {
  final String label;
  final ComponentAnchorMode selected;
  final bool enabled;
  final bool isHorizontal;
  final ValueChanged<ComponentAnchorMode> onChanged;

  const _AnchorModeSelector({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.isHorizontal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: KyBuilderSegmentedSelector<ComponentAnchorMode>(
            options: [
              KyBuilderSegmentOption(
                value: ComponentAnchorMode.free,
                label: ComponentAnchorMode.free.label,
                icon: Icons.open_in_full,
                tooltip: '$label free',
              ),
              KyBuilderSegmentOption(
                value: ComponentAnchorMode.start,
                label: ComponentAnchorMode.start.label,
                icon:
                    isHorizontal
                        ? Icons.align_horizontal_left
                        : Icons.vertical_align_top,
                tooltip: '$label start',
              ),
              KyBuilderSegmentOption(
                value: ComponentAnchorMode.center,
                label: ComponentAnchorMode.center.label,
                icon:
                    isHorizontal
                        ? Icons.align_horizontal_center
                        : Icons.vertical_align_center,
                tooltip: '$label center',
              ),
              KyBuilderSegmentOption(
                value: ComponentAnchorMode.end,
                label: ComponentAnchorMode.end.label,
                icon:
                    isHorizontal
                        ? Icons.align_horizontal_right
                        : Icons.vertical_align_bottom,
                tooltip: '$label end',
              ),
              KyBuilderSegmentOption(
                value: ComponentAnchorMode.stretch,
                label: ComponentAnchorMode.stretch.label,
                icon:
                    isHorizontal
                        ? Icons.horizontal_distribute
                        : Icons.vertical_distribute,
                tooltip: '$label stretch',
              ),
            ],
            selectedValue: selected,
            showLabels: false,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}

/// Displays a constraints section title with an optional reset action.
class _ConstraintsSectionHeader extends StatelessWidget {
  final String title;
  final String resetTooltip;
  final VoidCallback? onReset;

  const _ConstraintsSectionHeader({
    required this.title,
    required this.resetTooltip,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Tooltip(
          message: resetTooltip,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: const Icon(Icons.restart_alt, size: 18),
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}

/// Lays out two numeric constraint fields responsively.
class _ConstraintFieldPair extends StatelessWidget {
  static const _stackedBreakpoint = 260.0;

  final Widget first;
  final Widget second;

  const _ConstraintFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _stackedBreakpoint;

        if (shouldStack) {
          return Column(children: [first, const SizedBox(height: 8), second]);
        }

        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 8),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

/// Disables constraint fields visually when the component is locked.
class _LockedConstraintControl extends StatelessWidget {
  final bool isLocked;
  final Widget child;

  const _LockedConstraintControl({required this.isLocked, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return Opacity(opacity: 0.55, child: IgnorePointer(child: child));
  }
}

double? _constraintLimitOrNull(double value, double baseline) {
  if (value <= baseline + 0.01) return null;
  return value;
}
