import 'package:flutter/material.dart';

class AdvancedColorPicker extends StatefulWidget {
  final String? initialColor;
  final ValueChanged<String> onColorChanged;

  const AdvancedColorPicker({
    super.key,
    this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();

  final List<Color> _recentColors = [];
  final List<Color> _presetColors = [
    const Color(0xFFFF0000), // Red
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF000000), // Black
    const Color(0xFFFFFFFF), // White
    const Color(0xFF9E9E9E), // Gray
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _parseColor(widget.initialColor ?? '#000000');
    _hexController.text = _colorToHex(_selectedColor);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Picker',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Color preview
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 16),

          // Hex input
          TextField(
            controller: _hexController,
            decoration: const InputDecoration(
              labelText: 'Hex Code',
              prefixText: '#',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final color = _parseColor('#$value');
              setState(() => _selectedColor = color);
              widget.onColorChanged(_colorToHex(color));
            },
          ),
          const SizedBox(height: 16),

          // RGB Sliders
          _buildRGBSlider('Red', _selectedColor.red, (value) {
            setState(() {
              _selectedColor = Color.fromRGBO(
                value.toInt(),
                _selectedColor.green,
                _selectedColor.blue,
                1,
              );
              _hexController.text = _colorToHex(_selectedColor);
            });
            widget.onColorChanged(_colorToHex(_selectedColor));
          }),
          _buildRGBSlider('Green', _selectedColor.green, (value) {
            setState(() {
              _selectedColor = Color.fromRGBO(
                _selectedColor.red,
                value.toInt(),
                _selectedColor.blue,
                1,
              );
              _hexController.text = _colorToHex(_selectedColor);
            });
            widget.onColorChanged(_colorToHex(_selectedColor));
          }),
          _buildRGBSlider('Blue', _selectedColor.blue, (value) {
            setState(() {
              _selectedColor = Color.fromRGBO(
                _selectedColor.red,
                _selectedColor.green,
                value.toInt(),
                1,
              );
              _hexController.text = _colorToHex(_selectedColor);
            });
            widget.onColorChanged(_colorToHex(_selectedColor));
          }),
          const SizedBox(height: 16),

          // Preset colors
          const Text('Presets', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _presetColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _hexController.text = _colorToHex(color);
                      });
                      widget.onColorChanged(_colorToHex(color));
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selectedColor == color
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                          width: _selectedColor == color ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          // Recent colors
          if (_recentColors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Recent', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _recentColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                          _hexController.text = _colorToHex(color);
                        });
                        widget.onColorChanged(_colorToHex(color));
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRGBSlider(
    String label,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value.toDouble(), min: 0, max: 255, onChanged: onChanged),
      ],
    );
  }

  Color _parseColor(String color) {
    color = color.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    }
    return Colors.black;
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
            '${color.green.toRadixString(16).padLeft(2, '0')}'
            '${color.blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}
