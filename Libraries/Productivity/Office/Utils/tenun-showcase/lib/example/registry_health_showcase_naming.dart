import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

import 'chart_samples_registry.dart';

enum RegistryHealthShowcaseNamingStatus {
  canonical,
  normalized,
  alias,
  unknown,
}

class RegistryHealthShowcaseNamingRow {
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String sampleTitle;
  final int? sampleIndex;
  final String providedKey;
  final String? canonicalKey;
  final String? displayName;
  final RegistryHealthShowcaseNamingStatus status;
  final String suggestion;

  const RegistryHealthShowcaseNamingRow({
    required this.familyId,
    required this.familyTitle,
    this.familyIndex,
    required this.sampleTitle,
    this.sampleIndex,
    required this.providedKey,
    required this.canonicalKey,
    required this.displayName,
    required this.status,
    required this.suggestion,
  });

  bool get isCanonical =>
      status == RegistryHealthShowcaseNamingStatus.canonical;

  bool get needsAttention => !isCanonical;

  Map<String, dynamic> toJson() => {
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    'providedKey': providedKey,
    if (canonicalKey != null) 'canonicalKey': canonicalKey,
    if (displayName != null) 'displayName': displayName,
    'status': status.name,
    'suggestion': suggestion,
  };
}

class RegistryHealthShowcaseNamingReport {
  final List<RegistryHealthShowcaseNamingRow> rows;

  const RegistryHealthShowcaseNamingReport({required this.rows});

  int get sampleCount => rows.length;
  int get canonicalCount =>
      _count(RegistryHealthShowcaseNamingStatus.canonical);
  int get normalizedCount =>
      _count(RegistryHealthShowcaseNamingStatus.normalized);
  int get aliasCount => _count(RegistryHealthShowcaseNamingStatus.alias);
  int get unknownCount => _count(RegistryHealthShowcaseNamingStatus.unknown);
  int get issueCount => rows.where((row) => row.needsAttention).length;

  bool get isClean => issueCount == 0;

  List<RegistryHealthShowcaseNamingRow> get issueRows =>
      rows.where((row) => row.needsAttention).toList(growable: false);

  Map<String, dynamic> toJson() => {
    'sampleCount': sampleCount,
    'isClean': isClean,
    'issueCount': issueCount,
    'canonicalCount': canonicalCount,
    'normalizedCount': normalizedCount,
    'aliasCount': aliasCount,
    'unknownCount': unknownCount,
    'issues': [for (final row in issueRows) row.toJson()],
    'rows': [for (final row in rows) row.toJson()],
  };

  int _count(RegistryHealthShowcaseNamingStatus status) {
    return rows.where((row) => row.status == status).length;
  }
}

RegistryHealthShowcaseNamingReport registryHealthShowcaseNamingReport(
  Iterable<ChartShowcaseFamily> families, {
  ChartFamilyManifest? manifest,
}) {
  final targetManifest = manifest ?? ChartFamilyManifests.available();
  final rows = <RegistryHealthShowcaseNamingRow>[];
  final familyList = families.toList(growable: false);

  for (var familyIndex = 0; familyIndex < familyList.length; familyIndex++) {
    final family = familyList[familyIndex];
    for (
      var sampleIndex = 0;
      sampleIndex < family.samples.length;
      sampleIndex++
    ) {
      final sample = family.samples[sampleIndex];
      final providedKey = _sampleTypeKey(sample);
      rows.add(
        _namingRowForSample(
          family: family,
          familyIndex: familyIndex,
          sample: sample,
          sampleIndex: sampleIndex,
          providedKey: providedKey,
          manifest: targetManifest,
        ),
      );
    }
  }

  return RegistryHealthShowcaseNamingReport(
    rows: List<RegistryHealthShowcaseNamingRow>.unmodifiable(rows),
  );
}

