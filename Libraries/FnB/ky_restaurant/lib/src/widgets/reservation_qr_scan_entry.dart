import 'package:flutter/material.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_qr_scan_workflow.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Captures a pasted or scanner-entered reservation QR value without resolving it.
class RestaurantReservationQrScanEntry extends StatefulWidget {
  const RestaurantReservationQrScanEntry({
    super.key,
    this.initialValue = '',
    this.title = 'Scan QR handoff',
    this.subtitle = 'Paste or type a reservation QR link from a guest device.',
    this.hintText = 'Reservation QR link',
    this.submitLabel = 'Resolve scan',
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final String initialValue;
  final String title;
  final String subtitle;
  final String hintText;
  final String submitLabel;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<RestaurantReservationQrScanEntry> createState() {
    return _RestaurantReservationQrScanEntryState();
  }
}

class _RestaurantReservationQrScanEntryState
    extends State<RestaurantReservationQrScanEntry> {
  late final TextEditingController _controller;

  bool get _hasValue => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_syncText);
  }

  @override
  void didUpdateWidget(covariant RestaurantReservationQrScanEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == oldWidget.initialValue) return;
    _setText(widget.initialValue);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncText)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canSubmit = widget.enabled && _hasValue && widget.onSubmitted != null;

    return Semantics(
      container: true,
      label: 'Reservation QR scan entry',
      child: RestaurantSectionSurface(
        borderColor: colors.primary.withValues(alpha: .16),
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.qr_code_scanner_outlined,
              iconColor: colors.primary,
              title: widget.title,
              subtitle: widget.subtitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.done,
              minLines: 1,
              maxLines: 2,
              onSubmitted: widget.enabled ? _submitValue : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.link_rounded),
                suffixIcon: _hasValue
                    ? IconButton(
                        tooltip: 'Clear scan value',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: widget.enabled ? _clearValue : null,
                      )
                    : null,
                filled: true,
                fillColor: colors.surface.withValues(alpha: .72),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: canSubmit
                    ? () => _submitValue(_controller.text)
                    : null,
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(widget.submitLabel),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncText() {
    widget.onChanged?.call(_controller.text);
    setState(() {});
  }

  void _submitValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    widget.onSubmitted?.call(trimmed);
  }

  void _clearValue() {
    _setText('');
    widget.onClear?.call();
  }

  void _setText(String value) {
    if (_controller.text == value) return;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

/// Connects the reusable scan entry to a reservation QR session controller.
class RestaurantReservationQrScanControllerEntry extends StatelessWidget {
  const RestaurantReservationQrScanControllerEntry({
    super.key,
    required this.controller,
    this.initialValue = '',
    this.title = 'Scan QR handoff',
    this.subtitle = 'Paste or type a reservation QR link from a guest device.',
    this.hintText = 'Reservation QR link',
    this.submitLabel = 'Resolve scan',
    this.includeDismiss = true,
    this.enabled = true,
    this.autofocus = false,
    this.onScanResolved,
    this.onClear,
  });

  final RestaurantReservationQrSessionController controller;
  final String initialValue;
  final String title;
  final String subtitle;
  final String hintText;
  final String submitLabel;
  final bool includeDismiss;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<RestaurantReservationQrScanWorkflow>? onScanResolved;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return RestaurantReservationQrScanEntry(
      initialValue: initialValue,
      title: title,
      subtitle: subtitle,
      hintText: hintText,
      submitLabel: submitLabel,
      enabled: enabled,
      autofocus: autofocus,
      onSubmitted: _resolveScan,
      onClear: onClear,
    );
  }

  void _resolveScan(String value) {
    final workflow = controller.scanValue(
      value,
      includeDismiss: includeDismiss,
    );
    onScanResolved?.call(workflow);
  }
}
