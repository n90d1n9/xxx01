import 'section_order.dart';

class PresentationProfile {
  final String id;
  final String label;
  final SectionOrder sectionOrder;

  const PresentationProfile({
    required this.id,
    required this.label,
    this.sectionOrder = SectionOrder.defaultOrder,
  });

  static const standard = PresentationProfile(
    id: 'standard',
    label: 'Standard workspace',
  );

  static const operationsFirst = PresentationProfile(
    id: 'operations_first',
    label: 'Operations first workspace',
    sectionOrder: SectionOrder.operationsFirstOrder,
  );
}
