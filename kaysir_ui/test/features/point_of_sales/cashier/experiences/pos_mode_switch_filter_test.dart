import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_filter.dart';

void main() {
  test('mode switch filter searches labels and mode metadata', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));

    final quickResult = const POSModeSwitchFilter(query: 'quick').apply(state);
    expect(quickResult.matchCount, 1);
    expect(quickResult.options.single.id, quickCheckoutPOSExperience.id);

    final mobileResult = const POSModeSwitchFilter(
      query: 'mobile',
    ).apply(state);
    expect(
      mobileResult.options.map((option) => option.id),
      containsAll([defaultPOSExperience.id, quickCheckoutPOSExperience.id]),
    );
  });

  test('mode switch filter narrows by readiness status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));

    final readyResult = const POSModeSwitchFilter(
      status: POSModeSwitchFilterStatus.launchReady,
    ).apply(state);
    expect(readyResult.options.map((option) => option.id), [
      defaultPOSExperience.id,
    ]);

    final reviewResult = const POSModeSwitchFilter(
      status: POSModeSwitchFilterStatus.review,
    ).apply(state);
    expect(reviewResult.options.map((option) => option.id), [
      assistedServicePOSExperience.id,
      ecommercePOSExperience.id,
    ]);

    final confirmResult = const POSModeSwitchFilter(
      status: POSModeSwitchFilterStatus.confirm,
    ).apply(state);
    expect(confirmResult.options.map((option) => option.id), [
      quickCheckoutPOSExperience.id,
    ]);
  });

  test('mode switch filter keeps empty search results explicit', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));

    final result = const POSModeSwitchFilter(query: 'salon').apply(state);

    expect(result.isEmpty, isTrue);
    expect(result.totalCount, 4);
  });
}
