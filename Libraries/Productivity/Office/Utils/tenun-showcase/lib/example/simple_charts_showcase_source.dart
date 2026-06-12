import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'showcase_source_panel.dart';

class SimpleChartSampleSource {
  const SimpleChartSampleSource({
    required this.sampleJson,
    required this.dartCode,
  });

  final Map<String, dynamic> sampleJson;
  final String dartCode;

  String get jsonText => showcasePrettyJson(sampleJson);
}

Map<String, dynamic> simpleChartSourceJson({
  required String chartType,
  required String title,
  required String subtitle,
  required Map<String, dynamic> data,
  Map<String, dynamic> options = const {},
}) {
  return {
    'type': chartType,
    'title': title,
    'subtitle': subtitle,
    'data': data,
    if (options.isNotEmpty) 'options': options,
  };
}

List<Map<String, dynamic>> simpleBarDataJson(List<SimpleBarChartData> data) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleTrendSeriesJson(
  List<SimpleTrendSeries> series,
) {
  return [
    for (final item in series)
      {
        if (item.name != null) 'name': item.name,
        'points': simpleTrendPointsJson(item.points),
        if (item.color != null) 'color': colorHex(item.color!),
        if (item.strokeWidth != null) 'strokeWidth': item.strokeWidth,
        'lineStyle': item.lineStyle.name,
      },
  ];
}

List<Map<String, dynamic>> simpleTrendPointsJson(
  List<SimpleTrendPoint> points,
) {
  return [
    for (final point in points) {'label': point.label, 'value': point.value},
  ];
}

