import 'chart_showcase_tier.dart';

export 'chart_showcase_tier.dart';

class ChartShowcaseSample {
  final String title;
  final double height;
  final Map<String, dynamic> json;
  final String? code;

  const ChartShowcaseSample(this.title, this.height, this.json, {this.code});
}

class ChartShowcaseFamily {
  final String id;
  final String title;
  final String description;
  final ChartShowcaseTier tier;
  final List<ChartShowcaseSample> samples;

  const ChartShowcaseFamily({
    required this.id,
    required this.title,
    required this.description,
    this.tier = ChartShowcaseTier.core,
    required this.samples,
  });

  int get sampleCount => samples.length;

  String get tierLabel => tier.label;

  Iterable<String> get chartTypes sync* {
    for (final sample in samples) {
      final type = sample.json['type'];
      if (type is String && type.isNotEmpty) {
        yield type;
      }
    }
  }

  List<String> get uniqueChartTypes =>
      chartTypes.toSet().toList(growable: false);
}

List<ChartShowcaseFamily> chartShowcaseFamiliesForTier(
  Iterable<ChartShowcaseFamily> families,
  ChartShowcaseTierFilter tierFilter,
) {
  return families
      .where((family) => tierFilter.includes(family.tier))
      .toList(growable: false);
}

Map<String, int> chartShowcaseFamilyTierCounts(
  Iterable<ChartShowcaseFamily> families,
) {
  final counts = <String, int>{};
  for (final family in families) {
    counts.update(family.tier.key, (count) => count + 1, ifAbsent: () => 1);
  }
  return Map.unmodifiable(counts);
}

class ChartSamplesRegistry {
  static const Map<String, dynamic> gauge = {
    'type': 'gauge',
    'title': {'text': 'Gauge'},
    'value': 72,
    'min': 0,
    'max': 100,
    'unit': '%',
    'bands': [
      {'from': 0, 'to': 40, 'color': '#F44336'},
      {'from': 40, 'to': 70, 'color': '#FF9800'},
      {'from': 70, 'to': 100, 'color': '#4CAF50'},
    ],
  };

  static const Map<String, dynamic> radar = {
    'type': 'radar',
    'title': {'text': 'Radar'},
    'axes': [
      {'name': 'Speed', 'max': 100},
      {'name': 'Power', 'max': 100},
      {'name': 'Range', 'max': 100},
      {'name': 'Defense', 'max': 100},
      {'name': 'Agility', 'max': 100},
    ],
    'legend': {'show': true},
    'series': [
      {
        'name': 'Unit A',
        'data': [80, 65, 55, 70, 90],
        'color': '#1E88E5',
      },
      {
        'name': 'Unit B',
        'data': [40, 85, 70, 50, 60],
        'color': '#43A047',
      },
    ],
  };

  static const Map<String, dynamic> funnel = {
    'type': 'funnel',
    'title': {'text': 'Funnel'},
    'showPercentage': true,
    'series': [
      {
        'data': [
          {'name': 'Visits', 'value': 10000},
          {'name': 'Leads', 'value': 6200},
          {'name': 'Prospects', 'value': 3100},
          {'name': 'Qualified', 'value': 1400},
          {'name': 'Closed', 'value': 420},
        ],
      },
    ],
  };

  static const Map<String, dynamic> waterfall = {
    'type': 'waterfall',
    'title': {'text': 'Waterfall'},
    'series': [
      {
        'data': [
          {'name': 'Opening', 'value': 500, 'type': 'total'},
          {'name': 'Revenue', 'value': 320},
          {'name': 'Returns', 'value': -80},
          {'name': 'OpEx', 'value': -150},
          {'name': 'Tax', 'value': -45},
          {'name': 'Closing', 'value': 545, 'type': 'total'},
        ],
      },
    ],
  };

