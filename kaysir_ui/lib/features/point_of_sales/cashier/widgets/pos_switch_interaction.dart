import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double kPOSSwitchCompactSheetBreakpoint = 720;

Future<T?> showPOSSwitchCompactSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double heightFactor = 0.82,
  double minHeight = 360,
  double maxHeight = 720,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final sheetHeight =
          (MediaQuery.sizeOf(sheetContext).height * heightFactor)
              .clamp(minHeight, maxHeight)
              .toDouble();

      return SizedBox(height: sheetHeight, child: builder(sheetContext));
    },
  );
}

Future<bool?> showPOSSwitchConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  Widget? details,
  ValueListenable<bool>? canConfirmListenable,
}) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: _POSSwitchConfirmationContent(
            message: message,
            details: details,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            _POSSwitchConfirmationButton(
              label: confirmLabel,
              canConfirmListenable: canConfirmListenable,
            ),
          ],
        ),
  );
}

class _POSSwitchConfirmationContent extends StatelessWidget {
  final String message;
  final Widget? details;

  const _POSSwitchConfirmationContent({
    required this.message,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final detailContent = details;
    if (detailContent == null) return Text(message);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(message), const SizedBox(height: 12), detailContent],
      ),
    );
  }
}

class _POSSwitchConfirmationButton extends StatelessWidget {
  final String label;
  final ValueListenable<bool>? canConfirmListenable;

  const _POSSwitchConfirmationButton({
    required this.label,
    required this.canConfirmListenable,
  });

  @override
  Widget build(BuildContext context) {
    final listenable = canConfirmListenable;
    if (listenable == null) {
      return _button(context: context, canConfirm: true);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, canConfirm, _) {
        return _button(context: context, canConfirm: canConfirm);
      },
    );
  }

  Widget _button({required BuildContext context, required bool canConfirm}) {
    return FilledButton(
      onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
      child: Text(label),
    );
  }
}

Future<void> showPOSSwitchNoticeDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(confirmLabel),
            ),
          ],
        ),
  );
}
