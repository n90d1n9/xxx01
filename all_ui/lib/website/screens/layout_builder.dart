import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_provider.dart';
import '../states/layout_element_provider.dart';
import '../widgets/canvas_area.dart';
import '../widgets/element_pallete_item.dart';
import '../widgets/export_dialog.dart';
import '../widgets/preview_dialog.dart';
import '../widgets/properties_panel.dart';

class WebsiteLayoutBuilder extends ConsumerWidget {
  const WebsiteLayoutBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar - Elements Palette
          Container(
            width: 240,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Elements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      ElementPaletteItem(
                        icon: Icons.crop_square_outlined,
                        label: 'Container',
                        elementType: 'container',
                      ),
                      ElementPaletteItem(
                        icon: Icons.text_fields,
                        label: 'Text',
                        elementType: 'text',
                      ),
                      ElementPaletteItem(
                        icon: Icons.image_outlined,
                        label: 'Image',
                        elementType: 'image',
                      ),
                      ElementPaletteItem(
                        icon: Icons.smart_button_outlined,
                        label: 'Button',
                        elementType: 'button',
                      ),
                      ElementPaletteItem(
                        icon: Icons.grid_view,
                        label: 'Grid',
                        elementType: 'grid',
                      ),
                      ElementPaletteItem(
                        icon: Icons.splitscreen_outlined,
                        label: 'Column',
                        elementType: 'column',
                      ),
                      ElementPaletteItem(
                        icon: Icons.view_stream_outlined,
                        label: 'Row',
                        elementType: 'row',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Middle Section - Canvas
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    height: 60,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Canvas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, _) {
                            final deviceType = ref.watch(deviceTypeProvider);
                            return Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.smartphone_outlined),
                                  tooltip: 'Mobile View',
                                  color:
                                      deviceType == DeviceType.mobile
                                          ? Colors.blue
                                          : null,
                                  onPressed: () {
                                    ref
                                        .read(deviceTypeProvider.notifier)
                                        .state = DeviceType.mobile;
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.tablet_outlined),
                                  tooltip: 'Tablet View',
                                  color:
                                      deviceType == DeviceType.tablet
                                          ? Colors.blue
                                          : null,
                                  onPressed: () {
                                    ref
                                        .read(deviceTypeProvider.notifier)
                                        .state = DeviceType.tablet;
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.desktop_windows_outlined,
                                  ),
                                  tooltip: 'Desktop View',
                                  color:
                                      deviceType == DeviceType.desktop
                                          ? Colors.blue
                                          : null,
                                  onPressed: () {
                                    ref
                                        .read(deviceTypeProvider.notifier)
                                        .state = DeviceType.desktop;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          tooltip: 'Undo',
                          onPressed: () {
                            ref.read(layoutElementsProvider.notifier).undo();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.redo),
                          tooltip: 'Redo',
                          onPressed: () {
                            ref.read(layoutElementsProvider.notifier).redo();
                          },
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text('Preview'),
                          onPressed: () {
                            final elements = ref.read(layoutElementsProvider);
                            showDialog(
                              context: context,
                              builder:
                                  (context) =>
                                      PreviewDialog(elements: elements),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.code),
                          label: const Text('Export'),
                          onPressed: () {
                            final htmlCode =
                                ref
                                    .read(layoutElementsProvider.notifier)
                                    .exportToHTML();
                            showDialog(
                              context: context,
                              builder:
                                  (context) => ExportDialog(htmlCode: htmlCode),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Canvas Area
                  Expanded(child: Center(child: CanvasArea())),
                ],
              ),
            ),
          ),

          // Right Sidebar - Properties
          Container(
            width: 300,
            color: Colors.white,
            child: Consumer(
              builder: (context, ref, _) {
                final selectedId = ref.watch(selectedElementIdProvider);

                if (selectedId == null) {
                  return const Center(child: Text('No element selected'));
                }

                return const PropertiesPanel();
              },
            ),
          ),
        ],
      ),
    );
  }
}
