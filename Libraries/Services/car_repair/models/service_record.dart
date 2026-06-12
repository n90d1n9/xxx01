class ServiceRecord {
  final String id;
  final String vehicleId;
  final String serviceType;
  final DateTime date;
  final int mileage;
  final double cost;
  final String description;
  final String shopName;
  final String status;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.description,
    required this.shopName,
    required this.status,
  });
}
