import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/idata_service.dart';
import 'service_locator_provider.dart';

final dataServiceProvider = Provider<IDataService>((ref) {
  return ref.read(serviceLocatorProvider).get<IDataService>();
});