List<Map<String, dynamic>> simpleSmallMultiplePanelsJson(
  List<SimpleSmallMultiplePanel> panels,
) {
  return [
    for (final panel in panels)
      {
        'label': panel.label,
        if (panel.subtitle != null) 'subtitle': panel.subtitle,
        'series': simpleTrendSeriesJson(panel.series),
        if (panel.color != null) 'color': colorHex(panel.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleCyclePlotPointsJson(
  List<SimpleCyclePlotPoint> points,
) {
  return [
    for (final point in points)
      {
        'periodLabel': point.periodLabel,
        'cycleLabel': point.cycleLabel,
        'value': point.value,
      },
  ];
}

List<Map<String, dynamic>> simpleFanChartPointsJson(
  List<SimpleFanChartPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'value': point.value,
        if (point.color != null) 'color': colorHex(point.color!),
        if (point.bands.isNotEmpty)
          'bands': [
            for (final band in point.bands)
              {
                'label': band.label,
                'lower': band.lower,
                'upper': band.upper,
                if (band.color != null) 'color': colorHex(band.color!),
              },
          ],
      },
  ];
}

List<Map<String, dynamic>> simpleSpiralChartPointsJson(
  List<SimpleSpiralChartPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'value': point.value,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleCandlestickDataJson(
  List<SimpleCandlestickData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'open': item.open,
        'high': item.high,
        'low': item.low,
        'close': item.close,
        if (item.volume != null) 'volume': item.volume,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleConnectedScatterSeriesJson(
  List<SimpleConnectedScatterSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'points': [
          for (final point in item.points)
            {
              'label': point.label,
              'x': point.x,
              'y': point.y,
              if (point.value != null) 'value': point.value,
              if (point.color != null) 'color': colorHex(point.color!),
            },
        ],
        if (item.color != null) 'color': colorHex(item.color!),
        if (item.strokeWidth != null) 'strokeWidth': item.strokeWidth,
      },
  ];
}

List<Map<String, dynamic>> simpleControlChartPointsJson(
  List<SimpleControlChartPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'value': point.value,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleCohortRowsJson(
  List<SimpleCohortRetentionRow> rows,
) {
  return [
    for (final row in rows)
      {
        'label': row.label,
        'values': row.values,
        if (row.size != null) 'size': row.size,
        if (row.color != null) 'color': colorHex(row.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleFunnelDataJson(
  List<SimpleFunnelChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleSankeyLinksJson(List<SimpleSankeyLink> links) {
  return [
    for (final link in links)
      {
        'source': link.source,
        'target': link.target,
        'value': link.value,
        if (link.label != null) 'label': link.label,
        if (link.color != null) 'color': colorHex(link.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleAlluvialFlowsJson(
  List<SimpleAlluvialFlow> flows,
) {
  return [
    for (final flow in flows)
      {
        'categories': flow.categories,
        'value': flow.value,
        if (flow.label != null) 'label': flow.label,
        if (flow.color != null) 'color': colorHex(flow.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleChordNodesJson(List<SimpleChordNode> nodes) {
  return [
    for (final node in nodes)
      {
        'id': node.id,
        'label': node.label,
        if (node.color != null) 'color': colorHex(node.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleChordLinksJson(List<SimpleChordLink> links) {
  return [
    for (final link in links)
      {
        'source': link.source,
        'target': link.target,
        'value': link.value,
        if (link.label != null) 'label': link.label,
        if (link.color != null) 'color': colorHex(link.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleArcDiagramNodesJson(
  List<SimpleArcDiagramNode> nodes,
) {
  return [
    for (final node in nodes)
      {
        'id': node.id,
        'label': node.label,
        if (node.value != null) 'value': node.value,
        if (node.color != null) 'color': colorHex(node.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleArcDiagramLinksJson(
  List<SimpleArcDiagramLink> links,
) {
  return [
    for (final link in links)
      {
        'source': link.source,
        'target': link.target,
        'value': link.value,
        if (link.label != null) 'label': link.label,
        if (link.color != null) 'color': colorHex(link.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleNetworkNodesJson(
  List<SimpleNetworkNode> nodes,
) {
  return [
    for (final node in nodes)
      {
        'id': node.id,
        'label': node.label,
        'value': node.value,
        if (node.group != null) 'group': node.group,
        if (node.x != null) 'x': node.x,
        if (node.y != null) 'y': node.y,
        if (node.color != null) 'color': colorHex(node.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleNetworkLinksJson(
  List<SimpleNetworkLink> links,
) {
  return [
    for (final link in links)
      {
        'source': link.source,
        'target': link.target,
        'value': link.value,
        if (link.label != null) 'label': link.label,
        if (link.directed != null) 'directed': link.directed,
        if (link.color != null) 'color': colorHex(link.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleQuadrantPointsJson(
  List<SimpleQuadrantPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'x': point.x,
        'y': point.y,
        if (point.size != null) 'size': point.size,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBubbleDataJson(
  List<SimpleBubbleChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'x': item.x,
        'y': item.y,
        'size': item.size,
        if (item.group != null) 'group': item.group,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleDumbbellDataJson(
  List<SimpleDumbbellChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'start': item.start,
        'end': item.end,
        if (item.startLabel != null) 'startLabel': item.startLabel,
        if (item.endLabel != null) 'endLabel': item.endLabel,
        if (item.startColor != null) 'startColor': colorHex(item.startColor!),
        if (item.endColor != null) 'endColor': colorHex(item.endColor!),
        if (item.connectorColor != null)
          'connectorColor': colorHex(item.connectorColor!),
      },
  ];
}

List<Map<String, dynamic>> simpleGroupedBarSeriesJson(
  List<SimpleGroupedBarSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleDonutDataJson(
  List<SimpleDonutChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRoseDataJson(List<SimpleRoseChartData> data) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleWaterfallDataJson(
  List<SimpleWaterfallChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        'isTotal': item.isTotal,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRangeDataJson(
  List<SimpleRangeChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'min': item.min,
        'max': item.max,
        if (item.value != null) 'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
        if (item.markerColor != null)
          'markerColor': colorHex(item.markerColor!),
      },
  ];
}

List<Map<String, dynamic>> simpleTornadoDataJson(
  List<SimpleTornadoChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'low': item.low,
        'high': item.high,
        if (item.group != null) 'group': item.group,
        if (item.lowColor != null) 'lowColor': colorHex(item.lowColor!),
        if (item.highColor != null) 'highColor': colorHex(item.highColor!),
      },
  ];
}

List<Map<String, dynamic>> simpleErrorBarDataJson(
  List<SimpleErrorBarData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        'lower': item.lower,
        'upper': item.upper,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleForestPlotDataJson(
  List<SimpleForestPlotData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'estimate': item.estimate,
        'lower': item.lower,
        'upper': item.upper,
        if (item.weight != null) 'weight': item.weight,
        if (item.group != null) 'group': item.group,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleDotPlotSeriesJson(
  List<SimpleDotPlotSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleLikertCategoriesJson(
  List<SimpleLikertCategory> categories,
) {
  return [
    for (final item in categories)
      {
        'label': item.label,
        'sentiment': item.sentiment.name,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleLikertItemsJson(List<SimpleLikertItem> items) {
  return [
    for (final item in items)
      {
        'label': item.label,
        'values': item.values,
        if (item.group != null) 'group': item.group,
      },
  ];
}

List<Map<String, dynamic>> simpleBumpSeriesJson(List<SimpleBumpSeries> series) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'ranks': item.ranks,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleTimelineEventsJson(
  List<SimpleTimelineEvent> events,
) {
  return [
    for (final event in events)
      {
        'date': simpleDateJson(event.date),
        'title': event.title,
        if (event.description != null) 'description': event.description,
        if (event.tag != null) 'tag': event.tag,
        if (event.color != null) 'color': colorHex(event.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleMilestonesJson(
  List<SimpleMilestoneData> milestones,
) {
  return [
    for (final item in milestones)
      {
        'date': simpleDateJson(item.date),
        'label': item.label,
        if (item.description != null) 'description': item.description,
        if (item.tag != null) 'tag': item.tag,
        'status': item.status.name,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleEventStripLanesJson(
  List<SimpleEventStripLane> lanes,
) {
  return [
    for (final lane in lanes)
      {
        'label': lane.label,
        'events': [
          for (final event in lane.events)
            {
              'date': simpleDateJson(event.date),
              'label': event.label,
              if (event.description != null) 'description': event.description,
              if (event.tag != null) 'tag': event.tag,
              'weight': event.weight,
              if (event.color != null) 'color': colorHex(event.color!),
            },
        ],
        if (lane.color != null) 'color': colorHex(lane.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleGanttTasksJson(List<SimpleGanttTask> tasks) {
  return [
    for (final task in tasks)
      {
        'id': task.id,
        'label': task.label,
        'start': simpleDateJson(task.start),
        'end': simpleDateJson(task.end),
        'progress': task.progress,
        if (task.group != null) 'group': task.group,
        if (task.dependencies.isNotEmpty) 'dependencies': task.dependencies,
        'isMilestone': task.isMilestone,
        if (task.color != null) 'color': colorHex(task.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleSlopeDataJson(
  List<SimpleSlopeChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'start': item.start,
        'end': item.end,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simplePopulationPyramidDataJson(
  List<SimplePopulationPyramidData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'leftValue': item.leftValue,
        'rightValue': item.rightValue,
        if (item.leftColor != null) 'leftColor': colorHex(item.leftColor!),
        if (item.rightColor != null) 'rightColor': colorHex(item.rightColor!),
      },
  ];
}

List<Map<String, dynamic>> simpleWaffleDataJson(
  List<SimpleWaffleChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleDotDensityDataJson(
  List<SimpleDotDensityChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simplePictogramDataJson(
  List<SimplePictogramChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simplePackedBubbleDataJson(
  List<SimplePackedBubbleData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleTernaryPointsJson(
  List<SimpleTernaryPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'a': point.a,
        'b': point.b,
        'c': point.c,
        if (point.size != null) 'size': point.size,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleWordCloudDataJson(
  List<SimpleWordCloudData> words,
) {
  return [
    for (final word in words)
      {
        'text': word.text,
        'value': word.value,
        if (word.group != null) 'group': word.group,
        if (word.color != null) 'color': colorHex(word.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleVennSetsJson(List<SimpleVennSet> sets) {
  return [
    for (final set in sets)
      {
        'id': set.id,
        'label': set.label,
        'value': set.value,
        if (set.color != null) 'color': colorHex(set.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleVennIntersectionsJson(
  List<SimpleVennIntersection> intersections,
) {
  return [
    for (final intersection in intersections)
      {
        'setIds': intersection.setIds,
        'value': intersection.value,
        if (intersection.label != null) 'label': intersection.label,
        if (intersection.color != null) 'color': colorHex(intersection.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleUpsetSetsJson(List<SimpleUpsetSet> sets) {
  return [
    for (final set in sets)
      {
        'id': set.id,
        'label': set.label,
        if (set.value != null) 'value': set.value,
        if (set.color != null) 'color': colorHex(set.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleUpsetIntersectionsJson(
  List<SimpleUpsetIntersection> intersections,
) {
  return [
    for (final intersection in intersections)
      {
        'setIds': intersection.setIds,
        'value': intersection.value,
        if (intersection.label != null) 'label': intersection.label,
        if (intersection.color != null) 'color': colorHex(intersection.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleTreemapDataJson(List<SimpleTreemapData> data) {
  return [for (final item in data) simpleTreemapNodeJson(item)];
}

Map<String, dynamic> simpleTreemapNodeJson(SimpleTreemapData item) {
  return {
    'label': item.label,
    'value': item.value,
    if (item.children.isNotEmpty)
      'children': simpleTreemapDataJson(item.children),
    if (item.color != null) 'color': colorHex(item.color!),
  };
}

List<Map<String, dynamic>> simpleSunburstDataJson(
  List<SimpleSunburstData> data,
) {
  return [for (final item in data) simpleSunburstNodeJson(item)];
}

Map<String, dynamic> simpleSunburstNodeJson(SimpleSunburstData item) {
  return {
    'label': item.label,
    'value': item.value,
    if (item.children.isNotEmpty)
      'children': simpleSunburstDataJson(item.children),
    if (item.color != null) 'color': colorHex(item.color!),
  };
}

List<Map<String, dynamic>> simpleIcicleDataJson(List<SimpleIcicleData> data) {
  return [for (final item in data) simpleIcicleNodeJson(item)];
}

Map<String, dynamic> simpleIcicleNodeJson(SimpleIcicleData item) {
  return {
    'label': item.label,
    'value': item.value,
    if (item.children.isNotEmpty)
      'children': simpleIcicleDataJson(item.children),
    if (item.color != null) 'color': colorHex(item.color!),
  };
}

List<Map<String, dynamic>> simpleTreeDiagramDataJson(
  List<SimpleTreeDiagramData> data,
) {
  return [for (final item in data) simpleTreeDiagramNodeJson(item)];
}

Map<String, dynamic> simpleTreeDiagramNodeJson(SimpleTreeDiagramData item) {
  return {
    'label': item.label,
    'value': item.value,
    if (item.children.isNotEmpty)
      'children': simpleTreeDiagramDataJson(item.children),
    if (item.color != null) 'color': colorHex(item.color!),
  };
}

List<Map<String, dynamic>> simpleMarimekkoSeriesJson(
  List<SimpleMarimekkoSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleMosaicPlotCellsJson(
  List<SimpleMosaicPlotCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'xLabel': cell.xLabel,
        'yLabel': cell.yLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleHeatmapCellsJson(
  List<SimpleHeatmapCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'xLabel': cell.xLabel,
        'yLabel': cell.yLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

List<Map<String, dynamic>> simplePunchCardCellsJson(
  List<SimplePunchCardCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'xLabel': cell.xLabel,
        'yLabel': cell.yLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRadialHeatmapCellsJson(
  List<SimpleRadialHeatmapCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'ringLabel': cell.ringLabel,
        'segmentLabel': cell.segmentLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleCorrelationCellsJson(
  List<SimpleCorrelationCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'xLabel': cell.xLabel,
        'yLabel': cell.yLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleScatterMatrixPointsJson(
  List<SimpleScatterPlotMatrixPoint> points,
) {
  return [
    for (final point in points)
      {
        if (point.label != null) 'label': point.label,
        'values': point.values,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleTileMapDataJson(List<SimpleTileMapData> data) {
  return [
    for (final item in data)
      {
        'label': item.label,
        if (item.code != null) 'code': item.code,
        'value': item.value,
        'row': item.row,
        'column': item.column,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleHexbinPointsJson(
  List<SimpleHexbinPoint> points,
) {
  return [
    for (final point in points)
      {
        if (point.label != null) 'label': point.label,
        'x': point.x,
        'y': point.y,
        'weight': point.weight,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleContinuousHeatmapPointsJson(
  List<SimpleContinuousHeatmapPoint> points,
) {
  return [
    for (final point in points)
      {
        if (point.label != null) 'label': point.label,
        'x': point.x,
        'y': point.y,
        'weight': point.weight,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleVoronoiSitesJson(
  List<SimpleVoronoiSite> sites,
) {
  return [
    for (final site in sites)
      {
        'label': site.label,
        'x': site.x,
        'y': site.y,
        if (site.value != null) 'value': site.value,
        if (site.group != null) 'group': site.group,
        if (site.color != null) 'color': colorHex(site.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleContourPointsJson(
  List<SimpleContourPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'x': point.x,
        'y': point.y,
        'value': point.value,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleParallelAxesJson(
  List<SimpleParallelAxis> axes,
) {
  return [
    for (final axis in axes)
      {
        'label': axis.label,
        if (axis.min != null) 'min': axis.min,
        if (axis.max != null) 'max': axis.max,
        'inverted': axis.inverted,
        if (axis.color != null) 'color': colorHex(axis.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleParallelSeriesJson(
  List<SimpleParallelSeries> series,
) {
  return [
    for (final item in series)
      {
        'label': item.label,
        'values': item.values,
        if (item.group != null) 'group': item.group,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleCalendarHeatmapDataJson(
  List<SimpleCalendarHeatmapData> data,
) {
  return [
    for (final item in data)
      {
        'date': simpleDateJson(item.date),
        'value': item.value,
        if (item.label != null) 'label': item.label,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleDensitySeriesJson(
  List<SimpleDensitySeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRaincloudDataJson(
  List<SimpleRaincloudChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleEcdfSeriesJson(List<SimpleEcdfSeries> series) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleQQPlotSeriesJson(
  List<SimpleQQPlotSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'sampleValues': item.sampleValues,
        if (item.referenceValues.isNotEmpty)
          'referenceValues': item.referenceValues,
        'referenceDistribution': item.referenceDistribution.name,
        if (item.referenceName != null) 'referenceName': item.referenceName,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleLorenzSeriesJson(
  List<SimpleLorenzSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.weights.isNotEmpty) 'weights': item.weights,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBlandAltmanPointsJson(
  List<SimpleBlandAltmanPoint> points,
) {
  return [
    for (final point in points)
      {
        'label': point.label,
        'measurementA': point.measurementA,
        'measurementB': point.measurementB,
        if (point.group != null) 'group': point.group,
        if (point.color != null) 'color': colorHex(point.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBoxPlotDataJson(List<SimpleBoxPlotData> data) {
  return [
    for (final item in data)
      {
        'label': item.label,
        if (item.values.isNotEmpty) 'values': item.values,
        if (item.min != null) 'min': item.min,
        if (item.q1 != null) 'q1': item.q1,
        if (item.median != null) 'median': item.median,
        if (item.q3 != null) 'q3': item.q3,
        if (item.max != null) 'max': item.max,
        if (item.mean != null) 'mean': item.mean,
        if (item.outliers.isNotEmpty) 'outliers': item.outliers,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBoxenPlotDataJson(
  List<SimpleBoxenPlotData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleViolinDataJson(
  List<SimpleViolinChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRidgelineDataJson(
  List<SimpleRidgelineChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRugPlotSeriesJson(
  List<SimpleRugPlotSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBarcodePlotSeriesJson(
  List<SimpleBarcodePlotSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleStripPlotDataJson(
  List<SimpleStripPlotData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleSinaPlotDataJson(
  List<SimpleSinaPlotData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBeeswarmDataJson(
  List<SimpleBeeswarmData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBulletDataJson(
  List<SimpleBulletChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        'target': item.target,
        if (item.minValue != null) 'minValue': item.minValue,
        if (item.maxValue != null) 'maxValue': item.maxValue,
        if (item.color != null) 'color': colorHex(item.color!),
        if (item.targetColor != null)
          'targetColor': colorHex(item.targetColor!),
        if (item.ranges.isNotEmpty)
          'ranges': [
            for (final range in item.ranges) simpleBulletRangeJson(range),
          ],
      },
  ];
}

Map<String, dynamic> simpleBulletRangeJson(SimpleBulletRange range) {
  return {
    'from': range.from,
    'to': range.to,
    if (range.label != null) 'label': range.label,
    if (range.color != null) 'color': colorHex(range.color!),
  };
}

List<Map<String, dynamic>> simpleGaugeRangeJson(List<SimpleGaugeRange> ranges) {
  return [
    for (final range in ranges)
      {
        'from': range.from,
        'to': range.to,
        if (range.label != null) 'label': range.label,
        if (range.color != null) 'color': colorHex(range.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRadialBarDataJson(
  List<SimpleRadialBarChartData> data,
) {
  return [
    for (final item in data)
      {
        'label': item.label,
        'value': item.value,
        'maxValue': item.maxValue,
        if (item.targetValue != null) 'targetValue': item.targetValue,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleRadarAxesJson(List<SimpleRadarAxis> axes) {
  return [
    for (final axis in axes)
      {
        'label': axis.label,
        'minValue': axis.minValue,
        'maxValue': axis.maxValue,
      },
  ];
}

List<Map<String, dynamic>> simpleRadarSeriesJson(
  List<SimpleRadarSeries> series,
) {
  return [
    for (final item in series)
      {
        'name': item.name,
        'values': item.values,
        if (item.color != null) 'color': colorHex(item.color!),
      },
  ];
}

List<Map<String, dynamic>> simpleBubbleMatrixCellsJson(
  List<SimpleBubbleMatrixCell> cells,
) {
  return [
    for (final cell in cells)
      {
        'xLabel': cell.xLabel,
        'yLabel': cell.yLabel,
        'value': cell.value,
        if (cell.label != null) 'label': cell.label,
        if (cell.color != null) 'color': colorHex(cell.color!),
      },
  ];
}

String simpleDateJson(DateTime date) => date.toIso8601String().split('T').first;

String colorHex(Color color) {
  final value = color.toARGB32();
  return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
