import 'service_status.dart';

/// Describes a kitchen production station shared by restaurant and kitchen.
class FnbKitchenStation {
  const FnbKitchenStation({
    required this.id,
    required this.name,
    required this.lead,
    required this.ticketsInProgress,
    required this.averageFireMinutes,
    required this.queueLabel,
    required this.status,
  });

  final String id;
  final String name;
  final String lead;
  final int ticketsInProgress;
  final int averageFireMinutes;
  final String queueLabel;
  final FnbServiceStatus status;

  String get ticketLabel {
    return ticketsInProgress == 1 ? '1 ticket' : '$ticketsInProgress tickets';
  }

  String get fireTimeLabel => '${averageFireMinutes}m fire';

  String get averageFireTimeLabel => '${averageFireMinutes}m average fire';

  String get queueLeadLabel => '$queueLabel - Lead $lead';

  String get loadLabel => '$ticketLabel, $averageFireTimeLabel';

  String get accessibilityLabel => '$name, $queueLabel, lead $lead, $loadLabel';

  String get pressureAccessibilityLabel => '$name station pressure, $loadLabel';

  String get averageFireAccessibilityLabel {
    return '$name average fire time, $averageFireMinutes minutes';
  }

  FnbKitchenStation copyWith({
    String? name,
    String? lead,
    int? ticketsInProgress,
    int? averageFireMinutes,
    String? queueLabel,
    FnbServiceStatus? status,
  }) {
    return FnbKitchenStation(
      id: id,
      name: name ?? this.name,
      lead: lead ?? this.lead,
      ticketsInProgress: ticketsInProgress ?? this.ticketsInProgress,
      averageFireMinutes: averageFireMinutes ?? this.averageFireMinutes,
      queueLabel: queueLabel ?? this.queueLabel,
      status: status ?? this.status,
    );
  }
}
