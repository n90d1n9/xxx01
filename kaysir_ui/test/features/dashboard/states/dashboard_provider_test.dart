import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/dashboard/states/dashboard_provider.dart';

void main() {
  test('dashboard data follows the selected period filter', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final thisWeek = await container.read(dashboardDataProvider.future);

    container.read(selectedFilterProvider.notifier).state =
        DashboardFilters.thisMonth;
    final reloading = container.read(dashboardDataProvider);

    expect(reloading.isLoading, isTrue);
    expect(reloading.hasValue, isTrue);
    expect(reloading.requireValue.photos, thisWeek.photos);

    final thisMonth = await container.read(dashboardDataProvider.future);

    expect(thisWeek.photos, isNot(thisMonth.photos));
    expect(thisMonth.photos, 486200);
    expect(thisMonth.topProducts.first.name, 'Ramadan Promo Pack');
    expect(thisMonth.salesData, hasLength(thisWeek.salesData.length));
    expect(
      DashboardFilters.previousSeriesLabel(DashboardFilters.thisMonth),
      'Last month',
    );
  });
}
