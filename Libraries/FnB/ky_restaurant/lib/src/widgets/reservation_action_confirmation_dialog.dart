import 'package:flutter/material.dart';

import '../models/reservation_status_action_confirmation.dart';

/// Shows a focused confirmation step for cautionary reservation actions.
class RestaurantReservationActionConfirmationDialog extends StatelessWidget {
  const RestaurantReservationActionConfirmationDialog({
    super.key,
    required this.confirmation,
    this.onCancel,
    this.onConfirm,
  });

  final RestaurantReservationStatusActionConfirmation confirmation;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: colors.error),
      title: Text(confirmation.title),
      content: Text(confirmation.message),
      actions: [
        TextButton(onPressed: onCancel, child: Text(confirmation.cancelLabel)),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: onConfirm,
          child: Text(confirmation.confirmLabel),
        ),
      ],
    );
  }
}

Future<bool> showRestaurantReservationActionConfirmationDialog({
  required BuildContext context,
  required RestaurantReservationStatusActionConfirmation confirmation,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return RestaurantReservationActionConfirmationDialog(
        confirmation: confirmation,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      );
    },
  );

  return confirmed ?? false;
}
