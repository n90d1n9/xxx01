import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_families.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';
import 'simple_charts_showcase_widgets.dart';

typedef SimpleChartSourcePanelBuilder =
    List<Widget> Function(SimpleChartsGalleryOptions options);

class SimpleChartSourceAuditFamilySpec {
  const SimpleChartSourceAuditFamilySpec({
    required this.id,
    required this.title,
    required this.buildPanels,
    this.tier = SimpleChartsShowcaseTier.custom,
  });

  factory SimpleChartSourceAuditFamilySpec.fromShowcaseFamily(
    SimpleChartsShowcaseFamilySpec family,
  ) {
    return SimpleChartSourceAuditFamilySpec(
      id: family.id,
      title: family.auditTitle,
      tier: family.tier,
      buildPanels: family.buildPanels,
    );
  }

  final String id;
  final String title;
  final SimpleChartsShowcaseTier tier;
  final SimpleChartSourcePanelBuilder buildPanels;
}

class SimpleChartSourceAuditCase {
  const SimpleChartSourceAuditCase({
    required this.id,
    required this.label,
    required this.options,
    this.expectSources = true,
  });

  final String id;
  final String label;
  final SimpleChartsGalleryOptions options;
  final bool expectSources;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'expectSources': expectSources,
    'barStyle': options.barStyle.name,
    'trendStyle': options.trendStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showTracks': options.showTracks,
    'showTooltips': options.showTooltips,
    'showLegends': options.showLegends,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    'showActiveBars': options.showActiveBars,
    'stackAsPercent': options.stackAsPercent,
    'showSampleJson': options.showSampleJson,
    'showSampleCode': options.showSampleCode,
  };
}

class SimpleChartSourceAuditFamilyResult {
  const SimpleChartSourceAuditFamilyResult({
    required this.id,
    required this.title,
    required this.panelCount,
    required this.sourceCount,
    this.tier = SimpleChartsShowcaseTier.custom,
    this.expectedSourceCount,
    this.unexpectedSourceCount = 0,
    this.chartTypes = const [],
  });

  final String id;
  final String title;
  final SimpleChartsShowcaseTier tier;
  final int panelCount;
  final int sourceCount;
  final int? expectedSourceCount;
  final int unexpectedSourceCount;
  final List<String> chartTypes;

  int get requiredSourceCount => expectedSourceCount ?? panelCount;

  int get missingSourceCount => requiredSourceCount - sourceCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tier': tier.name,
    'panelCount': panelCount,
    'sourceCount': sourceCount,
    'requiredSourceCount': requiredSourceCount,
    'missingSourceCount': missingSourceCount,
    'unexpectedSourceCount': unexpectedSourceCount,
    'chartTypes': chartTypes,
  };
}

class SimpleChartSourceAuditCaseResult {
  const SimpleChartSourceAuditCaseResult({
    required this.id,
    required this.label,
    required this.panelCount,
    required this.sourceCount,
    required this.requiredSourceCount,
    this.unexpectedSourceCount = 0,
  });

  final String id;
  final String label;
  final int panelCount;
  final int sourceCount;
  final int requiredSourceCount;
  final int unexpectedSourceCount;

  int get missingSourceCount => requiredSourceCount - sourceCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'panelCount': panelCount,
    'sourceCount': sourceCount,
    'requiredSourceCount': requiredSourceCount,
    'missingSourceCount': missingSourceCount,
    'unexpectedSourceCount': unexpectedSourceCount,
  };
}

class SimpleChartSourceAuditIssue {
  const SimpleChartSourceAuditIssue({
    required this.code,
    required this.message,
    required this.familyId,
    required this.familyTitle,
    this.caseId,
    this.caseLabel,
    this.panelIndex,
    this.panelTitle,
    this.chartType,
    this.suggestion,
  });

