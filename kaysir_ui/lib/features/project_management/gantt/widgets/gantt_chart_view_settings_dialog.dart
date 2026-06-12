import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../states/gantt_chart_preferences_provider.dart';
import 'gantt_chart_display_options_bar.dart';

class GanttChartViewSettingsDialog extends ConsumerWidget {
  const GanttChartViewSettingsDialog({super.key});

  static const closeButtonKey = ValueKey(
    'gantt-chart-view-settings-close-button',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final displayPreferences = ref.watch(ganttChartDisplayPreferencesProvider);
    final interactionPreferences = ref.watch(
      ganttChartInteractionPreferencesProvider,
    );
    final preferencesNotifier = ref.read(
      ganttChartWorkspacePreferencesProvider.notifier,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1040,
          maxHeight: (size.height * 0.86).clamp(420.0, 760.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextCluster(
                      eyebrow: 'Timeline Preferences',
                      title: 'View Settings',
                      subtitle: 'Workspace chart preferences.',
                      titleStyle: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                      subtitleMaxLines: 2,
                    ),
                  ),
                  IconButton(
                    key: closeButtonKey,
                    tooltip: 'Close view settings',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: GanttChartDisplayOptionsBar(
                  displayPreferences: displayPreferences,
                  interactionPreferences: interactionPreferences,
                  onDisplayChanged: preferencesNotifier.setDisplayPreferences,
                  onInteractionChanged:
                      preferencesNotifier.setInteractionPreferences,
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: AppActionButton(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  variant: AppActionButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
