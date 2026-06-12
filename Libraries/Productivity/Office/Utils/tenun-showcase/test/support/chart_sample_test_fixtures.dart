import 'package:tenun_showcase/example/chart_samples_registry.dart';

const testBaseFamilies = [testCartesianFamily, testDistributionFamily];

const testTierFamilies = [testCartesianFamily, testAdvancedFamily];

const testCatalogFamilies = [
  testCartesianFamily,
  testDistributionCatalogFamily,
];

const testStatsFamilies = [testCartesianFamily, testDistributionStatsFamily];

const testMixedFamilies = [testMixedFamily];

const testSortFamilies = [
  ChartShowcaseFamily(
    id: 'gamma',
    title: 'Gamma',
    description: 'Original first family.',
    samples: [ChartShowcaseSample('Gamma Bars', 180, testBarSampleJson)],
  ),
  ChartShowcaseFamily(
    id: 'alpha',
    title: 'Alpha',
    description: 'Alphabetically first family.',
    samples: [
      ChartShowcaseSample('Alpha Distribution', 180, testHistogramSampleJson),
      ChartShowcaseSample('Alpha Shape', 180, testViolinSampleJson),
    ],
  ),
  ChartShowcaseFamily(
    id: 'beta',
    title: 'Beta',
    description: 'Largest sample family.',
    samples: [
      ChartShowcaseSample('Beta Bars', 180, testBarSampleJson),
      ChartShowcaseSample('Beta Distribution', 180, testHistogramSampleJson),
      ChartShowcaseSample('Beta Sparkline', 180, testSparklineSampleJson),
    ],
  ),
];

const testCartesianFamily = ChartShowcaseFamily(
  id: 'cartesian',
  title: 'Cartesian',
  description: 'Small cartesian chart family.',
  samples: [testRevenueBarsSample],
);

const testDistributionFamily = ChartShowcaseFamily(
  id: 'distribution',
  title: 'Distribution',
  description: 'Distribution chart family.',
  samples: [ChartShowcaseSample('Latency', 180, testHistogramSampleJson)],
);

const testDistributionCatalogFamily = ChartShowcaseFamily(
  id: 'distribution',
  title: 'Distribution',
  description: 'Distribution chart family.',
  samples: [
    ChartShowcaseSample('Latency', 180, testHistogramSampleJson),
    ChartShowcaseSample('Shape', 180, testViolinSampleJson),
  ],
);

const testDistributionStatsFamily = ChartShowcaseFamily(
  id: 'distribution',
  title: 'Distribution',
  description: 'Distribution chart family.',
  samples: [
    ChartShowcaseSample('Latency Histogram', 180, testHistogramSampleJson),
    ChartShowcaseSample('Variance Violin', 180, testViolinSampleJson),
  ],
);

const testAdvancedFamily = ChartShowcaseFamily(
  id: 'advanced',
  title: 'Advanced',
  description: 'Advanced chart family.',
  tier: ChartShowcaseTier.pro,
  samples: [
    ChartShowcaseSample('Latency Histogram', 180, testHistogramSampleJson),
  ],
);

const testMixedFamily = ChartShowcaseFamily(
  id: 'mixed',
  title: 'Mixed',
  description: 'Mixed chart family.',
  samples: [
    testRevenueBarsSample,
    ChartShowcaseSample('Latency Histogram', 180, testHistogramSampleJson),
    ChartShowcaseSample('Variance Violin', 180, testViolinSampleJson),
  ],
);

const testRevenueBarsSample = ChartShowcaseSample(
  'Revenue Bars',
  180,
  testBarSampleJson,
);

const testRevenueTrendSample = ChartShowcaseSample(
  'Revenue Trend',
  180,
  testLineSampleJson,
);

const Map<String, dynamic> testBarSampleJson = {
  'type': 'bar',
  'title': {'text': 'Revenue'},
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Sales',
      'data': [10, 20, 30],
    },
  ],
};

const Map<String, dynamic> testHistogramSampleJson = {
  'type': 'histogram',
  'series': [
    {
      'data': [1, 2, 3],
    },
  ],
};

const Map<String, dynamic> testViolinSampleJson = {
  'type': 'violin',
  'series': [
    {
      'data': [
        [1, 2, 3],
      ],
    },
  ],
};

const Map<String, dynamic> testSparklineSampleJson = {
  'type': 'sparkline',
  'series': [
    {
      'data': [2, 4, 3],
    },
  ],
};

const Map<String, dynamic> testLineSampleJson = {
  'type': 'line',
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Revenue',
      'data': [10, 24, 18],
    },
  ],
};
