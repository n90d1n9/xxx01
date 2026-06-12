/// Represents the lifecycle state of a reservation during service.
enum RestaurantReservationStatus {
  requested,
  confirmed,
  arrived,
  seated,
  completed,
  late,
  cancelled,
  noShow;

  String get label => switch (this) {
    RestaurantReservationStatus.requested => 'Requested',
    RestaurantReservationStatus.confirmed => 'Confirmed',
    RestaurantReservationStatus.arrived => 'Arrived',
    RestaurantReservationStatus.seated => 'Seated',
    RestaurantReservationStatus.completed => 'Completed',
    RestaurantReservationStatus.late => 'Late',
    RestaurantReservationStatus.cancelled => 'Cancelled',
    RestaurantReservationStatus.noShow => 'No-show',
  };

  bool get isOpen => switch (this) {
    RestaurantReservationStatus.requested ||
    RestaurantReservationStatus.confirmed ||
    RestaurantReservationStatus.arrived ||
    RestaurantReservationStatus.seated ||
    RestaurantReservationStatus.late => true,
    RestaurantReservationStatus.completed ||
    RestaurantReservationStatus.cancelled ||
    RestaurantReservationStatus.noShow => false,
  };

  bool get isClosed => !isOpen;

  bool get isNegative => switch (this) {
    RestaurantReservationStatus.late ||
    RestaurantReservationStatus.cancelled ||
    RestaurantReservationStatus.noShow => true,
    _ => false,
  };
}

/// Identifies how a reservation entered the restaurant booking flow.
enum RestaurantReservationSource {
  online,
  phone,
  concierge,
  walkIn,
  event,
  qrCode;

  String get label => switch (this) {
    RestaurantReservationSource.online => 'Online',
    RestaurantReservationSource.phone => 'Phone',
    RestaurantReservationSource.concierge => 'Concierge',
    RestaurantReservationSource.walkIn => 'Walk-in',
    RestaurantReservationSource.event => 'Event',
    RestaurantReservationSource.qrCode => 'QR code',
  };
}

/// Captures one guest booking with timing, seating, source, and status signals.
class RestaurantReservation {
  const RestaurantReservation({
    required this.id,
    required this.guestName,
    required this.partySize,
    required this.timeLabel,
    required this.arrivalMinutesFromNow,
    required this.zoneLabel,
    required this.status,
    required this.source,
    this.tableLabel,
    this.phoneNumber,
    this.emailAddress,
    this.notes,
    this.isVip = false,
  });

  final String id;
  final String guestName;
  final int partySize;
  final String timeLabel;
  final int arrivalMinutesFromNow;
  final String zoneLabel;
  final String? tableLabel;
  final String? phoneNumber;
  final String? emailAddress;
  final RestaurantReservationStatus status;
  final RestaurantReservationSource source;
  final String? notes;
  final bool isVip;

  bool get isUpcoming {
    return isPendingArrival;
  }

  bool get isPendingArrival {
    return status == RestaurantReservationStatus.requested ||
        status == RestaurantReservationStatus.confirmed;
  }

  bool get needsLateRecovery {
    return status == RestaurantReservationStatus.late ||
        (isPendingArrival && arrivalMinutesFromNow < 0);
  }

  bool get isInHouse {
    return status == RestaurantReservationStatus.arrived ||
        status == RestaurantReservationStatus.seated;
  }

  String get partyLabel => '$partySize ${partySize == 1 ? 'guest' : 'guests'}';

  String get seatingLabel {
    return tableLabel == null || tableLabel!.trim().isEmpty
        ? zoneLabel
        : '$zoneLabel - $tableLabel';
  }

  RestaurantReservation copyWith({
    String? guestName,
    int? partySize,
    String? timeLabel,
    int? arrivalMinutesFromNow,
    String? zoneLabel,
    String? tableLabel,
    String? phoneNumber,
    String? emailAddress,
    RestaurantReservationStatus? status,
    RestaurantReservationSource? source,
    String? notes,
    bool? isVip,
  }) {
    return RestaurantReservation(
      id: id,
      guestName: guestName ?? this.guestName,
      partySize: partySize ?? this.partySize,
      timeLabel: timeLabel ?? this.timeLabel,
      arrivalMinutesFromNow:
          arrivalMinutesFromNow ?? this.arrivalMinutesFromNow,
      zoneLabel: zoneLabel ?? this.zoneLabel,
      tableLabel: tableLabel ?? this.tableLabel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      status: status ?? this.status,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      isVip: isVip ?? this.isVip,
    );
  }
}
