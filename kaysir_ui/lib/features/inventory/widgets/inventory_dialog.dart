import 'package:flutter/material.dart';

class InventoryDialogFrame extends StatelessWidget {
  const InventoryDialogFrame({super.key, required this.child});

  static const insetPadding = EdgeInsets.all(20);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

Future<T?> showInventoryDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (dialogContext) => InventoryDialogFrame(child: builder(dialogContext)),
  );
}
