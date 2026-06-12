import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

class ProjectFormPercentSlider extends StatelessWidget {
  const ProjectFormPercentSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = (value * 100).round();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppStatusPill(
                  label: '$percent%',
                  icon: Icons.percent_rounded,
                  color: color,
                  maxWidth: 90,
                ),
              ],
            ),
            Slider(
              value: value.clamp(0, 1),
              divisions: 20,
              activeColor: color,
              label: '$percent%',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
