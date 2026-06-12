import 'package:flutter/material.dart';

import '../models/registry_diagnostics.dart';
import 'metric_pill.dart';
import 'notice_tone.dart';
import 'registry_issue_source_icon.dart';
import 'tone.dart';

class RegistrySourcePill extends StatelessWidget {
  const RegistrySourcePill({required this.summary, super.key});

  final RegistrySourceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = noticeIssueColors(
      theme.colorScheme,
      summary.hasIssues ? VisualTone.danger : VisualTone.success,
      backgroundAlpha: 0.1,
    );

    return MetricPill(
      icon: Icon(registryIssueSourceIcon(summary.source)),
      label: summary.label,
      value: summary.valueLabel,
      colors: colors,
      backgroundSource: ToneBackgroundSource.container,
    );
  }
}
