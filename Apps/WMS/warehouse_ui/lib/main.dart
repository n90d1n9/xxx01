// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'features/auth/states/settings_bloc.dart';
import 'core/features_core/features_registry.dart';
import 'core/routes/routes.dart';
import 'core/themes/theme.dart';
import 'core/utils/helper.dart';

Future<void> main() async {
  // Initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Setup logging
  setupLogging();

  // Register all module
  FeaturesRegistry.goroutes();
  FeaturesRegistry.branches();

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

    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
        key: rootNavigatorKey,
        theme: theme.light(),
        darkTheme: theme.dark(),
        highContrastTheme: theme.lightHighContrast(),
        highContrastDarkTheme: theme.darkHighContrast(),
        themeMode: ref.watch(themeProvider),
        routerConfig: Routes.config(ref: ref),
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedLocales);
  }
}
