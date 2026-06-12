import 'chart_samples_registry.dart';
import 'registry_health_showcase_source_location.dart';
import 'registry_health_showcase_source_map.dart';

enum RegistryHealthShowcaseSourceMapAuditSeverity { warning, error }

enum RegistryHealthShowcaseSourceMapAuditStatus { ready, warning, broken }

class RegistryHealthShowcaseSourceMapAuditIssue {
  final RegistryHealthShowcaseSourceMapAuditSeverity severity;
  final String code;
  final String message;
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String? sampleTitle;
  final int? sampleIndex;
  final String? chartType;
  final String? sourceChartType;

  const RegistryHealthShowcaseSourceMapAuditIssue({
    required this.severity,
    required this.code,
    required this.message,
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.chartType,
    required this.sourceChartType,
  });

  Map<String, dynamic> toJson() => {
    'severity': severity.name,
    'code': code,
    'message': message,
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    if (sampleTitle != null && sampleTitle!.isNotEmpty)
      'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    if (chartType != null && chartType!.isNotEmpty) 'chartType': chartType,
    if (sourceChartType != null && sourceChartType!.isNotEmpty)
      'sourceChartType': sourceChartType,
  };
}

class RegistryHealthShowcaseSourceMapAuditReport {
  final String sourceFile;
  final int expectedSampleCount;
  final int mappedSampleCount;
  final int exactTypePositionCount;
  final List<RegistryHealthShowcaseSourceMapAuditIssue> issues;

  const RegistryHealthShowcaseSourceMapAuditReport({
    required this.sourceFile,
    required this.expectedSampleCount,
    required this.mappedSampleCount,
    required this.exactTypePositionCount,
    required this.issues,
  });

  int get issueCount => issues.length;

  int get errorCount {
    return issues
        .where(
          (issue) =>
              issue.severity ==
              RegistryHealthShowcaseSourceMapAuditSeverity.error,
        )
        .length;
  }

  int get warningCount {
    return issues
        .where(
          (issue) =>
              issue.severity ==
              RegistryHealthShowcaseSourceMapAuditSeverity.warning,
        )
        .length;
  }

  bool get isReady =>
      status == RegistryHealthShowcaseSourceMapAuditStatus.ready;

  double get mappedRatio {
    if (expectedSampleCount == 0) return 1;
    return mappedSampleCount / expectedSampleCount;
  }

  double get exactTypePositionRatio {
    if (expectedSampleCount == 0) return 1;
    return exactTypePositionCount / expectedSampleCount;
  }

  RegistryHealthShowcaseSourceMapAuditStatus get status {
    if (errorCount > 0) {
      return RegistryHealthShowcaseSourceMapAuditStatus.broken;
    }
    if (warningCount > 0) {
      return RegistryHealthShowcaseSourceMapAuditStatus.warning;
    }
    return RegistryHealthShowcaseSourceMapAuditStatus.ready;
  }

  String get statusLabel {
    switch (status) {
      case RegistryHealthShowcaseSourceMapAuditStatus.ready:
        return 'Ready';
      case RegistryHealthShowcaseSourceMapAuditStatus.warning:
        return 'Warnings';
      case RegistryHealthShowcaseSourceMapAuditStatus.broken:
        return 'Broken';
    }
  }

  List<RegistryHealthShowcaseSourceMapAuditIssue> visibleIssues({
    int limit = 8,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    final sorted = List<RegistryHealthShowcaseSourceMapAuditIssue>.from(issues)
      ..sort((a, b) {
        final severity = _severityRank(
          b.severity,
        ).compareTo(_severityRank(a.severity));
        if (severity != 0) return severity;
        final family = (a.familyIndex ?? -1).compareTo(b.familyIndex ?? -1);
        if (family != 0) return family;
        final sample = (a.sampleIndex ?? -1).compareTo(b.sampleIndex ?? -1);
        if (sample != 0) return sample;
        return a.code.compareTo(b.code);
      });
    return sorted.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int issueLimit = 16}) {
    final safeLimit = issueLimit < 0 ? 0 : issueLimit;
    final exportedIssues = visibleIssues(limit: safeLimit);

    return {
      'sourceFile': sourceFile,
      'status': status.name,
      'statusLabel': statusLabel,
      'isReady': isReady,
      'expectedSampleCount': expectedSampleCount,
      'mappedSampleCount': mappedSampleCount,
      'exactTypePositionCount': exactTypePositionCount,
      'mappedRatio': mappedRatio,
      'exactTypePositionRatio': exactTypePositionRatio,
      'issueCount': issueCount,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'exportedIssueCount': exportedIssues.length,
      'hiddenIssueCount': issues.length - exportedIssues.length,
      'issues': [for (final issue in exportedIssues) issue.toJson()],
    };
  }
}

