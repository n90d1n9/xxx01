import 'dart:convert';

import 'chart_sample_source_helpers.dart';
import 'chart_samples_registry.dart';

class ChartSampleSourceAuditCase {
  const ChartSampleSourceAuditCase({
    required this.id,
    required this.label,
    required this.options,
  });

  final String id;
  final String label;
  final ChartSampleShowcaseOptions options;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'showLegend': options.showLegend,
    'showTooltip': options.showTooltip,
  };
}

class ChartSampleSourceAuditIssue {
  const ChartSampleSourceAuditIssue({
    required this.code,
    required this.message,
    required this.familyId,
    required this.familyTitle,
    required this.caseId,
    required this.caseLabel,
    this.familyIndex,
    this.sampleIndex,
    this.sampleTitle,
    this.chartType,
    this.suggestion,
  });

  final String code;
  final String message;
  final String familyId;
  final String familyTitle;
  final String caseId;
  final String caseLabel;
  final int? familyIndex;
  final int? sampleIndex;
  final String? sampleTitle;
  final String? chartType;
  final String? suggestion;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'familyId': familyId,
    'familyTitle': familyTitle,
    'caseId': caseId,
    'caseLabel': caseLabel,
    if (familyIndex != null) 'familyIndex': familyIndex,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    if (sampleTitle != null) 'sampleTitle': sampleTitle,
    if (chartType != null) 'chartType': chartType,
    if (suggestion != null) 'suggestion': suggestion,
  };
}

class ChartSampleSourceAuditFamilyResult {
  const ChartSampleSourceAuditFamilyResult({
    required this.id,
    required this.title,
    required this.sampleCount,
    required this.checkedSourceCount,
    required this.issueCount,
  });

  final String id;
  final String title;
  final int sampleCount;
  final int checkedSourceCount;
  final int issueCount;

  bool get isValid => issueCount == 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sampleCount': sampleCount,
    'checkedSourceCount': checkedSourceCount,
    'issueCount': issueCount,
    'isValid': isValid,
  };
}

class ChartSampleSourceAuditCaseResult {
  const ChartSampleSourceAuditCaseResult({
    required this.id,
    required this.label,
    required this.checkedSourceCount,
    required this.issueCount,
  });

  final String id;
  final String label;
  final int checkedSourceCount;
  final int issueCount;

  bool get isValid => issueCount == 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'checkedSourceCount': checkedSourceCount,
    'issueCount': issueCount,
    'isValid': isValid,
  };
}

class ChartSampleSourceAuditReport {
  const ChartSampleSourceAuditReport({
    required this.families,
    required this.cases,
    required this.issues,
    this.familyResults = const [],
    this.caseResults = const [],
  });

  final List<ChartShowcaseFamily> families;
  final List<ChartSampleSourceAuditCase> cases;
  final List<ChartSampleSourceAuditIssue> issues;
  final List<ChartSampleSourceAuditFamilyResult> familyResults;
  final List<ChartSampleSourceAuditCaseResult> caseResults;

  int get familyCount => families.length;

  int get sampleCount =>
      families.fold<int>(0, (count, family) => count + family.samples.length);

  int get caseCount => cases.length;

  int get checkedSourceCount => sampleCount * caseCount;

  bool get isValid => issues.isEmpty;

  List<String> get issueCodes =>
      issues.map((issue) => issue.code).toList(growable: false);