  final String code;
  final String message;
  final String familyId;
  final String familyTitle;
  final String? caseId;
  final String? caseLabel;
  final int? panelIndex;
  final String? panelTitle;
  final String? chartType;
  final String? suggestion;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (caseId != null) 'caseId': caseId,
    if (caseLabel != null) 'caseLabel': caseLabel,
    if (panelIndex != null) 'panelIndex': panelIndex,
    if (panelTitle != null) 'panelTitle': panelTitle,
    if (chartType != null) 'chartType': chartType,
    if (suggestion != null) 'suggestion': suggestion,
  };
}

class SimpleChartSourceAuditReport {
  const SimpleChartSourceAuditReport({
    required this.families,
    required this.issues,
    this.cases = const [],
    this.caseResults = const [],
  });

  final List<SimpleChartSourceAuditFamilyResult> families;
  final List<SimpleChartSourceAuditIssue> issues;
  final List<SimpleChartSourceAuditCase> cases;
  final List<SimpleChartSourceAuditCaseResult> caseResults;

  int get familyCount => families.length;

  int get caseCount => cases.length;

  int get panelCount =>
      families.fold<int>(0, (count, family) => count + family.panelCount);

  int get sourceCount =>
      families.fold<int>(0, (count, family) => count + family.sourceCount);

  int get requiredSourceCount => families.fold<int>(
    0,
    (count, family) => count + family.requiredSourceCount,
  );

  int get panelCheckCount => panelCount * caseCount;

  int get missingSourceCount => families.fold<int>(
    0,
    (count, family) => count + family.missingSourceCount,
  );

  int get unexpectedSourceCount => families.fold<int>(
    0,
    (count, family) => count + family.unexpectedSourceCount,
  );

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

  List<String> get chartTypes {
    final values = <String>{};
    for (final family in families) {
      values.addAll(family.chartTypes);
    }
    final sorted = values.toList(growable: false)..sort();
    return sorted;
  }

