import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CombinedChart extends StatelessWidget {
  const CombinedChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ChartData> data = [
      ChartData('Mon', 2.0, 2.6, 2.0),
      ChartData('Tue', 4.9, 5.9, 2.2),
      ChartData('Wed', 7.0, 9.0, 3.3),
      ChartData('Thu', 23.2, 26.4, 4.5),
      ChartData('Fri', 25.6, 28.7, 6.3),
      ChartData('Sat', 76.7, 70.7, 10.2),
      ChartData('Sun', 135.6, 175.6, 20.3),
    ];

    final List<charts.Series<ChartData, String>> seriesList = [
      charts.Series<ChartData, String>(
        id: 'Evaporation',
        domainFn: (ChartData data, _) => data.day,
        measureFn: (ChartData data, _) => data.evaporation,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        displayName: 'Evaporation',
      ),
      charts.Series<ChartData, String>(
        id: 'Precipitation',
        domainFn: (ChartData data, _) => data.day,
        measureFn: (ChartData data, _) => data.precipitation,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        displayName: 'Precipitation',
      ),
      charts.Series<ChartData, String>(
        id: 'Temperature',
        domainFn: (ChartData data, _) => data.day,
        measureFn: (ChartData data, _) => data.temperature,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        displayName: 'Temperature',
      )..setAttribute(charts.rendererIdKey, 'customLine'),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Weather Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: charts.OrdinalComboChart(
                seriesList,
                animate: true,
                defaultRenderer: charts.BarRendererConfig(
                  groupingType: charts.BarGroupingType.grouped,
                  strokeWidthPx: 1.0,
                ),
                customSeriesRenderers: [
                  charts.LineRendererConfig(
                    customRendererId: 'customLine',
                    includeArea: false,
                    stacked: false,
                  ),
                ],
                primaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                    desiredMinTickCount: 6,
                    desiredMaxTickCount: 10,
                  ),
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                  viewport: const charts.NumericExtents(0, 250),
                ),
                secondaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                    desiredMinTickCount: 6,
                    desiredMaxTickCount: 10,
                  ),
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                  viewport: const charts.NumericExtents(0, 25),
                ),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                ),
                behaviors: [
                  charts.SeriesLegend(
                    position: charts.BehaviorPosition.top,
                    outsideJustification: charts.OutsideJustification.startDrawArea,
                    horizontalFirst: false,
                    desiredMaxRows: 2,
                    cellPadding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                  ),
                  charts.ChartTitle(
                    'Precipitation (ml)',
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                  ),
                  charts.ChartTitle(
                    'Temperature (°C)',
                    behaviorPosition: charts.BehaviorPosition.end,
                    titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String day;
  final double evaporation;
  final double precipitation;
  final double temperature;

  ChartData(this.day, this.evaporation, this.precipitation, this.temperature);
}