  Map<String, int> get issueCodeCounts {
    final counts = <String, int>{};
    for (final issue in issues) {
      counts.update(issue.code, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedEntries = counts.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    return Map<String, int>.unmodifiable({
      for (final entry in sortedEntries) entry.key: entry.value,
    });
  }

  Map<String, dynamic> toJson() => {
    'familyCount': familyCount,
    'sampleCount': sampleCount,
    'caseCount': caseCount,
    'checkedSourceCount': checkedSourceCount,
    'isValid': isValid,
    'issueCount': issues.length,
    'issueCodeCounts': issueCodeCounts,
    'cases': cases
        .map((auditCase) => auditCase.toJson())
        .toList(growable: false),
    'caseResults': caseResults
        .map((auditCase) => auditCase.toJson())
        .toList(growable: false),
    'familyResults': familyResults
        .map((family) => family.toJson())
        .toList(growable: false),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

const chartSampleSourceAuditDefaultCases = [
  ChartSampleSourceAuditCase(
    id: 'default',
    label: 'Default',
    options: ChartSampleShowcaseOptions(),
  ),
  ChartSampleSourceAuditCase(
    id: 'legend_off',
    label: 'Legend off',
    options: ChartSampleShowcaseOptions(showLegend: false),
  ),
  ChartSampleSourceAuditCase(
    id: 'tooltip_off',
    label: 'Tooltip off',
    options: ChartSampleShowcaseOptions(showTooltip: false),
  ),
  ChartSampleSourceAuditCase(
    id: 'legend_tooltip_off',
    label: 'Legend and tooltip off',
    options: ChartSampleShowcaseOptions(showLegend: false, showTooltip: false),
  ),
];

class _ChartSampleSourceAuditFamilyCounter {
  _ChartSampleSourceAuditFamilyCounter(this.family);

  final ChartShowcaseFamily family;
  var checkedSourceCount = 0;
  var issueCount = 0;

  ChartSampleSourceAuditFamilyResult toResult() {
    return ChartSampleSourceAuditFamilyResult(
      id: family.id,
      title: family.title,
      sampleCount: family.samples.length,
      checkedSourceCount: checkedSourceCount,
      issueCount: issueCount,
    );
  }
}

class _ChartSampleSourceAuditCaseCounter {
  _ChartSampleSourceAuditCaseCounter(this.auditCase);

  final ChartSampleSourceAuditCase auditCase;
  var checkedSourceCount = 0;
  var issueCount = 0;

  ChartSampleSourceAuditCaseResult toResult() {
    return ChartSampleSourceAuditCaseResult(
      id: auditCase.id,
      label: auditCase.label,
      checkedSourceCount: checkedSourceCount,
      issueCount: issueCount,
    );
  }
}

ChartSampleSourceAuditReport auditFocusedChartSampleSources({
  List<ChartSampleSourceAuditCase> cases = chartSampleSourceAuditDefaultCases,
}) {
  return auditChartSampleSources(
    ChartSamplesRegistry.focusedFamilies,
    cases: cases,
  );
}

ChartSampleSourceAuditReport auditChartSampleSources(
  Iterable<ChartShowcaseFamily> families, {
  List<ChartSampleSourceAuditCase> cases = chartSampleSourceAuditDefaultCases,
}) {
  final familyList = families.toList(growable: false);
  final caseList = cases.toList(growable: false);
  final issues = <ChartSampleSourceAuditIssue>[];
  final familyCounters = [
    for (final family in familyList)
      _ChartSampleSourceAuditFamilyCounter(family),
  ];
  final caseCounters = [
    for (final auditCase in caseList)
      _ChartSampleSourceAuditCaseCounter(auditCase),
  ];
  _auditSourceAuditCaseMetadata(caseList, caseCounters, issues);

  for (var familyIndex = 0; familyIndex < familyList.length; familyIndex++) {
    final family = familyList[familyIndex];
    final familyCounter = familyCounters[familyIndex];
    for (
      var sampleIndex = 0;
      sampleIndex < family.samples.length;
      sampleIndex++
    ) {
      final sample = family.samples[sampleIndex];
      for (var caseIndex = 0; caseIndex < caseList.length; caseIndex++) {
        final auditCase = caseList[caseIndex];
        final caseCounter = caseCounters[caseIndex];
        final issueStart = issues.length;
        familyCounter.checkedSourceCount++;
        caseCounter.checkedSourceCount++;
        _auditSampleSource(
          family,
          familyIndex,
          sample,
          sampleIndex,
          auditCase,
          issues,
        );
        final issueDelta = issues.length - issueStart;
        familyCounter.issueCount += issueDelta;
        caseCounter.issueCount += issueDelta;
      }
    }
  }

  return ChartSampleSourceAuditReport(
    families: familyList,
    cases: caseList,
    issues: issues,
    familyResults: familyCounters
        .map((counter) => counter.toResult())
        .toList(growable: false),
    caseResults: caseCounters
        .map((counter) => counter.toResult())
        .toList(growable: false),
  );
}

void _auditSourceAuditCaseMetadata(
  List<ChartSampleSourceAuditCase> cases,
  List<_ChartSampleSourceAuditCaseCounter> caseCounters,
  List<ChartSampleSourceAuditIssue> issues,
) {
  final seenIds = <String>{};
  for (var index = 0; index < cases.length; index++) {
    final auditCase = cases[index];
    final caseCounter = caseCounters[index];
    final caseId = auditCase.id.trim();
    final caseLabel = auditCase.label.trim();
    final issueStart = issues.length;

    if (caseId.isEmpty) {
      issues.add(
        ChartSampleSourceAuditIssue(
          code: 'CASE_ID_EMPTY',
          message: 'Sample source audit case id must not be empty.',
          familyId: 'sample_source_audit',
          familyTitle: 'Sample Source Audit',
          caseId: auditCase.id,
          caseLabel: auditCase.label,
          sampleIndex: index,
          suggestion:
              'Use a stable non-empty case id for source audit coverage rows.',
        ),
      );
    } else {
      final normalizedId = _normalizedSourceAuditKey(caseId);
      if (!seenIds.add(normalizedId)) {
        issues.add(
          ChartSampleSourceAuditIssue(
            code: 'DUPLICATE_CASE_ID',
            message:
                'Sample source audit case id "${auditCase.id}" is duplicated.',
            familyId: 'sample_source_audit',
            familyTitle: 'Sample Source Audit',
            caseId: auditCase.id,
            caseLabel: auditCase.label,
            sampleIndex: index,
            suggestion:
                'Use unique case ids so source audit case rows stay unambiguous.',
          ),
        );
      }
    }

    if (caseLabel.isEmpty) {
      issues.add(
        ChartSampleSourceAuditIssue(
          code: 'CASE_LABEL_EMPTY',
          message: 'Sample source audit case label must not be empty.',
          familyId: 'sample_source_audit',
          familyTitle: 'Sample Source Audit',
          caseId: auditCase.id,
          caseLabel: auditCase.label,
          sampleIndex: index,
          suggestion:
              'Use a readable case label for Registry Health coverage chips.',
        ),
      );
    }
    caseCounter.issueCount += issues.length - issueStart;
  }
}

void _auditSampleSource(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  ChartSampleSourceAuditCase auditCase,
  List<ChartSampleSourceAuditIssue> issues,
) {
  final chartType = _chartTypeString(sample.json);
  late final String originalJsonText;
  try {
    originalJsonText = jsonEncode(sample.json);
  } catch (_) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SAMPLE_JSON_NOT_ENCODABLE',
        message: 'Sample JSON must be encodable before source generation.',
        suggestion: 'Keep sample payload values JSON-compatible.',
      ),
    );
    return;
  }

  late final Map<String, dynamic> adjusted;
  try {
    adjusted = chartSampleJsonWithOptions(sample.json, auditCase.options);
  } catch (_) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SOURCE_OPTIONS_FAILED',
        message: 'Sample source options could not be applied.',
      ),
    );
    return;
  }

  final adjustedType = adjusted['type'];
  if (adjustedType != sample.json['type']) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SOURCE_TYPE_MUTATED',
        message: 'Sample source options changed the chart type.',
      ),
    );
  }

  _auditOverlayShowValue(
    family,
    familyIndex,
    sample,
    sampleIndex,
    auditCase,
    chartType,
    adjusted,
    'legend',
    auditCase.options.showLegend,
    issues,
  );
  _auditOverlayShowValue(
    family,
    familyIndex,
    sample,
    sampleIndex,
    auditCase,
    chartType,
    adjusted,
    'tooltip',
    auditCase.options.showTooltip,
    issues,
  );

  late final String jsonText;
  try {
    jsonText = chartSampleJsonText(adjusted);
    final decoded = jsonDecode(jsonText);
    if (jsonEncode(decoded) != jsonEncode(adjusted)) {
      issues.add(
        _sourceIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          auditCase,
          chartType,
          code: 'SOURCE_JSON_ROUND_TRIP_MISMATCH',
          message:
              'Generated sample JSON does not decode to the source payload.',
        ),
      );
    }
  } catch (_) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SOURCE_JSON_INVALID',
        message: 'Generated sample JSON text is not valid JSON.',
      ),
    );
    return;
  }

  if (!jsonText.contains('"type":')) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SOURCE_JSON_MISSING_TYPE_TEXT',
        message: 'Generated sample JSON text does not show the chart type.',
      ),
    );
  }

  if (jsonText.contains('Instance of')) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SOURCE_JSON_INSTANCE_TEXT',
        message: 'Generated sample JSON contains Dart object instance text.',
      ),
    );
  }

  final customCode = sample.code;
  if (customCode == null) {
    _auditGeneratedCode(
      family,
      familyIndex,
      sample,
      sampleIndex,
      auditCase,
      chartType,
      adjusted,
      issues,
    );
  } else {
    _auditCustomCode(
      family,
      familyIndex,
      sample,
      sampleIndex,
      auditCase,
      chartType,
      customCode,
      issues,
    );
  }

  try {
    if (jsonEncode(sample.json) != originalJsonText) {
      issues.add(
        _sourceIssue(
          family,
          familyIndex,
          sample,
          sampleIndex,
          auditCase,
          chartType,
          code: 'SOURCE_MUTATED_SAMPLE_JSON',
          message: 'Source generation mutated the registry sample JSON.',
        ),
      );
    }
  } catch (_) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'SAMPLE_JSON_MUTATED_TO_UNENCODABLE',
        message: 'Source generation left registry sample JSON unencodable.',
      ),
    );
  }
}