  Map<String, int> get familyTierCounts {
    final counts = <String, int>{};
    for (final family in families) {
      counts.update(family.tier.name, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedEntries = counts.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    return Map<String, int>.unmodifiable({
      for (final entry in sortedEntries) entry.key: entry.value,
    });
  }

  Map<String, dynamic> toJson() => {
    'familyCount': familyCount,
    'caseCount': caseCount,
    'panelCount': panelCount,
    'panelCheckCount': panelCheckCount,
    'sourceCount': sourceCount,
    'requiredSourceCount': requiredSourceCount,
    'missingSourceCount': missingSourceCount,
    'unexpectedSourceCount': unexpectedSourceCount,
    'isValid': isValid,
    'issueCount': issues.length,
    'issueCodeCounts': issueCodeCounts,
    'familyTierCounts': familyTierCounts,
    'chartTypes': chartTypes,
    'cases': cases
        .map((auditCase) => auditCase.toJson())
        .toList(growable: false),
    'caseResults': caseResults
        .map((auditCase) => auditCase.toJson())
        .toList(growable: false),
    'families': families
        .map((family) => family.toJson())
        .toList(growable: false),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

final simpleChartSourceAuditDefaultFamilies =
    List<SimpleChartSourceAuditFamilySpec>.unmodifiable(
      simpleChartsShowcaseFamilies.map(
        (family) => SimpleChartSourceAuditFamilySpec.fromShowcaseFamily(family),
      ),
    );

SimpleChartsGalleryOptions simpleChartSourceAuditOptions({
  double panelWidth = 520,
  SimpleBarChartStyle barStyle = SimpleBarChartStyle.elegant,
  SimpleTrendChartStyle trendStyle = SimpleTrendChartStyle.modern,
  bool showGrid = true,
  bool showValues = true,
  bool showTracks = true,
  bool showTooltips = true,
  bool showLegends = true,
  bool showReferenceLines = true,
  bool showReferenceBands = true,
  bool showActiveBars = true,
  bool stackAsPercent = false,
  bool showSampleJson = true,
  bool showSampleCode = true,
}) {
  return SimpleChartsGalleryOptions(
    panelWidth: panelWidth,
    barStyle: barStyle,
    trendStyle: trendStyle,
    showGrid: showGrid,
    showValues: showValues,
    showTracks: showTracks,
    showTooltips: showTooltips,
    showLegends: showLegends,
    showReferenceLines: showReferenceLines,
    showReferenceBands: showReferenceBands,
    showActiveBars: showActiveBars,
    stackAsPercent: stackAsPercent,
    showSampleJson: showSampleJson,
    showSampleCode: showSampleCode,
  );
}

final simpleChartSourceAuditDefaultCases =
    List<SimpleChartSourceAuditCase>.unmodifiable([
      SimpleChartSourceAuditCase(
        id: 'default',
        label: 'Default',
        options: simpleChartSourceAuditOptions(),
      ),
      SimpleChartSourceAuditCase(
        id: 'minimal',
        label: 'Minimal chrome',
        options: simpleChartSourceAuditOptions(
          showGrid: false,
          showValues: false,
          showTracks: false,
          showTooltips: false,
          showLegends: false,
          showReferenceLines: false,
          showReferenceBands: false,
          showActiveBars: false,
          stackAsPercent: true,
        ),
      ),
      SimpleChartSourceAuditCase(
        id: 'json_only',
        label: 'JSON only',
        options: simpleChartSourceAuditOptions(showSampleCode: false),
      ),
      SimpleChartSourceAuditCase(
        id: 'code_only',
        label: 'Code only',
        options: simpleChartSourceAuditOptions(showSampleJson: false),
      ),
      SimpleChartSourceAuditCase(
        id: 'source_disabled',
        label: 'Source disabled',
        options: simpleChartSourceAuditOptions(
          showSampleJson: false,
          showSampleCode: false,
        ),
        expectSources: false,
      ),
    ]);

class _SimpleChartSourceAuditCaseCounter {
  _SimpleChartSourceAuditCaseCounter(this.auditCase);

  final SimpleChartSourceAuditCase auditCase;
  var panelCount = 0;
  var sourceCount = 0;
  var requiredSourceCount = 0;
  var unexpectedSourceCount = 0;

  SimpleChartSourceAuditCaseResult toResult() {
    return SimpleChartSourceAuditCaseResult(
      id: auditCase.id,
      label: auditCase.label,
      panelCount: panelCount,
      sourceCount: sourceCount,
      requiredSourceCount: requiredSourceCount,
      unexpectedSourceCount: unexpectedSourceCount,
    );
  }
}

SimpleChartSourceAuditReport auditSimpleChartShowcaseSources({
  Iterable<SimpleChartSourceAuditFamilySpec>? families,
  SimpleChartsGalleryOptions? options,
  Iterable<SimpleChartSourceAuditCase>? cases,
}) {
  final familySpecs = (families ?? simpleChartSourceAuditDefaultFamilies)
      .toList(growable: false);
  final caseSpecs = cases != null
      ? cases.toList(growable: false)
      : [
          if (options != null)
            SimpleChartSourceAuditCase(
              id: 'custom',
              label: 'Custom',
              options: options,
            )
          else
            ...simpleChartSourceAuditDefaultCases,
        ];
  final results = <SimpleChartSourceAuditFamilyResult>[];
  final issues = <SimpleChartSourceAuditIssue>[];
  _auditDuplicateCaseIds(caseSpecs, issues);
  _auditDuplicateFamilyIds(familySpecs, issues);
  final caseCounters = [
    for (final auditCase in caseSpecs)
      _SimpleChartSourceAuditCaseCounter(auditCase),
  ];

  for (final family in familySpecs) {
    int? panelCount;
    var sourceCount = 0;
    var expectedSourceCount = 0;
    var unexpectedSourceCount = 0;
    final chartTypes = <String>{};
    final panelTitlesByIndex = <int, String>{};
    final panelTitleFirstIndex = <String, int>{};
    final sourceTypesByIndex = <int, String>{};

    for (var caseIndex = 0; caseIndex < caseSpecs.length; caseIndex++) {
      final auditCase = caseSpecs[caseIndex];
      final caseCounter = caseCounters[caseIndex];
      late final List<Widget> widgets;
      try {
        widgets = family.buildPanels(auditCase.options);
      } catch (_) {
        issues.add(
          _simpleSourceIssue(
            family,
            auditCase: auditCase,
            code: 'FAMILY_BUILD_FAILED',
            message: 'Simple chart family panels could not be built.',
            suggestion: 'Keep showcase panel builders side-effect free.',
          ),
        );
        continue;
      }
      caseCounter.panelCount += widgets.length;

      if (panelCount == null) {
        panelCount = widgets.length;
      } else if (widgets.length != panelCount) {
        issues.add(
          _simpleSourceIssue(
            family,
            auditCase: auditCase,
            code: 'FAMILY_PANEL_COUNT_CHANGED',
            message:
                'Simple chart family panel count changed between audit cases.',
            suggestion:
                'Keep showcase panel counts stable across display/source knobs.',
          ),
        );
      }

      if (auditCase.expectSources) {
        expectedSourceCount += widgets.length;
        caseCounter.requiredSourceCount += widgets.length;
      }

      for (var panelIndex = 0; panelIndex < widgets.length; panelIndex++) {
        final widget = widgets[panelIndex];
        if (widget is! SimpleChartsShowcasePanel) {
          issues.add(
            _simpleSourceIssue(
              family,
              auditCase: auditCase,
              panelIndex: panelIndex,
              code: 'UNEXPECTED_PANEL_WIDGET',
              message: 'Simple chart family returned a non-showcase panel.',
              suggestion:
                  'Wrap simple chart demos in SimpleChartsShowcasePanel.',
            ),
          );
          continue;
        }

        if (caseIndex == 0) {
          _auditPanelMetadata(
            family,
            auditCase,
            panelIndex,
            widget.title,
            widget.subtitle,
            panelTitleFirstIndex,
            issues,
          );
        }
        _auditPanelTitleIdentity(
          family,
          auditCase,
          panelIndex,
          widget.title,
          panelTitlesByIndex,
          issues,
        );

        final source = widget.source;
        if (source == null) {
          if (auditCase.expectSources) {
            issues.add(
              _simpleSourceIssue(
                family,
                auditCase: auditCase,
                panelIndex: panelIndex,
                panelTitle: widget.title,
                code: 'SOURCE_MISSING',
                message:
                    'Panel has no sample JSON or Dart code source attached.',
                suggestion:
                    'Return a SimpleChartSampleSource when sample knobs are enabled.',
              ),
            );
          }
          continue;
        }

        if (!auditCase.expectSources) {
          unexpectedSourceCount++;
          caseCounter.unexpectedSourceCount++;
          issues.add(
            _simpleSourceIssue(
              family,
              auditCase: auditCase,
              panelIndex: panelIndex,
              panelTitle: widget.title,
              code: 'SOURCE_PRESENT_WHEN_DISABLED',
              message:
                  'Panel keeps sample source metadata when source knobs are disabled.',
              suggestion:
                  'Use options.showSampleSource before building SimpleChartSampleSource.',
            ),
          );
          continue;
        }

        sourceCount++;
        caseCounter.sourceCount++;
        final chartType = _simpleSourceChartType(source.sampleJson);
        if (chartType != null) {
          chartTypes.add(chartType);
          _auditSourceTypeIdentity(
            family,
            auditCase,
            panelIndex,
            widget.title,
            chartType,
            sourceTypesByIndex,
            issues,
          );
        }
        _auditSimpleSource(
          family,
          auditCase,
          panelIndex,
          widget.title,
          source,
          chartType,
          issues,
        );
      }
    }

    final sortedChartTypes = chartTypes.toList(growable: false)..sort();
    results.add(
      SimpleChartSourceAuditFamilyResult(
        id: family.id,
        title: family.title,
        tier: family.tier,
        panelCount: panelCount ?? 0,
        sourceCount: sourceCount,
        expectedSourceCount: expectedSourceCount,
        unexpectedSourceCount: unexpectedSourceCount,
        chartTypes: sortedChartTypes,
      ),
    );
  }

  return SimpleChartSourceAuditReport(
    families: results,
    issues: issues,
    cases: caseSpecs,
    caseResults: caseCounters
        .map((caseCounter) => caseCounter.toResult())
        .toList(growable: false),
  );
}

void _auditPanelMetadata(
  SimpleChartSourceAuditFamilySpec family,
  SimpleChartSourceAuditCase auditCase,
  int panelIndex,
  String panelTitle,
  String panelSubtitle,
  Map<String, int> panelTitleFirstIndex,
  List<SimpleChartSourceAuditIssue> issues,
) {
  final trimmedTitle = panelTitle.trim();
  final trimmedSubtitle = panelSubtitle.trim();

  if (trimmedTitle.isEmpty) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        code: 'PANEL_TITLE_EMPTY',
        message: 'Simple chart panel title must not be empty.',
        suggestion:
            'Use a stable readable panel title for source audit identity.',
      ),
    );
  } else {
    final firstIndex = panelTitleFirstIndex[trimmedTitle];
    if (firstIndex == null) {
      panelTitleFirstIndex[trimmedTitle] = panelIndex;
    } else {
      issues.add(
        _simpleSourceIssue(
          family,
          auditCase: auditCase,
          panelIndex: panelIndex,
          panelTitle: panelTitle,
          code: 'DUPLICATE_PANEL_TITLE',
          message:
              'Simple chart panel title "$trimmedTitle" duplicates panel index $firstIndex.',
          suggestion:
              'Use unique panel titles within each simple chart family.',
        ),
      );
    }
  }

  if (trimmedSubtitle.isEmpty) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        code: 'PANEL_SUBTITLE_EMPTY',
        message: 'Simple chart panel subtitle must not be empty.',
        suggestion:
            'Use a short readable subtitle so the showcase remains scannable.',
      ),
    );
  }
}

