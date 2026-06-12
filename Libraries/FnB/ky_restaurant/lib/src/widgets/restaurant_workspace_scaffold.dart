import 'package:flutter/material.dart';

/// Provides the shared responsive shell for restaurant workspace pages.
class RestaurantWorkspaceScaffold extends StatelessWidget {
  const RestaurantWorkspaceScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.maxWidth = 1280,
    this.backgroundColor,
    this.backgroundTintOpacity = .025,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final Color? backgroundColor;
  final double backgroundTintOpacity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          backgroundColor ??
          Color.alphaBlend(
            colors.primary.withValues(alpha: backgroundTintOpacity),
            colors.surface,
          ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
