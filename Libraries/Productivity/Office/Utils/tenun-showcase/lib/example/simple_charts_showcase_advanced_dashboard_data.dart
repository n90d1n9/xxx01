import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseAdvancedDashboardData {
  static const engagementScores = [
    SimpleBarChartData(label: 'Onboard', value: 64),
    SimpleBarChartData(label: 'Explore', value: 78),
    SimpleBarChartData(label: 'Adopt', value: 72),
    SimpleBarChartData(label: 'Renew', value: 86),
    SimpleBarChartData(label: 'Advocate', value: 69),
  ];

  static const operatingTargets = [
    SimpleBulletChartData(
      label: 'Revenue',
      value: 74,
      target: 82,
      maxValue: 100,
      ranges: [
        SimpleBulletRange(from: 0, to: 60, color: Color(0xFFE2E8F0)),
        SimpleBulletRange(from: 60, to: 82, color: Color(0xFFCBD5E1)),
        SimpleBulletRange(from: 82, to: 100, color: Color(0xFF94A3B8)),
      ],
    ),
    SimpleBulletChartData(
      label: 'Retention',
      value: 91,
      target: 88,
      maxValue: 100,
      ranges: [
        SimpleBulletRange(from: 0, to: 70, color: Color(0xFFE0F2FE)),
        SimpleBulletRange(from: 70, to: 88, color: Color(0xFFBAE6FD)),
        SimpleBulletRange(from: 88, to: 100, color: Color(0xFF7DD3FC)),
      ],
    ),
    SimpleBulletChartData(
      label: 'Quality',
      value: 86,
      target: 90,
      maxValue: 100,
      ranges: [
        SimpleBulletRange(from: 0, to: 72, color: Color(0xFFDCFCE7)),
        SimpleBulletRange(from: 72, to: 90, color: Color(0xFFBBF7D0)),
        SimpleBulletRange(from: 90, to: 100, color: Color(0xFF86EFAC)),
      ],
    ),
  ];

  static const operatingTargetsPlain = [
    SimpleBulletChartData(
      label: 'Revenue',
      value: 74,
      target: 82,
      maxValue: 100,
    ),
    SimpleBulletChartData(
      label: 'Retention',
      value: 91,
      target: 88,
      maxValue: 100,
    ),
    SimpleBulletChartData(
      label: 'Quality',
      value: 86,
      target: 90,
      maxValue: 100,
    ),
  ];

  static const readinessRanges = [
    SimpleGaugeRange(from: 0, to: 60, color: Color(0xFFEF4444)),
    SimpleGaugeRange(from: 60, to: 82, color: Color(0xFFF59E0B)),
    SimpleGaugeRange(from: 82, to: 100, color: Color(0xFF22C55E)),
  ];

  static const readinessRings = [
    SimpleRadialBarChartData(label: 'Revenue', value: 74, targetValue: 82),
    SimpleRadialBarChartData(label: 'Retention', value: 91, targetValue: 88),
    SimpleRadialBarChartData(label: 'Quality', value: 86, targetValue: 90),
    SimpleRadialBarChartData(label: 'Delivery', value: 68, targetValue: 75),
  ];

  static const capabilityAxes = [
    SimpleRadarAxis(label: 'Speed'),
    SimpleRadarAxis(label: 'Quality'),
    SimpleRadarAxis(label: 'Cost'),
    SimpleRadarAxis(label: 'Risk'),
    SimpleRadarAxis(label: 'Reach'),
  ];

  static const capabilityProfile = [
    SimpleRadarSeries(name: 'Current', values: [82, 76, 64, 58, 72]),
    SimpleRadarSeries(name: 'Target', values: [88, 84, 70, 45, 80]),
  ];

  static const capabilityMatrixColumns = ['Speed', 'Quality', 'Reach', 'Risk'];

  static const capabilityMatrixRows = ['Core', 'Growth', 'Learning', 'Support'];

  static const capabilityMatrix = [
    SimpleBubbleMatrixCell(xLabel: 'Speed', yLabel: 'Core', value: 82),
    SimpleBubbleMatrixCell(xLabel: 'Quality', yLabel: 'Core', value: 76),
    SimpleBubbleMatrixCell(xLabel: 'Reach', yLabel: 'Core', value: 68),
    SimpleBubbleMatrixCell(xLabel: 'Risk', yLabel: 'Core', value: 42),
    SimpleBubbleMatrixCell(xLabel: 'Speed', yLabel: 'Growth', value: 74),
    SimpleBubbleMatrixCell(xLabel: 'Quality', yLabel: 'Growth', value: 70),
    SimpleBubbleMatrixCell(xLabel: 'Reach', yLabel: 'Growth', value: 86),
    SimpleBubbleMatrixCell(xLabel: 'Risk', yLabel: 'Growth', value: 54),
    SimpleBubbleMatrixCell(xLabel: 'Speed', yLabel: 'Learning', value: 66),
    SimpleBubbleMatrixCell(xLabel: 'Quality', yLabel: 'Learning', value: 84),
    SimpleBubbleMatrixCell(xLabel: 'Reach', yLabel: 'Learning', value: 58),
    SimpleBubbleMatrixCell(xLabel: 'Risk', yLabel: 'Learning', value: 34),
    SimpleBubbleMatrixCell(xLabel: 'Speed', yLabel: 'Support', value: 62),
    SimpleBubbleMatrixCell(xLabel: 'Quality', yLabel: 'Support', value: 78),
    SimpleBubbleMatrixCell(xLabel: 'Reach', yLabel: 'Support', value: 52),
    SimpleBubbleMatrixCell(xLabel: 'Risk', yLabel: 'Support', value: 48),
  ];
}
