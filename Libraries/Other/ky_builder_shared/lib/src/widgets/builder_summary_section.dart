import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'builder_issue_list.dart';
import 'builder_metric_strip.dart';

/// Groups builder summary text, metrics, issues, and detail rows consistently.
class KyBuilderSummarySection extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final List<KyBuilderMetricItem> metrics;
  final List<KyBuilderIssueItem> issues;
  final List<Widget> children;
  final double spacing;

  const KyBuilderSummarySection({
    super.key,
    this.title,
    this.subtitle,
    this.metrics = const [],
    this.issues = const [],
    this.children = const [],
    this.spacing = 12,
  });

  @Preview(name: 'Builder summary section')
  const KyBuilderSummarySection.preview({super.key})
    : title = const Text('Import summary'),
      subtitle = const Text('Register Layout'),
      metrics = const [
        KyBuilderMetricItem(
          icon: Icons.file_download_outlined,
          value: '4',
          label: 'imported',
        ),
        KyBuilderMetricItem(icon: Icons.transform, value: '2', label: 'mapped'),
      ],
      issues = const [
        KyBuilderIssueItem(
          severity: KyBuilderIssueSeverity.info,
          message: 'Two legacy kinds will be mapped automatically.',
        ),
      ],
      children = const [],
      spacing = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final content = <Widget>[];

    if (title != null) {
      content.add(
        DefaultTextStyle.merge(
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          child: title!,
        ),
      );
    }

    if (subtitle != null) {
      content.add(
        DefaultTextStyle.merge(
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          child: subtitle!,
        ),
      );
    }

    if (metrics.isNotEmpty) {
      content.add(KyBuilderMetricStrip(metrics: metrics));
    }

    if (issues.isNotEmpty) {
      content.add(KyBuilderIssueList(issues: issues));
    }

    content.addAll(children);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < content.length; index += 1) ...[
          if (index > 0) SizedBox(height: spacing),
          content[index],
        ],
      ],
    );
  }
}
