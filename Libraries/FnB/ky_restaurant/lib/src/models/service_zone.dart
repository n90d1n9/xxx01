import 'core_aliases.dart';

/// Describes floor capacity, demand, and pressure for one service zone.
class RestaurantServiceZone {
  const RestaurantServiceZone({
    required this.id,
    required this.name,
    required this.section,
    required this.occupiedTables,
    required this.totalTables,
    required this.covers,
    required this.waitList,
    required this.ticketMinutes,
    required this.status,
  });

  final String id;
  final String name;
  final String section;
  final int occupiedTables;
  final int totalTables;
  final int covers;
  final int waitList;
  final int ticketMinutes;
  final RestaurantServiceStatus status;

  int get availableTables => totalTables - occupiedTables;

  double get occupancyRate {
    if (totalTables == 0) return 0;
    return occupiedTables / totalTables;
  }

  RestaurantServiceZone copyWith({
    String? name,
    String? section,
    int? occupiedTables,
    int? totalTables,
    int? covers,
    int? waitList,
    int? ticketMinutes,
    RestaurantServiceStatus? status,
  }) {
    return RestaurantServiceZone(
      id: id,
      name: name ?? this.name,
      section: section ?? this.section,
      occupiedTables: occupiedTables ?? this.occupiedTables,
      totalTables: totalTables ?? this.totalTables,
      covers: covers ?? this.covers,
      waitList: waitList ?? this.waitList,
      ticketMinutes: ticketMinutes ?? this.ticketMinutes,
      status: status ?? this.status,
    );
  }
}
