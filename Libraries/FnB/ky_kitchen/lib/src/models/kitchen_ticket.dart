import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Tracks the production stage of a kitchen ticket.
enum KitchenTicketStage { queued, firing, plating, ready, served, cancelled }

/// Presentation and pressure helpers for kitchen ticket stages.
extension KitchenTicketStageDetails on KitchenTicketStage {
  String get label => switch (this) {
    KitchenTicketStage.queued => 'Queued',
    KitchenTicketStage.firing => 'Firing',
    KitchenTicketStage.plating => 'Plating',
    KitchenTicketStage.ready => 'Ready',
    KitchenTicketStage.served => 'Served',
    KitchenTicketStage.cancelled => 'Cancelled',
  };

  FnbServiceStatus get serviceStatus => switch (this) {
    KitchenTicketStage.queued => FnbServiceStatus.busy,
    KitchenTicketStage.firing => FnbServiceStatus.busy,
    KitchenTicketStage.plating => FnbServiceStatus.critical,
    KitchenTicketStage.ready => FnbServiceStatus.busy,
    KitchenTicketStage.served => FnbServiceStatus.calm,
    KitchenTicketStage.cancelled => FnbServiceStatus.blocked,
  };

  bool get isOpen => switch (this) {
    KitchenTicketStage.queued ||
    KitchenTicketStage.firing ||
    KitchenTicketStage.plating ||
    KitchenTicketStage.ready => true,
    KitchenTicketStage.served || KitchenTicketStage.cancelled => false,
  };
}

/// Represents one menu item on a kitchen production ticket.
class KitchenTicketItem {
  const KitchenTicketItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    this.modifiers = const [],
  });

  final String menuItemId;
  final String name;
  final int quantity;
  final List<String> modifiers;
}

/// Represents a kitchen production ticket with due-time pressure helpers.
class KitchenTicket {
  const KitchenTicket({
    required this.id,
    required this.orderId,
    required this.stationId,
    required this.stationName,
    required this.customerLabel,
    required this.dueAt,
    required this.stage,
    required this.items,
    this.notes,
    this.serviceContext,
  });

  final String id;
  final String orderId;
  final String stationId;
  final String stationName;
  final String customerLabel;
  final DateTime dueAt;
  final KitchenTicketStage stage;
  final List<KitchenTicketItem> items;
  final String? notes;
  final FnbServiceContext? serviceContext;

  bool get isOpen => stage.isOpen;

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int minutesUntilDue(DateTime now) {
    return dueAt.difference(now).inMinutes;
  }

  bool isLateAt(DateTime now) {
    return isOpen && minutesUntilDue(now) < 0;
  }

  FnbServiceStatus serviceStatusAt(DateTime now) {
    if (isLateAt(now)) return FnbServiceStatus.critical;
    return stage.serviceStatus;
  }

  String timingLabel(DateTime now) {
    final minutes = minutesUntilDue(now);
    if (!isOpen) return stage.label;
    if (minutes == 0) return 'Due now';
    if (minutes < 0) return '${minutes.abs()}m late';
    return '${minutes}m';
  }

  KitchenTicket copyWith({
    String? orderId,
    String? stationId,
    String? stationName,
    String? customerLabel,
    DateTime? dueAt,
    KitchenTicketStage? stage,
    List<KitchenTicketItem>? items,
    String? notes,
    FnbServiceContext? serviceContext,
  }) {
    return KitchenTicket(
      id: id,
      orderId: orderId ?? this.orderId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      customerLabel: customerLabel ?? this.customerLabel,
      dueAt: dueAt ?? this.dueAt,
      stage: stage ?? this.stage,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      serviceContext: serviceContext ?? this.serviceContext,
    );
  }
}
