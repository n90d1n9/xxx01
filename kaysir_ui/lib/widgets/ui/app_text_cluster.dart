import 'package:flutter/material.dart';

class AppTextCluster extends StatelessWidget {
  const AppTextCluster({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.titleStyle,
    this.subtitleStyle,
    this.eyebrowStyle,
    this.titleMaxLines,
    this.subtitleMaxLines,
    this.eyebrowMaxLines = 1,
    this.titleOverflow,
    this.subtitleOverflow,
    this.eyebrowOverflow = TextOverflow.ellipsis,
    this.eyebrowGap = 4,
    this.titleGap = 6,
    this.subtitleMaxWidth,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? eyebrowStyle;
  final int? titleMaxLines;
  final int? subtitleMaxLines;
  final int? eyebrowMaxLines;
  final TextOverflow? titleOverflow;
  final TextOverflow? subtitleOverflow;
  final TextOverflow? eyebrowOverflow;
  final double eyebrowGap;
  final double titleGap;
  final double? subtitleMaxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedTitleStyle =
        titleStyle ??
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    final resolvedSubtitleStyle =
        subtitleStyle ??
        Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);
    final resolvedEyebrowStyle =
        eyebrowStyle ??
        Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        );

    final subtitleText =
        subtitle == null
            ? null
            : Text(
              subtitle!,
              maxLines: subtitleMaxLines,
              overflow: subtitleOverflow,
              textAlign: textAlign,
              style: resolvedSubtitleStyle,
            );

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            maxLines: eyebrowMaxLines,
            overflow: eyebrowOverflow,
            textAlign: textAlign,
            style: resolvedEyebrowStyle,
          ),
          SizedBox(height: eyebrowGap),
        ],
        Text(
          title,
          maxLines: titleMaxLines,
          overflow: titleOverflow,
          textAlign: textAlign,
          style: resolvedTitleStyle,
        ),
        if (subtitleText != null) ...[
          SizedBox(height: titleGap),
          if (subtitleMaxWidth == null)
            subtitleText
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: subtitleMaxWidth!),
              child: subtitleText,
            ),
        ],
      ],
    );
  }
}
