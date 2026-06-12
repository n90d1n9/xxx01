import 'registry_health_api_conformance_gate.dart';

String registryHealthApiConformanceGateText(
  RegistryHealthApiConformanceGateReport report, {
  int gateLimit = 8,
}) {
  final lines = <String>[
    '# API Conformance Gates',
    '',
    'Status: ${report.statusLabel}',
    'Gates: ${report.gateCount}',
    'Ready: ${report.readyGateCount}',
    'Review: ${report.reviewGateCount}',
    'Blocked: ${report.blockedGateCount}',
    'Checks: ${report.requiredCheckCount}',
    'Acceptance: ${report.acceptanceCriteriaCount}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: gateLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.gateLabel}')
      ..add('')
      ..add('- Status: ${item.statusLabel}')
      ..add('- Scope: ${item.caseScopeLabel}')
      ..add('- ${item.summaryLabel}');
    for (final check in item.requiredChecks) {
      lines.add('- [ ] $check');
    }
    for (final criterion in item.acceptanceCriteria) {
      lines.add('- Accept: $criterion');
    }
    lines.add('');
  }

  final hiddenCount = report.gateCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more conformance gates hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}
