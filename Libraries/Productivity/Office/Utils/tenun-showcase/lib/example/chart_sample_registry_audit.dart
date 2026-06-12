import 'package:tenun/tenun.dart';

import 'chart_samples_registry.dart';

enum ChartSampleRegistryAuditSeverity { error, warning, info }

class ChartSampleRegistryAuditIssue {
  final ChartSampleRegistryAuditSeverity severity;
  final String code;
  final String message;
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final int? sampleIndex;
  final String? sampleTitle;
  final String? chartType;
  final String? field;
  final String? suggestion;

  const ChartSampleRegistryAuditIssue({
    required this.severity,
    required this.code,
    required this.message,
    required this.familyId,
    required this.familyTitle,
    this.familyIndex,
    this.sampleIndex,
    this.sampleTitle,
    this.chartType,
    this.field,
    this.suggestion,
  });

  bool get isError => severity == ChartSampleRegistryAuditSeverity.error;

  bool get isWarning => severity == ChartSampleRegistryAuditSeverity.warning;

  Map<String, dynamic> toJson() => {
    'severity': severity.name,
    'code': code,
    'message': message,
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    if (sampleTitle != null) 'sampleTitle': sampleTitle,
    if (chartType != null) 'chartType': chartType,
    if (field != null) 'field': field,
    if (suggestion != null) 'suggestion': suggestion,
  };
}

class ChartSampleRegistryAuditReport {
  final List<ChartShowcaseFamily> families;
  final List<ChartSampleRegistryAuditIssue> issues;

  const ChartSampleRegistryAuditReport({
    required this.families,
    required this.issues,
  });

  int get familyCount => families.length;

  int get sampleCount =>
      families.fold<int>(0, (count, family) => count + family.samples.length);

  List<ChartSampleRegistryAuditIssue> get errors =>
      issues.where((issue) => issue.isError).toList(growable: false);

  List<ChartSampleRegistryAuditIssue> get warnings =>
      issues.where((issue) => issue.isWarning).toList(growable: false);

  bool get isValid => errors.isEmpty;

  List<String> get errorCodes =>
      errors.map((issue) => issue.code).toList(growable: false);

  List<String> get warningCodes =>
      warnings.map((issue) => issue.code).toList(growable: false);

  Map<String, dynamic> toJson() => {
    'familyCount': familyCount,
    'sampleCount': sampleCount,
    'isValid': isValid,
    'issueCount': issues.length,
    'errorCount': errors.length,
    'warningCount': warnings.length,
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

ChartSampleRegistryAuditReport auditChartSampleFamilies(
  Iterable<ChartShowcaseFamily> families, {
  ChartFamilyManifest? manifest,
  bool requireRegisteredTypes = false,
  bool deepPayloadValidation = false,
  bool includeValidationWarnings = true,
}) {
  final familyList = families.toList(growable: false);
  final targetManifest = manifest ?? ChartFamilyManifests.available();
  final issues = <ChartSampleRegistryAuditIssue>[];
  final familyIds = <String, ChartShowcaseFamily>{};
  final familyTitles = <String, ChartShowcaseFamily>{};

  for (int familyIndex = 0; familyIndex < familyList.length; familyIndex++) {
    final family = familyList[familyIndex];
    _auditFamilyIdentity(family, familyIndex, familyIds, familyTitles, issues);
    _auditFamilySamples(
      family,
      familyIndex,
      targetManifest,
      requireRegisteredTypes,
      deepPayloadValidation,
      includeValidationWarnings,
      issues,
    );
  }

  return ChartSampleRegistryAuditReport(families: familyList, issues: issues);
}

ChartSampleRegistryAuditReport auditFocusedChartSamples({
  ChartFamilyManifest? manifest,
  bool requireRegisteredTypes = false,
  bool deepPayloadValidation = false,
  bool includeValidationWarnings = true,
}) {
  return auditChartSampleFamilies(
    ChartSamplesRegistry.focusedFamilies,
    manifest: manifest,
    requireRegisteredTypes: requireRegisteredTypes,
    deepPayloadValidation: deepPayloadValidation,
    includeValidationWarnings: includeValidationWarnings,
  );
}

void _auditFamilyIdentity(
  ChartShowcaseFamily family,
  int familyIndex,
  Map<String, ChartShowcaseFamily> familyIds,
  Map<String, ChartShowcaseFamily> familyTitles,
  List<ChartSampleRegistryAuditIssue> issues,
) {
  final id = family.id.trim();
  final title = family.title.trim();

  if (id.isEmpty) {
    issues.add(
      _familyIssue(
        family,
        familyIndex,
        code: 'EMPTY_FAMILY_ID',
        message: 'Family id must not be empty.',
      ),
    );
  } else {
    final normalizedId = _normalizedAuditKey(id);
    if (familyIds.containsKey(normalizedId)) {
      issues.add(
        _familyIssue(
          family,
          familyIndex,
          code: 'DUPLICATE_FAMILY_ID',
          message: 'Family id "$id" is already used.',
        ),
      );
    } else {
      familyIds[normalizedId] = family;
    }
  }

  if (title.isEmpty) {
    issues.add(
      _familyIssue(
        family,
        familyIndex,
        code: 'EMPTY_FAMILY_TITLE',
        message: 'Family title must not be empty.',
      ),
    );
  } else {
    final normalizedTitle = _normalizedAuditKey(title);
    if (familyTitles.containsKey(normalizedTitle)) {
      issues.add(
        _familyIssue(
          family,
          familyIndex,
          code: 'DUPLICATE_FAMILY_TITLE',
          message: 'Family title "$title" is already used.',
        ),
      );
    } else {
      familyTitles[normalizedTitle] = family;
    }
  }

  if (family.description.trim().isEmpty) {
    issues.add(
      _familyIssue(
        family,
        familyIndex,
        code: 'EMPTY_FAMILY_DESCRIPTION',
        message: 'Family description must not be empty.',
      ),
    );
  }

  if (family.samples.isEmpty) {
    issues.add(
      _familyIssue(
        family,
        familyIndex,
        code: 'EMPTY_FAMILY_SAMPLES',
        message: 'Family must contain at least one sample.',
      ),
    );
  }
}

void _auditFamilySamples(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartFamilyManifest manifest,
  bool requireRegisteredTypes,
  bool deepPayloadValidation,
  bool includeValidationWarnings,
  List<ChartSampleRegistryAuditIssue> issues,
) {
  final sampleTitles = <String>{};

  for (
    int sampleIndex = 0;
    sampleIndex < family.samples.length;
    sampleIndex++
  ) {
    final sample = family.samples[sampleIndex];
    final sampleTitle = sample.title.trim();
    final chartType = _chartTypeString(sample.json);

    if (sampleTitle.isEmpty) {
      issues.add(
        _sampleIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          chartType,
          code: 'EMPTY_SAMPLE_TITLE',
          message: 'Sample title must not be empty.',
        ),
      );
    } else {
      final normalizedTitle = _normalizedAuditKey(sampleTitle);
      if (!sampleTitles.add(normalizedTitle)) {
        issues.add(
          _sampleIssue(
            family,
            familyIndex,
            sample,
            sampleIndex,
            chartType,
            code: 'DUPLICATE_SAMPLE_TITLE',
            message: 'Sample title "$sampleTitle" is repeated in this family.',
          ),
        );
      }
    }

    if (sample.height <= 0 || !sample.height.isFinite) {
      issues.add(
        _sampleIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          chartType,
          code: 'INVALID_SAMPLE_HEIGHT',
          message: 'Sample height must be a finite value greater than zero.',
          field: 'height',
        ),
      );
    }

    final rawType = sample.json['type'];
    if (rawType != null && rawType is! String) {
      issues.add(
        _sampleIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          chartType,
          code: 'INVALID_TYPE_FIELD',
          message: 'Sample JSON "type" must be a string.',
          field: 'type',
        ),
      );
    }

