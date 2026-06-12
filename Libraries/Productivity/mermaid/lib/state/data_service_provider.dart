import 'package:flutter_riverpod/legacy.dart';

import '../service/idata_service.dart';
import 'service_locator_provider.dart';

final dataServiceProvider = Provider<IDataService>((ref) {
  return ref.read(serviceLocatorProvider).get<IDataService>();
});
