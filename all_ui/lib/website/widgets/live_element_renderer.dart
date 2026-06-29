import 'package:flutter/material.dart';

import '../models/layout_element.dart';

class LiveElementRenderer extends StatelessWidget {
  final LayoutElement element;

  const LiveElementRenderer({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    Widget renderedElement;

    switch (element.type) {
      case 'container':
        renderedElement = Container(
          width: element.properties['width'] as double? ?? double.infinity,
          height: element.properties['height'] as double? ?? 100.0,
          color: Color(
            element.properties['color'] as int? ?? Colors.grey[200]!.value,
          ),
          padding: EdgeInsets.all(
            element.properties['padding'] as double? ?? 16.0,
          ),
          child:
              element.children.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        element.children
                            .map((child) => LiveElementRenderer(element: child))
                            .toList(),
                  )
                  : const SizedBox(),
        );
        break;
      case 'text':
        renderedElement = Text(
          element.properties['text'] as String? ?? 'Text Element',
          style: TextStyle(
            fontSize: element.properties['fontSize'] as double? ?? 16.0,
            color: Color(
              element.properties['color'] as int? ?? Colors.black.value,
            ),
          ),
        );
        break;
      case 'image':
        renderedElement = Image.network(
          element.properties['url'] as String? ??
              'https://via.placeholder.com/150',
          width: element.properties['width'] as double? ?? 150.0,
          height: element.properties['height'] as double? ?? 150.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: element.properties['width'] as double? ?? 150.0,
              height: element.properties['height'] as double? ?? 150.0,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        );
        break;
      case 'button':
        renderedElement = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(
              element.properties['color'] as int? ?? Colors.blue.value,
            ),
            foregroundColor: Color(
              element.properties['textColor'] as int? ?? Colors.white.value,
            ),
          ),
          onPressed: () {},
          child: Text(element.properties['text'] as String? ?? 'Button'),
        );
        break;
      default:
        renderedElement = Container(
          width: element.properties['width'] as double? ?? double.infinity,
          height: element.properties['height'] as double? ?? 100.0,
          color: Colors.grey[200],
          child: const Center(child: Text('Unknown Element Type')),
        );
    }

    return renderedElement;
  }
}
