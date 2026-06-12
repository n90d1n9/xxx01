/// Describes whether a menu item can be sold during the current service.
enum FnbMenuAvailability {
  available,
  limited,
  soldOut,
  hidden;

  String get label => switch (this) {
    FnbMenuAvailability.available => 'Available',
    FnbMenuAvailability.limited => 'Limited',
    FnbMenuAvailability.soldOut => 'Sold out',
    FnbMenuAvailability.hidden => 'Hidden',
  };

  bool get canOrder => switch (this) {
    FnbMenuAvailability.available || FnbMenuAvailability.limited => true,
    FnbMenuAvailability.soldOut || FnbMenuAvailability.hidden => false,
  };

  bool get needsAttention => switch (this) {
    FnbMenuAvailability.limited || FnbMenuAvailability.soldOut => true,
    FnbMenuAvailability.available || FnbMenuAvailability.hidden => false,
  };
}
