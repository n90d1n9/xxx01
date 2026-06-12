import 'package:flutter/material.dart';

import 'billing_navigation_destination.dart';

class BillingReleaseWorkspaceAction {
  final String id;
  final String label;
  final String tooltip;
  final IconData icon;
  final BillingNavigationDestinationId destinationId;
  final bool isPrimary;

  const BillingReleaseWorkspaceAction({
    required this.id,
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.destinationId,
    this.isPrimary = false,
  });
}

class BillingReleaseWorkspaceActionStrip extends StatelessWidget {
  final List<BillingReleaseWorkspaceAction> actions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingReleaseWorkspaceActionStrip({
    super.key,
    required this.actions,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          actions.map((action) {
            return Tooltip(
              message: action.tooltip,
              child:
                  action.isPrimary
                      ? FilledButton.tonalIcon(
                        onPressed: _handlerFor(action),
                        icon: Icon(action.icon, size: 16),
                        label: Text(action.label, maxLines: 1),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                      : TextButton.icon(
                        onPressed: _handlerFor(action),
                        icon: Icon(action.icon, size: 16),
                        label: Text(action.label, maxLines: 1),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
            );
          }).toList(),
    );
  }

  VoidCallback? _handlerFor(BillingReleaseWorkspaceAction action) {
    final handler = onDestinationSelected;
    if (handler == null) return null;

    return () => handler(action.destinationId);
  }
}
