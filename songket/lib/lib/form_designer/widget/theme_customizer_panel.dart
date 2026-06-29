import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/color_scheme.dart' as col;
import '../model/form_theme.dart';
import '../model/theme/border_style.dart';
import '../service/theme_manager.dart';

class ThemeCustomizerPanel extends ConsumerWidget {
  const ThemeCustomizerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: theme.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Theme Customizer',
                style: TextStyle(
                  color: theme.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: theme.colors.textSecondary),
                onPressed: () =>
                    ref.read(showThemePanelProvider.notifier).state = false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _ColorPicker(
                label: 'Primary',
                color: theme.colors.primary,
                onChanged: (color) {
                  ref
                      .read(themeManagerProvider.notifier)
                      .updateColors(
                        col.ColorScheme(
                          primary: color,
                          secondary: theme.colors.secondary,
                          background: theme.colors.background,
                          surface: theme.colors.surface,
                          error: theme.colors.error,
                          text: theme.colors.text,
                          textSecondary: theme.colors.textSecondary,
                          border: theme.colors.border,
                          inputBackground: theme.colors.inputBackground,
                        ),
                      );
                },
              ),
              _ColorPicker(
                label: 'Background',
                color: theme.colors.background,
                onChanged: (color) {
                  ref
                      .read(themeManagerProvider.notifier)
                      .updateColors(
                        col.ColorScheme(
                          primary: theme.colors.primary,
                          secondary: theme.colors.secondary,
                          background: color,
                          surface: theme.colors.surface,
                          error: theme.colors.error,
                          text: theme.colors.text,
                          textSecondary: theme.colors.textSecondary,
                          border: theme.colors.border,
                          inputBackground: theme.colors.inputBackground,
                        ),
                      );
                },
              ),
              _ColorPicker(
                label: 'Surface',
                color: theme.colors.surface,
                onChanged: (color) {
                  ref
                      .read(themeManagerProvider.notifier)
                      .updateColors(
                        col.ColorScheme(
                          primary: theme.colors.primary,
                          secondary: theme.colors.secondary,
                          background: theme.colors.background,
                          surface: color,
                          error: theme.colors.error,
                          text: theme.colors.text,
                          textSecondary: theme.colors.textSecondary,
                          border: theme.colors.border,
                          inputBackground: theme.colors.inputBackground,
                        ),
                      );
                },
              ),
              _SliderControl(
                label: 'Border Radius',
                value: theme.borders.radius,
                min: 0,
                max: 24,
                onChanged: (value) {
                  ref
                      .read(themeManagerProvider.notifier)
                      .updateBorders(
                        BorderStyles(
                          radius: value,
                          width: theme.borders.width,
                          style: theme.borders.style,
                        ),
                      );
                },
              ),
              _SliderControl(
                label: 'Spacing',
                value: theme.spacing.md,
                min: 8,
                max: 32,
                onChanged: (value) {
                  ref
                      .read(themeManagerProvider.notifier)
                      .updateSpacing(
                        Spacing(
                          xs: value / 4,
                          sm: value / 2,
                          md: value,
                          lg: value * 1.5,
                          xl: value * 2,
                        ),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final Function(Color) onChanged;

  const _ColorPicker({
    required this.label,
    required this.color,
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
          onTap: () {
            // In a real app, show color picker dialog
            // For now, cycle through preset colors
            final colors = [
              const Color(0xFF2196F3),
              const Color(0xFF9C27B0),
              const Color(0xFF4CAF50),
              const Color(0xFFFF9800),
              const Color(0xFFF44336),
            ];
            final currentIndex = colors.indexOf(color);
            final nextColor = colors[(currentIndex + 1) % colors.length];
            onChanged(nextColor);
          },
          child: Container(
            width: 60,
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

class _SliderControl extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _SliderControl({
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
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 8),
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
        SizedBox(
          width: 150,
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
