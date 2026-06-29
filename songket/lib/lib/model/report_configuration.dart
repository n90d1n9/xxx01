import 'package:flutter/material.dart';

import 'ai_insight.dart';
import 'chart_configuration.dart';
import 'conditional_format.dart';
import 'data_source.dart';
import 'data_type.dart';
import 'performance_config.dart';
import 'report.dart';
import 'report_collaboration.dart';
import 'report_column.dart';
import 'report_filter.dart';
import 'report_grouping.dart';
import 'report_schedule.dart';
import 'report_sort.dart';
import 'report_version.dart';
import 'report_visibility.dart';
import 'template_category.dart';
import 'visualization_type.dart';

class ReportConfiguration {
  final String id;
  final String name;
  final String description;
  final ReportDomain domain;
  final ReportType type;

  final int pageSize;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ChartConfiguration? chartConfig;
  final Map<String, dynamic> customSettings;

  final String? dataSourceQuery; // SQL or custom query
  final bool enableDrillDown;
  final bool enableExport;

  final String? icon;
  final Color? accentColor;

  // Data source
  final DataSource dataSource;
  final String? customQuery;
  final Map<String, dynamic> queryParameters;

  // Structure
  final List<ReportColumn> columns;
  final List<ReportColumn> selectedColumns;
  final List<ReportFilter> filters;
  final List<ReportSort> sorts;
  final List<ReportGrouping> groupings;
  final Map<String, AggregationType> aggregations;

  // Visualization
  final VisualizationType visualizationType;
  final Map<String, dynamic> visualizationConfig;
  final List<ConditionalFormat> conditionalFormats;

  // Advanced features
  final ReportVisibility visibility;
  final ReportCollaboration? collaboration;
  final List<ReportVersion> versions;
  final int currentVersion;
  final PerformanceConfig performanceConfig;
  final List<AIInsight> aiInsights;
  final bool enableRealTimeUpdates;
  final Duration? refreshInterval;

  // Automation
  final TriggerType triggerType;
  final ReportSchedule? schedule;
  final List<String> webhooks;
  final Map<String, dynamic> automationRules;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;
  final String ownerName;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool isFavorite;
  final bool isTemplate;
  final TemplateCategory? templateCategory;

  // Analytics
  final int viewCount;
  final int exportCount;
  final DateTime? lastAccessedAt;
  final Map<String, int> accessLog;

