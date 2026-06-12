import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseFlowData {
  static const conversionFunnel = [
    SimpleFunnelChartData(label: 'Visitors', value: 12000),
    SimpleFunnelChartData(label: 'Leads', value: 7800),
    SimpleFunnelChartData(label: 'Trials', value: 3900),
    SimpleFunnelChartData(label: 'Qualified', value: 1800),
    SimpleFunnelChartData(label: 'Closed', value: 540),
  ];

  static const journeyFlow = [
    SimpleSankeyLink(source: 'Visitors', target: 'Lead', value: 7800),
    SimpleSankeyLink(source: 'Visitors', target: 'Explore', value: 4200),
    SimpleSankeyLink(source: 'Lead', target: 'Trial', value: 3900),
    SimpleSankeyLink(source: 'Lead', target: 'Demo', value: 1800),
    SimpleSankeyLink(source: 'Explore', target: 'Demo', value: 1400),
    SimpleSankeyLink(source: 'Trial', target: 'Closed', value: 540),
    SimpleSankeyLink(source: 'Demo', target: 'Closed', value: 320),
  ];

  static const journeyAlluvialStages = ['Channel', 'Intent', 'Outcome'];

  static const journeyAlluvial = [
    SimpleAlluvialFlow(
      categories: ['Search', 'Trial', 'Closed'],
      value: 2800,
      label: 'Search trial',
    ),
    SimpleAlluvialFlow(
      categories: ['Search', 'Demo', 'Closed'],
      value: 1400,
      label: 'Search demo',
    ),
    SimpleAlluvialFlow(
      categories: ['Partner', 'Demo', 'Closed'],
      value: 900,
      label: 'Partner demo',
    ),
    SimpleAlluvialFlow(
      categories: ['Academy', 'Trial', 'Nurture'],
      value: 760,
      label: 'Academy trial',
    ),
    SimpleAlluvialFlow(
      categories: ['Direct', 'Explore', 'Nurture'],
      value: 620,
      label: 'Direct explore',
    ),
    SimpleAlluvialFlow(
      categories: ['Referral', 'Demo', 'Closed'],
      value: 420,
      label: 'Referral demo',
    ),
  ];

  static const journeyChordNodes = [
    SimpleChordNode(id: 'awareness', label: 'Awareness'),
    SimpleChordNode(id: 'trial', label: 'Trial'),
    SimpleChordNode(id: 'demo', label: 'Demo'),
    SimpleChordNode(id: 'closed', label: 'Closed'),
  ];

  static const journeyChord = [
    SimpleChordLink(source: 'awareness', target: 'trial', value: 3900),
    SimpleChordLink(source: 'awareness', target: 'demo', value: 1800),
    SimpleChordLink(source: 'awareness', target: 'closed', value: 540),
    SimpleChordLink(source: 'trial', target: 'closed', value: 540),
    SimpleChordLink(source: 'demo', target: 'closed', value: 320),
  ];

  static const journeyArcNodes = [
    SimpleArcDiagramNode(id: 'awareness', label: 'Awareness'),
    SimpleArcDiagramNode(id: 'trial', label: 'Trial'),
    SimpleArcDiagramNode(id: 'demo', label: 'Demo'),
    SimpleArcDiagramNode(id: 'closed', label: 'Closed'),
    SimpleArcDiagramNode(id: 'nurture', label: 'Nurture'),
  ];

  static const journeyArcLinks = [
    SimpleArcDiagramLink(
      source: 'awareness',
      target: 'trial',
      value: 3900,
      label: 'Awareness to Trial',
    ),
    SimpleArcDiagramLink(
      source: 'awareness',
      target: 'demo',
      value: 1800,
      label: 'Awareness to Demo',
    ),
    SimpleArcDiagramLink(
      source: 'trial',
      target: 'closed',
      value: 540,
      label: 'Trial to Closed',
    ),
    SimpleArcDiagramLink(
      source: 'demo',
      target: 'closed',
      value: 320,
      label: 'Demo to Closed',
    ),
    SimpleArcDiagramLink(
      source: 'trial',
      target: 'nurture',
      value: 760,
      label: 'Trial to Nurture',
    ),
  ];

  static const ecosystemNetworkNodes = [
    SimpleNetworkNode(
      id: 'platform',
      label: 'Platform',
      value: 30,
      group: 'Core',
      x: 0.24,
      y: 0.46,
    ),
    SimpleNetworkNode(
      id: 'data',
      label: 'Data',
      value: 20,
      group: 'Core',
      x: 0.50,
      y: 0.22,
    ),
    SimpleNetworkNode(
      id: 'academy',
      label: 'Academy',
      value: 16,
      group: 'Experience',
      x: 0.78,
      y: 0.34,
    ),
    SimpleNetworkNode(
      id: 'support',
      label: 'Support',
      value: 14,
      group: 'Experience',
      x: 0.72,
      y: 0.72,
    ),
    SimpleNetworkNode(
      id: 'billing',
      label: 'Billing',
      value: 12,
      group: 'Operations',
      x: 0.34,
      y: 0.78,
    ),
    SimpleNetworkNode(
      id: 'compliance',
      label: 'Compliance',
      value: 10,
      group: 'Operations',
      x: 0.14,
      y: 0.70,
    ),
  ];

  static const ecosystemNetworkLinks = [
    SimpleNetworkLink(
      source: 'platform',
      target: 'data',
      value: 9,
      label: 'Events',
    ),
    SimpleNetworkLink(
      source: 'data',
      target: 'academy',
      value: 5,
      label: 'Signals',
    ),
    SimpleNetworkLink(
      source: 'academy',
      target: 'support',
      value: 4,
      label: 'Guidance',
    ),
    SimpleNetworkLink(
      source: 'support',
      target: 'platform',
      value: 3,
      label: 'Feedback',
    ),
    SimpleNetworkLink(
      source: 'platform',
      target: 'billing',
      value: 4,
      label: 'Usage',
    ),
    SimpleNetworkLink(
      source: 'billing',
      target: 'compliance',
      value: 3,
      label: 'Audit',
    ),
    SimpleNetworkLink(
      source: 'compliance',
      target: 'platform',
      value: 2,
      label: 'Policy',
    ),
  ];

  static const opportunityBubbles = [
    SimpleBubbleChartData(
      label: 'Quick Win',
      x: 20,
      y: 82,
      size: 32,
      group: 'Growth',
    ),
    SimpleBubbleChartData(
      label: 'Scale',
      x: 52,
      y: 74,
      size: 44,
      group: 'Growth',
    ),
    SimpleBubbleChartData(
      label: 'Platform',
      x: 72,
      y: 64,
      size: 36,
      group: 'Core',
    ),
    SimpleBubbleChartData(
      label: 'Cleanup',
      x: 38,
      y: 36,
      size: 20,
      group: 'Core',
    ),
    SimpleBubbleChartData(
      label: 'Pilot',
      x: 46,
      y: 58,
      size: 24,
      group: 'Experiment',
    ),
  ];

  static const priorityQuadrant = [
    SimpleQuadrantPoint(
      label: 'Quick Win',
      x: 20,
      y: 82,
      size: 32,
      group: 'Growth',
    ),
    SimpleQuadrantPoint(
      label: 'Scale',
      x: 52,
      y: 74,
      size: 44,
      group: 'Growth',
    ),
    SimpleQuadrantPoint(
      label: 'Platform',
      x: 72,
      y: 64,
      size: 36,
      group: 'Core',
    ),
    SimpleQuadrantPoint(
      label: 'Cleanup',
      x: 38,
      y: 36,
      size: 20,
      group: 'Core',
    ),
    SimpleQuadrantPoint(
      label: 'Pilot',
      x: 46,
      y: 58,
      size: 24,
      group: 'Experiment',
    ),
  ];

  static const channelMixCategories = ['Q1', 'Q2', 'Q3', 'Q4'];

  static const channelMix = [
    SimpleGroupedBarSeries(name: 'Online', values: [28, 34, 39, 46]),
    SimpleGroupedBarSeries(name: 'Partner', values: [22, 27, 32, 38]),
    SimpleGroupedBarSeries(name: 'Field', values: [18, 25, 29, 33]),
  ];

  static const channelShare = [
    SimpleDonutChartData(label: 'Online', value: 46),
    SimpleDonutChartData(label: 'Partner', value: 38),
    SimpleDonutChartData(label: 'Field', value: 33),
    SimpleDonutChartData(label: 'Education', value: 11),
  ];

  static const channelRose = [
    SimpleRoseChartData(label: 'Online', value: 46),
    SimpleRoseChartData(label: 'Partner', value: 38),
    SimpleRoseChartData(label: 'Field', value: 33),
    SimpleRoseChartData(label: 'Education', value: 11),
    SimpleRoseChartData(label: 'Events', value: 24),
  ];

  static const budgetMixCategories = ['Plan', 'Build', 'Launch', 'Scale'];

  static const budgetMix = [
    SimpleGroupedBarSeries(name: 'People', values: [38, 44, 48, 54]),
    SimpleGroupedBarSeries(name: 'Tools', values: [12, 16, 18, 21]),
    SimpleGroupedBarSeries(name: 'Programs', values: [20, 24, 28, 34]),
  ];

  static const profitBridge = [
    SimpleWaterfallChartData(label: 'Opening', value: 120, isTotal: true),
    SimpleWaterfallChartData(label: 'Sales', value: 48),
    SimpleWaterfallChartData(label: 'Returns', value: -14),
    SimpleWaterfallChartData(label: 'Ops', value: -22),
    SimpleWaterfallChartData(label: 'Expansion', value: 34),
    SimpleWaterfallChartData(label: 'Closing', value: 166, isTotal: true),
  ];

  static const beforeAfterScores = [
    SimpleDumbbellChartData(
      label: 'Onboard',
      start: 58,
      end: 74,
      startLabel: 'Baseline',
      endLabel: 'Current',
    ),
    SimpleDumbbellChartData(
      label: 'Adopt',
      start: 64,
      end: 82,
      startLabel: 'Baseline',
      endLabel: 'Current',
    ),
    SimpleDumbbellChartData(
      label: 'Renew',
      start: 71,
      end: 86,
      startLabel: 'Baseline',
      endLabel: 'Current',
    ),
    SimpleDumbbellChartData(
      label: 'Cost',
      start: 62,
      end: 55,
      startLabel: 'Baseline',
      endLabel: 'Current',
    ),
  ];
}