  static const Map<String, dynamic> sankey = {
    'type': 'sankey',
    'title': {'text': 'Sankey'},
    'series': [
      {
        'nodes': [
          {'id': 'visits', 'name': 'Visits', 'column': 0},
          {'id': 'organic', 'name': 'Organic', 'column': 0},
          {'id': 'product', 'name': 'Product', 'column': 1},
          {'id': 'checkout', 'name': 'Checkout', 'column': 2},
          {'id': 'purchase', 'name': 'Purchase', 'column': 2},
        ],
        'links': [
          {'source': 'visits', 'target': 'product', 'value': 5000},
          {'source': 'organic', 'target': 'product', 'value': 3000},
          {'source': 'product', 'target': 'checkout', 'value': 4200},
          {'source': 'product', 'target': 'purchase', 'value': 1200},
          {'source': 'checkout', 'target': 'purchase', 'value': 3800},
        ],
      },
    ],
  };

  static const Map<String, dynamic> sunburst = {
    'type': 'sunburst',
    'title': {'text': 'Sunburst'},
    'series': [
      {
        'data': [
          {
            'name': 'Product A',
            'value': 40,
            'children': [
              {'name': 'Online', 'value': 28},
              {'name': 'Offline', 'value': 12},
            ],
          },
          {
            'name': 'Product B',
            'value': 35,
            'children': [
              {'name': 'Online', 'value': 20},
              {'name': 'Offline', 'value': 15},
            ],
          },
          {'name': 'Product C', 'value': 25},
        ],
      },
    ],
  };

  static const Map<String, dynamic> treemap = {
    'type': 'treemap',
    'title': {'text': 'Treemap'},
    'series': [
      {
        'data': [
          {
            'name': 'Tech',
            'value': 45,
            'children': [
              {'name': 'AAPL', 'value': 20},
              {'name': 'GOOGL', 'value': 15},
              {'name': 'MSFT', 'value': 10},
            ],
          },
          {'name': 'Finance', 'value': 30},
          {'name': 'Healthcare', 'value': 25},
        ],
      },
    ],
  };

  static const Map<String, dynamic> gantt = {
    'type': 'gantt',
    'title': {'text': 'Gantt'},
    'series': [
      {
        'data': [
          {
            'id': 't1',
            'name': 'Research',
            'start': '2026-01-01',
            'end': '2026-01-15',
            'progress': 100,
          },
          {
            'id': 't2',
            'name': 'Design',
            'start': '2026-01-10',
            'end': '2026-02-01',
            'progress': 80,
            'deps': ['t1'],
          },
          {
            'id': 't3',
            'name': 'Build',
            'start': '2026-02-01',
            'end': '2026-03-10',
            'progress': 40,
            'deps': ['t2'],
          },
          {
            'id': 't4',
            'name': 'QA',
            'start': '2026-03-01',
            'end': '2026-03-20',
            'progress': 10,
            'deps': ['t3'],
          },
          {
            'id': 'ms1',
            'name': 'Launch',
            'start': '2026-03-25',
            'milestone': true,
          },
        ],
      },
    ],
  };

  static const Map<String, dynamic> polarBar = {
    'type': 'polarBar',
    'title': {'text': 'Polar Bar'},
    'categories': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'series': [
      {
        'name': 'Revenue',
        'data': [120, 200, 150, 80, 170, 110],
        'color': '#1E88E5',
      },
      {
        'name': 'Cost',
        'data': [60, 90, 70, 50, 80, 55],
        'color': '#F4511E',
      },
    ],
  };

  static const Map<String, dynamic> radial = {
    'type': 'radial',
    'title': {'text': 'KPI Rings'},
    'series': [
      {
        'data': [
          {'label': 'Revenue', 'value': 78, 'max': 100, 'color': '#1E88E5'},
          {'label': 'Retention', 'value': 64, 'max': 100, 'color': '#43A047'},
          {'label': 'NPS', 'value': 52, 'max': 100, 'color': '#FB8C00'},
        ],
      },
    ],
  };

  static const Map<String, dynamic> choropleth = {
    'type': 'choropleth',
    'title': {'text': 'Simple Choropleth'},
    'series': [
      {
        'regions': [
          {
            'id': 'A',
            'name': 'Region A',
            'value': 50,
            'polygon': [
              [-125, 49],
              [-95, 49],
              [-95, 25],
              [-125, 25],
            ],
          },
          {
            'id': 'B',
            'name': 'Region B',
            'value': 80,
            'polygon': [
              [-95, 49],
              [-67, 49],
              [-67, 25],
              [-95, 25],
            ],
          },
        ],
      },
    ],
  };

