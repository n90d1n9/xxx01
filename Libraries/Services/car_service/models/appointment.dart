import 'service.dart';

enum AppointmentStatus { scheduled, inProgress, completed, cancelled }

class Appointment {
  final String id;
  final String vehicleId;
  final List<String> serviceIds;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? notes;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleLicensePlate;
  final List<Service>? services;
  final String? vehicleImageUrl;

  final String? serviceNames;

  Appointment({
    this.serviceNames,
    this.services,
    this.vehicleImageUrl,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    required this.id,
    required this.vehicleId,
    required this.serviceIds,
    required this.dateTime,
    required this.status,
    this.vehicleLicensePlate,
    this.notes,
  });

  double get totalPrice => 0; // This would be calculated based on services

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      vehicleId: json['vehicleId'],
      serviceIds: List<String>.from(json['serviceIds']),
      dateTime: DateTime.parse(json['dateTime']),
      status: AppointmentStatus.values.byName(json['status']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceIds': serviceIds,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  Appointment copyWith({
    String? id,
    String? vehicleId,
    List<String>? serviceIds,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceIds: serviceIds ?? this.serviceIds,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
