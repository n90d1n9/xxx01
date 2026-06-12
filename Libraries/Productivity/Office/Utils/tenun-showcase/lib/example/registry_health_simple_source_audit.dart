import 'package:flutter/material.dart';

import 'simple_charts_showcase_families.dart';
import 'simple_charts_showcase_source_audit.dart';

class RegistryHealthSimpleSourceAuditPanel extends StatelessWidget {
  const RegistryHealthSimpleSourceAuditPanel({
    super.key,
    required this.audit,
    this.issueLimit = 8,
  });

  final SimpleChartSourceAuditReport audit;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final statusColor = registryHealthSimpleSourceAuditStatusColor(audit);
    final visibleIssues = registryHealthSimpleSourceAuditVisibleIssues(
      audit,
      limit: issueLimit,
    );
    final visibleIssueCodes = registryHealthSimpleSourceAuditVisibleIssueCodes(
      audit,
    );
    final tierCounts = registryHealthSimpleSourceAuditTierCounts(audit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthSimpleSourceAuditSummary(audit),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SimpleSourceAuditMetricChip(
              label: 'Status',
              value: registryHealthSimpleSourceAuditStatusLabel(audit),
              color: statusColor,
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Sources',
              value: '${audit.sourceCount}/${audit.requiredSourceCount}',
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Panels',
              value: audit.panelCount.toString(),
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Families',
              value: audit.familyCount.toString(),
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Cases',
              value: audit.caseCount.toString(),
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Types',
              value: audit.chartTypes.length.toString(),
            ),
            _SimpleSourceAuditMetricChip(
              label: 'Issues',
              value: audit.issues.length.toString(),
              color: audit.issues.isEmpty
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tierCounts.isNotEmpty) ...[
          _SimpleSourceAuditCoverageGroup(
            title: 'Tier Coverage',
            children: [
              for (final entry in tierCounts)
                _SimpleSourceAuditCoverageChip(
                  label: entry.key.label,
                  value: registryHealthSimpleSourceAuditFamilyCountLabel(
                    entry.value,
                  ),
                  color: registryHealthSimpleSourceAuditTierColor(entry.key),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (audit.caseResults.isNotEmpty) ...[
          _SimpleSourceAuditCoverageGroup(
            title: 'Case Coverage',
            children: [
              for (final result in audit.caseResults)
                _SimpleSourceAuditCoverageChip(
                  label: result.label,
                  value: registryHealthSimpleSourceAuditCoverageLabel(
                    sourceCount: result.sourceCount,
                    requiredSourceCount: result.requiredSourceCount,
                    unexpectedSourceCount: result.unexpectedSourceCount,
                  ),
                  color: registryHealthSimpleSourceAuditCoverageColor(
                    missingSourceCount: result.missingSourceCount,
                    unexpectedSourceCount: result.unexpectedSourceCount,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        _SimpleSourceAuditCoverageGroup(
          title: 'Family Coverage',
          children: [
            for (final family in audit.families)
              _SimpleSourceAuditCoverageChip(
                label: family.title,
                value: registryHealthSimpleSourceAuditCoverageLabel(
                  sourceCount: family.sourceCount,
                  requiredSourceCount: family.requiredSourceCount,
                  unexpectedSourceCount: family.unexpectedSourceCount,
                ),
                color: registryHealthSimpleSourceAuditCoverageColor(
                  missingSourceCount: family.missingSourceCount,
                  unexpectedSourceCount: family.unexpectedSourceCount,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleIssueCodes.isNotEmpty) ...[
          _SimpleSourceAuditCoverageGroup(
            title: 'Issue Breakdown',
            children: [
              for (final entry in visibleIssueCodes)
                _SimpleSourceAuditCoverageChip(
                  label: entry.key,
                  value: entry.value.toString(),
                  color: Colors.red.shade700,
                ),
              if (audit.issueCodeCounts.length > visibleIssueCodes.length)
                _SimpleSourceAuditCoverageChip(
                  label: 'More',
                  value:
                      '+${audit.issueCodeCounts.length - visibleIssueCodes.length}',
                  color: Colors.orange.shade800,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleIssues.isEmpty)
          const Text('No simple source audit issues.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final issue in visibleIssues)
                _SimpleSourceAuditIssueRow(issue: issue),
              if (audit.issues.length > visibleIssues.length)
                Text(
                  '+${audit.issues.length - visibleIssues.length} more issues',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
      ],
    );
  }
}

String registryHealthSimpleSourceAuditStatusLabel(
  SimpleChartSourceAuditReport audit,
) {
  return audit.isValid ? 'Ready' : 'Issues';
}

String registryHealthSimpleSourceAuditSummary(
  SimpleChartSourceAuditReport audit,
) {
  if (audit.caseCount > 0) {
    final sourceLabel = audit.sourceCount == 1 ? 'source' : 'sources';
    final panelLabel = audit.panelCount == 1 ? 'panel' : 'panels';
    final familyLabel = audit.familyCount == 1 ? 'family' : 'families';
    final caseLabel = audit.caseCount == 1 ? 'knob case' : 'knob cases';
    return '${audit.sourceCount}/${audit.requiredSourceCount} simple chart '
        '$sourceLabel across ${audit.panelCount} $panelLabel, '
        '${audit.familyCount} $familyLabel, and ${audit.caseCount} '
        '$caseLabel checked for copy-ready JSON and Dart code.';
  }

  final sourceLabel = audit.sourceCount == 1 ? 'source' : 'sources';
  final panelLabel = audit.panelCount == 1 ? 'panel' : 'panels';
  final familyLabel = audit.familyCount == 1 ? 'family' : 'families';
  return '${audit.sourceCount} simple chart $sourceLabel across '
      '${audit.panelCount} $panelLabel and ${audit.familyCount} $familyLabel '
      'checked for copy-ready JSON and Dart code.';
}

Color registryHealthSimpleSourceAuditStatusColor(
  SimpleChartSourceAuditReport audit,
) {
  return audit.isValid ? Colors.green.shade700 : Colors.red.shade700;
}

List<MapEntry<SimpleChartsShowcaseTier, int>>
registryHealthSimpleSourceAuditTierCounts(SimpleChartSourceAuditReport audit) {
  final counts = <SimpleChartsShowcaseTier, int>{};
  for (final family in audit.families) {
    counts.update(family.tier, (count) => count + 1, ifAbsent: () => 1);
  }

  return [
    for (final tier in SimpleChartsShowcaseTier.values)
      if ((counts[tier] ?? 0) > 0) MapEntry(tier, counts[tier]!),
  ];
}

String registryHealthSimpleSourceAuditFamilyCountLabel(int count) {
  final familyLabel = count == 1 ? 'family' : 'families';
  return '$count $familyLabel';
}

Color registryHealthSimpleSourceAuditTierColor(SimpleChartsShowcaseTier tier) {
  return switch (tier) {
    SimpleChartsShowcaseTier.core => Colors.blue.shade700,
    SimpleChartsShowcaseTier.pro => Colors.indigo.shade700,
    SimpleChartsShowcaseTier.custom => Colors.grey.shade700,
  };
}

String registryHealthSimpleSourceAuditCoverageLabel({
  required int sourceCount,
  required int requiredSourceCount,
  int unexpectedSourceCount = 0,
}) {
  final base = '$sourceCount/$requiredSourceCount';
  if (unexpectedSourceCount == 0) {
    return base;
  }
  return '$base +$unexpectedSourceCount';
}

Color registryHealthSimpleSourceAuditCoverageColor({
  required int missingSourceCount,
  required int unexpectedSourceCount,
}) {
  return missingSourceCount == 0 && unexpectedSourceCount == 0
      ? Colors.green.shade700
      : Colors.red.shade700;
}

List<MapEntry<String, int>> registryHealthSimpleSourceAuditVisibleIssueCodes(
  SimpleChartSourceAuditReport audit, {
  int limit = 6,
}) {
  final sorted = audit.issueCodeCounts.entries.toList(growable: false)
    ..sort((a, b) {
      final count = b.value.compareTo(a.value);
      if (count != 0) return count;
      return a.key.compareTo(b.key);
    });

  return sorted.take(limit).toList(growable: false);
}

List<SimpleChartSourceAuditIssue> registryHealthSimpleSourceAuditVisibleIssues(
  SimpleChartSourceAuditReport audit, {
  int limit = 8,
}) {
  final sorted = List<SimpleChartSourceAuditIssue>.from(audit.issues)
    ..sort((a, b) {
      final family = a.familyId.compareTo(b.familyId);
      if (family != 0) return family;
      final auditCase = (a.caseId ?? '').compareTo(b.caseId ?? '');
      if (auditCase != 0) return auditCase;
      final panel = (a.panelIndex ?? -1).compareTo(b.panelIndex ?? -1);
      if (panel != 0) return panel;
      return a.code.compareTo(b.code);
    });

  return sorted.take(limit).toList(growable: false);
}

String registryHealthSimpleSourceAuditIssueLocation(
  SimpleChartSourceAuditIssue issue,
) {
  final panel = issue.panelTitle?.trim();
  final type = issue.chartType?.trim();
  final location = panel == null || panel.isEmpty
      ? issue.familyTitle
      : '${issue.familyTitle} / $panel';
  final typedLocation = type == null || type.isEmpty
      ? location
      : '$location ($type)';
  final auditCase = issue.caseLabel?.trim();
  if (auditCase == null || auditCase.isEmpty) {
    return typedLocation;
  }
  return '$typedLocation / $auditCase';
}

class _SimpleSourceAuditMetricChip extends StatelessWidget {
  const _SimpleSourceAuditMetricChip({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: effectiveColor.withValues(alpha: 0.12),
        foregroundColor: effectiveColor,
        child: Text(value, style: const TextStyle(fontSize: 10)),
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SimpleSourceAuditCoverageGroup extends StatelessWidget {
  const _SimpleSourceAuditCoverageGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _SimpleSourceAuditCoverageChip extends StatelessWidget {
  const _SimpleSourceAuditCoverageChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SimpleSourceAuditIssueRow extends StatelessWidget {
  const _SimpleSourceAuditIssueRow({required this.issue});

  final SimpleChartSourceAuditIssue issue;

  @override
  Widget build(BuildContext context) {
    final color = Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registryHealthSimpleSourceAuditIssueLocation(issue),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${issue.code}: ${issue.message}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
