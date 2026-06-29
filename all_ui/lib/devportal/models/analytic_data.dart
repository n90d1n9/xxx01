import 'package:fl_chart/fl_chart.dart';

import 'api_performance.dart';
import 'endpoint_data.dart';
import 'error_log.dart';

class AnalyticsData {
  final List<FlSpot> authApiSpots;
  final List<FlSpot> dataApiSpots;
  final String totalApiCalls;
  final String apiCallsChange;
  final bool apiCallsPositive;
  final String avgResponseTime;
  final String responseTimeChange;
  final bool responseTimePositive;
  final String errorRate;
  final String errorRateChange;
  final bool errorRatePositive;
  final int totalErrors;
  final List<ApiPerformance> apiPerformances;
  final List<EndpointData> endpoints;
  final List<ErrorLog> errorLogs;

  AnalyticsData({
    required this.authApiSpots,
    required this.dataApiSpots,
    required this.totalApiCalls,
    required this.apiCallsChange,
    required this.apiCallsPositive,
    required this.avgResponseTime,
    required this.responseTimeChange,
    required this.responseTimePositive,
    required this.errorRate,
    required this.errorRateChange,
    required this.errorRatePositive,
    required this.totalErrors,
    required this.apiPerformances,
    required this.endpoints,
    required this.errorLogs,
  });
}