void _auditDuplicateCaseIds(
  List<SimpleChartSourceAuditCase> cases,
  List<SimpleChartSourceAuditIssue> issues,
) {
  final seenIds = <String>{};
  for (var index = 0; index < cases.length; index++) {
    final auditCase = cases[index];
    final caseId = auditCase.id.trim();
    final caseLabel = auditCase.label.trim();
    if (caseId.isEmpty) {
      issues.add(
        SimpleChartSourceAuditIssue(
          code: 'CASE_ID_EMPTY',
          message: 'Simple source audit case id must not be empty.',
          familyId: 'simple_source_audit',
          familyTitle: 'Simple Source Audit',
          caseId: auditCase.id,
          caseLabel: auditCase.label,
          panelIndex: index,
          suggestion:
              'Use a stable non-empty case id for source audit coverage rows.',
        ),
      );
    }
    if (caseLabel.isEmpty) {
      issues.add(
        SimpleChartSourceAuditIssue(
          code: 'CASE_LABEL_EMPTY',
          message: 'Simple source audit case label must not be empty.',
          familyId: 'simple_source_audit',
          familyTitle: 'Simple Source Audit',
          caseId: auditCase.id,
          caseLabel: auditCase.label,
          panelIndex: index,
          suggestion:
              'Use a readable case label for Registry Health coverage chips.',
        ),
      );
    }
    if (seenIds.add(auditCase.id)) {
      continue;
    }

    issues.add(
      SimpleChartSourceAuditIssue(
        code: 'DUPLICATE_CASE_ID',
        message: 'Simple source audit case id "${auditCase.id}" is duplicated.',
        familyId: 'simple_source_audit',
        familyTitle: 'Simple Source Audit',
        caseId: auditCase.id,
        caseLabel: auditCase.label,
        panelIndex: index,
        suggestion:
            'Use unique case ids so case coverage rows remain unambiguous.',
      ),
    );
  }
}

