import 'package:flutter/material.dart';

class POSShellContent {
  final Widget commandBar;
  final Widget? statusBanner;
  final Widget body;

  const POSShellContent({
    required this.commandBar,
    this.statusBanner,
    required this.body,
  });
}

typedef POSShellContentBuilder =
    POSShellContent Function(BuildContext context, BoxConstraints constraints);

class POSShellScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final POSShellContentBuilder contentBuilder;
  final Map<ShortcutActivator, VoidCallback> shortcuts;
  final bool autofocus;
  final Duration bodyTransitionDuration;
  final Curve bodySwitchInCurve;
  final Curve bodySwitchOutCurve;

  const POSShellScaffold({
    super.key,
    required this.appBar,
    required this.contentBuilder,
    this.shortcuts = const <ShortcutActivator, VoidCallback>{},
    this.autofocus = true,
    this.bodyTransitionDuration = const Duration(milliseconds: 220),
    this.bodySwitchInCurve = Curves.easeOutCubic,
    this.bodySwitchOutCurve = Curves.easeInCubic,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: autofocus,
        child: Scaffold(
          appBar: appBar,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final content = contentBuilder(context, constraints);

              return Column(
                children: [
                  content.commandBar,
                  if (content.statusBanner != null) content.statusBanner!,
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: bodyTransitionDuration,
                      switchInCurve: bodySwitchInCurve,
                      switchOutCurve: bodySwitchOutCurve,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.02, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: content.body,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