  static const Map<String, dynamic> timeline = {
    'type': 'timeline',
    'title': {'text': 'Product Timeline'},
    'series': [
      {
        'data': [
          {'date': '2026-01-04', 'label': 'Discovery'},
          {'date': '2026-01-18', 'label': 'Design Complete'},
          {'date': '2026-02-06', 'label': 'MVP Build'},
          {'date': '2026-02-24', 'label': 'Beta Test'},
          {'date': '2026-03-12', 'label': 'Launch'},
        ],
      },
    ],
  };

  static const Map<String, dynamic> wordcloud = {
    'type': 'wordcloud',
    'title': {'text': 'Search Terms'},
    'series': [
      {
        'data': [
          {'text': 'Flutter', 'weight': 95},
          {'text': 'Dart', 'weight': 80},
          {'text': 'Charts', 'weight': 70},
          {'text': 'Mobile', 'weight': 55},
          {'text': 'Analytics', 'weight': 48},
          {'text': 'KPI', 'weight': 44},
        ],
      },
    ],
  };

  static const Map<String, dynamic> calendar = {
    'type': 'calendar',
    'title': {'text': 'Daily Activity'},
    'year': 2026,
    'month': 3,
    'series': [
      {
        'data': [
          {'date': '2026-03-01', 'value': 4},
          {'date': '2026-03-02', 'value': 8},
          {'date': '2026-03-03', 'value': 3},
          {'date': '2026-03-04', 'value': 9},
        ],
      },
    ],
  };

  static const Map<String, dynamic> confusionMatrix = {
    'type': 'confusionMatrix',
    'title': {'text': 'Digit Classifier (MNIST)'},
    'labels': ['0', '1', '2', '3', '4'],
    'data': [
      [980, 0, 5, 2, 3],
      [0, 1110, 2, 8, 0],
      [12, 10, 890, 20, 5],
      [5, 8, 30, 920, 10],
      [2, 0, 5, 10, 950],
    ],
    'baseColor': '#4CAF50',
  };

  static const Map<String, dynamic> rocCurve = {
    'type': 'rocCurve',
    'title': {'text': 'Model Comparison'},
    'series': [
      {
        'name': 'Random Forest',
        'color': '#2196F3',
        'data': [
          [0.0, 0.0],
          [0.1, 0.4],
          [0.2, 0.7],
          [0.4, 0.85],
          [0.6, 0.92],
          [0.8, 0.98],
          [1.0, 1.0],
        ],
      },
      {
        'name': 'Logistic Regression',
        'color': '#F44336',
        'data': [
          [0.0, 0.0],
          [0.1, 0.3],
          [0.3, 0.6],
          [0.5, 0.75],
          [0.7, 0.85],
          [1.0, 1.0],
        ],
      },
    ],
  };

  static const Map<String, dynamic> sCurve = {
    'type': 'sCurve',
    'title': {'text': 'Software Development Lifecycle'},
    'targetValue': 100,
    'series': [
      {
        'name': 'Planned',
        'data': [5, 10, 15, 20, 25, 15, 10],
        'color': '#A0A0A0',
      },
      {
        'name': 'Actual',
        'data': [4, 12, 18, 22],
        'color': '#4A90E2',
      },
    ],
  };

  static const Map<String, dynamic> businessPareto = {
    'type': 'pareto',
    'title': {'text': 'Customer Complaints by Category'},
    'xAxis': {
      'data': ['Shipping', 'Price', 'Quality', 'Support', 'Website', 'Other'],
    },
    'series': [
      {
        'name': 'Frequency',
        'data': [120, 45, 180, 60, 20, 10],
        'color': '#5470C6',
      },
    ],
    'lineIndicatorColor': '#EE6666',
  };

  static const Map<String, dynamic> revenueIndicator = {
    'type': 'indicator',
    'label': 'Total Revenue',
    'value': 1250400,
    'previousValue': 1180200,
    'unit': '\$',
    'precision': 0,
  };

  static const Map<String, dynamic> usersIndicator = {
    'type': 'indicator',
    'label': 'Active Users',
    'value': 8420,
    'previousValue': 9100,
    'precision': 0,
  };