void _auditDuplicateFamilyIds(
  List<SimpleChartSourceAuditFamilySpec> families,
  List<SimpleChartSourceAuditIssue> issues,
) {
  final seenIds = <String>{};
  for (var index = 0; index < families.length; index++) {
    final family = families[index];
    final familyId = family.id.trim();
    final familyTitle = family.title.trim();
    if (familyId.isEmpty) {
      issues.add(
        SimpleChartSourceAuditIssue(
          code: 'FAMILY_ID_EMPTY',
          message: 'Simple source audit family id must not be empty.',
          familyId: family.id,
          familyTitle: family.title,
          panelIndex: index,
          suggestion:
              'Use a stable non-empty family id for source audit coverage rows.',
        ),
      );
    }
    if (familyTitle.isEmpty) {
      issues.add(
        SimpleChartSourceAuditIssue(
          code: 'FAMILY_TITLE_EMPTY',
          message: 'Simple source audit family title must not be empty.',
          familyId: family.id,
          familyTitle: family.title,
          panelIndex: index,
          suggestion:
              'Use a readable family title for Registry Health coverage chips.',
        ),
      );
    }
    if (seenIds.add(family.id)) {
      continue;
    }

    issues.add(
      SimpleChartSourceAuditIssue(
        code: 'DUPLICATE_FAMILY_ID',
        message: 'Simple source audit family id "${family.id}" is duplicated.',
        familyId: family.id,
        familyTitle: family.title,
        panelIndex: index,
        suggestion:
            'Use unique family ids so family coverage rows remain unambiguous.',
      ),
    );
  }
}