RegistryHealthShowcaseNamingReport focusedRegistryHealthShowcaseNamingReport({
  ChartFamilyManifest? manifest,
}) {
  return registryHealthShowcaseNamingReport(
    ChartSamplesRegistry.focusedFamilies,
    manifest: manifest,
  );
}

String registryHealthShowcaseNamingStatusLabel(
  RegistryHealthShowcaseNamingStatus status,
) {
  switch (status) {
    case RegistryHealthShowcaseNamingStatus.canonical:
      return 'Canonical';
    case RegistryHealthShowcaseNamingStatus.normalized:
      return 'Normalized';
    case RegistryHealthShowcaseNamingStatus.alias:
      return 'Alias';
    case RegistryHealthShowcaseNamingStatus.unknown:
      return 'Unknown';
  }
}

String registryHealthShowcaseNamingReportLabel(
  RegistryHealthShowcaseNamingReport report,
) {
  if (report.unknownCount > 0) return 'Unknowns';
  if (report.issueCount > 0) return 'Drift';
  return 'Clean';
}

Color registryHealthShowcaseNamingReportColor(
  RegistryHealthShowcaseNamingReport report,
) {
  if (report.unknownCount > 0) return Colors.red.shade700;
  if (report.issueCount > 0) return Colors.orange.shade800;
  return Colors.green.shade700;
}

List<RegistryHealthShowcaseNamingRow> registryHealthShowcaseNamingVisibleRows(
  RegistryHealthShowcaseNamingReport report, {
  int limit = 10,
}) {
  final rows = List<RegistryHealthShowcaseNamingRow>.from(report.issueRows)
    ..sort((a, b) {
      final status = _namingStatusRank(
        a.status,
      ).compareTo(_namingStatusRank(b.status));
      if (status != 0) return status;
      final family = a.familyId.compareTo(b.familyId);
      if (family != 0) return family;
      return a.sampleTitle.compareTo(b.sampleTitle);
    });

  return rows.take(limit).toList(growable: false);
}

class RegistryHealthShowcaseNamingPanel extends StatelessWidget {
  const RegistryHealthShowcaseNamingPanel({
    super.key,
    required this.report,
    this.visibleLimit = 10,
  });

