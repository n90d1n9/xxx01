import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_provider.dart';
import '../models/layout_element.dart';
import '../states/layout_element_provider.dart';
import 'element_renderer.dart';
import 'live_element_renderer.dart';

class PreviewDialog extends ConsumerWidget {
  final List<LayoutElement> elements;

  const PreviewDialog({super.key, required this.elements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(layoutElementsProvider);
    final deviceType = ref.watch(deviceTypeProvider);

    double previewWidth;
    switch (deviceType) {
      case DeviceType.mobile:
        previewWidth = 375;
        break;
      case DeviceType.tablet:
        previewWidth = 768;
        break;
      case DeviceType.desktop:
      default:
        previewWidth = 1200;
        break;
    }

    /* return Dialog(
      child: Container(
        width: previewWidth + 100,
        height: 800,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Preview (${deviceType.toString().split('.').last} View)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Container(
                width: previewWidth,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        elements
                            .map(
                              (element) =>
                                  LiveElementRenderer(element: element),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ); */

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children:
                        elements
                            .map(
                              (element) => ElementRenderer(
                                element: element,
                                isPreview: true,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
