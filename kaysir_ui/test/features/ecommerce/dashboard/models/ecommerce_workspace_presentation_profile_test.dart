import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/presentation_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';

void main() {
  test('standard profile keeps the default workspace section order', () {
    expect(PresentationProfile.standard.id, 'standard');
    expect(
      PresentationProfile.standard.sectionOrder,
      SectionOrder.defaultOrder,
    );
  });

  test('operations-first profile can prioritize operational work', () {
    final order = PresentationProfile.operationsFirst.sectionOrder;

    expect(PresentationProfile.operationsFirst.id, 'operations_first');
    expect(order.slots.first, SectionSlot.operations);
    expect(order.slots, SectionOrder.operationsFirstSlots);
  });
}
