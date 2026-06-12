import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  static const List<Color> _swatches = [
    Colors.white,
    Color(0xFFF8FAFC),
    Color(0xFFE0F2FE),
    Color(0xFFDCFCE7),
    Color(0xFFFEF3C7),
    Color(0xFFFEE2E2),
    Color(0xFFEDE9FE),
    Color(0xFF111827),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Wrap(
          spacing: 6,
          children: [
            for (final swatch in _swatches)
              Tooltip(
                message: '#${swatch.toARGB32().toRadixString(16).substring(2)}',
                child: InkWell(
                  onTap: () => onColorChanged(swatch),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: swatch,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            swatch.toARGB32() == color.toARGB32()
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black12,
                        width: swatch.toARGB32() == color.toARGB32() ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
