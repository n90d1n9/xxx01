import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import 'number_field.dart';
import 'size_editor.dart';

/// Edits the selected component's canvas position and base size.
class ComponentGeometryEditor extends ConsumerWidget {
  final ComponentData component;
  final LayoutConfig config;

  const ComponentGeometryEditor({
    super.key,
    required this.component,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GeometrySectionHeader(
          title: 'Position',
          resetTooltip: 'Reset position to origin',
          onReset:
              component.isLocked || component.position == Offset.zero
                  ? null
                  : () => notifier.updateComponentPosition(
                    component.id,
                    Offset.zero,
                  ),
        ),
        const SizedBox(height: 8),
        _GeometryFieldPair(
          first: NumberField(
            label: 'X',
            value: component.position.dx,
            onChanged:
                (value) => notifier.updateComponentPosition(
                  component.id,
                  Offset(value, component.position.dy),
                ),
          ),
          second: NumberField(
            label: 'Y',
            value: component.position.dy,
            onChanged:
                (value) => notifier.updateComponentPosition(
                  component.id,
                  Offset(component.position.dx, value),
                ),
          ),
        ),
        const SizedBox(height: 16),
        _GeometrySectionHeader(
          title: 'Size',
          resetTooltip: 'Reset to default size',
          onReset:
              component.isLocked ||
                      _isSameSize(component.size, component.type.defaultSize)
                  ? null
                  : () => notifier.updateComponentSize(
                    component.id,
                    component.type.defaultSize,
                  ),
        ),
        const SizedBox(height: 8),
        SizeEditor(
          size: component.size,
          minSize: Size(config.minComponentWidth, config.minComponentHeight),
          step: config.gridSize,
          onSizeChanged:
              (newSize) => notifier.updateComponentSize(component.id, newSize),
        ),
      ],
    );
  }
}

/// Renders the component geometry editor with sample values for previews.
@Preview(name: 'Component geometry editor')
Widget componentGeometryEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-geometry-button',
    type: ComponentType.customButton,
    position: const Offset(32, 48),
    size: const Size(180, 64),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentGeometryEditor(
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

/// Displays a geometry section title with an optional reset action.
class _GeometrySectionHeader extends StatelessWidget {
  final String title;
  final String resetTooltip;
  final VoidCallback? onReset;

  const _GeometrySectionHeader({
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

/// Lays out two geometry number fields responsively.
class _GeometryFieldPair extends StatelessWidget {
  static const _stackedBreakpoint = 260.0;

  final Widget first;
  final Widget second;

  const _GeometryFieldPair({required this.first, required this.second});

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

bool _isSameSize(Size first, Size second) {
  return (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}
