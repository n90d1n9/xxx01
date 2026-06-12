import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';

class FulfillmentSelection {
  final POSFulfillmentMode mode;
  final String contactName;
  final String destination;
  final String scheduleLabel;
  final String note;

  const FulfillmentSelection({
    required this.mode,
    this.contactName = '',
    this.destination = '',
    this.scheduleLabel = '',
    this.note = '',
  });

  const FulfillmentSelection.pickup({
    String contactName = '',
    String scheduleLabel = '',
    String note = '',
  }) : this(
         mode: POSFulfillmentMode.pickup,
         contactName: contactName,
         scheduleLabel: scheduleLabel,
         note: note,
       );

  const FulfillmentSelection.delivery({
    String contactName = '',
    String destination = '',
    String scheduleLabel = '',
    String note = '',
  }) : this(
         mode: POSFulfillmentMode.delivery,
         contactName: contactName,
         destination: destination,
         scheduleLabel: scheduleLabel,
         note: note,
       );

  const FulfillmentSelection.shipment({
    String contactName = '',
    String destination = '',
    String scheduleLabel = '',
    String note = '',
  }) : this(
         mode: POSFulfillmentMode.shipment,
         contactName: contactName,
         destination: destination,
         scheduleLabel: scheduleLabel,
         note: note,
       );

  String get modeKey => mode.name;

  String get modeLabel => mode.label;

  bool get requiresDestination {
    return switch (mode) {
      POSFulfillmentMode.delivery ||
      POSFulfillmentMode.shipment ||
      POSFulfillmentMode.fieldDelivery => true,
      _ => false,
    };
  }

  bool get hasDestination => destination.trim().isNotEmpty;

  bool get hasContact => contactName.trim().isNotEmpty;

  String get summaryLabel {
    final destinationLabel = destination.trim();
    final schedule = scheduleLabel.trim();
    final contact = contactName.trim();

    switch (mode) {
      case POSFulfillmentMode.pickup:
        if (schedule.isNotEmpty) return '${mode.label} - $schedule';
        if (contact.isNotEmpty) return '${mode.label} for $contact';
        return mode.label;
      case POSFulfillmentMode.delivery:
      case POSFulfillmentMode.shipment:
      case POSFulfillmentMode.fieldDelivery:
        if (destinationLabel.isNotEmpty) {
          return '${mode.label} to $destinationLabel';
        }
        if (schedule.isNotEmpty) return '${mode.label} - $schedule';
        return mode.label;
      case POSFulfillmentMode.preorder:
        if (schedule.isNotEmpty) return '${mode.label} - $schedule';
        if (contact.isNotEmpty) return '${mode.label} for $contact';
        return mode.label;
      case POSFulfillmentMode.immediateHandoff:
      case POSFulfillmentMode.tableService:
        return mode.label;
    }
  }

  FulfillmentSelection copyWith({
    POSFulfillmentMode? mode,
    String? contactName,
    String? destination,
    String? scheduleLabel,
    String? note,
  }) {
    return FulfillmentSelection(
      mode: mode ?? this.mode,
      contactName: contactName ?? this.contactName,
      destination: destination ?? this.destination,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      note: note ?? this.note,
    );
  }
}

abstract final class FulfillmentOptions {
  static const pickup = FulfillmentSelection.pickup();
  static const delivery = FulfillmentSelection.delivery();
  static const shipment = FulfillmentSelection.shipment();

  static const all = [pickup, delivery, shipment];

  static FulfillmentSelection forMode(POSFulfillmentMode mode) {
    for (final option in all) {
      if (option.mode == mode) return option;
    }

    return FulfillmentSelection(mode: mode);
  }
}