void _auditOverlayShowValue(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  ChartSampleSourceAuditCase auditCase,
  String? chartType,
  Map<String, dynamic> adjusted,
  String overlayKey,
  bool expected,
  List<ChartSampleSourceAuditIssue> issues,
) {
  final overlay = adjusted[overlayKey];
  final show = overlay is Map ? overlay['show'] : null;
  if (show == expected) return;

  issues.add(
    _sourceIssue(
      family,
      familyIndex,
      sample,
      sampleIndex,
      auditCase,
      chartType,
      code: 'SOURCE_OVERLAY_OPTION_MISMATCH',
      message: 'Generated source did not apply $overlayKey.show=$expected.',
    ),
  );
}

void _auditGeneratedCode(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  ChartSampleSourceAuditCase auditCase,
  String? chartType,
  Map<String, dynamic> adjusted,
  List<ChartSampleSourceAuditIssue> issues,
) {
  final codeText = chartSampleCodeText(adjusted);
  final requiredSnippets = [
    'TenunChartFromJson(',
    'jsonConfig: const <String, dynamic>{',
    'padding: const EdgeInsets.all(8)',
  ];

  for (final snippet in requiredSnippets) {
    if (codeText.contains(snippet)) continue;
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'GENERATED_CODE_MISSING_SNIPPET',
        message: 'Generated Dart code is missing "$snippet".',
      ),
    );
  }
}

