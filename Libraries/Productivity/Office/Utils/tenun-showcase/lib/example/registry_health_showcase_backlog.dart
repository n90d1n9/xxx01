import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

import 'chart_sample_source_helpers.dart';
import 'showcase_source_panel.dart';

class RegistryHealthShowcaseBacklogPanel extends StatelessWidget {
  const RegistryHealthShowcaseBacklogPanel({
    super.key,
    required this.entries,
    this.visibleLimit = 6,
    this.options = const RegistryHealthShowcaseBacklogPanelOptions(),
  });

  final List<ChartFamilyManifestEntry> entries;
  final int visibleLimit;
  final RegistryHealthShowcaseBacklogPanelOptions options;

  @override
  Widget build(BuildContext context) {
    final items = registryHealthShowcaseBacklogItems(entries);
    if (items.isEmpty) {
      return const Text('No missing showcase starter templates.');
    }

    final visibleItems = items.take(visibleLimit).toList(growable: false);
    final hiddenCount = items.length - visibleItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in visibleItems)
          _BacklogItemTile(item: item, options: options),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+$hiddenCount more starter templates available from the coverage report.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class RegistryHealthShowcaseBacklogPanelOptions {
  const RegistryHealthShowcaseBacklogPanelOptions({
    this.showMetadataChips = true,
    this.showStarterJson = true,
    this.showDartSample = true,
    this.sourcePanelHeight = 220,
    this.sourcePanelMinWidth = 420,
  }) : assert(sourcePanelHeight > 0),
       assert(sourcePanelMinWidth > 0);

  static const compact = RegistryHealthShowcaseBacklogPanelOptions(
    sourcePanelHeight: 160,
    sourcePanelMinWidth: 320,
  );

  static const starterJsonOnly = RegistryHealthShowcaseBacklogPanelOptions(
    showDartSample: false,
  );

  final bool showMetadataChips;
  final bool showStarterJson;
  final bool showDartSample;
  final double sourcePanelHeight;
  final double sourcePanelMinWidth;

  bool get showSourcePanels => showStarterJson || showDartSample;

  RegistryHealthShowcaseBacklogPanelOptions copyWith({
    bool? showMetadataChips,
    bool? showStarterJson,
    bool? showDartSample,
    double? sourcePanelHeight,
    double? sourcePanelMinWidth,
  }) {
    return RegistryHealthShowcaseBacklogPanelOptions(
      showMetadataChips: showMetadataChips ?? this.showMetadataChips,
      showStarterJson: showStarterJson ?? this.showStarterJson,
      showDartSample: showDartSample ?? this.showDartSample,
      sourcePanelHeight: sourcePanelHeight ?? this.sourcePanelHeight,
      sourcePanelMinWidth: sourcePanelMinWidth ?? this.sourcePanelMinWidth,
    );
  }
}

class RegistryHealthShowcaseBacklogItem {
  final ChartFamilyManifestEntry entry;
  final int priorityRank;
  final String priorityLabel;
  final String suggestedFamilyId;
  final String suggestedFamilyTitle;
  final String sampleTitle;
  final double sampleHeight;
  final Map<String, dynamic> json;
  final String jsonText;
  final String codeText;

  const RegistryHealthShowcaseBacklogItem({
    required this.entry,
    required this.priorityRank,
    required this.priorityLabel,
    required this.suggestedFamilyId,
    required this.suggestedFamilyTitle,
    required this.sampleTitle,
    required this.sampleHeight,
    required this.json,
    required this.jsonText,
    required this.codeText,
  });