void _auditPanelTitleIdentity(
  SimpleChartSourceAuditFamilySpec family,
  SimpleChartSourceAuditCase auditCase,
  int panelIndex,
  String panelTitle,
  Map<int, String> panelTitlesByIndex,
  List<SimpleChartSourceAuditIssue> issues,
) {
  final baselineTitle = panelTitlesByIndex[panelIndex];
  if (baselineTitle == null) {
    panelTitlesByIndex[panelIndex] = panelTitle;
    return;
  }

  if (baselineTitle == panelTitle) {
    return;
  }

  issues.add(
    _simpleSourceIssue(
      family,
      auditCase: auditCase,
      panelIndex: panelIndex,
      panelTitle: panelTitle,
      code: 'PANEL_TITLE_CHANGED',
      message:
          'Panel title changed between audit cases. Expected "$baselineTitle".',
      suggestion:
          'Keep simple chart panel order and titles stable across source/display knobs.',
    ),
  );
}

void _auditSourceTypeIdentity(
  SimpleChartSourceAuditFamilySpec family,
  SimpleChartSourceAuditCase auditCase,
  int panelIndex,
  String panelTitle,
  String chartType,
  Map<int, String> sourceTypesByIndex,
  List<SimpleChartSourceAuditIssue> issues,
) {
  final baselineType = sourceTypesByIndex[panelIndex];
  if (baselineType == null) {
    sourceTypesByIndex[panelIndex] = chartType;
    return;
  }

  if (baselineType == chartType) {
    return;
  }

  issues.add(
    _simpleSourceIssue(
      family,
      auditCase: auditCase,
      panelIndex: panelIndex,
      panelTitle: panelTitle,
      chartType: chartType,
      code: 'SOURCE_TYPE_CHANGED',
      message:
          'Panel source chart type changed between audit cases. Expected "$baselineType".',
      suggestion:
          'Keep each simple chart panel bound to the same chart type across source/display knobs.',
    ),
  );
}

