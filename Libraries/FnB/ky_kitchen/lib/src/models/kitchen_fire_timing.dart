import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';

/// Estimates when a kitchen ticket should begin firing for on-time service.
class KitchenFireTiming {
  const KitchenFireTiming({
    required this.ticket,
    required this.now,
    required this.averageFireMinutes,
  }) : assert(averageFireMinutes > 0, 'averageFireMinutes must be positive.');

  final KitchenTicket ticket;
  final DateTime now;
  final int averageFireMinutes;

  DateTime get fireAt {
    return ticket.dueAt.subtract(Duration(minutes: averageFireMinutes));
  }

  int get minutesUntilFire {
    return fireAt.difference(now).inMinutes;
  }

  int get minutesUntilDue {
    return ticket.minutesUntilDue(now);
  }

  bool get shouldFireNow {
    return ticket.stage == KitchenTicketStage.queued && minutesUntilFire <= 0;
  }

  bool get isLateToFire {
    return ticket.stage == KitchenTicketStage.queued && minutesUntilFire < 0;
  }

  bool get isInProduction {
    return switch (ticket.stage) {
      KitchenTicketStage.firing ||
      KitchenTicketStage.plating ||
      KitchenTicketStage.ready => true,
      KitchenTicketStage.queued ||
      KitchenTicketStage.served ||
      KitchenTicketStage.cancelled => false,
    };
  }

  FnbServiceStatus get serviceStatus {
    if (!ticket.isOpen) return FnbServiceStatus.calm;
    if (isLateToFire || ticket.isLateAt(now)) return FnbServiceStatus.critical;
    if (shouldFireNow || isInProduction) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  String get primaryLabel {
    if (!ticket.isOpen) return ticket.stage.label;
    if (isInProduction) return ticket.stage.label;
    if (minutesUntilFire == 0) return 'Fire now';
    if (minutesUntilFire < 0) return '${minutesUntilFire.abs()}m late to fire';
    return 'Fire in ${minutesUntilFire}m';
  }

  String get secondaryLabel {
    if (!ticket.isOpen) return 'Closed ticket';
    return '${averageFireMinutes}m fire window';
  }
}
