class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });
}
