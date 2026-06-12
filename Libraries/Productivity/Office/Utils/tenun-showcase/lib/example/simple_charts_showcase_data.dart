import 'simple_charts_showcase_advanced_dashboard_data.dart';
import 'simple_charts_showcase_comparison_data.dart';
import 'simple_charts_showcase_composition_data.dart';
import 'simple_charts_showcase_core_data.dart';
import 'simple_charts_showcase_flow_data.dart';
import 'simple_charts_showcase_statistical_data.dart';
import 'simple_charts_showcase_trends_data.dart';

export 'simple_charts_showcase_advanced_dashboard_data.dart';
export 'simple_charts_showcase_comparison_data.dart';
export 'simple_charts_showcase_composition_data.dart';
export 'simple_charts_showcase_core_data.dart';
export 'simple_charts_showcase_flow_data.dart';
export 'simple_charts_showcase_statistical_data.dart';
export 'simple_charts_showcase_trends_data.dart';

abstract final class SimpleChartsShowcaseData {
  static const regionalGrowth = SimpleChartsShowcaseCoreData.regionalGrowth;
  static const courseOutcomes = SimpleChartsShowcaseCoreData.courseOutcomes;
  static const engagementScores =
      SimpleChartsShowcaseAdvancedDashboardData.engagementScores;
  static const operatingTargets =
      SimpleChartsShowcaseAdvancedDashboardData.operatingTargets;
  static const operatingTargetsPlain =
      SimpleChartsShowcaseAdvancedDashboardData.operatingTargetsPlain;
  static const readinessRanges =
      SimpleChartsShowcaseAdvancedDashboardData.readinessRanges;
  static const readinessRings =
      SimpleChartsShowcaseAdvancedDashboardData.readinessRings;
  static const capabilityAxes =
      SimpleChartsShowcaseAdvancedDashboardData.capabilityAxes;
  static const capabilityProfile =
      SimpleChartsShowcaseAdvancedDashboardData.capabilityProfile;
  static const capabilityMatrixColumns =
      SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixColumns;
  static const capabilityMatrixRows =
      SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixRows;
  static const capabilityMatrix =
      SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrix;

  static const capabilityParallelAxes =
      SimpleChartsShowcaseStatisticalData.capabilityParallelAxes;
  static const capabilityParallel =
      SimpleChartsShowcaseStatisticalData.capabilityParallel;
  static const capabilityCorrelationVariables =
      SimpleChartsShowcaseStatisticalData.capabilityCorrelationVariables;
  static const capabilityCorrelations =
      SimpleChartsShowcaseStatisticalData.capabilityCorrelations;
  static const capabilityScatterMatrix =
      SimpleChartsShowcaseStatisticalData.capabilityScatterMatrix;
  static const activityDays = SimpleChartsShowcaseStatisticalData.activityDays;
  static const activitySegments =
      SimpleChartsShowcaseStatisticalData.activitySegments;
  static const activityHeatmap =
      SimpleChartsShowcaseStatisticalData.activityHeatmap;
  static const activityPunchCards =
      SimpleChartsShowcaseStatisticalData.activityPunchCards;
  static const activityRadialHeatmap =
      SimpleChartsShowcaseStatisticalData.activityRadialHeatmap;
  static const regionalTileMap =
      SimpleChartsShowcaseStatisticalData.regionalTileMap;
  static const usageDensityPoints =
      SimpleChartsShowcaseStatisticalData.usageDensityPoints;
  static const usageHeatmapPoints =
      SimpleChartsShowcaseStatisticalData.usageHeatmapPoints;
  static const serviceTerritories =
      SimpleChartsShowcaseStatisticalData.serviceTerritories;
  static const performanceSurface =
      SimpleChartsShowcaseStatisticalData.performanceSurface;
  static final learningCalendar =
      SimpleChartsShowcaseStatisticalData.learningCalendar;
  static const scoreDistribution =
      SimpleChartsShowcaseStatisticalData.scoreDistribution;
  static const scoreQQPlot = SimpleChartsShowcaseStatisticalData.scoreQQPlot;
  static const concentrationLorenz =
      SimpleChartsShowcaseStatisticalData.concentrationLorenz;
  static const measurementAgreement =
      SimpleChartsShowcaseStatisticalData.measurementAgreement;
  static const scoreDensity = SimpleChartsShowcaseStatisticalData.scoreDensity;
  static const scoreRaincloud =
      SimpleChartsShowcaseStatisticalData.scoreRaincloud;
  static const responseEcdf = SimpleChartsShowcaseStatisticalData.responseEcdf;
  static const scoreSpread = SimpleChartsShowcaseStatisticalData.scoreSpread;
  static const scoreBoxen = SimpleChartsShowcaseStatisticalData.scoreBoxen;
  static const scoreShape = SimpleChartsShowcaseStatisticalData.scoreShape;
  static const cohortRidges = SimpleChartsShowcaseStatisticalData.cohortRidges;
  static const scoreRugs = SimpleChartsShowcaseStatisticalData.scoreRugs;
  static const responseBarcode =
      SimpleChartsShowcaseStatisticalData.responseBarcode;
  static const sampleStrips = SimpleChartsShowcaseStatisticalData.sampleStrips;
  static const sampleBeeswarm =
      SimpleChartsShowcaseStatisticalData.sampleBeeswarm;
  static const sampleSina = SimpleChartsShowcaseStatisticalData.sampleSina;

