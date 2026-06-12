import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'menu_signal.dart';

/// Backwards-compatible restaurant name for shared menu signal sorting.
typedef RestaurantMenuSort = FnbMenuSignalSort;

/// Returns menu signals ordered by the requested restaurant operating sort.
List<RestaurantMenuSignal> sortRestaurantMenuSignals(
  Iterable<RestaurantMenuSignal> signals,
  RestaurantMenuSort sort,
) {
  return sortFnbMenuSignals(signals, sort);
}
