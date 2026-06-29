import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/alert.dart';
import '../models/analytic_data.dart';
import '../models/api_key.dart';
import '../models/api_performance.dart';
import '../models/api_usage_data.dart';
import '../models/endpoint_data.dart';
import '../models/enums.dart';
import '../models/error_log.dart';
import 'analytic_controller.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);
final usageDataProvider = FutureProvider<List<ApiUsageData>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    ApiUsageData(name: 'Authentication', calls: 12453, growth: 23),
    ApiUsageData(name: 'Data Processing', calls: 8721, growth: -5),
    ApiUsageData(name: 'Storage', calls: 15234, growth: 17),
    ApiUsageData(name: 'Analytics', calls: 6542, growth: 8),
  ];
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    Project(
      id: '1',
      name: 'Production API',
      status: ProjectStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      apis: ['Authentication', 'Data Processing', 'Storage'],
    ),
    Project(
      id: '2',
      name: 'Beta Analytics',
      status: ProjectStatus.warning,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      apis: ['Analytics', 'Storage'],
    ),
    Project(
      id: '3',
      name: 'Dev Environment',
      status: ProjectStatus.inactive,
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      apis: ['Authentication', 'Analytics'],
    ),
  ];
});

final apiKeysProvider = FutureProvider<List<ApiKey>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    ApiKey(
      id: 'apikey_prod_123456',
      name: 'Production Key',
      /* created: DateTime.now().subtract(const Duration(days: 90)),
      expires: DateTime.now().add(const Duration(days: 275)),
      lastUsed: DateTime.now().subtract(const Duration(minutes: 5)), */
      status: ApiKeyStatus.active.toString(),
    ),
    ApiKey(
      id: 'apikey_dev_789012',
      name: 'Development Key',
      /* created: DateTime.now().subtract(const Duration(days: 30)),
      expires: DateTime.now().add(const Duration(days: 335)),
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)), */
      status: ApiKeyStatus.active.toString(),
    ),
    ApiKey(
      id: 'apikey_test_345678',
      name: 'Test Environment',
      /* created: DateTime.now().subtract(const Duration(days: 120)),
      expires: DateTime.now().subtract(const Duration(days: 10)),
      lastUsed: DateTime.now().subtract(const Duration(days: 15)), */
      status: ApiKeyStatus.expired.toString(),
    ),
  ];
});

final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    Alert(
      id: '1',
      title: 'API Rate Limit Approaching',
      message: 'Your Authentication API is at 85% of its rate limit',
      severity: AlertSeverity.warning,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    Alert(
      id: '2',
      title: 'New Security Advisory',
      message: 'Security update available for your Storage API integration',
      severity: AlertSeverity.info,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    Alert(
      id: '3',
      title: 'API Key Expiring',
      message: 'Your Test Environment API key will expire in 10 days',
      severity: AlertSeverity.critical,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
  ];
});

final timeframeProvider = StateProvider<String>((ref) => 'Daily');

final analyticsDataProvider = FutureProvider<AnalyticsData>((ref) async {
  final timeframe = ref.watch(timeframeProvider);
  // Simulate API call delay
  await Future.delayed(const Duration(milliseconds: 800));

  // Generate random data (would come from API in real app)
  return AnalyticsData(
    authApiSpots: generateRandomSpots(30, 600, 1400),
    dataApiSpots: generateRandomSpots(30, 200, 800),
    totalApiCalls: '42,950',
    apiCallsChange: '+15%',
    apiCallsPositive: true,
    avgResponseTime: '127ms',
    responseTimeChange: '-5%',
    responseTimePositive: true,
    errorRate: '0.8%',
    errorRateChange: '+0.2%',
    errorRatePositive: false,
    totalErrors: 341,
    apiPerformances: [
      ApiPerformance(
        name: 'Authentication',
        responseTime: '102ms',
        errorRate: '0.5%',
        uptime: '99.9%',
      ),
      ApiPerformance(
        name: 'Data Processing',
        responseTime: '245ms',
        errorRate: '1.2%',
        uptime: '99.8%',
      ),
      ApiPerformance(
        name: 'Data Processing',
        responseTime: '245ms',
        errorRate: '1.2%',
        uptime: '99.8%',
      ),
      ApiPerformance(
        name: 'Storage',
        responseTime: '89ms',
        errorRate: '0.3%',
        uptime: '100%',
      ),
      ApiPerformance(
        name: 'Analytics',
        responseTime: '167ms',
        errorRate: '1.1%',
        uptime: '99.7%',
      ),
    ],
    endpoints: [
      EndpointData(
        path: '/api/v1/auth/token',
        callCount: '8,453',
        change: '+12%',
        percentage: 0.8,
      ),
      EndpointData(
        path: '/api/v1/data/process',
        callCount: '6,254',
        change: '+8%',
        percentage: 0.6,
      ),
      EndpointData(
        path: '/api/v1/storage/upload',
        callCount: '5,872',
        change: '+21%',
        percentage: 0.55,
      ),
      EndpointData(
        path: '/api/v1/analytics/events',
        callCount: '3,984',
        change: '-3%',
        percentage: 0.35,
      ),
      EndpointData(
        path: '/api/v1/users/profile',
        callCount: '3,145',
        change: '+5%',
        percentage: 0.3,
      ),
    ],
    errorLogs: [
      ErrorLog(
        time: '15:32:21',
        message: 'Invalid Authentication Token',
        endpoint: '/api/v1/auth/verify',
        status: 401,
      ),
      ErrorLog(
        time: '14:23:15',
        message: 'Rate Limit Exceeded',
        endpoint: '/api/v1/data/process',
        status: 429,
      ),
      ErrorLog(
        time: '12:45:08',
        message: 'Resource Not Found',
        endpoint: '/api/v1/storage/file/123',
        status: 404,
      ),
      ErrorLog(
        time: '09:21:54',
        message: 'Bad Request Format',
        endpoint: '/api/v1/analytics/events',
        status: 400,
      ),
      ErrorLog(
        time: '08:12:39',
        message: 'Server Process Error',
        endpoint: '/api/v1/data/transform',
        status: 500,
      ),
    ],
  );
});
