import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dummy.dart';
import '../features/components/properties/properties_panel.dart';
import '../features/workflow/state/workflow_provider.dart';
import '../features/workflow/service/keyboard_shortcut_handler.dart';
import '../features/workflow/widget/app_header.dart';
import '../features/workflow/widget/execution_log.dart';
import '../features/workflow/widget/execution_overlay.dart';
import '../features/workflow/components/palette/node_pallete.dart';
import '../features/workflow/components/canvas/wcanvas_area.dart';
import '../widgets/settings/widgets/settings_bar.dart';
import '../widgets/settings/widgets/settings_panel.dart';

class WayangBuilder extends ConsumerStatefulWidget {
  const WayangBuilder({super.key});

  @override
  ConsumerState<WayangBuilder> createState() => _WayangBuilderState();
}

class _WayangBuilderState extends ConsumerState<WayangBuilder> {
  late TransformationController _transformationController;
  final GlobalKey _canvasKey = GlobalKey();

  // Viewport dimensions relative to the total canvas
  final double viewportWidth = 200;
  final double viewportHeight = 120;

  final (double, double) _zoomBarPosition = (800, 250);

  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);

    return KeyboardShortcutHandler(
      onUndo: () => ref.read(workflowProvider.notifier).undo(),
      onRedo: () => ref.read(workflowProvider.notifier).redo(),
      onSave: () => _saveWorkflow(),
    ).wrap(
      Scaffold(
        appBar: AppHeader(),
        body: Stack(
          children: [
            Row(
              children: [
                NodePalette(onNodeSelected: (nodeType) {}),
                Expanded(child: WorkflowCanvas()),
                if (workflowState.selectedNodeId != null)
                  PropertiesPanel(nodeTypes: nodeTypesByCategory),
              ],
            ),

            //Setting bar
            SettingsBar(
              transformationController: _transformationController,
              canvasKey: _canvasKey,
              position: _zoomBarPosition,
              onShowSetting: _toggleSettings,
            ),

            // Setting Panel
            if (_showSettings)
              SettingsPanel(
                onPressedSave: () {
                  // Save settings to persistent storage here
                  _toggleSettings();
                },
                onPressedCancel: () =>
                    _toggleSettings(), //Navigator.of(context).pop(),
              ),

            if (ref.watch(executionLogProvider)) ExecutionLog(),
            if (workflowState.isExecuting) ExecutionOverlay(),
          ],
        ),
      ),
    );
  }

  void _saveWorkflow() {
    final workflow = ref.read(workflowProvider.notifier).exportWorkflow();
    Clipboard.setData(ClipboardData(text: workflow));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workflow copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
  }
}
