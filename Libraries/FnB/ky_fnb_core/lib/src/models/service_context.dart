import 'service_alert.dart';

/// Shared guest, reservation, and service notes carried across FnB workflows.
class FnbServiceContext {
  const FnbServiceContext({
    this.guestName,
    this.partySize,
    this.reservationTime,
    this.vip = false,
    this.occasion,
    this.notes,
    this.alerts = const [],
  }) : assert(
         partySize == null || partySize > 0,
         'partySize must be positive.',
       );

  final String? guestName;
  final int? partySize;
  final DateTime? reservationTime;
  final bool vip;
  final String? occasion;
  final String? notes;
  final List<FnbServiceAlert> alerts;

  bool get hasReservation => reservationTime != null;

  bool get hasAlerts => alerts.isNotEmpty;

  bool get hasCriticalAlerts {
    return alerts.any((alert) => alert.critical);
  }

  bool get hasGuestContext {
    return summaryLabels.isNotEmpty ||
        alerts.isNotEmpty ||
        (notes?.trim().isNotEmpty ?? false);
  }

  String? get guestLabel {
    final value = guestName?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get partySizeLabel {
    final count = partySize;
    if (count == null) return null;
    return count == 1 ? '1 guest' : '$count guests';
  }

  String? get reservationTimeLabel {
    final time = reservationTime;
    if (time == null) return null;
    return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)} reservation';
  }

  String? get vipLabel {
    return vip ? 'VIP' : null;
  }

  String? get occasionLabel {
    final value = occasion?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get notesLabel {
    final value = notes?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  List<String> get summaryLabels {
    return [
      ?vipLabel,
      ?guestLabel,
      ?partySizeLabel,
      ?reservationTimeLabel,
      ?occasionLabel,
    ];
  }

  List<FnbServiceAlert> get priorityAlerts {
    return [...alerts]..sort(
      (first, second) => second.priorityScore.compareTo(first.priorityScore),
    );
  }

  FnbServiceAlert? get primaryAlert {
    final ordered = priorityAlerts;
    if (ordered.isEmpty) return null;
    return ordered.first;
  }

  String? get alertSummaryLabel {
    final alert = primaryAlert;
    if (alert == null) return null;
    if (alerts.length == 1) return alert.compactLabel;
    return '${alert.compactLabel} +${alerts.length - 1}';
  }

  String get accessibilityLabel {
    final labels = [
      ...summaryLabels,
      ...priorityAlerts.map((alert) => alert.accessibilityLabel),
      ?notesLabel,
    ];
    if (labels.isEmpty) return 'No service context';
    return labels.join(', ');
  }
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
