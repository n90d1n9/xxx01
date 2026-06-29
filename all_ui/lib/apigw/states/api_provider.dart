// Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_gateway_service.dart';

final apiServiceProvider = Provider<ApiGatewayService>((ref) {
  return ApiGatewayService();
});