  static const portfolioShare =
      SimpleChartsShowcaseCompositionData.portfolioShare;
  static const portfolioPackedBubbles =
      SimpleChartsShowcaseCompositionData.portfolioPackedBubbles;
  static const strategyTernary =
      SimpleChartsShowcaseCompositionData.strategyTernary;
  static const voiceThemes = SimpleChartsShowcaseCompositionData.voiceThemes;
  static const audienceVennSets =
      SimpleChartsShowcaseCompositionData.audienceVennSets;
  static const audienceVennIntersections =
      SimpleChartsShowcaseCompositionData.audienceVennIntersections;
  static const audienceUpsetSets =
      SimpleChartsShowcaseCompositionData.audienceUpsetSets;
  static const audienceUpsetIntersections =
      SimpleChartsShowcaseCompositionData.audienceUpsetIntersections;
  static const portfolioTreemap =
      SimpleChartsShowcaseCompositionData.portfolioTreemap;
  static const portfolioSunburst =
      SimpleChartsShowcaseCompositionData.portfolioSunburst;
  static const portfolioTree =
      SimpleChartsShowcaseCompositionData.portfolioTree;
  static const portfolioIcicle =
      SimpleChartsShowcaseCompositionData.portfolioIcicle;
  static const readinessIcons =
      SimpleChartsShowcaseCompositionData.readinessIcons;
  static const readinessDots =
      SimpleChartsShowcaseCompositionData.readinessDots;
  static const marketMosaicCategories =
      SimpleChartsShowcaseCompositionData.marketMosaicCategories;
  static const marketMosaic = SimpleChartsShowcaseCompositionData.marketMosaic;
  static const marketMosaicPlot =
      SimpleChartsShowcaseCompositionData.marketMosaicPlot;

  static const priorityPareto =
      SimpleChartsShowcaseComparisonData.priorityPareto;
  static const forecastRanges =
      SimpleChartsShowcaseComparisonData.forecastRanges;
  static const sensitivityTornado =
      SimpleChartsShowcaseComparisonData.sensitivityTornado;
  static const experimentIntervals =
      SimpleChartsShowcaseComparisonData.experimentIntervals;
  static const experimentEffects =
      SimpleChartsShowcaseComparisonData.experimentEffects;
  static const benchmarkCategories =
      SimpleChartsShowcaseComparisonData.benchmarkCategories;
  static const benchmarkDots = SimpleChartsShowcaseComparisonData.benchmarkDots;
  static const feedbackLikertCategories =
      SimpleChartsShowcaseComparisonData.feedbackLikertCategories;
  static const feedbackLikert =
      SimpleChartsShowcaseComparisonData.feedbackLikert;
  static const priorityPeriods =
      SimpleChartsShowcaseComparisonData.priorityPeriods;
  static const priorityRanks = SimpleChartsShowcaseComparisonData.priorityRanks;
  static final roadmapTimeline =
      SimpleChartsShowcaseComparisonData.roadmapTimeline;
  static final roadmapMilestones =
      SimpleChartsShowcaseComparisonData.roadmapMilestones;
  static final eventStrip = SimpleChartsShowcaseComparisonData.eventStrip;
  static final projectGantt = SimpleChartsShowcaseComparisonData.projectGantt;
  static const slopeMoves = SimpleChartsShowcaseComparisonData.slopeMoves;
  static const cohortPyramid = SimpleChartsShowcaseComparisonData.cohortPyramid;

