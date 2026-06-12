import 'package:flutter_riverpod/legacy.dart';

import '../service/ai_service.dart';
import 'service_locator_provider.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return ref.read(serviceLocatorProvider).get<AIService>();
});