  Map<String, dynamic> toJson() => {
    'type': entry.showcaseExampleKey,
    'displayName': entry.displayName,
    'priorityRank': priorityRank,
    'priorityLabel': priorityLabel,
    'suggestedFamilyId': suggestedFamilyId,
    'suggestedFamilyTitle': suggestedFamilyTitle,
    'sampleTitle': sampleTitle,
    'sampleHeight': sampleHeight,
    'dataShape': entry.dataShape.name,
    'primaryBundleName': entry.primaryBundleName,
    'apiContract': entry.apiContract.name,
    'seriesStrategy': entry.seriesStrategy.name,
    'dataFieldPriority': List<String>.from(entry.dataFieldPriority),
    if (entry.namedCollectionField != null)
      'namedCollectionField': entry.namedCollectionField,
    'starterJson': json,
    'dartCode': codeText,
  };
}

List<RegistryHealthShowcaseBacklogItem> registryHealthShowcaseBacklogItems(
  Iterable<ChartFamilyManifestEntry> entries,
) {
  final items = [
    for (final entry in entries)
      RegistryHealthShowcaseBacklogItem(
        entry: entry,
        priorityRank: registryHealthShowcaseBacklogPriorityRank(entry),
        priorityLabel: registryHealthShowcaseBacklogPriorityLabel(entry),
        suggestedFamilyId: registryHealthShowcaseSuggestedFamilyId(entry),
        suggestedFamilyTitle: registryHealthShowcaseSuggestedFamilyTitle(entry),
        sampleTitle: '${entry.displayName} Starter',
        sampleHeight: registryHealthShowcaseSuggestedSampleHeight(entry),
        json: registryHealthShowcaseStarterJson(entry),
        jsonText: registryHealthShowcaseStarterJsonText(entry),
        codeText: registryHealthShowcaseStarterCodeText(entry),
      ),
  ];

  return items..sort((a, b) {
    final priority = a.priorityRank.compareTo(b.priorityRank);
    if (priority != 0) return priority;
    final family = a.suggestedFamilyId.compareTo(b.suggestedFamilyId);
    if (family != 0) return family;
    final shape = a.entry.dataShape.name.compareTo(b.entry.dataShape.name);
    if (shape != 0) return shape;
    return a.entry.showcaseExampleKey.compareTo(b.entry.showcaseExampleKey);
  });
}

Map<String, dynamic> registryHealthShowcaseBacklogJson(
  Iterable<ChartFamilyManifestEntry> entries, {
  int itemLimit = 12,
}) {
  final items = registryHealthShowcaseBacklogItems(entries);
  final visibleItems = items.take(itemLimit).toList(growable: false);

  return {
    'count': items.length,
    'exportedCount': visibleItems.length,
    'hiddenCount': items.length - visibleItems.length,
    'items': [for (final item in visibleItems) item.toJson()],
  };
}

int registryHealthShowcaseBacklogPriorityRank(ChartFamilyManifestEntry entry) {
  if (entry.bundleNames.contains('core')) return 0;
  if (entry.bundleNames.contains('business') ||
      entry.bundleNames.contains('ai_ml')) {
    return 1;
  }
  if (entry.bundleNames.contains('common')) return 2;
  return 3;
}

String registryHealthShowcaseBacklogPriorityLabel(
  ChartFamilyManifestEntry entry,
) {
  return switch (registryHealthShowcaseBacklogPriorityRank(entry)) {
    0 => 'Core',
    1 => 'Domain',
    2 => 'Common',
    _ => 'Specialized',
  };
}

String registryHealthShowcaseSuggestedFamilyId(ChartFamilyManifestEntry entry) {
  if (entry.bundleNames.contains('core')) return 'canonical_mixed';
  if (entry.bundleNames.contains('business')) return 'business_project';
  if (entry.bundleNames.contains('ai_ml')) return 'ai_ml';

  return switch (entry.primaryBundleName) {
    'hierarchical' => 'hierarchy',
    'flow' => 'flow',
    'radial' => 'radial',
    'geo' => 'geo',
    'calendar' => 'text_timeline',
    'pie' => 'canonical_mixed',
    'financial' || 'matrix' || 'graph' || 'common' => 'stat_trading_graph',
    _ => 'v3_variant',
  };
}

String registryHealthShowcaseSuggestedFamilyTitle(
  ChartFamilyManifestEntry entry,
) {
  return switch (registryHealthShowcaseSuggestedFamilyId(entry)) {
    'ai_ml' => 'AI & Machine Learning',
    'business_project' => 'Business & Project Management',
    'hierarchy' => 'Hierarchy',
    'flow' => 'Flow',
    'radial' => 'Radial',
    'geo' => 'Geo',
    'text_timeline' => 'Text & Timeline',
    'canonical_mixed' => 'Canonical Mixed',
    'stat_trading_graph' => 'Stat, Trading & Graph',
    _ => 'V3 Variants',
  };
}

double registryHealthShowcaseSuggestedSampleHeight(
  ChartFamilyManifestEntry entry,
) {
  return switch (entry.dataShape) {
    ChartSeriesDataShape.radial || ChartSeriesDataShape.pieLike => 280,
    ChartSeriesDataShape.flow ||
    ChartSeriesDataShape.graph ||
    ChartSeriesDataShape.geospatial => 320,
    ChartSeriesDataShape.calendar => 240,
    _ => 300,
  };
}

Map<String, dynamic> registryHealthShowcaseStarterJson(
  ChartFamilyManifestEntry entry,
) {
  final json = <String, dynamic>{
    'type': entry.showcaseExampleKey,
    'title': {'text': '${entry.displayName} Example'},
    'legend': {'show': true},
    'tooltip': {'show': true},
  };

  switch (entry.seriesStrategy) {
    case ChartPayloadSeriesStrategy.namedCollection:
      json[entry.namedCollectionField ?? 'regions'] = _starterRegions();
      break;
    case ChartPayloadSeriesStrategy.nodeLink:
      json['nodes'] = _starterNodes();
      json['links'] = _starterLinks();
      break;
    case ChartPayloadSeriesStrategy.calendarDateValues:
      json['data'] = _starterCalendarData();
      break;
    case ChartPayloadSeriesStrategy.ringSlices:
      json['rings'] = _starterRingSlices();
      break;
    case ChartPayloadSeriesStrategy.partitionPie:
      json['mainSlices'] = _starterSlices();
      json['subSlices'] = _starterSubSlices();
      break;
    case ChartPayloadSeriesStrategy.dataFields:
      _applyDataFieldTemplate(json, entry);
      break;
  }

  return json;
}

String registryHealthShowcaseStarterJsonText(ChartFamilyManifestEntry entry) {
  return chartSampleJsonText(registryHealthShowcaseStarterJson(entry));
}

String registryHealthShowcaseStarterCodeText(ChartFamilyManifestEntry entry) {
  return chartSampleCodeText(registryHealthShowcaseStarterJson(entry));
}

void _applyDataFieldTemplate(
  Map<String, dynamic> json,
  ChartFamilyManifestEntry entry,
) {
  switch (entry.dataShape) {
    case ChartSeriesDataShape.cartesian:
      json['categories'] = ['Q1', 'Q2', 'Q3', 'Q4'];
      json['series'] = [
        {
          'name': 'Actual',
          'data': [42, 58, 64, 72],
        },
      ];
      json[_preferredDataField(entry)] = [42, 58, 64, 72];
      break;
    case ChartSeriesDataShape.pieLike:
      json[_preferredDataField(entry)] = _starterSlices();
      break;
    case ChartSeriesDataShape.hierarchical:
      json[_preferredDataField(entry)] = _starterHierarchy();
      break;
    case ChartSeriesDataShape.matrix:
      json['xAxis'] = {
        'data': ['A', 'B', 'C'],
      };
      json['yAxis'] = {
        'data': ['Low', 'Mid', 'High'],
      };
      json[_preferredDataField(entry)] = _starterMatrixData();
      break;
    case ChartSeriesDataShape.graph:
      json['nodes'] = _starterNodes();
      json['links'] = _starterLinks();
      break;
    case ChartSeriesDataShape.flow:
      json[_preferredDataField(entry)] = _starterFlowItems();
      break;
    case ChartSeriesDataShape.financial:
      json[_preferredDataField(entry)] = _starterPrices();
      break;
    case ChartSeriesDataShape.radial:
      json.addAll(_starterRadialFields());
      break;
    case ChartSeriesDataShape.calendar:
      json[_preferredDataField(entry)] = _starterCalendarData();
      break;
    case ChartSeriesDataShape.geospatial:
      json[_preferredDataField(entry)] = _starterRegions();
      break;
    case ChartSeriesDataShape.unknown:
      json[_preferredDataField(entry)] = [24, 38, 52, 61];
      break;
  }
}

String _preferredDataField(ChartFamilyManifestEntry entry) {
  return entry.dataFieldPriority.isEmpty
      ? 'data'
      : entry.dataFieldPriority.first;
}

List<Map<String, dynamic>> _starterSlices() {
  return [
    {'name': 'Alpha', 'value': 42},
    {'name': 'Beta', 'value': 28},
    {'name': 'Gamma', 'value': 18},
    {'name': 'Delta', 'value': 12},
  ];
}

List<Map<String, dynamic>> _starterSubSlices() {
  return [
    {'parent': 'Alpha', 'name': 'Alpha A', 'value': 24},
    {'parent': 'Alpha', 'name': 'Alpha B', 'value': 18},
    {'parent': 'Beta', 'name': 'Beta A', 'value': 16},
    {'parent': 'Beta', 'name': 'Beta B', 'value': 12},
  ];
}

List<Map<String, dynamic>> _starterHierarchy() {
  return [
    {
      'name': 'Portfolio',
      'children': [
        {'name': 'Growth', 'value': 42},
        {'name': 'Retention', 'value': 28},
        {'name': 'Quality', 'value': 18},
      ],
    },
  ];
}

List<List<num>> _starterMatrixData() {
  return [
    [0, 0, 12],
    [1, 1, 24],
    [2, 2, 36],
  ];
}

List<Map<String, dynamic>> _starterNodes() {
  return [
    {'id': 'start', 'name': 'Start'},
    {'id': 'review', 'name': 'Review'},
    {'id': 'done', 'name': 'Done'},
  ];
}

List<Map<String, dynamic>> _starterLinks() {
  return [
    {'source': 'start', 'target': 'review', 'value': 42},
    {'source': 'review', 'target': 'done', 'value': 30},
  ];
}

List<Map<String, dynamic>> _starterFlowItems() {
  return [
    {'name': 'Intake', 'value': 100},
    {'name': 'Qualified', 'value': 72},
    {'name': 'Completed', 'value': 44},
  ];
}

List<num> _starterPrices() {
  return [100, 104, 101, 108, 112, 109, 116];
}

Map<String, dynamic> _starterRadialFields() {
  return {
    'value': 72,
    'min': 0,
    'max': 100,
    'unit': '%',
    'bands': [
      {'from': 0, 'to': 40, 'color': '#E57373'},
      {'from': 40, 'to': 70, 'color': '#FFB74D'},
      {'from': 70, 'to': 100, 'color': '#81C784'},
    ],
  };
}

List<Map<String, dynamic>> _starterCalendarData() {
  return [
    {'date': '2026-01-01', 'value': 12},
    {'date': '2026-01-02', 'value': 18},
    {'date': '2026-01-03', 'value': 24},
  ];
}

List<Map<String, dynamic>> _starterRegions() {
  return [
    {'region': 'North', 'value': 42},
    {'region': 'South', 'value': 36},
    {'region': 'West', 'value': 28},
  ];
}

List<Map<String, dynamic>> _starterRingSlices() {
  return [
    {'name': 'Outer', 'slices': _starterSlices()},
    {
      'name': 'Inner',
      'slices': [
        {'name': 'Focus', 'value': 54},
        {'name': 'Other', 'value': 46},
      ],
    },
  ];
}

class _BacklogItemTile extends StatelessWidget {
  const _BacklogItemTile({required this.item, required this.options});

  final RegistryHealthShowcaseBacklogItem item;
  final RegistryHealthShowcaseBacklogPanelOptions options;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Text(item.sampleTitle),
      subtitle: Text(
        '${item.priorityLabel} priority - ${item.suggestedFamilyTitle} - ${item.entry.dataShape.name}',
      ),
      children: [
        if (options.showMetadataChips) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text('type.${item.entry.showcaseExampleKey}'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('family.${item.suggestedFamilyId}'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('height.${item.sampleHeight.round()}'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
        if (options.showSourcePanels) ...[
          if (options.showMetadataChips) const SizedBox(height: 8),
          ShowcaseSourceTextPanelGroup(
            panelHeight: options.sourcePanelHeight,
            minPanelWidth: options.sourcePanelMinWidth,
            items: [
              if (options.showStarterJson)
                ShowcaseSourceTextItem(
                  title: 'Starter JSON',
                  text: item.jsonText,
                  copyLabel: '${item.sampleTitle} JSON',
                ),
              if (options.showDartSample)
                ShowcaseSourceTextItem(
                  title: 'Dart Sample',
                  text: item.codeText,
                  copyLabel: '${item.sampleTitle} code',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
