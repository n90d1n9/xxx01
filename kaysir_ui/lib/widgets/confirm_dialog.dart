import 'package:flutter/material.dart';

import 'ui/app_dialog_actions.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title,
    this.content,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
  });

  final String? title;
  final String? content;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Confirm action'),
      content: SingleChildScrollView(
        child: ListBody(children: <Widget>[Text(content ?? 'Are you sure?')]),
      ),
      actions: <Widget>[
        AppDialogActions(
          cancelLabel: cancelLabel ?? 'Cancel',
          confirmLabel: confirmLabel ?? 'Approve',
          onCancel: () {
            onCancel?.call();
            Navigator.of(context).pop(false);
          },
          onConfirm: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
