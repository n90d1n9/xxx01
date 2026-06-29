import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/admin_provider.dart';
import '../states/admin_state.dart';
import '../utils/keyboard_intent.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.f11): const ToggleFullscreenIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const ExitFullscreenIntent(),
      },
      child: Actions(
        actions: {
          ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
            onInvoke: (intent) =>
                ref.read(adminProvider.notifier).toggleFullscreen(),
          ),
          ExitFullscreenIntent: CallbackAction<ExitFullscreenIntent>(
            onInvoke: (intent) {
              if (adminState.isFullscreen) {
                ref.read(adminProvider.notifier).toggleFullscreen();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Stack(
              children: [
                // Main content
                Row(
                  children: [
                    // Reserve space for sidebar in expanded/minimized mode
                    if (adminState.sidebarVisible &&
                        adminState.sidebarMode != SidebarMode.overlay)
                      SizedBox(width: _getSidebarWidth(adminState.sidebarMode)),
                    Expanded(
                      child: Column(
                        children: [
                          // Hide header in fullscreen mode
                          if (!adminState.isFullscreen) const AdminHeader(),
                          Expanded(
                            child: Container(
                              color: theme.colorScheme.surface,
                              child: child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Sidebar - hidden in fullscreen mode
                if (adminState.sidebarVisible && !adminState.isFullscreen) ...[
                  // Overlay backdrop
                  if (adminState.sidebarMode == SidebarMode.overlay)
                    GestureDetector(
                      onTap: () =>
                          ref.read(adminProvider.notifier).toggleSidebar(),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                  // Sidebar itself
                  const Positioned(
                      left: 0, top: 0, bottom: 0, child: AdminSidebar()),
                ],
                // Fullscreen exit button
                if (adminState.isFullscreen)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit,
                            color: Colors.white),
                        onPressed: () =>
                            ref.read(adminProvider.notifier).toggleFullscreen(),
                        tooltip: 'Exit Fullscreen (ESC)',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getSidebarWidth(SidebarMode mode) {
    switch (mode) {
      case SidebarMode.expanded:
        return 280;
      case SidebarMode.minimized:
        return 80;
      case SidebarMode.overlay:
        return 280;
    }
  }
}