  static const conversionFunnel = SimpleChartsShowcaseFlowData.conversionFunnel;
  static const journeyFlow = SimpleChartsShowcaseFlowData.journeyFlow;
  static const journeyAlluvialStages =
      SimpleChartsShowcaseFlowData.journeyAlluvialStages;
  static const journeyAlluvial = SimpleChartsShowcaseFlowData.journeyAlluvial;
  static const journeyChordNodes =
      SimpleChartsShowcaseFlowData.journeyChordNodes;
  static const journeyChord = SimpleChartsShowcaseFlowData.journeyChord;
  static const journeyArcNodes = SimpleChartsShowcaseFlowData.journeyArcNodes;
  static const journeyArcLinks = SimpleChartsShowcaseFlowData.journeyArcLinks;
  static const ecosystemNetworkNodes =
      SimpleChartsShowcaseFlowData.ecosystemNetworkNodes;
  static const ecosystemNetworkLinks =
      SimpleChartsShowcaseFlowData.ecosystemNetworkLinks;
  static const opportunityBubbles =
      SimpleChartsShowcaseFlowData.opportunityBubbles;
  static const priorityQuadrant = SimpleChartsShowcaseFlowData.priorityQuadrant;
  static const channelMixCategories =
      SimpleChartsShowcaseFlowData.channelMixCategories;
  static const channelMix = SimpleChartsShowcaseFlowData.channelMix;
  static const channelShare = SimpleChartsShowcaseFlowData.channelShare;
  static const channelRose = SimpleChartsShowcaseFlowData.channelRose;
  static const budgetMixCategories =
      SimpleChartsShowcaseFlowData.budgetMixCategories;
  static const budgetMix = SimpleChartsShowcaseFlowData.budgetMix;
  static const profitBridge = SimpleChartsShowcaseFlowData.profitBridge;
  static const beforeAfterScores =
      SimpleChartsShowcaseFlowData.beforeAfterScores;

  static const salesPulse = SimpleChartsShowcaseTrendsData.salesPulse;
  static const retentionPulse = SimpleChartsShowcaseTrendsData.retentionPulse;
  static const completionPulse = SimpleChartsShowcaseTrendsData.completionPulse;
  static const riskPulse = SimpleChartsShowcaseTrendsData.riskPulse;
  static const processControl = SimpleChartsShowcaseTrendsData.processControl;
  static const marketCandles = SimpleChartsShowcaseTrendsData.marketCandles;
  static const revenueTrend = SimpleChartsShowcaseTrendsData.revenueTrend;
  static const regionalSmallMultiples =
      SimpleChartsShowcaseTrendsData.regionalSmallMultiples;
  static const seasonalPeriods = SimpleChartsShowcaseTrendsData.seasonalPeriods;
  static const seasonalCycles = SimpleChartsShowcaseTrendsData.seasonalCycles;
  static const seasonalCyclePlot =
      SimpleChartsShowcaseTrendsData.seasonalCyclePlot;
  static const capacitySteps = SimpleChartsShowcaseTrendsData.capacitySteps;
  static const revenueForecastFan =
      SimpleChartsShowcaseTrendsData.revenueForecastFan;
  static const seasonalDemandSpiral =
      SimpleChartsShowcaseTrendsData.seasonalDemandSpiral;
  static const productTrajectory =
      SimpleChartsShowcaseTrendsData.productTrajectory;
  static const productAdoption = SimpleChartsShowcaseTrendsData.productAdoption;
  static const retentionPeriods =
      SimpleChartsShowcaseTrendsData.retentionPeriods;
  static const retentionCohorts =
      SimpleChartsShowcaseTrendsData.retentionCohorts;
  static const healthHorizon = SimpleChartsShowcaseTrendsData.healthHorizon;
  static const channelStream = SimpleChartsShowcaseTrendsData.channelStream;
}