  ReportConfiguration({
    String? id,
    required this.name,
    required this.description,
    required this.domain,
    required this.type,
    required this.columns,
    required this.selectedColumns,
    this.filters = const [],
    this.sorts = const [],
    this.groupings = const [],
    this.aggregations = const {},
    this.pageSize = 50,
    this.dateFrom,
    this.dateTo,
    this.chartConfig,
    this.customSettings = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dataSourceQuery,
    this.enableDrillDown = false,
    this.enableExport = true,
    this.schedule,
    this.tags = const [],

    this.icon,
    this.accentColor,
    required this.dataSource,
    this.customQuery,
    this.queryParameters = const {},

    this.visualizationType = VisualizationType.table,
    this.visualizationConfig = const {},
    this.conditionalFormats = const [],
    this.visibility = ReportVisibility.private,
    this.collaboration,
    this.versions = const [],
    this.currentVersion = 1,
    this.performanceConfig = const PerformanceConfig(),
    this.aiInsights = const [],
    this.enableRealTimeUpdates = false,
    this.refreshInterval,
    this.triggerType = TriggerType.manual,

    this.webhooks = const [],
    this.automationRules = const {},

    required this.ownerId,
    required this.ownerName,

    this.metadata = const {},
    this.isFavorite = false,
    this.isTemplate = false,
    this.templateCategory,
    this.viewCount = 0,
    this.exportCount = 0,
    this.lastAccessedAt,
    this.accessLog = const {},
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ReportConfiguration copyWith({
    String? id,
    String? name,
    String? description,
    ReportDomain? domain,
    ReportType? type,
    List<ReportColumn>? columns,
    List<ReportColumn>? selectedColumns,
    List<ReportFilter>? filters,
    List<ReportSort>? sorts,
    List<ReportGrouping>? groupings,
    Map<String, AggregationType>? aggregations,
    int? pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
    ChartConfiguration? chartConfig,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dataSourceQuery,
    bool? enableDrillDown,
    bool? enableExport,
    ReportSchedule? schedule,
    List<String>? tags,
    bool? enableRealTimeUpdates,
    List<AIInsight>? aiInsights,
  }) {
    return ReportConfiguration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      columns: columns ?? this.columns,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      filters: filters ?? this.filters,
      sorts: sorts ?? this.sorts,
      groupings: groupings ?? this.groupings,
      aggregations: aggregations ?? this.aggregations,
      pageSize: pageSize ?? this.pageSize,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      chartConfig: chartConfig ?? this.chartConfig,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      dataSourceQuery: dataSourceQuery ?? this.dataSourceQuery,
      enableDrillDown: enableDrillDown ?? this.enableDrillDown,
      enableExport: enableExport ?? this.enableExport,
      schedule: schedule ?? this.schedule,
      tags: tags ?? this.tags,

      icon: icon,
      accentColor: accentColor,
      dataSource: dataSource,
      customQuery: customQuery,
      queryParameters: queryParameters,

      visualizationType: visualizationType,
      visualizationConfig: visualizationConfig,
      conditionalFormats: conditionalFormats,
      visibility: visibility,
      collaboration: collaboration,
      versions: versions,
      currentVersion: currentVersion,
      performanceConfig: performanceConfig,
      aiInsights: aiInsights ?? this.aiInsights,
      enableRealTimeUpdates:
          enableRealTimeUpdates ?? this.enableRealTimeUpdates,
      refreshInterval: refreshInterval,
      triggerType: triggerType,

      webhooks: webhooks,
      automationRules: automationRules,

      ownerId: ownerId,
      ownerName: ownerName,

      metadata: metadata,
      isFavorite: isFavorite,
      isTemplate: isTemplate,
      templateCategory: templateCategory,
      viewCount: viewCount,
      exportCount: exportCount,
      lastAccessedAt: lastAccessedAt,
      accessLog: accessLog,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'domain': domain.name,
    'type': type.name,
    'columns': columns.map((c) => c.toJson()).toList(),
    'selectedColumns': selectedColumns.map((c) => c.toJson()).toList(),
    'filters': filters.map((f) => f.toJson()).toList(),
    'sorts': sorts.map((s) => s.toJson()).toList(),
    'groupings': groupings.map((g) => g.toJson()).toList(),
    'aggregations': aggregations.map((k, v) => MapEntry(k, v.name)),
    'pageSize': pageSize,
    'dateFrom': dateFrom?.toIso8601String(),
    'dateTo': dateTo?.toIso8601String(),
    'chartConfig': chartConfig?.toJson(),
    'customSettings': customSettings,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'dataSourceQuery': dataSourceQuery,
    'enableDrillDown': enableDrillDown,
    'enableExport': enableExport,
    'tags': tags,
  };

  factory ReportConfiguration.fromJson(Map<String, dynamic> json) {
    return ReportConfiguration(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      domain: ReportDomain.values.firstWhere((e) => e.name == json['domain']),
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      columns: (json['columns'] as List)
          .map((c) => ReportColumn.fromJson(c))
          .toList(),
      selectedColumns: (json['selectedColumns'] as List)
          .map((c) => ReportColumn.fromJson(c))
          .toList(),
      filters: json['filters'] != null
          ? (json['filters'] as List)
                .map((f) => ReportFilter.fromJson(f))
                .toList()
          : [],
      sorts: json['sorts'] != null
          ? (json['sorts'] as List).map((s) => ReportSort.fromJson(s)).toList()
          : [],
      groupings: json['groupings'] != null
          ? (json['groupings'] as List)
                .map((g) => ReportGrouping.fromJson(g))
                .toList()
          : [],
      aggregations: json['aggregations'] != null
          ? (json['aggregations'] as Map).map(
              (k, v) => MapEntry(
                k,
                AggregationType.values.firstWhere((e) => e.name == v),
              ),
            )
          : {},
      pageSize: json['pageSize'] ?? 50,
      dateFrom: json['dateFrom'] != null
          ? DateTime.parse(json['dateFrom'])
          : null,
      dateTo: json['dateTo'] != null ? DateTime.parse(json['dateTo']) : null,
      chartConfig: json['chartConfig'] != null
          ? ChartConfiguration.fromJson(json['chartConfig'])
          : null,
      customSettings: json['customSettings'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      dataSourceQuery: json['dataSourceQuery'],
      enableDrillDown: json['enableDrillDown'] ?? false,
      enableExport: json['enableExport'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      dataSource: json['dataSource'],
      ownerId: '',
      ownerName: '',
    );
  }
}