RegistryHealthShowcaseSourceMapAuditReport
registryHealthShowcaseSourceMapAuditReport(
  RegistryHealthShowcaseSourceMap sourceMap,
  Iterable<ChartShowcaseFamily> families,
) {
  final issues = <RegistryHealthShowcaseSourceMapAuditIssue>[];
  final familyList = families.toList(growable: false);
  final expectedKeys = <String>{};
  var mappedSampleCount = 0;
  var exactTypePositionCount = 0;

  for (var familyIndex = 0; familyIndex < familyList.length; familyIndex++) {
    final family = familyList[familyIndex];
    for (
      var sampleIndex = 0;
      sampleIndex < family.samples.length;
      sampleIndex++
    ) {
      expectedKeys.add(_sourceMapKey(familyIndex, sampleIndex));
      final sample = family.samples[sampleIndex];
      final chartType = _sampleType(sample);
      final entry = sourceMap.entryFor(
        familyId: family.id,
        familyIndex: familyIndex,
        sampleTitle: sample.title,
        sampleIndex: sampleIndex,
      );

      if (entry == null) {
        issues.add(
          _issue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.error,
            code: 'MISSING_SOURCE_ENTRY',
            message: 'No source-map entry was found for this focused sample.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
          ),
        );
        continue;
      }

      mappedSampleCount++;
      if (entry.typeLine != null) exactTypePositionCount++;

      if (entry.familyId != family.id) {
        issues.add(
          _entryIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.error,
            code: 'FAMILY_ID_MISMATCH',
            message:
                'Source-map family id does not match the runtime registry.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
            entry: entry,
          ),
        );
      }
      if (entry.familyTitle != family.title) {
        issues.add(
          _entryIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.warning,
            code: 'FAMILY_TITLE_MISMATCH',
            message:
                'Source-map family title differs from the runtime registry.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
            entry: entry,
          ),
        );
      }
      if (entry.sampleTitle != sample.title) {
        issues.add(
          _entryIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.error,
            code: 'SAMPLE_TITLE_MISMATCH',
            message:
                'Source-map sample title does not match the runtime registry.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
            entry: entry,
          ),
        );
      }
      if (entry.chartType != chartType) {
        issues.add(
          _entryIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.error,
            code: 'CHART_TYPE_MISMATCH',
            message:
                'Source-map chart type does not match the runtime registry.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
            entry: entry,
          ),
        );
      }
      if (entry.typeLine == null) {
        issues.add(
          _entryIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.warning,
            code: 'MISSING_TYPE_POSITION',
            message: 'Source-map entry has no exact line for json.type.',
            family: family,
            familyIndex: familyIndex,
            sample: sample,
            sampleIndex: sampleIndex,
            chartType: chartType,
            entry: entry,
          ),
        );
      }
    }
  }

  for (final entry in sourceMap.entries) {
    final key = _sourceMapKey(entry.familyIndex, entry.sampleIndex);
    if (expectedKeys.contains(key)) continue;
    issues.add(
      RegistryHealthShowcaseSourceMapAuditIssue(
        severity: RegistryHealthShowcaseSourceMapAuditSeverity.warning,
        code: 'ORPHAN_SOURCE_ENTRY',
        message: 'Source-map entry is not present in the runtime registry.',
        familyId: entry.familyId,
        familyTitle: entry.familyTitle,
        familyIndex: entry.familyIndex,
        sampleTitle: entry.sampleTitle,
        sampleIndex: entry.sampleIndex,
        chartType: null,
        sourceChartType: entry.chartType,
      ),
    );
  }

  return RegistryHealthShowcaseSourceMapAuditReport(
    sourceFile: sourceMap.sourceFile,
    expectedSampleCount: familyList.fold<int>(
      0,
      (count, family) => count + family.samples.length,
    ),
    mappedSampleCount: mappedSampleCount,
    exactTypePositionCount: exactTypePositionCount,
    issues: List<RegistryHealthShowcaseSourceMapAuditIssue>.unmodifiable(
      issues,
    ),
  );
}

