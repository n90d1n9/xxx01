import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'pos_layout_strategy.dart';

export 'pos_layout_strategy.dart';

final posLayoutPreferenceProvider = StateProvider<POSLayoutPreference>(
  (ref) => POSLayoutPreference.auto,
);

POSLayoutStrategy resolvePOSLayoutStrategy({
  required POSLayoutPreference preference,
  required double width,
}) {
  return defaultPOSLayoutStrategyRegistry
      .resolve(preference: preference, width: width)
      .strategy;
}
