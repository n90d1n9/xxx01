import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final String? label;

  const ColorPickerButton({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.label,
  });

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label ?? 'Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              onColorChanged: (Color selectedColor) {
                onColorChanged(selectedColor);
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showColorPicker(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(100, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label ?? 'Select Color',
        style: TextStyle(
          color: useWhiteForeground(color) ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Helper method to determine text color based on background
  bool useWhiteForeground(Color backgroundColor) {
    return (ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark);
  }
}
