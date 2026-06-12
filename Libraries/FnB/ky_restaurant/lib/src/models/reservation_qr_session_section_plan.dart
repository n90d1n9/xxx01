/// Identifies a renderable section in the reservation QR session panel.
enum RestaurantReservationQrSessionSection {
  summary,
  activeLink,
  scanStatus,
  selectedAction,
  activityTrail,
}

/// Describes which QR session panel sections should be rendered and in order.
class RestaurantReservationQrSessionSectionPlan {
  const RestaurantReservationQrSessionSectionPlan({required this.sections});

  final List<RestaurantReservationQrSessionSection> sections;

  bool get isEmpty => sections.isEmpty;

  bool contains(RestaurantReservationQrSessionSection section) {
    return sections.contains(section);
  }
}
