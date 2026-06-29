import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/theme_provider.dart';
import '../settings_states/settings_notifier.dart';

class WorkflowSettings extends ConsumerWidget {
  final WayangTheme currentTheme;
  final void Function() onPressedSave;
  final void Function() onPressedCancel;
  final Function(WayangTheme) onThemeChanged;

  const WorkflowSettings({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onPressedCancel,
    required this.onPressedSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Workflow Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).toggleTheme();
              },
              icon: Icon(
                ref.watch(settingsProvider).themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
            _buildColorPicker(
              'Background Color',
              currentTheme.canvas.backgroundColor,
              (color) => _updateTheme(backgroundColor: color),
            ),
            _buildColorPicker(
              'Node Color',
              currentTheme.node.nodeColor,
              (color) => _updateTheme(nodeColor: color),
            ),
            _buildSlider(
              'Node Border Radius',
              currentTheme.node.nodeBorderRadius,
              0.0,
              16.0,
              (value) => _updateTheme(nodeBorderRadius: value),
            ),
            _buildColorPicker(
              'Grid Color',
              currentTheme.canvas.gridColor,
              (color) => _updateTheme(gridColor: color),
            ),
            _buildSlider(
              'Grid Spacing',
              currentTheme.canvas.gridSpacing,
              10.0,
              50.0,
              (value) => _updateTheme(gridSpacing: value),
            ),
            ToggleButtons(
              isSelected: [true, false],
              children: [Text('Dot'), Text('Line')],
              onPressed: (index) => _updateTheme(
                gridType: index == 0 ? GridType.dot : GridType.line,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onPressedCancel, child: const Text('Cancel')),
        TextButton(onPressed: onPressedSave, child: const Text('Save')),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return ListTile(
      title: Text(label),
      trailing: GestureDetector(
        onTap: () {
          // Show color picker dialog
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: currentColor,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  void _updateTheme({
    Color? backgroundColor,
    Color? gridColor,
    Color? nodeColor,
    double? gridSpacing,
    double? nodeBorderRadius,
    GridType? gridType,
  }) {
    final newTheme = WayangTheme(
      node: NodeTheme(
        nodeColor: nodeColor ?? currentTheme.node.nodeColor,
        selectedNodeColor: currentTheme.node.selectedNodeColor,
        nodeBorderRadius:
            nodeBorderRadius ?? currentTheme.node.nodeBorderRadius,
      ),
      connection: ConnectionTheme(
        connectionColor: currentTheme.connection.connectionColor,
        portColor: currentTheme.connection.portColor,
      ),
      canvas: CanvasTheme(
        gridSpacing: gridSpacing ?? currentTheme.canvas.gridSpacing,
        gridType: gridType ?? currentTheme.canvas.gridType,
        gridColor: gridColor ?? currentTheme.canvas.gridColor,
        backgroundColor: backgroundColor ?? currentTheme.canvas.backgroundColor,
      ),
    );
    onThemeChanged(newTheme);
  }
}
