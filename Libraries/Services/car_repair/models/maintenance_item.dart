class MaintenanceItem {
  final String id;
  final String vehicleId;
  final String type;
  final DateTime lastServiced;
  final int lastServicedMileage;
  final int recommendedIntervalMonths;
  final int recommendedIntervalMiles;
  final double health; // Percentage
  final DateTime? nextDueDate;
  final int? nextDueMileage;

  MaintenanceItem({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.lastServiced,
    required this.lastServicedMileage,
    required this.recommendedIntervalMonths,
    required this.recommendedIntervalMiles,
    required this.health,
    this.nextDueDate,
    this.nextDueMileage,
  });
}
