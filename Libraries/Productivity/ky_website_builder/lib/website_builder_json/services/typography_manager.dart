import 'package:flutter/material.dart';

import '../models/schema/styles/typography.dart' as t;
import '../widgets/advanced_color_picker.dart';

class TypographyManager extends StatefulWidget {
  final t.Typography? initialTypography;
  final ValueChanged<t.Typography> onTypographyChanged;

  const TypographyManager({
    super.key,
    this.initialTypography,
    required this.onTypographyChanged,
  });

  @override
  State<TypographyManager> createState() => _TypographyManagerState();
}

class _TypographyManagerState extends State<TypographyManager> {
  late t.Typography _typography;

  final List<String> _fontFamilies = [
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Playfair Display',
    'Merriweather',
  ];

  @override
  void initState() {
    super.initState();
    _typography = widget.initialTypography ?? t.Typography();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Typography',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'The quick brown fox jumps over the lazy dog',
              style: TextStyle(
                fontFamily: _typography.fontFamily,
                fontSize:
                    double.tryParse(
                      _typography.fontSize?.replaceAll('px', '') ?? '16',
                    ) ??
                    16,
                fontWeight: _parseFontWeight(_typography.fontWeight),
                fontStyle:
                    _typography.fontStyle == 'italic'
                        ? FontStyle.italic
                        : FontStyle.normal,
                color: _parseColor(_typography.color ?? '#000000'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Font Family
          const Text(
            'Font Family',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _typography.fontFamily ?? _fontFamilies[0],
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items:
                _fontFamilies.map((font) {
                  return DropdownMenuItem(value: font, child: Text(font));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _typography = _typography.copyWith(fontFamily: value);
              });
              widget.onTypographyChanged(_typography);
            },
          ),
          const SizedBox(height: 16),

          // Font Size
          const Text(
            'Font Size',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value:
                      double.tryParse(
                        _typography.fontSize?.replaceAll('px', '') ?? '16',
                      ) ??
                      16,
                  min: 8,
                  max: 72,
                  divisions: 64,
                  label: _typography.fontSize ?? '16px',
                  onChanged: (value) {
                    setState(() {
                      _typography = _typography.copyWith(
                        fontSize: '${value.toInt()}px',
                      );
                    });
                    widget.onTypographyChanged(_typography);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  _typography.fontSize ?? '16px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Font Weight
          const Text(
            'Font Weight',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ['300', '400', '500', '600', '700', '800'].map((weight) {
                  final isSelected =
                      _typography.fontWeight == weight ||
                      (_typography.fontWeight == 'normal' && weight == '400') ||
                      (_typography.fontWeight == 'bold' && weight == '700');
                  return ChoiceChip(
                    label: Text(weight),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _typography = _typography.copyWith(
                            fontWeight: weight,
                          );
                        });
                        widget.onTypographyChanged(_typography);
                      }
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),

          // Text Align
          const Text(
            'Text Align',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'left',
                label: Text('Left'),
                icon: Icon(Icons.format_align_left, size: 16),
              ),
              ButtonSegment(
                value: 'center',
                label: Text('Center'),
                icon: Icon(Icons.format_align_center, size: 16),
              ),
              ButtonSegment(
                value: 'right',
                label: Text('Right'),
                icon: Icon(Icons.format_align_right, size: 16),
              ),
            ],
            selected: {_typography.textAlign ?? 'left'},
            onSelectionChanged: (selected) {
              setState(() {
                _typography = _typography.copyWith(textAlign: selected.first);
              });
              widget.onTypographyChanged(_typography);
            },
          ),
          const SizedBox(height: 16),

          // Text Color
          const Text(
            'Text Color',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          content: AdvancedColorPicker(
                            initialColor: _typography.color ?? '#000000',
                            onColorChanged: (color) {
                              setState(() {
                                _typography = _typography.copyWith(
                                  color: color,
                                );
                              });
                              widget.onTypographyChanged(_typography);
                            },
                          ),
                        ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(_typography.color ?? '#000000'),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _typography.color ?? '#000000',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Line Height
          const Text(
            'Line Height',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: double.tryParse(_typography.lineHeight ?? '1.5') ?? 1.5,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            label: _typography.lineHeight ?? '1.5',
            onChanged: (value) {
              setState(() {
                _typography = _typography.copyWith(
                  lineHeight: value.toStringAsFixed(1),
                );
              });
              widget.onTypographyChanged(_typography);
            },
          ),

          // Letter Spacing
          const Text(
            'Letter Spacing',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value:
                double.tryParse(
                  _typography.letterSpacing?.replaceAll('px', '') ?? '0',
                ) ??
                0,
            min: -2,
            max: 10,
            divisions: 24,
            label: '${_typography.letterSpacing ?? '0px'}',
            onChanged: (value) {
              setState(() {
                _typography = _typography.copyWith(
                  letterSpacing: '${value.toStringAsFixed(1)}px',
                );
              });
              widget.onTypographyChanged(_typography);
            },
          ),
        ],
      ),
    );
  }

  FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '400':
      case 'normal':
        return FontWeight.w400;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '700':
      case 'bold':
        return FontWeight.w700;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  Color _parseColor(String color) {
    color = color.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    }
    return Colors.black;
  }
}
