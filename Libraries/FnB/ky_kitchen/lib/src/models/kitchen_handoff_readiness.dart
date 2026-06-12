import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';

/// Describes what service must verify before a ready ticket leaves the pass.
class KitchenHandoffReadiness {
  const KitchenHandoffReadiness({required this.ticket, required this.now});

  final KitchenTicket ticket;
  final DateTime now;

  List<FnbServiceAlert> get alerts {
    return ticket.serviceContext?.priorityAlerts ?? const [];
  }

  int get alertCount => alerts.length;

  int get criticalAlertCount {
    return alerts.where((alert) => alert.critical).length;
  }

  bool get hasCriticalAlerts => criticalAlertCount > 0;

  bool get hasAlerts => alertCount > 0;

  bool get isLate => ticket.isLateAt(now);

  String? get serviceNoteLabel {
    final note = ticket.serviceContext?.notesLabel;
    if (note != null) return note;

    final ticketNote = ticket.notes?.trim();
    if (ticketNote == null || ticketNote.isEmpty) return null;
    return ticketNote;
  }

  bool get hasServiceNotes => serviceNoteLabel != null;

  bool get needsAttention {
    return hasCriticalAlerts || hasAlerts || hasServiceNotes || isLate;
  }

  FnbServiceStatus get serviceStatus {
    if (hasCriticalAlerts || isLate) return FnbServiceStatus.critical;
    if (hasAlerts || hasServiceNotes) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  String get primaryLabel {
    if (hasCriticalAlerts) {
      return criticalAlertCount == 1
          ? 'Verify 1 critical alert'
          : 'Verify $criticalAlertCount critical alerts';
    }
    if (hasAlerts) {
      return alertCount == 1 ? 'Review 1 alert' : 'Review $alertCount alerts';
    }
    if (hasServiceNotes) return 'Review service note';
    if (isLate) return 'Handoff is late';
    return 'Ready to handoff';
  }

  String get secondaryLabel {
    final labels = [
      if (hasAlerts)
        alertCount == 1 ? '1 service alert' : '$alertCount service alerts',
      if (hasServiceNotes) 'service note',
      ticket.timingLabel(now),
    ];

    return labels.join(' - ');
  }
}
