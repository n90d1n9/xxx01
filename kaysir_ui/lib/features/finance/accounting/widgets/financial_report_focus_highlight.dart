import 'package:flutter/material.dart';

class FinancialReportFocusHighlight extends StatelessWidget {
  const FinancialReportFocusHighlight({
    required this.active,
    required this.child,
    this.color,
    super.key,
  });

  final bool active;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.72) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow:
            active
                ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
                : const [],
      ),
      child: child,
    );
  }
}