    final manifestEntry = chartType == null
        ? null
        : manifest.entryForTypeString(chartType);

    if (chartType != null && manifestEntry == null) {
      issues.add(
        _sampleIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          chartType,
          code: 'UNSUPPORTED_TYPE',
          message: 'Chart type "$chartType" is not listed in the manifest.',
          field: 'type',
          suggestion:
              'Add the chart to the manifest or update the sample type.',
        ),
      );
    }

    final validation = ChartConfigValidator.validateJsonPayload(
      sample.json,
      deep: deepPayloadValidation,
      requireRegisteredType: requireRegisteredTypes,
    );
    for (final validationIssue in validation.issues) {
      if (_shouldSkipValidationIssue(
        validationIssue,
        manifestEntry,
        chartType,
      )) {
        continue;
      }
      if (validationIssue.severity == ValidationSeverity.info) continue;
      if (!includeValidationWarnings && validationIssue.isWarning) continue;

      issues.add(
        _sampleIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          chartType,
          severity: _auditSeverityFor(validationIssue.severity),
          code: validationIssue.code,
          message: validationIssue.message,
          field: validationIssue.field,
          suggestion: validationIssue.suggestion,
        ),
      );
    }
  }
}

bool _shouldSkipValidationIssue(
  ValidationIssue validationIssue,
  ChartFamilyManifestEntry? manifestEntry,
  String? chartType,
) {
  final isSeriesIssue =
      validationIssue.code == 'MISSING_SERIES' ||
      validationIssue.code == 'EMPTY_SERIES';
  if (!isSeriesIssue) return false;

  if (manifestEntry != null && !manifestEntry.requiresSeries) return true;
  return _isKnownOptionalSeriesType(chartType);
}

bool _isKnownOptionalSeriesType(String? chartType) {
  if (chartType == null) return false;
  return const {
    'gauge',
    'barrace',
    'indicator',
    'halfdonut',
  }.contains(normalizeChartTypeKey(chartType));
}

ChartSampleRegistryAuditIssue _familyIssue(
  ChartShowcaseFamily family,
  int familyIndex, {
  required String code,
  required String message,
}) {
  return ChartSampleRegistryAuditIssue(
    severity: ChartSampleRegistryAuditSeverity.error,
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
  );
}

ChartSampleRegistryAuditIssue _sampleIssue(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  String? chartType, {
  ChartSampleRegistryAuditSeverity severity =
      ChartSampleRegistryAuditSeverity.error,
  required String code,
  required String message,
  String? field,
  String? suggestion,
}) {
  return ChartSampleRegistryAuditIssue(
    severity: severity,
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
    sampleIndex: sampleIndex,
    sampleTitle: sample.title,
    chartType: chartType,
    field: field,
    suggestion: suggestion,
  );
}

ChartSampleRegistryAuditSeverity _auditSeverityFor(
  ValidationSeverity severity,
) {
  switch (severity) {
    case ValidationSeverity.error:
      return ChartSampleRegistryAuditSeverity.error;
    case ValidationSeverity.warning:
      return ChartSampleRegistryAuditSeverity.warning;
    case ValidationSeverity.info:
      return ChartSampleRegistryAuditSeverity.info;
  }
}

String? _chartTypeString(Map<String, dynamic> json) {
  final rawType = json['type'];
  if (rawType is! String) return null;

  final trimmed = rawType.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _normalizedAuditKey(String value) {
  return normalizeChartTypeKey(value);
}
