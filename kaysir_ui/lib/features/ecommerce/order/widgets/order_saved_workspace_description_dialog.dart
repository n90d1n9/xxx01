import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';

Future<String?> showOrderSavedWorkspaceDescriptionDialog({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
}) {
  return showDialog<String>(
    context: context,
    builder:
        (context) => OrderSavedWorkspaceDescriptionDialog(workspace: workspace),
  );
}

class OrderSavedWorkspaceDescriptionDialog extends StatefulWidget {
  final OrderSavedWorkspace workspace;

  const OrderSavedWorkspaceDescriptionDialog({
    super.key,
    required this.workspace,
  });

  @override
  State<OrderSavedWorkspaceDescriptionDialog> createState() =>
      _OrderSavedWorkspaceDescriptionDialogState();
}

class _OrderSavedWorkspaceDescriptionDialogState
    extends State<OrderSavedWorkspaceDescriptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.workspace.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedDescription = _controller.text.trim();

    return AlertDialog(
      key: const ValueKey('order_saved_workspace_description_dialog'),
      title: const Text('Edit workspace note'),
      content: SizedBox(
        width: 420,
        child: TextField(
          key: const ValueKey('order_saved_workspace_description_field'),
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          maxLength: 180,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Workspace note',
            alignLabelWithHint: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('order_saved_workspace_description_save'),
          onPressed:
              normalizedDescription.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(normalizedDescription),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
