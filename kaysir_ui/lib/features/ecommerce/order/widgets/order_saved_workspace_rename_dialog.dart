import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';

Future<String?> showOrderSavedWorkspaceRenameDialog({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => OrderSavedWorkspaceRenameDialog(workspace: workspace),
  );
}

class OrderSavedWorkspaceRenameDialog extends StatefulWidget {
  final OrderSavedWorkspace workspace;

  const OrderSavedWorkspaceRenameDialog({super.key, required this.workspace});

  @override
  State<OrderSavedWorkspaceRenameDialog> createState() =>
      _OrderSavedWorkspaceRenameDialogState();
}

class _OrderSavedWorkspaceRenameDialogState
    extends State<OrderSavedWorkspaceRenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.workspace.label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedLabel = _controller.text.trim();

    return AlertDialog(
      title: const Text('Rename workspace'),
      content: TextField(
        key: const ValueKey('order_saved_workspace_rename_field'),
        controller: _controller,
        autofocus: true,
        maxLength: 48,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Workspace name'),
        onChanged: (_) => setState(() {}),
        onSubmitted:
            normalizedLabel.isEmpty
                ? null
                : (_) => Navigator.of(context).pop(normalizedLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('order_saved_workspace_rename_save'),
          onPressed:
              normalizedLabel.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(normalizedLabel),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
