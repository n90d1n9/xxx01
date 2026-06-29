class RepairShop {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String website;
  final double rating;
  final int reviewCount;
  final List<String> services;
  final String openHours;
  final bool isOpen;
  final double distance; // In miles from current location

  RepairShop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.website,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.openHours,
    required this.isOpen,
    required this.distance,
  });
}