void _auditCustomCode(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  ChartSampleSourceAuditCase auditCase,
  String? chartType,
  String customCode,
  List<ChartSampleSourceAuditIssue> issues,
) {
  if (customCode.trim().isEmpty) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'EMPTY_CUSTOM_CODE',
        message: 'Custom sample code must not be empty.',
      ),
    );
  }

  if (customCode.contains('Instance of')) {
    issues.add(
      _sourceIssue(
        family,
        familyIndex,
        sample,
        sampleIndex,
        auditCase,
        chartType,
        code: 'CUSTOM_CODE_INSTANCE_TEXT',
        message: 'Custom sample code contains Dart object instance text.',
      ),
    );
  }
}

ChartSampleSourceAuditIssue _sourceIssue(
  ChartShowcaseFamily family,
  int familyIndex,
  ChartShowcaseSample sample,
  int sampleIndex,
  ChartSampleSourceAuditCase auditCase,
  String? chartType, {
  required String code,
  required String message,
  String? suggestion,
}) {
  return ChartSampleSourceAuditIssue(
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    familyIndex: familyIndex,
    sampleIndex: sampleIndex,
    sampleTitle: sample.title,
    chartType: chartType,
    caseId: auditCase.id,
    caseLabel: auditCase.label,
    suggestion: suggestion,
  );
}

String? _chartTypeString(Map<String, dynamic> json) {
  final type = json['type'];
  if (type is! String) return null;

  final trimmed = type.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _normalizedSourceAuditKey(String value) => value.trim().toLowerCase();
