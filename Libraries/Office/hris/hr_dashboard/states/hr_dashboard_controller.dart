import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'metric_provider.dart';

final hrDashboardRefreshDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 800),
);

final hrDashboardControllerProvider = Provider<HRDashboardController>(
  (ref) => HRDashboardController(ref),
);

class HRDashboardController {
  final Ref _ref;

  const HRDashboardController(this._ref);

  Future<void> changePeriod(String? period) async {
    if (period == null) return;

    _ref.read(selectedPeriodProvider.notifier).state = period;
    await refresh();
  }

  Future<void> refresh() async {
    _ref.read(isLoadingProvider.notifier).state = true;

    try {
      await Future<void>.delayed(_ref.read(hrDashboardRefreshDelayProvider));
      _ref.read(dashboardLastUpdatedProvider.notifier).state =
          _ref.read(hrDashboardClockProvider)();
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
