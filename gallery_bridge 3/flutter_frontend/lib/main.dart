// lib/main.dart — GalleryBridge app entry point with go_router.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'core/navigation/app_router.dart';
import 'core/providers/gallery_providers.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(const WindowOptions(size: Size(1440, 900), minimumSize: Size(960, 640), center: true, title: 'GalleryBridge', backgroundColor: AppTheme.bg0, titleBarStyle: TitleBarStyle.hidden), () async => windowManager.show());
  }
  runApp(const ProviderScope(child: GalleryBridgeApp()));
}

class GalleryBridgeApp extends ConsumerWidget {
  const GalleryBridgeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(title: 'GalleryBridge', debugShowCheckedModeBanner: false, theme: AppTheme.theme, routerConfig: router,
      builder: (context, child) => ref.watch(engineInitProvider).when(data: (_) => child ?? const SizedBox.shrink(), loading: () => const _Splash(), error: (e, _) => _Error(error: '$e')));
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppTheme.bg0, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.photo_library, size: 40, color: AppTheme.accent), SizedBox(height: 16), Text('GalleryBridge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: AppTheme.textPrimary)), SizedBox(height: 24), SizedBox(width: 120, child: LinearProgressIndicator(backgroundColor: AppTheme.bg3, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent), minHeight: 2))])));
}

class _Error extends StatelessWidget {
  final String error;
  const _Error({required this.error});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppTheme.bg0, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 32, color: AppTheme.flagRed), const SizedBox(height: 12), Text('Engine failed:\n$error', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.flagRed))])));
}
