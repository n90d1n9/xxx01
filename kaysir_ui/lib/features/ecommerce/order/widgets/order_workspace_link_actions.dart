import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderWorkspaceLinkActions extends StatelessWidget {
  final String location;
  final ValueChanged<String>? onOpenLocation;

  const OrderWorkspaceLinkActions({
    super.key,
    required this.location,
    this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedLocation = location.trim();
    if (normalizedLocation.isEmpty) return const SizedBox.shrink();

    return Row(
      key: const ValueKey('order_workspace_link_actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onOpenLocation != null)
          IconButton(
            key: const ValueKey('order_workspace_open_current_location'),
            tooltip: 'Open current workspace link',
            visualDensity: VisualDensity.compact,
            onPressed: () => onOpenLocation?.call(normalizedLocation),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        IconButton(
          key: const ValueKey('order_workspace_copy_current_location'),
          tooltip: 'Copy current workspace link',
          visualDensity: VisualDensity.compact,
          onPressed: () => _copyLocation(context, normalizedLocation),
          icon: const Icon(Icons.link_rounded),
        ),
      ],
    );
  }

  Future<void> _copyLocation(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Workspace link copied'),
        ),
      );
  }
}