  final RegistryHealthShowcaseNamingReport report;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    final visibleRows = registryHealthShowcaseNamingVisibleRows(
      report,
      limit: visibleLimit,
    );
    final hiddenCount = report.issueRows.length - visibleRows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${report.sampleCount} focused sample type keys checked against manifest naming.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _NamingMetricChip(
              label: 'Status',
              value: registryHealthShowcaseNamingReportLabel(report),
              color: registryHealthShowcaseNamingReportColor(report),
            ),
            _NamingMetricChip(
              label: 'Canonical',
              value: report.canonicalCount.toString(),
              color: Colors.green.shade700,
            ),
            _NamingMetricChip(
              label: 'Normalized',
              value: report.normalizedCount.toString(),
              color: report.normalizedCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _NamingMetricChip(
              label: 'Alias',
              value: report.aliasCount.toString(),
              color: report.aliasCount == 0
                  ? Colors.green.shade700
                  : Colors.blueGrey.shade700,
            ),
            _NamingMetricChip(
              label: 'Unknown',
              value: report.unknownCount.toString(),
              color: report.unknownCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleRows.isEmpty)
          const Text('No showcase type naming drift.')
        else
          _NamingIssueTable(rows: visibleRows),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+$hiddenCount more naming issues',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

RegistryHealthShowcaseNamingRow _namingRowForSample({
  required ChartShowcaseFamily family,
  required int familyIndex,
  required ChartShowcaseSample sample,
  required int sampleIndex,
  required String providedKey,
  required ChartFamilyManifest manifest,
}) {
  final entry = providedKey.isEmpty
      ? null
      : manifest.entryForTypeString(providedKey);
  if (entry == null) {
    return RegistryHealthShowcaseNamingRow(
      familyId: family.id,
      familyTitle: family.title,
      familyIndex: familyIndex,
      sampleTitle: sample.title,
      sampleIndex: sampleIndex,
      providedKey: providedKey,
      canonicalKey: null,
      displayName: null,
      status: RegistryHealthShowcaseNamingStatus.unknown,
      suggestion: 'Add a manifest registration or update the sample type key.',
    );
  }

  final status = _namingStatusFor(providedKey, entry);
  return RegistryHealthShowcaseNamingRow(
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
    sampleTitle: sample.title,
    sampleIndex: sampleIndex,
    providedKey: providedKey,
    canonicalKey: entry.showcaseExampleKey,
    displayName: entry.displayName,
    status: status,
    suggestion: status == RegistryHealthShowcaseNamingStatus.canonical
        ? 'Already uses the manifest canonical key.'
        : 'Use "${entry.showcaseExampleKey}" for manifest-canonical naming.',
  );
}

RegistryHealthShowcaseNamingStatus _namingStatusFor(
  String providedKey,
  ChartFamilyManifestEntry entry,
) {
  if (providedKey == entry.showcaseExampleKey) {
    return RegistryHealthShowcaseNamingStatus.canonical;
  }

  if (entry.aliases.contains(providedKey)) {
    return RegistryHealthShowcaseNamingStatus.alias;
  }

  final normalized = normalizeChartTypeKey(providedKey);
  if (normalizeChartTypeKey(entry.showcaseExampleKey) == normalized) {
    return RegistryHealthShowcaseNamingStatus.normalized;
  }

  if (entry.aliases.any(
    (alias) => normalizeChartTypeKey(alias) == normalized,
  )) {
    return RegistryHealthShowcaseNamingStatus.alias;
  }

  return RegistryHealthShowcaseNamingStatus.normalized;
}

String _sampleTypeKey(ChartShowcaseSample sample) {
  final value = sample.json['type'];
  return value is String ? value.trim() : '';
}

int _namingStatusRank(RegistryHealthShowcaseNamingStatus status) {
  switch (status) {
    case RegistryHealthShowcaseNamingStatus.unknown:
      return 0;
    case RegistryHealthShowcaseNamingStatus.normalized:
      return 1;
    case RegistryHealthShowcaseNamingStatus.alias:
      return 2;
    case RegistryHealthShowcaseNamingStatus.canonical:
      return 3;
  }
}

class _NamingIssueTable extends StatelessWidget {
  const _NamingIssueTable({required this.rows});

  final List<RegistryHealthShowcaseNamingRow> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(label: Text('Sample')),
                DataColumn(label: Text('Provided')),
                DataColumn(label: Text('Canonical')),
                DataColumn(label: Text('Match')),
                DataColumn(label: Text('Suggestion')),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(Text('${row.familyTitle} / ${row.sampleTitle}')),
                      DataCell(
                        Text(row.providedKey.isEmpty ? '-' : row.providedKey),
                      ),
                      DataCell(Text(row.canonicalKey ?? '-')),
                      DataCell(_NamingStatusChip(row.status)),
                      DataCell(Text(row.suggestion)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NamingMetricChip extends StatelessWidget {
  const _NamingMetricChip({
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
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text(value, style: const TextStyle(fontSize: 10)),
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _NamingStatusChip extends StatelessWidget {
  const _NamingStatusChip(this.status);

  final RegistryHealthShowcaseNamingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RegistryHealthShowcaseNamingStatus.canonical => Colors.green.shade700,
      RegistryHealthShowcaseNamingStatus.normalized => Colors.orange.shade800,
      RegistryHealthShowcaseNamingStatus.alias => Colors.blueGrey.shade700,
      RegistryHealthShowcaseNamingStatus.unknown => Colors.red.shade700,
    };

    return Chip(
      label: Text(registryHealthShowcaseNamingStatusLabel(status)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}
