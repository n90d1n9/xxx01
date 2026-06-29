import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/traffic_data.dart';
import 'api_provider.dart';

final trafficDataProvider = FutureProvider<List<TrafficData>>((ref) {
  return ref.read(apiServiceProvider).getTrafficData();
});
