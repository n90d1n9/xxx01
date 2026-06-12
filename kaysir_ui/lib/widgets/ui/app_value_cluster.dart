import 'package:flutter/material.dart';

class AppValueCluster extends StatelessWidget {
  const AppValueCluster({
    super.key,
    this.value,
    this.label,
    this.detail,
    this.valueStyle,
    this.labelStyle,
    this.detailStyle,
    this.valueMaxLines = 1,
    this.labelMaxLines = 1,
    this.detailMaxLines = 1,
    this.valueOverflow = TextOverflow.ellipsis,
    this.labelOverflow = TextOverflow.ellipsis,
    this.detailOverflow = TextOverflow.ellipsis,
    this.labelGap = 6,
    this.detailGap = 3,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign,
  });

  final String? value;
  final String? label;
  final String? detail;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final TextStyle? detailStyle;
  final int? valueMaxLines;
  final int? labelMaxLines;
  final int? detailMaxLines;
  final TextOverflow? valueOverflow;
  final TextOverflow? labelOverflow;
  final TextOverflow? detailOverflow;
  final double labelGap;
  final double detailGap;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedLabelStyle =
        labelStyle ??
        Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        );
    final resolvedValueStyle =
        valueStyle ??
        Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800);
    final resolvedDetailStyle =
        detailStyle ??
        Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            maxLines: labelMaxLines,
            overflow: labelOverflow,
            textAlign: textAlign,
            style: resolvedLabelStyle,
          ),
          if (value != null) SizedBox(height: labelGap),
        ],
        if (value != null)
          Text(
            value!,
            maxLines: valueMaxLines,
            overflow: valueOverflow,
            textAlign: textAlign,
            style: resolvedValueStyle,
          ),
        if (detail != null) ...[
          if (label != null || value != null) SizedBox(height: detailGap),
          Text(
            detail!,
            maxLines: detailMaxLines,
            overflow: detailOverflow,
            textAlign: textAlign,
            style: resolvedDetailStyle,
          ),
        ],
      ],
    );
  }
}
