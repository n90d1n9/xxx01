import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layout_element.dart';
import '../states/layout_element_provider.dart';

class ElementRenderer extends ConsumerWidget {
  final LayoutElement element;
  final bool isPreview;

  const ElementRenderer({
    super.key,
    required this.element,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedElementIdProvider);
    final isSelected = selectedId == element.id && !isPreview;

    Widget renderedElement;

    // Helper function to resolve width
    double resolveWidth(dynamic width) {
      if (width == double.infinity) {
        return isPreview ? MediaQuery.of(context).size.width : double.infinity;
      }
      return width as double? ?? 100.0;
    }

    switch (element.type) {
      case 'container':
        renderedElement = Container(
          width: resolveWidth(element.properties['width']),
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
                            .map(
                              (child) => ElementRenderer(
                                element: child,
                                isPreview: isPreview,
                              ),
                            )
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
          width: resolveWidth(element.properties['width']),
          height: element.properties['height'] as double? ?? 150.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: resolveWidth(element.properties['width']),
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
      case 'row':
        final mainAxisAlignment = _getMainAxisAlignment(
          element.properties['mainAxisAlignment'] as String? ?? 'start',
        );
        final crossAxisAlignment = _getCrossAxisAlignment(
          element.properties['crossAxisAlignment'] as String? ?? 'center',
        );
        final spacing = element.properties['spacing'] as double? ?? 8.0;
        final padding = element.properties['padding'] as double? ?? 16.0;
        final bgColor = Color(
          element.properties['backgroundColor'] as int? ??
              Colors.transparent.value,
        );

        renderedElement = Container(
          width: resolveWidth(element.properties['width']),
          height: element.properties['height'] as double? ?? 100.0,
          padding: EdgeInsets.all(padding),
          color: bgColor,
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children:
                element.children.isEmpty
                    ? [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Drop elements here',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ]
                    : _addSpacingBetweenChildren(
                      element.children
                          .map(
                            (child) => ElementRenderer(
                              element: child,
                              isPreview: isPreview,
                            ),
                          )
                          .toList(),
                      spacing,
                      isHorizontal: true,
                    ),
          ),
        );
        break;
      case 'column':
        final mainAxisAlignment = _getMainAxisAlignment(
          element.properties['mainAxisAlignment'] as String? ?? 'start',
        );
        final crossAxisAlignment = _getCrossAxisAlignment(
          element.properties['crossAxisAlignment'] as String? ?? 'start',
        );
        final spacing = element.properties['spacing'] as double? ?? 8.0;
        final padding = element.properties['padding'] as double? ?? 16.0;
        final bgColor = Color(
          element.properties['backgroundColor'] as int? ??
              Colors.transparent.value,
        );

        renderedElement = Container(
          width: resolveWidth(element.properties['width']),
          height: element.properties['height'] as double? ?? 200.0,
          padding: EdgeInsets.all(padding),
          color: bgColor,
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children:
                element.children.isEmpty
                    ? [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Drop elements here',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ]
                    : _addSpacingBetweenChildren(
                      element.children
                          .map(
                            (child) => ElementRenderer(
                              element: child,
                              isPreview: isPreview,
                            ),
                          )
                          .toList(),
                      spacing,
                      isHorizontal: false,
                    ),
          ),
        );
        break;
      case 'grid':
        final columns = element.properties['columns'] as int? ?? 3;
        final spacing = element.properties['spacing'] as double? ?? 8.0;
        final padding = element.properties['padding'] as double? ?? 16.0;
        final bgColor = Color(
          element.properties['backgroundColor'] as int? ??
              Colors.grey[50]!.value,
        );

        renderedElement = Container(
          width: resolveWidth(element.properties['width']),
          height: element.properties['height'] as double? ?? 300.0,
          padding: EdgeInsets.all(padding),
          color: bgColor,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: element.children.isEmpty ? 1 : element.children.length,
            itemBuilder: (context, index) {
              if (element.children.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Drop elements here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              }
              return ElementRenderer(
                element: element.children[index],
                isPreview: isPreview,
              );
            },
          ),
        );
        break;
      default:
        renderedElement = Container(
          width: resolveWidth(element.properties['width']),
          height: element.properties['height'] as double? ?? 100.0,
          color: Colors.grey[200],
          child: const Center(child: Text('Unknown Element Type')),
        );
    }

    // Wrap with drag target for containers, rows, columns, and grids
    /* if (['container', 'row', 'column', 'grid'].contains(element.type) &&
        !isPreview) {
      renderedElement = DragTarget<String>(
        onAccept: (elementType) {
          final newElement = _createDefaultElement(elementType);
          ref
              .read(layoutElementsProvider.notifier)
              .addElement(newElement, parentId: element.id);
        },
        builder: (context, candidateData, rejectedData) {
          return renderedElement;
        },
      );
    } */

    // Change to this:
    if (['container', 'row', 'column', 'grid'].contains(element.type) &&
        !isPreview) {
      final child = renderedElement; // Store the already built widget
      renderedElement = DragTarget<String>(
        onAccept: (elementType) {
          final newElement = _createDefaultElement(elementType);
          ref
              .read(layoutElementsProvider.notifier)
              .addElement(newElement, parentId: element.id);
        },
        builder: (context, candidateData, rejectedData) {
          return child; // Use the stored widget
        },
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isPreview) {
          ref.read(selectedElementIdProvider.notifier).state = element.id;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: renderedElement,
      ),
    );
  }

  // Helper to add spacing between children
  List<Widget> _addSpacingBetweenChildren(
    List<Widget> children,
    double spacing, {
    bool isHorizontal = false,
  }) {
    if (children.isEmpty) return [];
    if (children.length == 1) return children;

    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        if (isHorizontal) {
          result.add(SizedBox(width: spacing));
        } else {
          result.add(SizedBox(height: spacing));
        }
      }
    }
    return result;
  }

  // Helper to get MainAxisAlignment from string
  MainAxisAlignment _getMainAxisAlignment(String value) {
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  // Helper to get CrossAxisAlignment from string
  CrossAxisAlignment _getCrossAxisAlignment(String value) {
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  // Helper to create default element (moved from CanvasArea)
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
