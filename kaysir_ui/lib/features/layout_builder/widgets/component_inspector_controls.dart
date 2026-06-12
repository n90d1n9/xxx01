import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Displays a compact inspector section heading with an optional reset action.
class ComponentInspectorSectionHeader extends StatelessWidget {
  final String title;
  final String resetTooltip;
  final VoidCallback? onReset;

  const ComponentInspectorSectionHeader({
    super.key,
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

/// Lays out two inspector fields side-by-side, stacking them on narrow panels.
class ComponentInspectorFieldPair extends StatelessWidget {
  static const _stackedBreakpoint = 260.0;

  final Widget first;
  final Widget second;

  const ComponentInspectorFieldPair({
    super.key,
    required this.first,
    required this.second,
  });

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

/// Displays a compact icon-and-label chip for inspector summaries.
class ComponentInspectorChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ComponentInspectorChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Renders the reusable inspector controls with sample field placeholders.
@Preview(name: 'Component inspector controls')
Widget componentInspectorControlsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ComponentInspectorSectionHeader(
                  title: 'Grid position',
                  resetTooltip: 'Snap to grid rules',
                  onReset: () {},
                ),
                const SizedBox(height: 8),
                const ComponentInspectorFieldPair(
                  first: TextField(
                    decoration: InputDecoration(
                      labelText: 'Col',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  second: TextField(
                    decoration: InputDecoration(
                      labelText: 'Row',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ComponentInspectorChip(icon: Icons.grid_on, label: 'C2 R3'),
                    ComponentInspectorChip(
                      icon: Icons.open_in_full,
                      label: '2 x 1 cells',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
