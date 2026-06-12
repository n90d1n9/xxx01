import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseTrendsData {
  static const salesPulse = [
    SimpleTrendPoint(label: 'Mon', value: 42),
    SimpleTrendPoint(label: 'Tue', value: 48),
    SimpleTrendPoint(label: 'Wed', value: 46),
    SimpleTrendPoint(label: 'Thu', value: 55),
    SimpleTrendPoint(label: 'Fri', value: 61),
    SimpleTrendPoint(label: 'Sat', value: 68),
    SimpleTrendPoint(label: 'Sun', value: 74),
  ];

  static const retentionPulse = [
    SimpleTrendPoint(label: 'W1', value: 84),
    SimpleTrendPoint(label: 'W2', value: 86),
    SimpleTrendPoint(label: 'W3', value: 85),
    SimpleTrendPoint(label: 'W4', value: 88),
    SimpleTrendPoint(label: 'W5', value: 90),
    SimpleTrendPoint(label: 'W6', value: 91),
  ];

  static const completionPulse = [
    SimpleTrendPoint(label: 'A', value: 62),
    SimpleTrendPoint(label: 'B', value: 68),
    SimpleTrendPoint(label: 'C', value: 72),
    SimpleTrendPoint(label: 'D', value: 74),
    SimpleTrendPoint(label: 'E', value: 80),
    SimpleTrendPoint(label: 'F', value: 84),
  ];

  static const riskPulse = [
    SimpleTrendPoint(label: 'M1', value: 28),
    SimpleTrendPoint(label: 'M2', value: 24),
    SimpleTrendPoint(label: 'M3', value: 21),
    SimpleTrendPoint(label: 'M4', value: 19),
    SimpleTrendPoint(label: 'M5', value: 15),
    SimpleTrendPoint(label: 'M6', value: 12),
  ];

  static const processControl = [
    SimpleControlChartPoint(label: 'W1', value: 84),
    SimpleControlChartPoint(label: 'W2', value: 86),
    SimpleControlChartPoint(label: 'W3', value: 83),
    SimpleControlChartPoint(label: 'W4', value: 87),
    SimpleControlChartPoint(label: 'W5', value: 91),
    SimpleControlChartPoint(label: 'W6', value: 88),
    SimpleControlChartPoint(label: 'W7', value: 85),
    SimpleControlChartPoint(label: 'W8', value: 92),
    SimpleControlChartPoint(label: 'W9', value: 95),
    SimpleControlChartPoint(label: 'W10', value: 86),
  ];

  static const marketCandles = [
    SimpleCandlestickData(
      label: 'Jan',
      open: 102,
      high: 109,
      low: 98,
      close: 107,
      volume: 1200000,
    ),
    SimpleCandlestickData(
      label: 'Feb',
      open: 107,
      high: 113,
      low: 103,
      close: 104,
      volume: 1450000,
    ),
    SimpleCandlestickData(
      label: 'Mar',
      open: 104,
      high: 118,
      low: 102,
      close: 115,
      volume: 1860000,
    ),
    SimpleCandlestickData(
      label: 'Apr',
      open: 115,
      high: 121,
      low: 111,
      close: 112,
      volume: 1580000,
    ),
    SimpleCandlestickData(
      label: 'May',
      open: 112,
      high: 124,
      low: 110,
      close: 122,
      volume: 2240000,
    ),
    SimpleCandlestickData(
      label: 'Jun',
      open: 122,
      high: 128,
      low: 117,
      close: 126,
      volume: 1950000,
    ),
    SimpleCandlestickData(
      label: 'Jul',
      open: 126,
      high: 131,
      low: 121,
      close: 123,
      volume: 1710000,
    ),
  ];

  static const revenueTrend = [
    SimpleTrendSeries(
      name: 'Actual',
      points: [
        SimpleTrendPoint(label: 'Jan', value: 42),
        SimpleTrendPoint(label: 'Feb', value: 48),
        SimpleTrendPoint(label: 'Mar', value: 46),
        SimpleTrendPoint(label: 'Apr', value: 61),
        SimpleTrendPoint(label: 'May', value: 67),
        SimpleTrendPoint(label: 'Jun', value: 74),
      ],
    ),
    SimpleTrendSeries(
      name: 'Target',
      lineStyle: SimpleTrendLineStyle.dashed,
      points: [
        SimpleTrendPoint(label: 'Jan', value: 44),
        SimpleTrendPoint(label: 'Feb', value: 50),
        SimpleTrendPoint(label: 'Mar', value: 55),
        SimpleTrendPoint(label: 'Apr', value: 60),
        SimpleTrendPoint(label: 'May', value: 66),
        SimpleTrendPoint(label: 'Jun', value: 72),
      ],
    ),
  ];

  static const regionalSmallMultiples = [
    SimpleSmallMultiplePanel(
      label: 'North',
      subtitle: '+18%',
      color: Color(0xFF2563EB),
      series: [
        SimpleTrendSeries(
          name: 'Revenue',
          points: [
            SimpleTrendPoint(label: 'Jan', value: 42),
            SimpleTrendPoint(label: 'Feb', value: 45),
            SimpleTrendPoint(label: 'Mar', value: 48),
            SimpleTrendPoint(label: 'Apr', value: 54),
            SimpleTrendPoint(label: 'May', value: 61),
            SimpleTrendPoint(label: 'Jun', value: 72),
          ],
        ),
      ],
    ),
    SimpleSmallMultiplePanel(
      label: 'South',
      subtitle: '+11%',
      color: Color(0xFF0D9488),
      series: [
        SimpleTrendSeries(
          name: 'Revenue',
          points: [
            SimpleTrendPoint(label: 'Jan', value: 36),
            SimpleTrendPoint(label: 'Feb', value: 39),
            SimpleTrendPoint(label: 'Mar', value: 43),
            SimpleTrendPoint(label: 'Apr', value: 45),
            SimpleTrendPoint(label: 'May', value: 49),
            SimpleTrendPoint(label: 'Jun', value: 54),
          ],
        ),
      ],
    ),
    SimpleSmallMultiplePanel(
      label: 'East',
      subtitle: '+24%',
      color: Color(0xFF7C3AED),
      series: [
        SimpleTrendSeries(
          name: 'Revenue',
          points: [
            SimpleTrendPoint(label: 'Jan', value: 30),
            SimpleTrendPoint(label: 'Feb', value: 34),
            SimpleTrendPoint(label: 'Mar', value: 41),
            SimpleTrendPoint(label: 'Apr', value: 48),
            SimpleTrendPoint(label: 'May', value: 58),
            SimpleTrendPoint(label: 'Jun', value: 66),
          ],
        ),
      ],
    ),
    SimpleSmallMultiplePanel(
      label: 'West',
      subtitle: '+8%',
      color: Color(0xFFF97316),
      series: [
        SimpleTrendSeries(
          name: 'Revenue',
          points: [
            SimpleTrendPoint(label: 'Jan', value: 51),
            SimpleTrendPoint(label: 'Feb', value: 49),
            SimpleTrendPoint(label: 'Mar', value: 53),
            SimpleTrendPoint(label: 'Apr', value: 57),
            SimpleTrendPoint(label: 'May', value: 60),
            SimpleTrendPoint(label: 'Jun', value: 65),
          ],
        ),
      ],
    ),
  ];

  static const seasonalPeriods = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  static const seasonalCycles = ['2024', '2025', '2026'];

  static const seasonalCyclePlot = [
    SimpleCyclePlotPoint(periodLabel: 'Jan', cycleLabel: '2024', value: 38),
    SimpleCyclePlotPoint(periodLabel: 'Feb', cycleLabel: '2024', value: 44),
    SimpleCyclePlotPoint(periodLabel: 'Mar', cycleLabel: '2024', value: 51),
    SimpleCyclePlotPoint(periodLabel: 'Apr', cycleLabel: '2024', value: 57),
    SimpleCyclePlotPoint(periodLabel: 'May', cycleLabel: '2024', value: 63),
    SimpleCyclePlotPoint(periodLabel: 'Jun', cycleLabel: '2024', value: 68),
    SimpleCyclePlotPoint(periodLabel: 'Jan', cycleLabel: '2025', value: 42),
    SimpleCyclePlotPoint(periodLabel: 'Feb', cycleLabel: '2025', value: 49),
    SimpleCyclePlotPoint(periodLabel: 'Mar', cycleLabel: '2025', value: 56),
    SimpleCyclePlotPoint(periodLabel: 'Apr', cycleLabel: '2025', value: 64),
    SimpleCyclePlotPoint(periodLabel: 'May', cycleLabel: '2025', value: 72),
    SimpleCyclePlotPoint(periodLabel: 'Jun', cycleLabel: '2025', value: 78),
    SimpleCyclePlotPoint(periodLabel: 'Jan', cycleLabel: '2026', value: 47),
    SimpleCyclePlotPoint(periodLabel: 'Feb', cycleLabel: '2026', value: 54),
    SimpleCyclePlotPoint(periodLabel: 'Mar', cycleLabel: '2026', value: 61),
    SimpleCyclePlotPoint(periodLabel: 'Apr', cycleLabel: '2026', value: 69),
    SimpleCyclePlotPoint(periodLabel: 'May', cycleLabel: '2026', value: 77),
    SimpleCyclePlotPoint(periodLabel: 'Jun', cycleLabel: '2026', value: 84),
  ];

  static const capacitySteps = [
    SimpleTrendSeries(
      name: 'Committed',
      points: [
        SimpleTrendPoint(label: 'Jan', value: 24),
        SimpleTrendPoint(label: 'Feb', value: 24),
        SimpleTrendPoint(label: 'Mar', value: 36),
        SimpleTrendPoint(label: 'Apr', value: 36),
        SimpleTrendPoint(label: 'May', value: 48),
        SimpleTrendPoint(label: 'Jun', value: 64),
      ],
    ),
    SimpleTrendSeries(
      name: 'Demand',
      lineStyle: SimpleTrendLineStyle.dashed,
      points: [
        SimpleTrendPoint(label: 'Jan', value: 18),
        SimpleTrendPoint(label: 'Feb', value: 28),
        SimpleTrendPoint(label: 'Mar', value: 31),
        SimpleTrendPoint(label: 'Apr', value: 42),
        SimpleTrendPoint(label: 'May', value: 46),
        SimpleTrendPoint(label: 'Jun', value: 58),
      ],
    ),
  ];

  static const revenueForecastFan = [
    SimpleFanChartPoint(
      label: 'Jul',
      value: 78,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 66, upper: 91),
        SimpleFanChartBand(label: '50%', lower: 72, upper: 84),
      ],
    ),
    SimpleFanChartPoint(
      label: 'Aug',
      value: 84,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 68, upper: 101),
        SimpleFanChartBand(label: '50%', lower: 76, upper: 92),
      ],
    ),
    SimpleFanChartPoint(
      label: 'Sep',
      value: 91,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 70, upper: 114),
        SimpleFanChartBand(label: '50%', lower: 81, upper: 101),
      ],
    ),
    SimpleFanChartPoint(
      label: 'Oct',
      value: 98,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 73, upper: 126),
        SimpleFanChartBand(label: '50%', lower: 87, upper: 109),
      ],
    ),
    SimpleFanChartPoint(
      label: 'Nov',
      value: 106,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 76, upper: 139),
        SimpleFanChartBand(label: '50%', lower: 94, upper: 118),
      ],
    ),
    SimpleFanChartPoint(
      label: 'Dec',
      value: 114,
      bands: [
        SimpleFanChartBand(label: '80%', lower: 80, upper: 152),
        SimpleFanChartBand(label: '50%', lower: 101, upper: 128),
      ],
    ),
  ];

  static const seasonalDemandSpiral = [
    SimpleSpiralChartPoint(label: 'Jan', value: 42),
    SimpleSpiralChartPoint(label: 'Feb', value: 48),
    SimpleSpiralChartPoint(label: 'Mar', value: 52),
    SimpleSpiralChartPoint(label: 'Apr', value: 61),
    SimpleSpiralChartPoint(label: 'May', value: 67),
    SimpleSpiralChartPoint(label: 'Jun', value: 74),
    SimpleSpiralChartPoint(label: 'Jul', value: 82),
    SimpleSpiralChartPoint(label: 'Aug', value: 79),
    SimpleSpiralChartPoint(label: 'Sep', value: 88),
    SimpleSpiralChartPoint(label: 'Oct', value: 93),
    SimpleSpiralChartPoint(label: 'Nov', value: 104),
    SimpleSpiralChartPoint(label: 'Dec', value: 118),
    SimpleSpiralChartPoint(label: 'Jan+', value: 86),
    SimpleSpiralChartPoint(label: 'Feb+', value: 91),
    SimpleSpiralChartPoint(label: 'Mar+', value: 96),
    SimpleSpiralChartPoint(label: 'Apr+', value: 108),
  ];

  static const productTrajectory = [
    SimpleConnectedScatterSeries(
      name: 'Current Path',
      points: [
        SimpleConnectedScatterPoint(label: 'Q1', x: 20, y: 82, value: 32),
        SimpleConnectedScatterPoint(label: 'Q2', x: 34, y: 76, value: 42),
        SimpleConnectedScatterPoint(label: 'Q3', x: 48, y: 68, value: 55),
        SimpleConnectedScatterPoint(label: 'Q4', x: 64, y: 72, value: 68),
        SimpleConnectedScatterPoint(label: 'Q5', x: 78, y: 84, value: 81),
      ],
    ),
    SimpleConnectedScatterSeries(
      name: 'Target Path',
      points: [
        SimpleConnectedScatterPoint(label: 'Q1', x: 24, y: 70, value: 36),
        SimpleConnectedScatterPoint(label: 'Q2', x: 40, y: 74, value: 48),
        SimpleConnectedScatterPoint(label: 'Q3', x: 56, y: 78, value: 62),
        SimpleConnectedScatterPoint(label: 'Q4', x: 72, y: 86, value: 76),
      ],
    ),
  ];

  static const productAdoption = [
    SimpleTrendSeries(
      name: 'Activation',
      points: [
        SimpleTrendPoint(label: 'W1', value: 21),
        SimpleTrendPoint(label: 'W2', value: 28),
        SimpleTrendPoint(label: 'W3', value: 33),
        SimpleTrendPoint(label: 'W4', value: 41),
        SimpleTrendPoint(label: 'W5', value: 48),
        SimpleTrendPoint(label: 'W6', value: 57),
      ],
    ),
    SimpleTrendSeries(
      name: 'Retention',
      lineStyle: SimpleTrendLineStyle.dotted,
      points: [
        SimpleTrendPoint(label: 'W1', value: 18),
        SimpleTrendPoint(label: 'W2', value: 22),
        SimpleTrendPoint(label: 'W3', value: 31),
        SimpleTrendPoint(label: 'W4', value: 36),
        SimpleTrendPoint(label: 'W5', value: 43),
        SimpleTrendPoint(label: 'W6', value: 51),
      ],
    ),
  ];

  static const retentionPeriods = ['W0', 'W1', 'W2', 'W3', 'W4', 'W5'];

  static const retentionCohorts = [
    SimpleCohortRetentionRow(
      label: 'Jan',
      size: 1240,
      values: [1, 0.64, 0.48, 0.38, 0.31, 0.27],
    ),
    SimpleCohortRetentionRow(
      label: 'Feb',
      size: 1380,
      values: [1, 0.62, 0.45, 0.35, 0.29, null],
    ),
    SimpleCohortRetentionRow(
      label: 'Mar',
      size: 1460,
      values: [1, 0.59, 0.43, 0.33, null, null],
    ),
    SimpleCohortRetentionRow(
      label: 'Apr',
      size: 1510,
      values: [1, 0.61, 0.46, null, null, null],
    ),
    SimpleCohortRetentionRow(
      label: 'May',
      size: 1620,
      values: [1, 0.66, null, null, null, null],
    ),
  ];

  static const healthHorizon = [
    SimpleTrendSeries(
      name: 'Revenue',
      points: [
        SimpleTrendPoint(label: 'W1', value: -8),
        SimpleTrendPoint(label: 'W2', value: -2),
        SimpleTrendPoint(label: 'W3', value: 5),
        SimpleTrendPoint(label: 'W4', value: 12),
        SimpleTrendPoint(label: 'W5', value: 8),
        SimpleTrendPoint(label: 'W6', value: 18),
      ],
    ),
    SimpleTrendSeries(
      name: 'Quality',
      points: [
        SimpleTrendPoint(label: 'W1', value: -4),
        SimpleTrendPoint(label: 'W2', value: 3),
        SimpleTrendPoint(label: 'W3', value: 8),
        SimpleTrendPoint(label: 'W4', value: 6),
        SimpleTrendPoint(label: 'W5', value: -3),
        SimpleTrendPoint(label: 'W6', value: 10),
      ],
    ),
    SimpleTrendSeries(
      name: 'Risk',
      points: [
        SimpleTrendPoint(label: 'W1', value: 12),
        SimpleTrendPoint(label: 'W2', value: 8),
        SimpleTrendPoint(label: 'W3', value: 4),
        SimpleTrendPoint(label: 'W4', value: -2),
        SimpleTrendPoint(label: 'W5', value: -8),
        SimpleTrendPoint(label: 'W6', value: -12),
      ],
    ),
  ];

  static const channelStream = [
    SimpleTrendSeries(
      name: 'Search',
      points: [
        SimpleTrendPoint(label: 'Q1', value: 28),
        SimpleTrendPoint(label: 'Q2', value: 34),
        SimpleTrendPoint(label: 'Q3', value: 39),
        SimpleTrendPoint(label: 'Q4', value: 46),
      ],
    ),
    SimpleTrendSeries(
      name: 'Partner',
      points: [
        SimpleTrendPoint(label: 'Q1', value: 18),
        SimpleTrendPoint(label: 'Q2', value: 26),
        SimpleTrendPoint(label: 'Q3', value: 32),
        SimpleTrendPoint(label: 'Q4', value: 38),
      ],
    ),
    SimpleTrendSeries(
      name: 'Academy',
      points: [
        SimpleTrendPoint(label: 'Q1', value: 12),
        SimpleTrendPoint(label: 'Q2', value: 18),
        SimpleTrendPoint(label: 'Q3', value: 24),
        SimpleTrendPoint(label: 'Q4', value: 30),
      ],
    ),
    SimpleTrendSeries(
      name: 'Support',
      points: [
        SimpleTrendPoint(label: 'Q1', value: 8),
        SimpleTrendPoint(label: 'Q2', value: 10),
        SimpleTrendPoint(label: 'Q3', value: 14),
        SimpleTrendPoint(label: 'Q4', value: 18),
      ],
    ),
  ];
}
