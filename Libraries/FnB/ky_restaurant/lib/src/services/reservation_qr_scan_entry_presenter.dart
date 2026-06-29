import '../models/reservation_qr_scan_entry_presentation.dart';

/// Builds operator-facing state for reservation QR scan entry controls.
class RestaurantReservationQrScanEntryPresenter {
  const RestaurantReservationQrScanEntryPresenter();

  RestaurantReservationQrScanEntryPresentation build({
    required String value,
    required bool enabled,
    required bool hasSubmitHandler,
  }) {
    final normalizedValue = value.trim();
    final hasValue = normalizedValue.isNotEmpty;
    final canSubmit = enabled && hasValue && hasSubmitHandler;

    return RestaurantReservationQrScanEntryPresentation(
      normalizedValue: normalizedValue,
      hasValue: hasValue,
      canSubmit: canSubmit,
      helperText: _helperTextFor(
        enabled: enabled,
        hasValue: hasValue,
        hasSubmitHandler: hasSubmitHandler,
      ),
      clearTooltip: 'Clear scan value',
      submitTooltip: canSubmit ? 'Resolve this reservation QR scan' : null,
    );
  }

  String _helperTextFor({
    required bool enabled,
    required bool hasValue,
    required bool hasSubmitHandler,
  }) {
    if (!enabled) {
      return 'Scanning is paused for the current handoff.';
    }

    if (!hasSubmitHandler) {
      return 'Connect a scan handler before resolving QR values.';
    }

    if (!hasValue) {
      return 'Scan or paste a QR handoff link to resolve the guest action.';
    }

    return 'Ready to resolve this QR handoff.';
  }
}
