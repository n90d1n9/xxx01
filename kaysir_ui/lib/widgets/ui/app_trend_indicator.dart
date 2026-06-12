import 'package:flutter/material.dart';

enum AppTrendIndicatorVariant { pill, inline, icon }

class AppTrendIndicator extends StatelessWidget {
  const AppTrendIndicator({
    super.key,
    required this.value,
    this.isPositive,
    this.variant = AppTrendIndicatorVariant.pill,
    this.compactValue = true,
    this.color,
    this.tooltip,
    this.maxWidth = 120,
    this.iconSize = 16,
  });

  final String value;
  final bool? isPositive;
  final AppTrendIndicatorVariant variant;
  final bool compactValue;
  final Color? color;
  final String? tooltip;
  final double maxWidth;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final trendIsPositive = isPositive ?? !value.trim().startsWith('-');
    final trendColor =
        color ??
        (trendIsPositive
            ? const Color(0xFF168A52)
            : Theme.of(context).colorScheme.error);
    final icon = Icon(
      trendIsPositive ? Icons.trending_up : Icons.trending_down,
      color: trendColor,
      size: iconSize,
    );

    if (variant == AppTrendIndicatorVariant.icon) {
      return Tooltip(message: tooltip ?? value, child: icon);
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            compactValue ? _compactLabel(value) : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );

    if (variant == AppTrendIndicatorVariant.inline) {
      return Tooltip(
        message: tooltip ?? value,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    return Tooltip(
      message: tooltip ?? value,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: trendColor.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(8),
        ),
        child: content,
      ),
    );
  }

  String _compactLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return value;

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && (parts.first == '+' || parts.first == '-')) {
      return '${parts.first} ${parts[1]}';
    }

    return parts.first;
  }
}
