import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_surface.dart';

class AdminLoadingState extends StatelessWidget {
  const AdminLoadingState({
    super.key,
    this.title = 'Loading workspace',
    this.message,
    this.icon = Icons.sync_outlined,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppSurface(
          elevated: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconBadge(
                icon: icon,
                size: 52,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdminErrorState extends StatelessWidget {
  const AdminErrorState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.error_outline,
    this.action,
    this.padding = const EdgeInsets.all(24),
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppEmptyState(
        title: title,
        message: message,
        icon: icon,
        action: action,
      ),
    );
  }
}

class AdminPageUpdatingIndicator extends StatelessWidget {
  const AdminPageUpdatingIndicator({
    super.key,
    this.top = 0,
    this.left = 0,
    this.right = 0,
    this.minHeight = 2,
    this.color,
  });

  final double top;
  final double left;
  final double right;
  final double minHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: LinearProgressIndicator(
        minHeight: minHeight,
        backgroundColor: Colors.transparent,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
