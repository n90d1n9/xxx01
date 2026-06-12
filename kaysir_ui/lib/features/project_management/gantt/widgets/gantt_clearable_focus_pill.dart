import 'package:flutter/material.dart';

class GanttClearableFocusPill extends StatelessWidget {
  const GanttClearableFocusPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onClear,
    this.clearButtonKey,
    this.clearTooltip,
    this.maxWidth = 240,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onClear;
  final Key? clearButtonKey;
  final String? clearTooltip;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = color;
    final background = color.withValues(alpha: 0.1);
    final border = color.withValues(alpha: 0.35);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: clearTooltip ?? 'Clear $label',
                child: IconButton(
                  key: clearButtonKey,
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    foregroundColor: foreground,
                    disabledForegroundColor: colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: onClear,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
