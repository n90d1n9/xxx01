import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'core/providers/gantt_providers.dart';
import 'core/utils/persistent_settings.dart';
import 'core/services/hive_persistence_service.dart';
import 'features/gantt/main_view_switcher.dart';
import 'shared/theme/gantt_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Parallel load of all persisted data
  final results = await Future.wait([
    PersistentSettings.load().then((r) => r),
    HivePersistenceService.instance.loadTasks(),
    HivePersistenceService.instance.loadSnapshots(),
    HivePersistenceService.instance.loadCustomFieldDefs(),
  ]);

  final persisted =
      results[0] as ({GanttViewSettings settings, GanttFilter filter});
  final savedTasks = results[1] as List;
  final savedSnaps = results[2] as List;
  final savedFields = results[3] as List;

  runApp(ProviderScope(
    observers: [
      SettingsPersistenceObserver(),
      DataPersistenceObserver(),
    ],
    overrides: [
      viewSettingsProvider.overrideWith((_) => persisted.settings),
      filterProvider.overrideWith((_) => persisted.filter),
    ],
    child: GanttApp(
      savedTasks: savedTasks.cast(),
      savedSnaps: savedSnaps.cast(),
      savedFields: savedFields.cast(),
    ),
  ));
}

class GanttApp extends ConsumerStatefulWidget {
  final List savedTasks;
  final List savedSnaps;
  final List savedFields;
  const GanttApp(
      {super.key,
      required this.savedTasks,
      required this.savedSnaps,
      required this.savedFields});

  @override
  ConsumerState<GanttApp> createState() => _GanttAppState();
}

class _GanttAppState extends ConsumerState<GanttApp> {
  @override
  void initState() {
    super.initState();
    // Restore persisted data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.savedTasks.isNotEmpty) {
        ref
            .read(tasksProvider.notifier)
            .loadPersisted(widget.savedTasks.cast());
      }
      for (final s in widget.savedSnaps) {
        ref.read(snapshotsProvider.notifier).save(s);
      }
      for (final d in widget.savedFields) {
        ref.read(customFieldDefsProvider.notifier).add(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Enterprise Gantt Chart',
        debugShowCheckedModeBanner: false,
        theme: GanttTheme.dark,
        home: const GanttAppShell(),
      );
}
