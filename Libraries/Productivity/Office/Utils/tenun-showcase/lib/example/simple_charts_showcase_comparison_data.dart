import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseComparisonData {
  static const priorityPareto = [
    SimpleBarChartData(label: 'Docs', value: 52),
    SimpleBarChartData(label: 'Setup', value: 38),
    SimpleBarChartData(label: 'Billing', value: 24),
    SimpleBarChartData(label: 'Search', value: 16),
    SimpleBarChartData(label: 'Locale', value: 10),
  ];

  static const forecastRanges = [
    SimpleRangeChartData(label: 'North', min: 62, max: 88, value: 76),
    SimpleRangeChartData(label: 'South', min: 55, max: 82, value: 70),
    SimpleRangeChartData(label: 'East', min: 68, max: 92, value: 84),
    SimpleRangeChartData(label: 'West', min: 58, max: 78, value: 66),
  ];

  static const sensitivityTornado = [
    SimpleTornadoChartData(label: 'Demand', low: 58, high: 90),
    SimpleTornadoChartData(label: 'Pricing', low: 62, high: 86),
    SimpleTornadoChartData(label: 'Delivery', low: 66, high: 82),
    SimpleTornadoChartData(label: 'Support', low: 68, high: 79),
    SimpleTornadoChartData(label: 'Content', low: 70, high: 77),
  ];

  static const experimentIntervals = [
    SimpleErrorBarData(label: 'North', value: 72, lower: 66, upper: 78),
    SimpleErrorBarData(label: 'South', value: 68, lower: 62, upper: 74),
    SimpleErrorBarData(label: 'East', value: 84, lower: 77, upper: 91),
    SimpleErrorBarData(label: 'West', value: 76, lower: 70, upper: 83),
  ];

  static const experimentEffects = [
    SimpleForestPlotData(
      label: 'Onboarding',
      estimate: 0.18,
      lower: 0.08,
      upper: 0.28,
      weight: 28,
      group: 'Growth',
    ),
    SimpleForestPlotData(
      label: 'Learning',
      estimate: 0.11,
      lower: -0.03,
      upper: 0.25,
      weight: 18,
      group: 'Education',
    ),
    SimpleForestPlotData(
      label: 'Support',
      estimate: -0.07,
      lower: -0.22,
      upper: 0.06,
      weight: 12,
      group: 'Ops',
    ),
    SimpleForestPlotData(
      label: 'Automation',
      estimate: 0.24,
      lower: 0.12,
      upper: 0.36,
      weight: 22,
      group: 'Platform',
    ),
  ];

  static const benchmarkCategories = ['Clarity', 'Quality', 'Speed', 'Reach'];

  static const benchmarkDots = [
    SimpleDotPlotSeries(name: 'Current', values: [84, 78, 72, 66]),
    SimpleDotPlotSeries(name: 'Target', values: [90, 86, 82, 78]),
  ];

  static const feedbackLikertCategories = [
    SimpleLikertCategory(
      label: 'Strongly disagree',
      sentiment: SimpleLikertSentiment.negative,
    ),
    SimpleLikertCategory(
      label: 'Disagree',
      sentiment: SimpleLikertSentiment.negative,
    ),
    SimpleLikertCategory(
      label: 'Neutral',
      sentiment: SimpleLikertSentiment.neutral,
    ),
    SimpleLikertCategory(
      label: 'Agree',
      sentiment: SimpleLikertSentiment.positive,
    ),
    SimpleLikertCategory(
      label: 'Strongly agree',
      sentiment: SimpleLikertSentiment.positive,
    ),
  ];

  static const feedbackLikert = [
    SimpleLikertItem(label: 'Ease', values: [4, 6, 18, 42, 30]),
    SimpleLikertItem(label: 'Trust', values: [6, 10, 20, 40, 24]),
    SimpleLikertItem(label: 'Support', values: [8, 12, 22, 36, 22]),
    SimpleLikertItem(label: 'Learning', values: [3, 8, 24, 38, 27]),
  ];

  static const priorityPeriods = ['Q1', 'Q2', 'Q3', 'Q4'];

  static const priorityRanks = [
    SimpleBumpSeries(name: 'Search', ranks: [2, 1, 1, 2]),
    SimpleBumpSeries(name: 'Academy', ranks: [1, 2, 3, 1]),
    SimpleBumpSeries(name: 'Support', ranks: [3, 3, 2, 3]),
  ];

  static final roadmapTimeline = [
    SimpleTimelineEvent(
      date: DateTime(2026, 1, 8),
      title: 'Discovery',
      description: 'Signals and needs mapped',
      tag: 'Plan',
    ),
    SimpleTimelineEvent(
      date: DateTime(2026, 2, 14),
      title: 'Pilot',
      description: 'First cohort activated',
      tag: 'Build',
    ),
    SimpleTimelineEvent(
      date: DateTime(2026, 3, 22),
      title: 'Launch',
      description: 'Public workflow released',
      tag: 'Ship',
    ),
    SimpleTimelineEvent(
      date: DateTime(2026, 4, 18),
      title: 'Review',
      description: 'Adoption and quality readout',
      tag: 'Learn',
    ),
  ];

  static final roadmapMilestones = [
    SimpleMilestoneData(
      date: DateTime(2026, 1, 8),
      label: 'Discovery',
      description: 'Signals mapped',
      tag: 'Plan',
      status: SimpleMilestoneStatus.done,
    ),
    SimpleMilestoneData(
      date: DateTime(2026, 2, 14),
      label: 'Pilot',
      description: 'Cohort activated',
      tag: 'Build',
      status: SimpleMilestoneStatus.active,
    ),
    SimpleMilestoneData(
      date: DateTime(2026, 3, 22),
      label: 'Launch',
      description: 'Workflow released',
      tag: 'Ship',
    ),
    SimpleMilestoneData(
      date: DateTime(2026, 4, 18),
      label: 'Review',
      description: 'Quality readout',
      tag: 'Learn',
    ),
  ];

  static final eventStrip = [
    SimpleEventStripLane(
      label: 'Release',
      events: [
        SimpleEventStripEvent(
          date: DateTime(2026, 1, 8),
          label: 'Discovery',
          description: 'Signals mapped',
          tag: 'Plan',
          weight: 1,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 2, 14),
          label: 'Beta',
          description: 'Cohort activated',
          tag: 'Build',
          weight: 2,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 3, 22),
          label: 'Launch',
          description: 'Workflow released',
          tag: 'Ship',
          weight: 3,
        ),
      ],
    ),
    SimpleEventStripLane(
      label: 'Ops',
      events: [
        SimpleEventStripEvent(
          date: DateTime(2026, 1, 18),
          label: 'Audit',
          description: 'Readiness check',
          tag: 'QA',
          weight: 1.4,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 2, 26),
          label: 'Incident',
          description: 'Latency spike',
          tag: 'Risk',
          weight: 2.6,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 4, 10),
          label: 'Recovery',
          description: 'Stability restored',
          tag: 'Ops',
          weight: 1.8,
        ),
      ],
    ),
    SimpleEventStripLane(
      label: 'Learning',
      events: [
        SimpleEventStripEvent(
          date: DateTime(2026, 1, 15),
          label: 'Lesson',
          description: 'Module opened',
          tag: 'Class',
          weight: 1.2,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 3, 5),
          label: 'Workshop',
          description: 'Practice lab',
          tag: 'Class',
          weight: 2.2,
        ),
        SimpleEventStripEvent(
          date: DateTime(2026, 4, 18),
          label: 'Review',
          description: 'Quality readout',
          tag: 'Learn',
          weight: 1.7,
        ),
      ],
    ),
  ];

  static final projectGantt = [
    SimpleGanttTask(
      id: 'discover',
      label: 'Discovery',
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 12),
      progress: 1,
      group: 'Plan',
    ),
    SimpleGanttTask(
      id: 'design',
      label: 'Design',
      start: DateTime(2026, 1, 10),
      end: DateTime(2026, 1, 28),
      progress: 0.72,
      group: 'Build',
      dependencies: const ['discover'],
    ),
    SimpleGanttTask(
      id: 'pilot',
      label: 'Pilot',
      start: DateTime(2026, 1, 24),
      end: DateTime(2026, 2, 18),
      progress: 0.48,
      group: 'Build',
      dependencies: const ['design'],
    ),
    SimpleGanttTask(
      id: 'launch',
      label: 'Launch',
      start: DateTime(2026, 2, 28),
      end: DateTime(2026, 2, 28),
      progress: 0,
      group: 'Ship',
      dependencies: const ['pilot'],
      isMilestone: true,
    ),
  ];

  static const slopeMoves = [
    SimpleSlopeChartData(label: 'Onboarding', start: 62, end: 82),
    SimpleSlopeChartData(label: 'Activation', start: 54, end: 76),
    SimpleSlopeChartData(label: 'Retention', start: 70, end: 84),
    SimpleSlopeChartData(label: 'Risk', start: 48, end: 32),
  ];

  static const cohortPyramid = [
    SimplePopulationPyramidData(label: '18-24', leftValue: 42, rightValue: 38),
    SimplePopulationPyramidData(label: '25-34', leftValue: 48, rightValue: 45),
    SimplePopulationPyramidData(label: '35-44', leftValue: 36, rightValue: 40),
    SimplePopulationPyramidData(label: '45-54', leftValue: 24, rightValue: 29),
  ];
}
