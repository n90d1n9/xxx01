import 'registry_health_api_consistency_release_brief.dart';

String registryHealthApiConsistencyReleaseBriefText(
  RegistryHealthApiConsistencyReleaseBriefReport report, {
  int itemLimit = 8,
}) {
  final lines = <String>[
    '# API Release Brief',
    '',
    'Status: ${report.statusLabel}',
    'Release: ${report.releaseLabel}',
    'Current score: ${report.currentScorePercent}%',
    'Projected score: ${report.projectedScorePercent}%',
    'Score lift: ${report.scoreLiftLabel} pts',
    'Review: ${report.reviewItemCount}',
    'Blocked: ${report.blockedItemCount}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: itemLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.kindLabel}')
      ..add('')
      ..add('- Status: ${item.statusLabel}')
      ..add('- ${item.summaryLabel}')
      ..add('- ${item.detailLabel}')
      ..add('- Metrics: ${item.metricSummaryLabel}')
      ..add('');
  }

  final hiddenCount = report.itemCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more release brief items hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}