  static const Map<String, dynamic> combo = {
    'type': 'combo',
    'title': {'text': 'Quarterly Revenue + Margin'},
    'categories': ['Q1', 'Q2', 'Q3', 'Q4'],
    'series': [
      {
        'name': 'Revenue',
        'seriesType': 'bar',
        'data': [820, 930, 1140, 1300],
      },
      {
        'name': 'Cost',
        'seriesType': 'bar',
        'data': [600, 680, 790, 960],
      },
      {
        'name': 'Margin %',
        'seriesType': 'line',
        'yAxis': 1,
        'data': [27, 27, 31, 26],
      },
    ],
  };

  static const Map<String, dynamic> bullet = {
    'type': 'bullet',
    'title': {'text': 'KPI Progress'},
    'series': [
      {
        'data': [
          {
            'label': 'Revenue',
            'value': 270,
            'target': 300,
            'max': 400,
            'bands': [
              {'to': 200, 'color': '#F44336'},
              {'to': 280, 'color': '#FF9800'},
              {'to': 400, 'color': '#4CAF50'},
            ],
          },
          {'label': 'Margin', 'value': 23, 'target': 25, 'max': 35},
          {'label': 'Users', 'value': 1850, 'target': 2000, 'max': 2500},
        ],
      },
    ],
  };

  static const Map<String, dynamic> histogram = {
    'type': 'histogram',
    'title': {'text': 'Response Time Distribution'},
    'bins': 12,
    'showKDE': true,
    'series': [
      {
        'name': 'Latency',
        'data': [
          120,
          145,
          98,
          210,
          175,
          132,
          88,
          156,
          201,
          134,
          167,
          99,
          143,
          188,
          120,
          155,
        ],
      },
    ],
  };

  static const Map<String, dynamic> lollipop = {
    'type': 'lollipop',
    'title': {'text': 'Weekly Throughput'},
    'categories': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    'series': [
      {
        'name': 'Actual',
        'data': [42, 67, 55, 80, 73],
      },
      {
        'name': 'Target',
        'data': [60, 60, 60, 60, 60],
      },
    ],
  };

  static const Map<String, dynamic> sparkline = {
    'type': 'sparkline',
    'sparklineType': 'area',
    'showHighLow': true,
    'series': [
      {
        'data': [42, 55, 38, 67, 72, 58, 81],
      },
    ],
  };

  static const Map<String, dynamic> kagi = {
    'type': 'kagi',
    'title': {'text': 'Kagi'},
    'reversalPct': 4,
    'series': [
      {
        'data': [150, 152, 148, 155, 151, 160, 158, 165, 162, 170],
      },
    ],
  };

  static const Map<String, dynamic> renko = {
    'type': 'renko',
    'title': {'text': 'Renko'},
    'brickSize': 2,
    'series': [
      {
        'data': [100, 101, 103, 106, 104, 108, 107, 112, 110, 115],
      },
    ],
  };

  static const Map<String, dynamic> macd = {
    'type': 'macd',
    'title': {'text': 'MACD'},
    'fast': 12,
    'slow': 26,
    'signal': 9,
    'series': [
      {
        'data': [
          150,
          151,
          153,
          149,
          152,
          158,
          155,
          162,
          160,
          165,
          163,
          170,
          168,
          172,
          176,
          174,
          180,
          183,
          181,
          186,
          189,
          192,
          194,
          197,
          196,
          200,
          203,
          206,
          208,
          211,
          210,
          214,
          216,
          219,
          221,
          224,
          226,
          229,
          231,
          233,
        ],
      },
    ],
  };

  static const Map<String, dynamic> ridgeline = {
    'type': 'ridgeline',
    'title': {'text': 'Ridgeline'},
    'categories': ['2021', '2022', '2023', '2024'],
    'series': [
      {
        'data': [
          [55, 62, 68, 72, 75, 80, 58, 61],
          [60, 65, 70, 73, 78, 82, 67, 71],
          [58, 66, 72, 76, 80, 85, 64, 69],
          [63, 70, 74, 79, 83, 88, 70, 74],
        ],
      },
    ],
  };