void _auditSimpleSource(
  SimpleChartSourceAuditFamilySpec family,
  SimpleChartSourceAuditCase auditCase,
  int panelIndex,
  String panelTitle,
  SimpleChartSampleSource source,
  String? chartType,
  List<SimpleChartSourceAuditIssue> issues,
) {
  if (chartType == null || chartType.trim().isEmpty) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        code: 'SOURCE_TYPE_MISSING',
        message: 'Sample JSON source is missing a non-empty string type.',
        suggestion:
            'Set the simpleChartSourceJson chartType to the widget name.',
      ),
    );
  }

  String? jsonText;
  try {
    jsonText = source.jsonText;
  } catch (_) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        chartType: chartType,
        code: 'SOURCE_JSON_NOT_ENCODABLE',
        message: 'Sample JSON source could not be encoded.',
        suggestion: 'Keep sample source values JSON-compatible.',
      ),
    );
  }

  if (jsonText != null) {
    if (jsonText.trim().isEmpty) {
      issues.add(
        _simpleSourceIssue(
          family,
          auditCase: auditCase,
          panelIndex: panelIndex,
          panelTitle: panelTitle,
          chartType: chartType,
          code: 'SOURCE_JSON_EMPTY',
          message: 'Generated sample JSON text is empty.',
        ),
      );
    }

    if (jsonText.contains('Instance of')) {
      issues.add(
        _simpleSourceIssue(
          family,
          auditCase: auditCase,
          panelIndex: panelIndex,
          panelTitle: panelTitle,
          chartType: chartType,
          code: 'SOURCE_JSON_INSTANCE_TEXT',
          message: 'Generated sample JSON contains Dart instance text.',
          suggestion:
              'Convert nested model objects to JSON maps before export.',
        ),
      );
    }

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        issues.add(
          _simpleSourceIssue(
            family,
            auditCase: auditCase,
            panelIndex: panelIndex,
            panelTitle: panelTitle,
            chartType: chartType,
            code: 'SOURCE_JSON_NOT_OBJECT',
            message: 'Generated sample JSON must decode to an object.',
          ),
        );
      } else {
        final decodedType = _simpleSourceChartType(decoded);
        if (decodedType == null || decodedType.trim().isEmpty) {
          issues.add(
            _simpleSourceIssue(
              family,
              auditCase: auditCase,
              panelIndex: panelIndex,
              panelTitle: panelTitle,
              code: 'SOURCE_JSON_TYPE_MISSING',
              message: 'Generated sample JSON is missing a string type.',
            ),
          );
        } else if (chartType != null && decodedType != chartType) {
          issues.add(
            _simpleSourceIssue(
              family,
              auditCase: auditCase,
              panelIndex: panelIndex,
              panelTitle: panelTitle,
              chartType: chartType,
              code: 'SOURCE_JSON_TYPE_MISMATCH',
              message:
                  'Generated sample JSON type differs from source JSON type.',
            ),
          );
        }
      }
    } catch (_) {
      issues.add(
        _simpleSourceIssue(
          family,
          auditCase: auditCase,
          panelIndex: panelIndex,
          panelTitle: panelTitle,
          chartType: chartType,
          code: 'SOURCE_JSON_INVALID',
          message: 'Generated sample JSON text could not be decoded.',
        ),
      );
    }
  }

  final dartCode = source.dartCode;

  if (dartCode.trim().isEmpty) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        chartType: chartType,
        code: 'SOURCE_CODE_EMPTY',
        message: 'Dart sample source is empty.',
      ),
    );
  }

  if (dartCode.contains('Instance of')) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        chartType: chartType,
        code: 'SOURCE_CODE_INSTANCE_TEXT',
        message: 'Dart sample source contains instance placeholder text.',
      ),
    );
  }

  if (chartType != null && !dartCode.contains(chartType)) {
    issues.add(
      _simpleSourceIssue(
        family,
        auditCase: auditCase,
        panelIndex: panelIndex,
        panelTitle: panelTitle,
        chartType: chartType,
        code: 'SOURCE_CODE_TYPE_MISSING',
        message: 'Dart sample source does not mention the JSON chart type.',
        suggestion:
            'Keep sample JSON type and Dart constructor examples aligned.',
      ),
    );
  }
}

String? _simpleSourceChartType(Object? json) {
  if (json is! Map) return null;
  final type = json['type'];
  return type is String ? type : null;
}

SimpleChartSourceAuditIssue _simpleSourceIssue(
  SimpleChartSourceAuditFamilySpec family, {
  required String code,
  required String message,
  SimpleChartSourceAuditCase? auditCase,
  int? panelIndex,
  String? panelTitle,
  String? chartType,
  String? suggestion,
}) {
  return SimpleChartSourceAuditIssue(
    code: code,
    message: message,
    familyId: family.id,
    familyTitle: family.title,
    caseId: auditCase?.id,
    caseLabel: auditCase?.label,
    panelIndex: panelIndex,
    panelTitle: panelTitle,
    chartType: chartType,
    suggestion: suggestion,
  );
}
