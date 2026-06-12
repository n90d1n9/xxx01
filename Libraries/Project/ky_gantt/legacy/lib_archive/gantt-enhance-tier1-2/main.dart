import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'core/providers/gantt_providers.dart';
import 'core/utils/persistent_settings.dart';
import 'shared/theme/gantt_theme.dart';
import 'features/gantt/gantt_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings before first build
  final persisted = await PersistentSettings.load();

  runApp(ProviderScope(
    observers: [SettingsPersistenceObserver()],
    overrides: [
      viewSettingsProvider.overrideWith((_) => persisted.settings),
      filterProvider.overrideWith((_) => persisted.filter),
    ],
    child: const GanttApp(),
  ));
}

class GanttApp extends StatelessWidget {
  const GanttApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Enterprise Gantt Chart',
        debugShowCheckedModeBanner: false,
        theme: GanttTheme.dark,
        home: const GanttScreen(),
      );
}
