import 'package:tenun/tenun_core.dart';

Map<String, dynamic> buildPayloadNormalizationBrokenPayload(String type) {
  if (type == 'pie') {
    return {
      'type': 'pie',
      'title': {'text': 'Broken Pie Payload'},
      'dataMode': 'turbo',
      'sampling': {'enabled': 'yes', 'threshold': 0, 'strategy': 'fastest'},
      'series': [
        {
          'name': 'Share',
          'data': [
            {'name': 'A', 'value': 35},
            {'name': 'B', 'value': 25},
            {'name': 'C', 'value': 40},
          ],
        },
      ],
    };
  }

  if (type == 'renko') {
    return {
      'type': 'renko',
      'title': {'text': 'Broken Renko Payload'},
      'dataMode': 'large',
      'sampling': {'enabled': true, 'threshold': 8, 'strategy': 'nth'},
      'brickSize': -2,
      'series': [
        {
          'name': 'Price',
          'data': [
            100,
            '101',
            {'close': 102},
            {'value': '103.5'},
            [1, 2, 3, 104],
            'bad',
            null,
            105,
          ],
        },
      ],
    };
  }

  if (type == 'kagi') {
    return {
      'type': 'kagi',
      'title': {'text': 'Broken Kagi Payload'},
      'reversalPct': 0,
      'dataMode': 'large',
      'sampling': {'enabled': true, 'threshold': 10, 'strategy': 'minmax'},
      'series': [
        {
          'name': 'Price',
          'data': [
            100,
            '98',
            95,
            {'close': 103},
            'bad',
            105,
          ],
        },
      ],
    };
  }

  if (type == 'macd') {
    return {
      'type': 'macd',
      'title': {'text': 'Broken MACD Payload'},
      'fast': 26,
      'slow': 12,
      'signal': 0,
      'dataMode': 'large',
      'sampling': {'enabled': true, 'threshold': 6, 'strategy': 'nth'},
      'series': [
        {
          'name': 'Price',
          'data': [
            '100',
            101,
            {'close': 102},
            'bad',
            103,
            104,
            105,
          ],
        },
      ],
    };
  }

  return {
    'type': 'line',
    'title': {'text': 'Broken Line Payload'},
    'xAxis': {
      'data': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    },
    'dataMode': 'turbo',
    'sampling': {'enabled': 'yes', 'threshold': 0, 'strategy': 'fastest'},
    'series': [
      {
        'name': 'Revenue',
        'data': [120, 138, 110, 150, 160, 170],
      },
    ],
  };
}

ChartDataMode parsePayloadNormalizationMode(String raw) {
  switch (raw) {
    case 'regular':
      return ChartDataMode.regular;
    case 'large':
      return ChartDataMode.large;
    default:
      return ChartDataMode.auto;
  }
}
