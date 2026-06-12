class WarehouseLocation {
  final String id;
  final String name;
  final String zone;
  final String rack;
  final String level;
  final String position;

  WarehouseLocation({
    required this.id,
    required this.name,
    required this.zone,
    required this.rack,
    required this.level,
    required this.position,
  });

  factory WarehouseLocation.fromMap(Map<String, dynamic> map) {
    return WarehouseLocation(
      id: map['id'],
      name: map['name'],
      zone: map['zone'],
      rack: map['rack'],
      level: map['level'],
      position: map['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'zone': zone,
      'rack': rack,
      'level': level,
      'position': position,
    };
  }

  String get fullLocation => '$zone-$rack-$level-$position';
}
