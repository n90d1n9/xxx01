/// Registration bundle for all advanced charts.
///
/// Call [advancedChartsBundle.register()] in main() to include all
/// advanced chart types in [ChartRegistry] (and in the compiled binary).
///
/// Or register selectively:
/// ```dart
/// ChartRegistry.register(sunburstRegistration);
/// ChartRegistry.register(funnelRegistration);
/// ```
///
/// JSON examples for each chart type are provided as inline docs below.
library chart_registration_bundle;

import 'sunburst_chart.dart';
import 'funnel_chart.dart';
import 'sankey_chart.dart';
import 'waterfall_chart.dart';
import 'gauge_chart.dart';
import 'radar_chart.dart';
import 'gantt_chart.dart';
import 'polar_bar_chart.dart';

import '../core/config/chart_registry.dart';
import '../core/config/chart_type.dart';

// ─────────────────────────────────────────────────────────
// Individual registrations
// ─────────────────────────────────────────────────────────

/// Sunburst — multi-ring radial hierarchy with drill-down.
///
/// ```json
/// { "type": "sunburst", "centerText": "Sales",
///   "series": [{ "data": [
///     { "name": "A", "value": 60, "children": [
///         { "name": "A1", "value": 40 }, { "name": "A2", "value": 20 }
///     ]},
///     { "name": "B", "value": 40 }
///   ]}]
/// }
/// ```
final sunburstRegistration = ChartRegistration(
  type: ChartType.sunburst,
  typeString: 'sunburst',
  fromJson: SunburstChartConfig.fromJson,
  description: 'Multi-ring radial hierarchy with drill-down',
  tags: ['hierarchical', 'radial', 'advanced'],
);

/// Funnel — tapering conversion stages.
///
/// ```json
/// { "type": "funnel", "showPercentage": true,
///   "series": [{ "data": [
///     { "name": "Visits", "value": 10000 },
///     { "name": "Leads",  "value": 4200  },
///     { "name": "Closed", "value": 420   }
///   ]}]
/// }
/// ```
final funnelRegistration = ChartRegistration(
  type: ChartType.funnel,
  typeString: 'funnel',
  aliases: ['pyramid'],
  fromJson: FunnelChartConfig.fromJson,
  description: 'Conversion funnel / pipeline chart',
  tags: ['flow', 'conversion', 'basic'],
);

/// Sankey — directional flow with proportional link widths.
///
/// ```json
/// { "type": "sankey",
///   "series": [{ "nodes": [
///     { "id": "A", "name": "Revenue" },
///     { "id": "B", "name": "COGS"    },
///     { "id": "C", "name": "GP"      }
///   ], "links": [
///     { "source": "A", "target": "B", "value": 300 },
///     { "source": "A", "target": "C", "value": 700 }
///   ]}]
/// }
/// ```
final sankeyRegistration = ChartRegistration(
  type: ChartType.sankey,
  typeString: 'sankey',
  fromJson: SankeyChartConfig.fromJson,
  description: 'Directional flow diagram with proportional link widths',
  tags: ['flow', 'advanced', 'network'],
);

/// Waterfall — cumulative bar chart showing incremental changes.
///
/// ```json
/// { "type": "waterfall",
///   "series": [{ "data": [
///     { "name": "Opening", "value": 500,  "type": "total" },
///     { "name": "Revenue", "value": 320  },
///     { "name": "Returns", "value": -80  },
///     { "name": "Closing", "value": 740,  "type": "total" }
///   ]}]
/// }
/// ```
final waterfallRegistration = ChartRegistration(
  type: ChartType.waterfall,
  typeString: 'waterfall',
  aliases: ['bridge', 'cascade'],
  fromJson: WaterfallChartConfig.fromJson,
  description: 'Bridge / waterfall chart for cumulative variance analysis',
  tags: ['statistical', 'financial', 'basic'],
);

/// Gauge — speedometer arc with bands and animated needle.
///
/// ```json
/// { "type": "gauge", "value": 72, "min": 0, "max": 100,
///   "label": "Score", "unit": "%",
///   "bands": [
///     { "from": 0,  "to": 40,  "color": "#F44336" },
///     { "from": 40, "to": 70,  "color": "#FF9800" },
///     { "from": 70, "to": 100, "color": "#4CAF50" }
///   ]
/// }
/// ```
final gaugeRegistration = ChartRegistration(
  type: ChartType.gauge,
  typeString: 'gauge',
  aliases: ['speedometer', 'meter'],
  fromJson: GaugeChartConfig.fromJson,
  description: 'Arc gauge / speedometer with qualitative bands and needle',
  tags: ['radial', 'kpi', 'basic'],
);

/// Radar — spider/web chart for multi-axis comparison.
///
/// ```json
/// { "type": "radar",
///   "axes": [
///     { "name": "Speed",   "max": 100 },
///     { "name": "Power",   "max": 100 },
///     { "name": "Agility", "max": 100 }
///   ],
///   "series": [
///     { "name": "Unit A", "data": [80, 65, 90] },
///     { "name": "Unit B", "data": [40, 85, 60] }
///   ]
/// }
/// ```
final radarRegistration = ChartRegistration(
  type: ChartType.radar,
  typeString: 'radar',
  aliases: ['spider', 'web'],
  fromJson: RadarChartConfig.fromJson,
  description: 'Spider/web chart for multi-dimensional comparison',
  tags: ['radial', 'statistical', 'basic'],
);

/// Gantt — horizontal timeline with tasks, milestones and dependencies.
///
/// ```json
/// { "type": "gantt",
///   "series": [{ "data": [
///     { "id":"t1", "name":"Research", "start":"2024-01-01", "end":"2024-01-15", "progress":100 },
///     { "id":"t2", "name":"Design",   "start":"2024-01-10", "end":"2024-02-01", "deps":["t1"] },
///     { "id":"m1", "name":"Launch",   "start":"2024-04-01", "milestone":true }
///   ]}]
/// }
/// ```
final ganttRegistration = ChartRegistration(
  type: ChartType.gantt,
  typeString: 'gantt',
  aliases: ['timeline', 'schedule'],
  fromJson: GanttChartConfig.fromJson,
  description: 'Gantt chart with milestones, dependencies and progress fill',
  tags: ['timeline', 'project', 'advanced'],
);

/// PolarBar — rose / nightingale chart with radial bars.
///
/// ```json
/// { "type": "polarBar",
///   "categories": ["Jan","Feb","Mar","Apr","May","Jun"],
///   "series": [{ "name": "Revenue", "data": [120, 200, 150, 80, 170, 110] }]
/// }
/// ```
final polarBarRegistration = ChartRegistration(
  type: ChartType.polarBar,
  typeString: 'polarBar',
  aliases: ['rose', 'nightingale', 'coxcomb'],
  fromJson: PolarBarChartConfig.fromJson,
  description: 'Polar bar / nightingale rose chart',
  tags: ['radial', 'categorical', 'basic'],
);

// ─────────────────────────────────────────────────────────
// Bundle
// ─────────────────────────────────────────────────────────

/// All advanced charts in one registration bundle.
///
/// ```dart
/// void main() {
///   advancedChartsBundle.register();
///   runApp(const MyApp());
/// }
/// ```
final advancedChartsBundle = RegistrationBundle(
  name: 'advanced',
  description: 'Sunburst, Funnel, Sankey, Waterfall, Gauge, Radar, Gantt, PolarBar',
  registrations: [
    sunburstRegistration,
    funnelRegistration,
    sankeyRegistration,
    waterfallRegistration,
    gaugeRegistration,
    radarRegistration,
    ganttRegistration,
    polarBarRegistration,
  ],
);
