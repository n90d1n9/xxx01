import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Accent-color picker for task editor forms.
class TaskEditorAccentPicker extends StatelessWidget {
  const TaskEditorAccentPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorChanged,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final color in colors)
            _TaskEditorColorOption(
              color: color,
              selected: color == selectedColor,
              onPressed: () => onColorChanged(color),
            ),
        ],
      ),
    );
  }
}

/// Preview for the task-editor accent-color picker.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task editor accents',
  size: Size(360, 96),
)
Widget taskEditorAccentPickerPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: TaskEditorAccentPicker(
          colors: defaultTaskEditorAccentColors,
          selectedColor: defaultTaskEditorAccentColors.first,
          onColorChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Default accent colors for task editor previews and forms.
const defaultTaskEditorAccentColors = [
  Color(0xFF2563EB),
  Color(0xFF0891B2),
  Color(0xFF16A34A),
  Color(0xFFD97706),
  Color(0xFF7C3AED),
  Color(0xFFDC2626),
];

/// Single circular color option for a task editor.
class _TaskEditorColorOption extends StatelessWidget {
  const _TaskEditorColorOption({
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Accent color',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.onSurface : color,
              width: selected ? 3 : 0,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
