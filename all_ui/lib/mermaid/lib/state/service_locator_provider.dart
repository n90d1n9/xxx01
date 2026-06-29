import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/ai_service.dart';
import '../service/analytic_service.dart';
import '../service/cache_service.dart';
import '../service/idata_service.dart';
import '../service/service_locator.dart';
import '../service/template_service.dart';
import '../service/unified_data_service.dart';

final serviceLocatorProvider = Provider((ref) {
  final locator = ServiceLocator();
  locator.register<IDataService>(UnifiedDataService());
  locator.register<AIService>(AIService());
  locator.register<CacheService>(CacheService());
  locator.register<AnalyticsService>(AnalyticsService());
  locator.register<TemplateService>(TemplateService());
  return locator;
});
