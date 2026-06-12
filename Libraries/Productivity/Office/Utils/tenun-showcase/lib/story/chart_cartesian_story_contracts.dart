import 'chart_story_contract.dart';
import 'chart_story_contract_presets.dart';

final chartCartesianAreaKnobsContract = ChartStoryContract(
  section: 'By Data Shape',
  dataShape: 'Cartesian',
  family: 'Area',
  variant: 'Knobs',
  summary:
      'Interactive area chart story covering display controls, sampling, and JSON-driven rendering.',
  tags: const ['area', 'trend', 'cartesian', 'interactive', 'json'],
  useCases: const [
    'Revenue or adoption trends',
    'Progress over time',
    'Cumulative education metrics',
  ],
  knobs: chartStoryInteractiveDataKnobSpecs(
    display: chartStoryCartesianDisplayKnobSpecs,
    extras: const [
      ChartStoryKnobSpec.boolean(
        key: 'gradientArea',
        label: 'Gradient Area',
        group: 'Display',
        defaultValue: true,
      ),
    ],
  ),
  sampleJson: const {
    'type': 'area',
    'title': 'Monthly learning hours',
    'categories': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'series': [
      {
        'name': 'Students',
        'data': [24, 31, 36, 44, 52, 61],
      },
      {
        'name': 'Mentors',
        'data': [12, 16, 21, 27, 32, 39],
      },
    ],
  },
  sampleCode: '''
TenunChartFromJson(
  jsonConfig: {
    'type': 'area',
    'categories': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'series': [
      {'name': 'Students', 'data': [24, 31, 36, 44, 52, 61]},
      {'name': 'Mentors', 'data': [12, 16, 21, 27, 32, 39]},
    ],
  },
)
''',
);

final chartCartesianLineKnobsContract = ChartStoryContract(
  section: 'By Data Shape',
  dataShape: 'Cartesian',
  family: 'Line',
  variant: 'Knobs',
  summary:
      'Interactive line chart story for trend readability, point markers, smoothness, and sampling.',
  tags: const ['line', 'trend', 'cartesian', 'interactive', 'sampling'],
  useCases: const [
    'Operational KPIs',
    'Classroom progress tracking',
    'SaaS activation and retention curves',
  ],
  knobs: chartStoryInteractiveDataKnobSpecs(
    display: chartStoryCartesianDisplayKnobSpecs,
    extras: const [
      ChartStoryKnobSpec(
        key: 'curveSmoothness',
        label: 'Curve Smoothness',
        type: ChartStoryKnobType.sliderDouble,
        group: 'Display',
        min: 0,
        max: 1,
        defaultValue: 0.35,
      ),
    ],
  ),
  sampleJson: const {
    'type': 'line',
    'title': 'Weekly support response time',
    'categories': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
    'series': [
      {
        'name': 'Median minutes',
        'data': [34, 31, 29, 25, 23, 20],
      },
    ],
  },
  sampleCode: '''
TenunChartFromJson(
  jsonConfig: {
    'type': 'line',
    'categories': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
    'series': [
      {'name': 'Median minutes', 'data': [34, 31, 29, 25, 23, 20]},
    ],
  },
)
''',
);

final chartCartesianBarSimpleContract = ChartStoryContract(
  section: 'By Data Shape',
  dataShape: 'Cartesian',
  family: 'Bar',
  variant: 'Simple',
  summary:
      'Simple bar chart story with business-neutral categorical data and large-data controls.',
  tags: const ['bar', 'categorical', 'comparison', 'interactive', 'json'],
  useCases: const [
    'Department performance',
    'Survey category comparison',
    'Product or course ranking',
  ],
  knobs: chartStoryInteractiveDataKnobSpecs(),
  sampleJson: const {
    'type': 'bar',
    'title': 'Quarterly outcome score',
    'categories': ['Operations', 'Sales', 'Learning', 'Support'],
    'series': [
      {
        'name': 'Score',
        'data': [82, 91, 76, 88],
      },
    ],
  },
  sampleCode: '''
TenunChartFromJson(
  jsonConfig: {
    'type': 'bar',
    'categories': ['Operations', 'Sales', 'Learning', 'Support'],
    'series': [
      {'name': 'Score', 'data': [82, 91, 76, 88]},
    ],
  },
)
''',
);
