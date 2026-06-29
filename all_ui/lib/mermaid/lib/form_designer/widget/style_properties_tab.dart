import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../states/form_field_provider.dart';
import '../style/field_style.dart';
import '../style/icon_picker_data.dart';
import '../style/style_preset.dart';

class StylePropertiesTab extends ConsumerWidget {
  final FormTheme theme;
  final FieldConfig field;

  const StylePropertiesTab({
    super.key,
    required this.theme,
    required this.field,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = field.style ?? const FieldStyle();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Style Presets
        Text(
          'Quick Presets',
          style: TextStyle(
            color: theme.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StylePresets.all.map((preset) {
            return OutlinedButton(
              onPressed: () {
                final updatedField = field.withStyle(preset.value);
                ref
                    .read(formFieldsProvider.notifier)
                    .updateField(field.id, updatedField);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colors.text,
                side: BorderSide(color: theme.colors.border),
              ),
              child: Text(preset.key, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Colors
        Text(
          'Colors',
          style: TextStyle(
            color: theme.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _ColorOption(
          label: 'Background',
          color: currentStyle.backgroundColor ?? theme.colors.inputBackground,
          onChanged: (color) =>
              _updateStyle(ref, currentStyle.copyWith(backgroundColor: color)),
        ),
        const SizedBox(height: 8),
        _ColorOption(
          label: 'Border',
          color: currentStyle.borderColor ?? theme.colors.border,
          onChanged: (color) =>
              _updateStyle(ref, currentStyle.copyWith(borderColor: color)),
        ),
        const SizedBox(height: 8),
        _ColorOption(
          label: 'Text',
          color: currentStyle.textColor ?? theme.colors.text,
          onChanged: (color) =>
              _updateStyle(ref, currentStyle.copyWith(textColor: color)),
        ),

        const SizedBox(height: 24),

        // Border & Spacing
        Text(
          'Border & Spacing',
          style: TextStyle(
            color: theme.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _SliderOption(
          label: 'Border Radius',
          value: currentStyle.borderRadius ?? 8,
          min: 0,
          max: 32,
          onChanged: (value) =>
              _updateStyle(ref, currentStyle.copyWith(borderRadius: value)),
        ),
        _SliderOption(
          label: 'Border Width',
          value: currentStyle.borderWidth ?? 1,
          min: 0,
          max: 8,
          onChanged: (value) =>
              _updateStyle(ref, currentStyle.copyWith(borderWidth: value)),
        ),
        _SliderOption(
          label: 'Elevation',
          value: currentStyle.elevation ?? 0,
          min: 0,
          max: 16,
          onChanged: (value) =>
              _updateStyle(ref, currentStyle.copyWith(elevation: value)),
        ),

        const SizedBox(height: 24),

        // Icons
        Text(
          'Icons',
          style: TextStyle(
            color: theme.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _IconPicker(
                label: 'Prefix Icon',
                icon: currentStyle.prefixIcon,
                onChanged: (icon) =>
                    _updateStyle(ref, currentStyle.copyWith(prefixIcon: icon)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _IconPicker(
                label: 'Suffix Icon',
                icon: currentStyle.suffixIcon,
                onChanged: (icon) =>
                    _updateStyle(ref, currentStyle.copyWith(suffixIcon: icon)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Reset button
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reset Style'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colors.error,
            side: BorderSide(color: theme.colors.error),
          ),
          onPressed: () {
            final updatedField = field.copyWith(
              options: [...?field.options]..remove('style'),
            );
            ref
                .read(formFieldsProvider.notifier)
                .updateField(field.id, updatedField);
          },
        ),
      ],
    );
  }

  void _updateStyle(WidgetRef ref, FieldStyle style) {
    final updatedField = field.withStyle(style);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }
}

class _ColorOption extends StatelessWidget {
  final String label;
  final Color color;
  final Function(Color) onChanged;

  const _ColorOption({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Cycle through preset colors
            final colors = [
              const Color(0xFF2196F3),
              const Color(0xFF4CAF50),
              const Color(0xFFFF9800),
              const Color(0xFF9C27B0),
              const Color(0xFFF44336),
              const Color(0xFF1E1E1E),
              const Color(0xFFFFFFFF),
            ];
            final currentIndex = colors.indexWhere(
              (c) => c.value == color.value,
            );
            final nextColor = colors[(currentIndex + 1) % colors.length];
            onChanged(nextColor);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliderOption extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _SliderOption({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '${value.toInt()}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Function(IconData?) onChanged;

  const _IconPicker({
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showIconPicker(context),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: Colors.white70)
                  : const Text(
                      'None',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Select Icon', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: IconPickerData.commonIcons.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    onChanged(null);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: icon == null ? Colors.blue : Colors.white24,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'None',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ),
                );
              }

              final iconData = IconPickerData.commonIcons[index - 1];
              return GestureDetector(
                onTap: () {
                  onChanged(iconData);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: icon == iconData ? Colors.blue : Colors.white24,
                    ),
                  ),
                  child: Icon(iconData, color: Colors.white70),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
