import 'restaurant_models.dart';

/// Summarizes floor-zone readiness, occupancy, waitlist, and ticket pace.
class RestaurantFloorSummary {
  const RestaurantFloorSummary({
    required this.zoneCount,
    required this.attentionCount,
    required this.waitlistCount,
    required this.calmCount,
    required this.occupiedTables,
    required this.totalTables,
    required this.totalCovers,
    required this.totalWaitList,
    required this.averageTicketMinutes,
  });

  factory RestaurantFloorSummary.fromZones(List<RestaurantServiceZone> zones) {
    var attentionCount = 0;
    var waitlistCount = 0;
    var occupiedTables = 0;
    var totalTables = 0;
    var totalCovers = 0;
    var totalWaitList = 0;
    var ticketMinutesTotal = 0;

    for (final zone in zones) {
      if (zone.status != RestaurantServiceStatus.calm) attentionCount += 1;
      if (zone.waitList > 0) waitlistCount += 1;
      occupiedTables += zone.occupiedTables;
      totalTables += zone.totalTables;
      totalCovers += zone.covers;
      totalWaitList += zone.waitList;
      ticketMinutesTotal += zone.ticketMinutes;
    }

    return RestaurantFloorSummary(
      zoneCount: zones.length,
      attentionCount: attentionCount,
      waitlistCount: waitlistCount,
      calmCount: zones.length - attentionCount,
      occupiedTables: occupiedTables,
      totalTables: totalTables,
      totalCovers: totalCovers,
      totalWaitList: totalWaitList,
      averageTicketMinutes: zones.isEmpty
          ? 0
          : (ticketMinutesTotal / zones.length).round(),
    );
  }

  final int zoneCount;
  final int attentionCount;
  final int waitlistCount;
  final int calmCount;
  final int occupiedTables;
  final int totalTables;
  final int totalCovers;
  final int totalWaitList;
  final int averageTicketMinutes;

  double get occupancyRate {
    if (totalTables == 0) return 0;
    return occupiedTables / totalTables;
  }

  String get readinessLabel => attentionCount == 1
      ? '1 zone needs attention'
      : '$attentionCount zones need attention';
}
