import 'dart:convert';

class ServicePoint {
  int id;
  String name;
  String? displayName;
  String? description;
  String? location;
  int? floorNumber;
  bool isActive;
  bool isVirtual;
  int capacity;
  int displayOrder;
  int? currentTicketId;
  int? lastTicketId;
  String? customPIN;
  String? ipAddress;
  String? macAddress;
  String? deviceId;
  String? photoUrl;
  String? videoCallUrl;
  DateTime createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? updatedBy;
  ServicePointStatus status;
  ServicePointType type;

  ServicePoint({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    this.location,
    this.floorNumber,
    this.isActive = true,
    this.isVirtual = false,
    this.capacity = 1,
    this.displayOrder = 0,
    this.currentTicketId,
    this.lastTicketId,
    this.customPIN,
    this.ipAddress,
    this.macAddress,
    this.deviceId,
    this.photoUrl,
    this.videoCallUrl,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.status = ServicePointStatus.TERSEDIA,
    this.type = ServicePointType.FISIK,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'location': location,
      'floorNumber': floorNumber,
      'isActive': isActive,
      'isVirtual': isVirtual,
      'capacity': capacity,
      'displayOrder': displayOrder,
      'currentTicketId': currentTicketId,
      'lastTicketId': lastTicketId,
      'customPIN': customPIN,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'deviceId': deviceId,
      'photoUrl': photoUrl,
      'videoCallUrl': videoCallUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
    };
  }

  factory ServicePoint.fromMap(Map<String, dynamic> map) {
    return ServicePoint(
      id: map['id'],
      name: map['name'],
      displayName: map['displayName'],
      description: map['description'],
      location: map['location'],
      floorNumber: map['floorNumber'],
      isActive: map['isActive'],
      isVirtual: map['isVirtual'],
      capacity: map['capacity'],
      displayOrder: map['displayOrder'],
      currentTicketId: map['currentTicketId'],
      lastTicketId: map['lastTicketId'],
      customPIN: map['customPIN'],
      ipAddress: map['ipAddress'],
      macAddress: map['macAddress'],
      deviceId: map['deviceId'],
      photoUrl: map['photoUrl'],
      videoCallUrl: map['videoCallUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      status: ServicePointStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      type: ServicePointType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServicePoint.fromJson(String source) =>
      ServicePoint.fromMap(json.decode(source));

  ServicePoint copyWith({
    int? id,
    String? name,
    String? displayName,
    String? description,
    String? location,
    int? floorNumber,
    bool? isActive,
    bool? isVirtual,
    int? capacity,
    int? displayOrder,
    int? currentTicketId,
    int? lastTicketId,
    String? customPIN,
    String? ipAddress,
    String? macAddress,
    String? deviceId,
    String? photoUrl,
    String? videoCallUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    int? updatedBy,
    ServicePointStatus? status,
    ServicePointType? type,
  }) {
    return ServicePoint(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      location: location ?? this.location,
      floorNumber: floorNumber ?? this.floorNumber,
      isActive: isActive ?? this.isActive,
      isVirtual: isVirtual ?? this.isVirtual,
      capacity: capacity ?? this.capacity,
      displayOrder: displayOrder ?? this.displayOrder,
      currentTicketId: currentTicketId ?? this.currentTicketId,
      lastTicketId: lastTicketId ?? this.lastTicketId,
      customPIN: customPIN ?? this.customPIN,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      deviceId: deviceId ?? this.deviceId,
      photoUrl: photoUrl ?? this.photoUrl,
      videoCallUrl: videoCallUrl ?? this.videoCallUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'ServicePoint(id: $id, name: $name, displayName: $displayName, description: $description, location: $location, floorNumber: $floorNumber, isActive: $isActive, isVirtual: $isVirtual, capacity: $capacity, displayOrder: $displayOrder, currentTicketId: $currentTicketId, lastTicketId: $lastTicketId, customPIN: $customPIN, ipAddress: $ipAddress, macAddress: $macAddress, deviceId: $deviceId, photoUrl: $photoUrl, videoCallUrl: $videoCallUrl, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, status: $status, type: $type)';
  }
}

// Enums in Bahasa Indonesia
enum ServicePointStatus { TERSEDIA, SIBUK, TUTUP }

enum ServicePointType { FISIK, VIRTUAL }
