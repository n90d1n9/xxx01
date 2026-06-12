/// Describes the current input and control state for a reservation QR scan box.
class RestaurantReservationQrScanEntryPresentation {
  const RestaurantReservationQrScanEntryPresentation({
    required this.normalizedValue,
    required this.hasValue,
    required this.canSubmit,
    required this.helperText,
    required this.clearTooltip,
    this.submitTooltip,
  });

  final String normalizedValue;
  final bool hasValue;
  final bool canSubmit;
  final String helperText;
  final String clearTooltip;
  final String? submitTooltip;
}
