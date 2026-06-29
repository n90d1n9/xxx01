import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../response/response.dart';

class AdvancedVisualization extends StatelessWidget {
  final List<SurveyResponse> responses;
  final String questionId;
  final VisualizationType visualizationType;

  const AdvancedVisualization({
    super.key,
    required this.responses,
    required this.questionId,
    required this.visualizationType,
  });

  @override
  Widget build(BuildContext context) {
    switch (visualizationType) {
      case VisualizationType.boxPlot:
        return _buildBoxPlot();
      case VisualizationType.histogram:
        return _buildHistogram();
      case VisualizationType.scatterPlot:
        return _buildScatterPlot();
      case VisualizationType.timeSeries:
        return _buildTimeSeries();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBoxPlot() {
    final numericAnswers = _getNumericAnswers();
    final stats = StatisticalCalculator.calculateStatistics(numericAnswers);

    return SizedBox(
      height: 300,
      child: CustomPaint(
        painter: BoxPlotPainter(
          min: numericAnswers.min,
          max: numericAnswers.max,
          q1: stats.percentiles['25th']!,
          median: stats.median,
          q3: stats.percentiles['75th']!,
        ),
      ),
    );
  }

  Widget _buildHistogram() {
    final numericAnswers = _getNumericAnswers();
    final bins = _createHistogramBins(numericAnswers);

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: bins.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.blue,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScatterPlot() {
    return SizedBox(
      height: 300,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: responses.map((response) {
            final x = response.answers[questionId] as num;
            final y = response.submittedAt.millisecondsSinceEpoch.toDouble();
            return ScatterSpot(x.toDouble(), y);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeSeries() {
    final groupedByDate = responses.groupBy(
      (response) => DateTime(
        response.submittedAt.year,
        response.submittedAt.month,
        response.submittedAt.day,
      ),
    );

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: groupedByDate.entries.map((entry) {
                final avgValue = entry.value
                    .map((r) => r.answers[questionId] as num)
                    .average;
                return FlSpot(
                  entry.key.millisecondsSinceEpoch.toDouble(),
                  avgValue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<num> _getNumericAnswers() {
    return responses
        .map((r) => r.answers[questionId])
        .whereType<num>()
        .toList();
  }

  Map<int, int> _createHistogramBins(List<num> data) {
    final min = data.min;
    final max = data.max;
    final binWidth = (max - min) / 10;
    final bins = <int, int>{};

    for (final value in data) {
      final binIndex = ((value - min) ~/ binWidth).toInt();
      bins[binIndex] = (bins[binIndex] ?? 0) + 1;
    }

    return bins;
  }
}
