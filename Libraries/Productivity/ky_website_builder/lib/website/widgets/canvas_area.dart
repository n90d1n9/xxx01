import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/device_provider.dart';
import '../models/layout_element.dart';
import '../states/layout_element_provider.dart';
import 'element_renderer.dart';

class CanvasArea extends ConsumerWidget {
  const CanvasArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(layoutElementsProvider);
    final deviceType = ref.watch(deviceTypeProvider);

    // Determine canvas width based on device type
    double canvasWidth = 1200;
    switch (deviceType) {
      case DeviceType.mobile:
        canvasWidth = 375;
        break;
      case DeviceType.tablet:
        canvasWidth = 768;
        break;
      case DeviceType.desktop:
      /* default:
        canvasWidth = 1200;
        break; */
    }

    return Container(
      width: canvasWidth,
      height: 800,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: DragTarget<String>(
        onAccept: (elementType) {
          final element = _createDefaultElement(elementType);
          ref.read(layoutElementsProvider.notifier).addElement(element);
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              ListView.builder(
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  return ElementRenderer(element: elements[index]);
                },
              ),
              if (elements.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.drag_indicator, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Drag elements here to build your layout',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /* LayoutElement _createDefaultElement(String type) {
    switch (type) {
      case 'container':
        return LayoutElement(
          type: 'container',
          properties: {
            'width': double.infinity,
            'height': 200.0,
            'color': Colors.grey[200]!.value,
            'padding': 16.0,
          },
        );
      case 'text':
        return LayoutElement(
          type: 'text',
          properties: {
            'text': 'New Text Element',
            'fontSize': 16.0,
            'color': Colors.black.value,
          },
        );
      case 'image':
        return LayoutElement(
          type: 'image',
          properties: {
            'url': 'https://via.placeholder.com/150',
            'width': 150.0,
            'height': 150.0,
          },
        );
      case 'button':
        return LayoutElement(
          type: 'button',
          properties: {
            'text': 'Button',
            'color': Colors.blue.value,
            'textColor': Colors.white.value,
          },
        );
      default:
        return LayoutElement(
          type: type,
          properties: {'width': double.infinity, 'height': 100.0},
        );
    }
  } */

  LayoutElement _createDefaultElement(String type) {
    switch (type) {
      case 'container':
        return LayoutElement(
          type: 'container',
          properties: {
            'width': double.infinity,
            'height': 200.0,
            'color': Colors.grey[200]!.value,
            'padding': 16.0,
          },
        );
      case 'text':
        return LayoutElement(
          type: 'text',
          properties: {
            'text': 'New Text Element',
            'fontSize': 16.0,
            'color': Colors.black.value,
          },
        );
      case 'image':
        return LayoutElement(
          type: 'image',
          properties: {
            'url': 'https://via.placeholder.com/150',
            'width': 150.0,
            'height': 150.0,
          },
        );
      case 'button':
        return LayoutElement(
          type: 'button',
          properties: {
            'text': 'Button',
            'color': Colors.blue.value,
            'textColor': Colors.white.value,
          },
        );
      case 'row':
        return LayoutElement(
          type: 'row',
          properties: {
            'width': double.infinity,
            'height': 100.0,
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'center',
            'spacing': 8.0,
            'padding': 16.0,
            'backgroundColor': Colors.transparent.value,
          },
        );
      case 'column':
        return LayoutElement(
          type: 'column',
          properties: {
            'width': double.infinity,
            'height': 200.0,
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'start',
            'spacing': 8.0,
            'padding': 16.0,
            'backgroundColor': Colors.transparent.value,
          },
        );
      case 'grid':
        return LayoutElement(
          type: 'grid',
          properties: {
            'width': double.infinity,
            'height': 300.0,
            'columns': 3,
            'spacing': 8.0,
            'padding': 16.0,
            'backgroundColor': Colors.grey[50]!.value,
          },
        );
      default:
        return LayoutElement(
          type: type,
          properties: {'width': double.infinity, 'height': 100.0},
        );
    }
  }
}
