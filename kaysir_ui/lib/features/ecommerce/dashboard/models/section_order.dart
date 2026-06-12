enum SectionSlot {
  header,
  channelStrategy,
  kpis,
  health,
  registryNotice,
  destinations,
  operations,
}

class SectionOrder {
  final List<SectionSlot> slots;

  const SectionOrder({this.slots = defaultSlots});

  static const defaultSlots = <SectionSlot>[
    SectionSlot.header,
    SectionSlot.channelStrategy,
    SectionSlot.kpis,
    SectionSlot.health,
    SectionSlot.registryNotice,
    SectionSlot.destinations,
    SectionSlot.operations,
  ];

  static const primarySlots = <SectionSlot>[
    SectionSlot.header,
    SectionSlot.channelStrategy,
    SectionSlot.kpis,
    SectionSlot.health,
    SectionSlot.registryNotice,
    SectionSlot.destinations,
  ];

  static const primaryOrder = SectionOrder(slots: primarySlots);

  static const operationsFirstSlots = <SectionSlot>[
    SectionSlot.operations,
    SectionSlot.header,
    SectionSlot.channelStrategy,
    SectionSlot.kpis,
    SectionSlot.health,
    SectionSlot.registryNotice,
    SectionSlot.destinations,
  ];

  static const defaultOrder = SectionOrder();
  static const operationsFirstOrder = SectionOrder(slots: operationsFirstSlots);

  bool get hasSlots => slots.isNotEmpty;
}