  static const Map<String, dynamic> strip = {
    'type': 'strip',
    'title': {'text': 'Strip'},
    'categories': ['Group A', 'Group B', 'Group C'],
    'series': [
      {
        'data': [
          [55, 60, 58, 72, 45, 68],
          [78, 82, 75, 88, 71, 80],
          [40, 52, 48, 61, 44, 56],
        ],
      },
    ],
  };

  static const Map<String, dynamic> errorBar = {
    'type': 'errorbar',
    'title': {'text': 'Error Bar'},
    'categories': ['Method A', 'Method B', 'Method C'],
    'series': [
      {
        'name': 'Accuracy',
        'data': [
          {'mean': 0.82, 'lower': 0.76, 'upper': 0.88},
          {'mean': 0.79, 'lower': 0.74, 'upper': 0.84},
          {'mean': 0.91, 'lower': 0.87, 'upper': 0.95},
        ],
      },
    ],
  };

  static const Map<String, dynamic> network = {
    'type': 'network',
    'title': {'text': 'Service Topology'},
    'series': [
      {
        'nodes': [
          {'id': 'A', 'name': 'Gateway', 'size': 20},
          {'id': 'B', 'name': 'Auth', 'size': 14},
          {'id': 'C', 'name': 'Billing', 'size': 14},
          {'id': 'D', 'name': 'DB', 'size': 16},
          {'id': 'E', 'name': 'Cache', 'size': 12},
        ],
        'links': [
          {'source': 'A', 'target': 'B', 'value': 5},
          {'source': 'A', 'target': 'C', 'value': 4},
          {'source': 'B', 'target': 'D', 'value': 3},
          {'source': 'C', 'target': 'D', 'value': 3},
          {'source': 'A', 'target': 'E', 'value': 2},
        ],
      },
    ],
  };

  static const Map<String, dynamic> statRadial = {
    'type': 'radial',
    'title': {'text': 'KPI Rings'},
    'series': [
      {
        'data': [
          {'label': 'Revenue', 'value': 78, 'max': 100, 'color': '#1E88E5'},
          {'label': 'Retention', 'value': 64, 'max': 100, 'color': '#43A047'},
          {'label': 'NPS', 'value': 52, 'max': 100, 'color': '#FB8C00'},
        ],
      },
    ],
  };

  static const Map<String, dynamic> statTimeline = {
    'type': 'timeline',
    'title': {'text': 'Product Timeline'},
    'series': [
      {
        'data': [
          {'date': '2026-01-04', 'label': 'Discovery'},
          {'date': '2026-01-18', 'label': 'Design Complete'},
          {'date': '2026-02-06', 'label': 'MVP Build'},
          {'date': '2026-02-24', 'label': 'Beta Test'},
          {'date': '2026-03-12', 'label': 'Launch'},
        ],
      },
    ],
  };

  static const Map<String, dynamic> statWordcloud = {
    'type': 'wordcloud',
    'title': {'text': 'Search Terms'},
    'series': [
      {
        'data': [
          {'text': 'Flutter', 'weight': 95},
          {'text': 'Dart', 'weight': 80},
          {'text': 'Charts', 'weight': 70},
          {'text': 'Mobile', 'weight': 55},
          {'text': 'Analytics', 'weight': 48},
          {'text': 'KPI', 'weight': 44},
          {'text': 'Dashboard', 'weight': 42},
          {'text': 'Realtime', 'weight': 35},
        ],
      },
    ],
  };

  static const Map<String, dynamic> statCalendar = {
    'type': 'calendar',
    'title': {'text': 'Activity Calendar'},
    'year': 2026,
    'series': [
      {
        'data': [
          {'date': '2026-01-05', 'value': 2},
          {'date': '2026-01-07', 'value': 4},
          {'date': '2026-01-11', 'value': 8},
          {'date': '2026-02-01', 'value': 6},
          {'date': '2026-02-13', 'value': 3},
          {'date': '2026-02-22', 'value': 7},
          {'date': '2026-03-01', 'value': 5},
        ],
      },
    ],
  };

  static const Map<String, dynamic> parallel = {
    'type': 'parallel',
    'title': {'text': 'Vehicle Comparison'},
    'axes': ['Price', 'Miles', 'HP', 'Weight', 'MPG'],
    'series': [
      {
        'name': 'Sedan',
        'data': [
          [25000, 45000, 150, 3200, 32],
          [32000, 12000, 180, 3500, 28],
          [28000, 26000, 165, 3300, 30],
        ],
      },
      {
        'name': 'SUV',
        'data': [
          [38000, 22000, 220, 4200, 22],
          [41000, 15000, 240, 4500, 20],
        ],
      },
    ],
  };

