import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_checker.dart';

final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return NetworkChecker();
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final checker = ref.watch(networkCheckerProvider);
  return checker.onStatusChangeDetailed();
});
