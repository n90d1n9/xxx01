import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'number_field.dart';

class StyleEditor extends StatelessWidget {
  final Map<String, dynamic> style;
  final ValueChanged<Map<String, dynamic>> onStyleChanged;

  const StyleEditor({
    super.key,
    required this.style,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderWidth = _doubleValue(style['borderWidth'], fallback: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Style', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ColorPicker(
          label: 'Background',
          color: _parseColor(style['backgroundColor']),
          onColorChanged: (color) {
            _updateStyle('backgroundColor', color.toARGB32());
          },
        ),
        const SizedBox(height: 10),
        ColorPicker(
          label: 'Border',
          color: _parseColor(style['borderColor'], fallback: Colors.black26),
          onColorChanged: (color) {
            _updateStyle('borderColor', color.toARGB32());
          },
        ),
        const SizedBox(height: 10),
        NumberField(
          label: 'Border width',
          value: borderWidth,
          min: 0,
          onChanged: (value) {
            _updateStyle('borderWidth', _nonNegative(value));
          },
        ),
        const SizedBox(height: 8),
        NumberField(
          label: 'Corner radius',
          value: _doubleValue(style['borderRadius'], fallback: 8),
          min: 0,
          onChanged: (value) {
            _updateStyle('borderRadius', _nonNegative(value));
          },
        ),
        const SizedBox(height: 8),
        NumberField(
          label: 'Padding',
          value: _doubleValue(style['padding'], fallback: 8),
          min: 0,
          onChanged: (value) {
            _updateStyle('padding', _nonNegative(value));
          },
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Draggable'),
          value: _boolValue(style['isDraggable'], fallback: true),
          onChanged: (value) => _updateStyle('isDraggable', value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Resizable'),
          value: _boolValue(style['isResizable'], fallback: true),
          onChanged: (value) => _updateStyle('isResizable', value),
        ),
      ],
    );
  }

  void _updateStyle(String key, Object value) {
    final newStyle = Map<String, dynamic>.from(style);
    newStyle[key] = value;
    onStyleChanged(newStyle);
  }

  Color _parseColor(dynamic value, {Color fallback = Colors.white}) {
    if (value is int) return Color(value);
    if (value is String && value.isNotEmpty) {
      final normalized = value.replaceAll('#', '');
      final parsed = int.tryParse(
        normalized.length == 6 ? 'FF$normalized' : normalized,
        radix: 16,
      );
      if (parsed != null) return Color(parsed);
    }
    return fallback;
  }

  double _doubleValue(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _boolValue(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  double _nonNegative(double value) => value < 0 ? 0 : value;
}
