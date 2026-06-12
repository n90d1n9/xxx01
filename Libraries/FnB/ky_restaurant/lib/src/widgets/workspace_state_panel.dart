import 'package:flutter/material.dart';

import 'restaurant_panel.dart';

/// Displays a centered workspace state panel for loading, empty, and error UI.
class RestaurantWorkspaceStatePanel extends StatelessWidget {
  const RestaurantWorkspaceStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.child,
    this.maxWidth = 560,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: RestaurantPanel(
          title: title,
          subtitle: message,
          leading: Icon(icon),
          child: child,
        ),
      ),
    );
  }
}

/// Displays the retry action used by workspace state panels.
class RestaurantWorkspaceRetryButton extends StatelessWidget {
  const RestaurantWorkspaceRetryButton({
    super.key,
    required this.onRetry,
    required this.label,
  });

  final VoidCallback onRetry;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(label),
      ),
    );
  }
}
