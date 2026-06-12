import 'package:flutter/material.dart';

class KyGanttSelectedTaskRowHighlight extends StatelessWidget {
  const KyGanttSelectedTaskRowHighlight({
    required this.selectedRowIndex,
    required this.width,
    required this.rowHeight,
    this.color,
    this.opacity = 0.08,
    Key? key,
  }) : super(key: key ?? defaultHighlightKey);

  static const defaultHighlightKey = ValueKey(
    'ky-gantt-selected-task-row-highlight',
  );

  final int selectedRowIndex;
  final double width;
  final double rowHeight;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (selectedRowIndex < 0 || width <= 0 || rowHeight <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final highlightColor = color ?? colorScheme.primary;
    final normalizedOpacity = opacity.clamp(0, 1).toDouble();
    final edgeOpacity = (normalizedOpacity * 2).clamp(0, 0.28).toDouble();

    return Positioned(
      left: 0,
      top: selectedRowIndex * rowHeight,
      width: width,
      height: rowHeight,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  highlightColor.withValues(alpha: normalizedOpacity),
                  highlightColor.withValues(alpha: normalizedOpacity * 0.56),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: highlightColor.withValues(alpha: edgeOpacity),
                  width: 0.8,
                ),
                bottom: BorderSide(
                  color: highlightColor.withValues(alpha: edgeOpacity),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
