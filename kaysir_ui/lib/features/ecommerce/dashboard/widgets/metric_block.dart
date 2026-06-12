import 'package:flutter/material.dart';

enum MetricBlockScale { compact, prominent }

class MetricBlock extends StatelessWidget {
  const MetricBlock({
    required this.label,
    required this.value,
    this.detail,
    this.scale = MetricBlockScale.compact,
    this.labelMaxLines = 1,
    this.valueMaxLines = 1,
    this.detailMaxLines = 1,
    this.labelFontWeight = FontWeight.w800,
    this.valueFontWeight = FontWeight.w900,
    this.detailFontWeight = FontWeight.w700,
    super.key,
  });

  final String label;
  final String value;
  final String? detail;
  final MetricBlockScale scale;
  final int labelMaxLines;
  final int valueMaxLines;
  final int detailMaxLines;
  final FontWeight labelFontWeight;
  final FontWeight valueFontWeight;
  final FontWeight detailFontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    final spacing = _spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: labelMaxLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: labelFontWeight,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          value,
          maxLines: valueMaxLines,
          overflow: TextOverflow.ellipsis,
          style: _valueTextStyle(theme)?.copyWith(fontWeight: valueFontWeight),
        ),
        if (detail != null) ...[
          SizedBox(height: spacing),
          Text(
            detail,
            maxLines: detailMaxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: detailFontWeight,
            ),
          ),
        ],
      ],
    );
  }

  double get _spacing {
    return switch (scale) {
      MetricBlockScale.compact => 2,
      MetricBlockScale.prominent => 3,
    };
  }

  TextStyle? _valueTextStyle(ThemeData theme) {
    return switch (scale) {
      MetricBlockScale.compact => theme.textTheme.titleSmall,
      MetricBlockScale.prominent => theme.textTheme.titleLarge,
    };
  }
}
