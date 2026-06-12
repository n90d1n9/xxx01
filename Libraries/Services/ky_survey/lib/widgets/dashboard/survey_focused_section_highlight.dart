import 'package:flutter/material.dart';

/// Adds a temporary, non-disruptive highlight around a dashboard section.
class SurveyFocusedSectionHighlight extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  final String? semanticsLabel;
  final EdgeInsetsGeometry padding;

  const SurveyFocusedSectionHighlight({
    super.key,
    required this.child,
    this.highlighted = false,
    this.semanticsLabel,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.tertiary;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.55)
              : Colors.transparent,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.14),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      child: child,
    );

    final label = semanticsLabel;
    if (label == null || label.isEmpty) {
      return content;
    }

    return Semantics(
      container: true,
      liveRegion: highlighted,
      label: label,
      child: content,
    );
  }
}