  static const Map<String, dynamic> violin = {
    'type': 'violin',
    'title': {'text': 'Score Distribution'},
    'categories': ['Control', 'Treatment A', 'Treatment B'],
    'series': [
      {
        'name': 'Score',
        'data': [
          [72, 68, 75, 80, 71, 69, 74],
          [85, 88, 79, 91, 87, 83, 90],
          [60, 65, 58, 62, 70, 55, 63],
        ],
      },
    ],
  };

  static const Map<String, dynamic> v3Choropleth = {
    'type': 'choropleth',
    'title': {'text': 'Simple Choropleth'},
    'series': [
      {
        'regions': [
          {
            'id': 'A',
            'name': 'Region A',
            'value': 50,
            'polygon': [
              [-125, 49],
              [-95, 49],
              [-95, 25],
              [-125, 25],
            ],
          },
          {
            'id': 'B',
            'name': 'Region B',
            'value': 80,
            'polygon': [
              [-95, 49],
              [-67, 49],
              [-67, 25],
              [-95, 25],
            ],
          },
        ],
      },
    ],
  };

  static const Map<String, dynamic> slope = {
    'type': 'slope',
    'title': {'text': 'Before vs After'},
    'categories': ['Team A', 'Team B', 'Team C', 'Team D'],
    'series': [
      {
        'name': 'Before',
        'data': [35, 52, 28, 61],
      },
      {
        'name': 'After',
        'data': [48, 47, 45, 58],
      },
    ],
  };

  static const Map<String, dynamic> dumbbell = {
    'type': 'dumbbell',
    'title': {'text': 'Actual vs Target'},
    'categories': ['Sales', 'Ops', 'CS', 'R&D'],
    'series': [
      {
        'name': 'Actual',
        'data': [72, 64, 81, 55],
      },
      {
        'name': 'Target',
        'data': [80, 70, 78, 60],
      },
    ],
  };

  static const Map<String, dynamic> areaBump = {
    'type': 'areaBump',
    'title': {'text': 'Ranking Flow'},
    'xLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
    'series': [
      {
        'name': 'Alpha',
        'ranks': [1, 2, 2, 3],
      },
      {
        'name': 'Beta',
        'ranks': [3, 1, 1, 1],
      },
      {
        'name': 'Gamma',
        'ranks': [2, 3, 3, 2],
      },
    ],
  };

  static const Map<String, dynamic> barRace = {
    'type': 'barRace',
    'title': {'text': 'Top Products'},
    'categories': ['A', 'B', 'C', 'D', 'E'],
    'frameLabels': ['2024', '2025', '2026'],
    'frames': [
      [120, 80, 65, 50, 45],
      [140, 95, 70, 56, 48],
      [160, 110, 77, 60, 55],
    ],
    'markers': {
      'A': {'text': 'A', 'backgroundColor': '#E6F4FF'},
      'B': {'text': 'B', 'backgroundColor': '#FFF7E6'},
      'C': {'text': 'C', 'backgroundColor': '#F6FFED'},
    },
    'autoPlay': false,
    'showControls': true,
    'showStepControls': true,
    'showProgressIndicator': true,
  };

