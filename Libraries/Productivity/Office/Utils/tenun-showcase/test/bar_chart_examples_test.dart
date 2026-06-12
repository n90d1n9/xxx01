import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_showcase/example/bar_chart_examples.dart';

void main() {
  test('bar sample builders preserve variant flags', () {
    final grouped = BarChartSamples.grouped(showTooltip: false);
    final stacked = BarChartSamples.stacked();
    final horizontal = BarChartSamples.horizontal();
    final simple = BarChartSamples.simple();

    expect(simple.series.single.name, 'Sales');
    expect(grouped.isMultiBar, isTrue);
    expect(grouped.tooltip?.show, isFalse);
    expect(stacked.isStacked, isTrue);
    expect(stacked.series.every((series) => series.stack == 'total'), isTrue);
    expect(horizontal.isHorizontal, isTrue);
    expect(horizontal.xAxis?.type, AxisType.value);
    expect(horizontal.yAxis?.type, AxisType.category);
  });

  test('interactive bar config builds regular mode payload', () {
    final config = buildBarInteractiveConfig(
      showTooltip: false,
      dataMode: 'regular',
      pointCount: 2500,
      samplingThreshold: 600,
      samplingStrategyIndex: 1,
    );
    final sampling = config['sampling'] as Map<String, dynamic>;
    final series = config['series'] as List<dynamic>;
    final data = (series.first as Map<String, dynamic>)['data'] as List<double>;

    expect(config['dataMode'], 'regular');
    expect(config['barWidth'], 20);
    expect((config['tooltip'] as Map<String, dynamic>)['show'], isFalse);
    expect(sampling['enabled'], isFalse);
    expect(data, hasLength(7));
  });

  test('interactive bar config builds large sampled payload', () {
    final config = buildBarInteractiveConfig(
      showTooltip: true,
      dataMode: 'large',
      pointCount: 42,
      samplingThreshold: 700,
      samplingStrategyIndex: 3,
    );
    final xAxis = config['xAxis'] as Map<String, dynamic>;
    final sampling = config['sampling'] as Map<String, dynamic>;
    final series = config['series'] as List<dynamic>;
    final data = (series.first as Map<String, dynamic>)['data'] as List<double>;

    expect(config['dataMode'], 'large');
    expect(config['barWidth'], 6);
    expect(xAxis['data'], hasLength(100));
    expect(data, hasLength(100));
    expect(sampling['enabled'], isTrue);
    expect(sampling['threshold'], 700);
    expect(sampling['strategy'], 'nth');
  });

  test('interactive bar helper maps point count and sampling strategy', () {
    expect(barInteractivePointCount(dataMode: 'regular', pointCount: 2500), 7);
    expect(barInteractivePointCount(dataMode: 'auto', pointCount: 42), 100);
    expect(barInteractivePointCount(dataMode: 'auto', pointCount: 2500), 2500);
    expect(barSamplingStrategyName(0), isNull);
    expect(barSamplingStrategyName(1), 'lttb');
    expect(barSamplingStrategyName(2), 'minMax');
    expect(barSamplingStrategyName(3), 'nth');
    expect(barSamplingStrategyName(99), isNull);
  });
}
