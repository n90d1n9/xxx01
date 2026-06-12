import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../provider/layout_state_provider.dart';
import 'dialog_utils.dart';

class LayoutBuilderToolbar extends ConsumerWidget {
  const LayoutBuilderToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSettings = ref.watch(
      layoutStateProvider.select((state) => state.gridSettings),
    );

    return BottomAppBar(
      child: Row(
        children: [
          // Grid Controls
          IconButton(
            icon: Icon(
              gridSettings.enabled ? Icons.grid_on : Icons.grid_off,
              color: gridSettings.enabled ? Colors.blue : null,
            ),
            onPressed: () {
              ref
                  .read(layoutStateProvider.notifier)
                  .updateGridSettings(
                    gridSettings.copyWith(enabled: !gridSettings.enabled),
                  );
            },
            tooltip: 'Toggle Grid',
          ),

          IconButton(
            icon: Icon(
              Icons.grid_goldenratio_sharp,
              color: gridSettings.snapToGrid ? Colors.blue : null,
            ),
            onPressed: () {
              ref
                  .read(layoutStateProvider.notifier)
                  .updateGridSettings(
                    gridSettings.copyWith(
                      snapToGrid: !gridSettings.snapToGrid,
                      enabled: true,
                    ),
                  );
            },
            tooltip: 'Toggle Snap to Grid',
          ),

          // Grid Size Slider
          Expanded(
            child: Slider(
              value: gridSettings.cellSize,
              min: 10,
              max: 50,
              divisions: 8,
              label: '${gridSettings.cellSize.round()}px',
              onChanged: (value) {
                ref
                    .read(layoutStateProvider.notifier)
                    .updateGridSettings(
                      gridSettings.copyWith(gridSize: value, enabled: true),
                    );
              },
            ),
          ),

          // Template Actions
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => showSaveTemplateDialog(context, ref),
            tooltip: 'Save Template',
          ),

          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => showLoadTemplateDialog(context, ref),
            tooltip: 'Load Template',
          ),
        ],
      ),
    );
  }
}