  static const Map<String, dynamic> lineGradient = {
    'type': 'lineGradient',
    'title': {'text': 'Revenue Trend'},
    'xLabels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'series': [
      {
        'name': 'Revenue',
        'data': [40, 55, 48, 63, 72, 68],
      },
    ],
  };

  static const Map<String, dynamic> halfDonut = {
    'type': 'halfDonut',
    'title': {'text': 'Progress'},
    'value': 72,
    'max': 100,
  };

  static const Map<String, dynamic> rainfall = {
    'type': 'rainfall',
    'title': {'text': 'Monthly Rainfall'},
    'categories': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'series': [
      {
        'name': 'Rain',
        'data': [120, 98, 143, 167, 130, 155],
      },
      {
        'name': 'Avg Temp',
        'data': [27, 28, 29, 30, 29, 28],
      },
    ],
  };

  static const List<ChartShowcaseSample> aiML = [
    ChartShowcaseSample('Confusion Matrix', 400, confusionMatrix),
    ChartShowcaseSample('ROC Curve', 480, rocCurve),
  ];

  static const List<ChartShowcaseSample> businessProject = [
    ChartShowcaseSample('S-Curve (Project Progress)', 300, sCurve),
    ChartShowcaseSample('Pareto Chart (80/20 Analysis)', 350, businessPareto),
    ChartShowcaseSample('KPI Indicator: Revenue', 150, revenueIndicator),
    ChartShowcaseSample('KPI Indicator: Active Users', 150, usersIndicator),
  ];

  static const List<ChartShowcaseSample> statTradingGraph = [
    ChartShowcaseSample('Combo', 300, combo),
    ChartShowcaseSample('Bullet', 300, bullet),
    ChartShowcaseSample('Histogram', 300, histogram),
    ChartShowcaseSample('Lollipop', 300, lollipop),
    ChartShowcaseSample('Sparkline', 120, sparkline),
    ChartShowcaseSample('Kagi', 300, kagi),
    ChartShowcaseSample('Renko', 300, renko),
    ChartShowcaseSample('MACD', 320, macd),
    ChartShowcaseSample('Ridgeline', 320, ridgeline),
    ChartShowcaseSample('Strip', 320, strip),
    ChartShowcaseSample('Error Bar', 320, errorBar),
    ChartShowcaseSample('Network', 340, network),
    ChartShowcaseSample('Radial', 300, statRadial),
    ChartShowcaseSample('Timeline', 320, statTimeline),
    ChartShowcaseSample('Wordcloud', 320, statWordcloud),
    ChartShowcaseSample('Calendar', 240, statCalendar),
    ChartShowcaseSample('Parallel', 320, parallel),
    ChartShowcaseSample('Violin', 320, violin),
  ];

  static const List<ChartShowcaseSample> v3Variant = [
    ChartShowcaseSample('Choropleth', 320, v3Choropleth),
    ChartShowcaseSample('Slope', 300, slope),
    ChartShowcaseSample('Dumbbell', 320, dumbbell),
    ChartShowcaseSample('Area Bump', 320, areaBump),
    ChartShowcaseSample('Bar Race', 320, barRace),
    ChartShowcaseSample('Line Gradient', 300, lineGradient),
    ChartShowcaseSample('Half Donut', 280, halfDonut),
    ChartShowcaseSample('Rainfall', 300, rainfall),
  ];

  static const List<ChartShowcaseSample> hierarchy = [
    ChartShowcaseSample('Treemap', 300, treemap),
    ChartShowcaseSample('Sunburst', 320, sunburst),
  ];

  static const List<ChartShowcaseSample> flow = [
    ChartShowcaseSample('Funnel', 300, funnel),
    ChartShowcaseSample('Waterfall', 300, waterfall),
    ChartShowcaseSample('Sankey', 320, sankey),
    ChartShowcaseSample('Gantt', 320, gantt),
  ];

  static const List<ChartShowcaseSample> radialFamily = [
    ChartShowcaseSample('Gauge', 280, gauge),
    ChartShowcaseSample('Radar', 300, radar),
    ChartShowcaseSample('Polar Bar', 300, polarBar),
    ChartShowcaseSample('Radial', 300, radial),
  ];

  static const List<ChartShowcaseSample> geo = [
    ChartShowcaseSample('Choropleth', 320, choropleth),
  ];

  static const List<ChartShowcaseSample> textTimeline = [
    ChartShowcaseSample('Timeline', 320, timeline),
    ChartShowcaseSample('Wordcloud', 320, wordcloud),
    ChartShowcaseSample('Calendar', 240, calendar),
  ];

  static const List<ChartShowcaseSample> canonicalMixed = [
    ChartShowcaseSample('Gauge', 280, gauge),
    ChartShowcaseSample('Radar', 280, radar),
    ChartShowcaseSample('Funnel', 280, funnel),
    ChartShowcaseSample('Waterfall', 280, waterfall),
    ChartShowcaseSample('Sankey', 280, sankey),
    ChartShowcaseSample('Sunburst', 280, sunburst),
    ChartShowcaseSample('Treemap', 280, treemap),
    ChartShowcaseSample('Gantt', 280, gantt),
    ChartShowcaseSample('Polar Bar', 280, polarBar),
  ];

  static const ChartShowcaseFamily aiMLFamily = ChartShowcaseFamily(
    id: 'ai_ml',
    title: 'AI & Machine Learning',
    description: 'Confusion matrix and ROC evaluation charts.',
    tier: ChartShowcaseTier.pro,
    samples: aiML,
  );

  static const ChartShowcaseFamily businessProjectFamily = ChartShowcaseFamily(
    id: 'business_project',
    title: 'Business & Project Management',
    description: 'S-curve, Pareto, and KPI indicator charts.',
    tier: ChartShowcaseTier.pro,
    samples: businessProject,
  );

  static const ChartShowcaseFamily hierarchyFamily = ChartShowcaseFamily(
    id: 'hierarchy',
    title: 'Hierarchy',
    description: 'Nested part-to-whole charts.',
    tier: ChartShowcaseTier.pro,
    samples: hierarchy,
  );

  static const ChartShowcaseFamily flowFamily = ChartShowcaseFamily(
    id: 'flow',
    title: 'Flow',
    description: 'Process, sequence, and movement charts.',
    tier: ChartShowcaseTier.pro,
    samples: flow,
  );

  static const ChartShowcaseFamily radialDataShapeFamily = ChartShowcaseFamily(
    id: 'radial',
    title: 'Radial',
    description: 'Circular gauges, radar, and radial comparison charts.',
    tier: ChartShowcaseTier.pro,
    samples: radialFamily,
  );

  static const ChartShowcaseFamily geoFamily = ChartShowcaseFamily(
    id: 'geo',
    title: 'Geo',
    description: 'Map-oriented chart samples.',
    tier: ChartShowcaseTier.pro,
    samples: geo,
  );

  static const ChartShowcaseFamily textTimelineFamily = ChartShowcaseFamily(
    id: 'text_timeline',
    title: 'Text & Timeline',
    description: 'Timeline, word, and calendar chart samples.',
    tier: ChartShowcaseTier.pro,
    samples: textTimeline,
  );

  static const ChartShowcaseFamily canonicalMixedFamily = ChartShowcaseFamily(
    id: 'canonical_mixed',
    title: 'Canonical Mixed',
    description: 'A compact cross-family smoke gallery.',
    tier: ChartShowcaseTier.pro,
    samples: canonicalMixed,
  );

  static const ChartShowcaseFamily statTradingGraphFamily = ChartShowcaseFamily(
    id: 'stat_trading_graph',
    title: 'Stat, Trading & Graph',
    description: 'Statistical, financial, graph, and special-purpose charts.',
    tier: ChartShowcaseTier.pro,
    samples: statTradingGraph,
  );

  static const ChartShowcaseFamily v3VariantFamily = ChartShowcaseFamily(
    id: 'v3_variant',
    title: 'V3 Variants',
    description: 'Newer variant charts and shape-specific renderers.',
    tier: ChartShowcaseTier.pro,
    samples: v3Variant,
  );

  static const List<ChartShowcaseFamily> focusedFamilies = [
    aiMLFamily,
    businessProjectFamily,
    hierarchyFamily,
    flowFamily,
    radialDataShapeFamily,
    geoFamily,
    textTimelineFamily,
    canonicalMixedFamily,
    statTradingGraphFamily,
    v3VariantFamily,
  ];

  static List<ChartShowcaseFamily> focusedFamiliesForTier(
    ChartShowcaseTierFilter tierFilter,
  ) {
    return chartShowcaseFamiliesForTier(focusedFamilies, tierFilter);
  }

  static Map<String, int> get focusedFamilyTierCounts {
    return chartShowcaseFamilyTierCounts(focusedFamilies);
  }

  static ChartShowcaseFamily? familyById(String id) {
    for (final family in focusedFamilies) {
      if (family.id == id) {
        return family;
      }
    }
    return null;
  }

  static Iterable<ChartShowcaseSample> get focusedSamples sync* {
    for (final family in focusedFamilies) {
      yield* family.samples;
    }
  }
}
