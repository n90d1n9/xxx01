import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/states/settings/settings_notifier.dart';
import 'core/features/features_registry.dart';
import 'core/routes/routes.dart';

import 'themes/theme.dart';
import 'utils/helper.dart';
import 'config/translations/app_localizations.dart';

Future<void> main() async {
  // Initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Setup logging
  setupLogging();

  // Register all module
  FeaturesRegistry.init();

  // Run main app
  runApp(const ProviderScope(child: GolokApp()));
}

class GolokApp extends ConsumerWidget {
  const GolokApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();

    MaterialTheme theme = materialTheme(context);
    var settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      key: rootNavigatorKey,
      theme: theme.light(),
      darkTheme: theme.dark(),
      highContrastTheme: theme.lightHighContrast(),
      highContrastDarkTheme: theme.darkHighContrast(),
      themeMode: settings.themeMode,
      routerConfig: Routes.config(ref: ref),
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
    );
  }
}
