import 'kitchen_handoff_verification.dart';
import 'kitchen_ticket.dart';

/// Archived handoff verification context for a ticket that left service-ready.
class KitchenHandoffAuditEntry {
  KitchenHandoffAuditEntry({
    required this.ticketId,
    required this.orderId,
    required this.customerLabel,
    required this.stationId,
    required this.stationName,
    required this.closedStage,
    required this.archivedAt,
    required Iterable<KitchenHandoffVerificationRecord> records,
  }) : records = List<KitchenHandoffVerificationRecord>.unmodifiable(records);

  /// Builds an audit entry from a ticket and its active verification records.
  factory KitchenHandoffAuditEntry.fromTicket({
    required KitchenTicket ticket,
    required DateTime archivedAt,
    required Iterable<KitchenHandoffVerificationRecord> records,
  }) {
    return KitchenHandoffAuditEntry(
      ticketId: ticket.id,
      orderId: ticket.orderId,
      customerLabel: ticket.customerLabel,
      stationId: ticket.stationId,
      stationName: ticket.stationName,
      closedStage: ticket.stage,
      archivedAt: archivedAt,
      records: records,
    );
  }

  final String ticketId;
  final String orderId;
  final String customerLabel;
  final String stationId;
  final String stationName;
  final KitchenTicketStage closedStage;
  final DateTime archivedAt;
  final List<KitchenHandoffVerificationRecord> records;

  bool get hasRecords => records.isNotEmpty;

  int get verifiedStepCount => records.length;

  List<String> get verifierLabels {
    final labels = <String>[];
    for (final record in records) {
      final label = record.verifierLabel;
      if (!labels.contains(label)) labels.add(label);
    }
    return List<String>.unmodifiable(labels);
  }

  String get checkCountLabel {
    return '$verifiedStepCount ${verifiedStepCount == 1 ? 'check' : 'checks'} verified';
  }

  String get verifierSummaryLabel {
    final labels = verifierLabels;
    if (labels.isEmpty) return 'No verifier';
    if (labels.length == 1) return labels.first;
    return '${labels.first} + ${labels.length - 1}';
  }

  String get summaryLabel {
    if (!hasRecords) return 'No handoff checks archived';
    return '$checkCountLabel by $verifierSummaryLabel';
  }

  String get archivedAtClockLabel {
    return '${_twoDigits(archivedAt.hour)}:${_twoDigits(archivedAt.minute)}';
  }

  String get closedLabel {
    return '${closedStage.label} at $archivedAtClockLabel';
  }
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
