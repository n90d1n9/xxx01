// lib/core/navigation/app_router.dart
//
// go_router navigation configuration for GalleryBridge.
// Supports deep linking to specific views, items, and collections.
//
// Routes:
//   /                    → GalleryScreen (main 3-panel shell)
//   /item/:id            → LightboxScreen for a specific item
//   /compare             → CompareView standalone
//   /slideshow           → SlideshowPlayer standalone
//   /analytics           → AnalyticsScreen standalone
//   /settings            → SettingsScreen
//   /settings/:tab       → SettingsScreen at specific tab (general|cache|export|shortcuts)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/gallery/gallery_screen.dart';
import '../../features/detail/lightbox_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/compare/compare_view.dart';
import '../../features/settings/settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // ── Main shell ────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const GalleryScreen(),
        routes: [
          // Lightbox — opened when double-clicking a thumbnail
          GoRoute(
            path: 'item/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return CustomTransitionPage(
                child: LightboxScreen(initialItemId: id),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              );
            },
          ),

          // Compare view
          GoRoute(
            path: 'compare',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CompareView(),
            ),
          ),

          // Analytics
          GoRoute(
            path: 'analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: ':tab',
                builder: (context, state) {
                  final tab = state.pathParameters['tab'] ?? 'general';
                  return SettingsScreen(initialTab: tab);
                },
              ),
            ],
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32, color: Colors.red),
            const SizedBox(height: 12),
            Text('Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Navigation helpers (call these instead of context.go directly)
// ─────────────────────────────────────────────────────────────────────────────

extension AppNavigation on BuildContext {
  void openLightbox(int itemId)  => go('/item/$itemId');
  void openCompare()             => go('/compare');
  void openAnalytics()           => go('/analytics');
  void openSettings({String tab = 'general'}) => go('/settings/$tab');
  void goHome()                  => go('/');
}
