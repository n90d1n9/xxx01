import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/area_chart_example.dart';

void main() {
  test('interactive area config applies visible toggles', () {
    final config = buildAreaInteractiveConfig(
      showLegend: false,
      showTooltip: false,
      showGrid: false,
      showDots: false,
      gradientArea: false,
      dataMode: 'regular',
      pointCount: 12,
      samplingThreshold: 500,
      samplingStrategyIndex: 0,
    );

    expect((config['legend'] as Map<String, dynamic>)['show'], isFalse);
    expect((config['tooltip'] as Map<String, dynamic>)['show'], isFalse);
    expect((config['grid'] as Map<String, dynamic>)['show'], isFalse);
    expect(config['showDots'], isFalse);
    expect(config['gradientArea'], isFalse);
    expect(config['dataMode'], 'regular');
    expect((config['sampling'] as Map<String, dynamic>)['enabled'], isFalse);
  });

  test('interactive area config expands advanced dataset mode safely', () {
    final config = buildAreaInteractiveConfig(
      showLegend: true,
      showTooltip: true,
      showGrid: true,
      showDots: true,
      gradientArea: true,
      dataMode: 'large',
      pointCount: 42,
      samplingThreshold: 700,
      samplingStrategyIndex: 2,
    );
    final xAxis = config['xAxis'] as Map<String, dynamic>;
    final sampling = config['sampling'] as Map<String, dynamic>;
    final series = config['series'] as List<dynamic>;

    expect(config['dataMode'], 'large');
    expect(sampling['enabled'], isTrue);
    expect(sampling['threshold'], 700);
    expect(sampling['strategy'], 'minMax');
    expect(xAxis['data'], hasLength(100));
    expect((series.first as Map<String, dynamic>)['data'], hasLength(100));
  });

  test('sampling strategy helper maps knob indices', () {
    expect(areaSamplingStrategyName(0), isNull);
    expect(areaSamplingStrategyName(1), 'lttb');
    expect(areaSamplingStrategyName(2), 'minMax');
    expect(areaSamplingStrategyName(3), 'nth');
    expect(areaSamplingStrategyName(99), isNull);
  });

  test('json config cloning does not mutate source samples', () {
    final clone = cloneAreaJsonConfig(AreaChartSamples.smoothJson);
    final cloneLegend = clone['legend'] as Map<String, dynamic>;
    final sourceLegend =
        AreaChartSamples.smoothJson['legend'] as Map<String, dynamic>;

    cloneLegend['show'] = false;

    expect(sourceLegend['show'], isTrue);
    expect(cloneLegend['show'], isFalse);
  });
}
