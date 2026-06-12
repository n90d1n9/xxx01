import 'restaurant_models.dart';
import 'restaurant_reservation.dart';

class RestaurantReservationZoneLoad {
  const RestaurantReservationZoneLoad({
    required this.zoneLabel,
    required this.reservations,
    this.dueSoonMinutes = 15,
  });

  static List<RestaurantReservationZoneLoad> loadsFor(
    Iterable<RestaurantReservation> reservations, {
    int dueSoonMinutes = 15,
  }) {
    final byZone = <String, List<RestaurantReservation>>{};

    for (final reservation in reservations) {
      if (reservation.status.isClosed) continue;
      final zoneLabel = reservation.zoneLabel.trim().isEmpty
          ? 'Unassigned'
          : reservation.zoneLabel.trim();
      byZone.putIfAbsent(zoneLabel, () => []).add(reservation);
    }

    final loads = [
      for (final entry in byZone.entries)
        RestaurantReservationZoneLoad(
          zoneLabel: entry.key,
          reservations: entry.value
            ..sort(
              (a, b) =>
                  a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow),
            ),
          dueSoonMinutes: dueSoonMinutes,
        ),
    ];

    loads.sort((a, b) {
      final statusComparison = b._statusRank.compareTo(a._statusRank);
      if (statusComparison != 0) return statusComparison;
      final coverComparison = b.coverCount.compareTo(a.coverCount);
      if (coverComparison != 0) return coverComparison;
      return a.zoneLabel.compareTo(b.zoneLabel);
    });

    return loads;
  }

  final String zoneLabel;
  final List<RestaurantReservation> reservations;
  final int dueSoonMinutes;

  int get bookingCount => reservations.length;

  int get coverCount {
    return reservations.fold(
      0,
      (total, reservation) => total + reservation.partySize,
    );
  }

  int get pendingCount {
    return reservations
        .where((reservation) => reservation.isPendingArrival)
        .length;
  }

  int get lateCount {
    return reservations
        .where((reservation) => reservation.needsLateRecovery)
        .length;
  }

  int get dueSoonCount {
    return reservations
        .where(
          (reservation) =>
              reservation.isPendingArrival &&
              reservation.arrivalMinutesFromNow >= 0 &&
              reservation.arrivalMinutesFromNow <= dueSoonMinutes,
        )
        .length;
  }

  int get inHouseCount {
    return reservations.where((reservation) => reservation.isInHouse).length;
  }

  int get vipCount {
    return reservations.where((reservation) => reservation.isVip).length;
  }

  int get attentionCount => lateCount + dueSoonCount + vipCount;

  RestaurantServiceStatus get serviceStatus {
    if (lateCount > 0) return RestaurantServiceStatus.critical;
    if (dueSoonCount > 0 || vipCount > 0) return RestaurantServiceStatus.busy;
    return RestaurantServiceStatus.calm;
  }

  String get bookingLabel {
    return '$bookingCount ${bookingCount == 1 ? 'booking' : 'bookings'}';
  }

  String get coverLabel {
    return '$coverCount ${coverCount == 1 ? 'cover' : 'covers'}';
  }

  String get pressureLabel {
    if (lateCount > 0) return '$lateCount late';
    if (dueSoonCount > 0) return '$dueSoonCount due soon';
    if (vipCount > 0) return '$vipCount VIP';
    if (inHouseCount > 0) return '$inHouseCount in house';
    return '$pendingCount pending';
  }

  int get _statusRank {
    return switch (serviceStatus) {
      RestaurantServiceStatus.critical => 3,
      RestaurantServiceStatus.busy => 2,
      RestaurantServiceStatus.calm => 1,
      RestaurantServiceStatus.blocked => 0,
    };
  }
}