RegistryHealthShowcaseSourceMapAuditReport
focusedRegistryHealthShowcaseSourceMapAuditReport(
  RegistryHealthShowcaseSourceMap sourceMap,
) {
  return registryHealthShowcaseSourceMapAuditReport(
    sourceMap,
    ChartSamplesRegistry.focusedFamilies,
  );
}

String registryHealthShowcaseSourceMapAuditReportLabel(
  RegistryHealthShowcaseSourceMapAuditReport report,
) {
  return report.statusLabel;
}

List<RegistryHealthShowcaseSourceMapAuditIssue>
registryHealthShowcaseSourceMapAuditVisibleIssues(
  RegistryHealthShowcaseSourceMapAuditReport report, {
  int limit = 8,
}) {
  return report.visibleIssues(limit: limit);
}

Map<String, dynamic> registryHealthShowcaseSourceMapAuditJson(
  RegistryHealthShowcaseSourceMap sourceMap,
  Iterable<ChartShowcaseFamily> families, {
  int issueLimit = 16,
}) {
  return registryHealthShowcaseSourceMapAuditReport(
    sourceMap,
    families,
  ).toJson(issueLimit: issueLimit);
}

Map<String, dynamic> registryHealthShowcaseSourceMapAuditExportJson({
  RegistryHealthShowcaseSourceMapAuditReport? report,
  String sourceFile = registryHealthChartSamplesRegistrySourceFile,
  Object? error,
  bool isLoading = false,
}) {
  if (report != null) return report.toJson();

  if (isLoading) {
    return {
      'sourceFile': sourceFile,
      'status': 'loading',
      'statusLabel': 'Loading',
      'isReady': false,
      'issueCount': 0,
    };
  }

  return {
    'sourceFile': sourceFile,
    'status': 'unavailable',
    'statusLabel': 'Unavailable',
    'isReady': false,
    'issueCount': 1,
    if (error != null) 'error': error.toString(),
  };
}

RegistryHealthShowcaseSourceMapAuditIssue _issue({
  required RegistryHealthShowcaseSourceMapAuditSeverity severity,
  required String code,
  required String message,
  required ChartShowcaseFamily family,
  required int familyIndex,
  required ChartShowcaseSample sample,
  required int sampleIndex,
  required String? chartType,
}) {
  return RegistryHealthShowcaseSourceMapAuditIssue(
    severity: severity,
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
    sampleTitle: sample.title,
    sampleIndex: sampleIndex,
    chartType: chartType,
    sourceChartType: null,
  );
}

RegistryHealthShowcaseSourceMapAuditIssue _entryIssue({
  required RegistryHealthShowcaseSourceMapAuditSeverity severity,
  required String code,
  required String message,
  required ChartShowcaseFamily family,
  required int familyIndex,
  required ChartShowcaseSample sample,
  required int sampleIndex,
  required String? chartType,
  required RegistryHealthShowcaseSourceMapEntry entry,
}) {
  return RegistryHealthShowcaseSourceMapAuditIssue(
    severity: severity,
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
    sampleTitle: sample.title,
    sampleIndex: sampleIndex,
    chartType: chartType,
    sourceChartType: entry.chartType,
  );
}

String? _sampleType(ChartShowcaseSample sample) {
  final type = sample.json['type'];
  return type is String && type.isNotEmpty ? type : null;
}

int _severityRank(RegistryHealthShowcaseSourceMapAuditSeverity severity) {
  switch (severity) {
    case RegistryHealthShowcaseSourceMapAuditSeverity.error:
      return 2;
    case RegistryHealthShowcaseSourceMapAuditSeverity.warning:
      return 1;
  }
}

String _sourceMapKey(int familyIndex, int sampleIndex) {
  return '$familyIndex:$sampleIndex';
}
