import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';

void main() {
  test('SectionOrder exposes the default workspace order', () {
    expect(SectionOrder.defaultOrder.slots, [
      SectionSlot.header,
      SectionSlot.channelStrategy,
      SectionSlot.kpis,
      SectionSlot.health,
      SectionSlot.registryNotice,
      SectionSlot.destinations,
      SectionSlot.operations,
    ]);
    expect(SectionOrder.defaultOrder.hasSlots, isTrue);
  });

  test('SectionOrder supports product-specific ordering', () {
    const order = SectionOrder(
      slots: [
        SectionSlot.operations,
        SectionSlot.channelStrategy,
        SectionSlot.header,
      ],
    );

    expect(order.slots.first, SectionSlot.operations);
    expect(order.slots.last, SectionSlot.header);
  });
}
