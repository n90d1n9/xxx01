import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

// Models
class LayoutElement {
  final String id;
  final String type; // 'container', 'text', 'image', etc.
  final Map<String, dynamic> properties;
  final List<LayoutElement> children;

  LayoutElement({
    String? id,
    required this.type,
    this.properties = const {},
    this.children = const [],
  }) : id = id ?? const Uuid().v4();

  LayoutElement copyWith({
    String? type,
    Map<String, dynamic>? properties,
    List<LayoutElement>? children,
  }) {
    return LayoutElement(
      id: this.id,
      type: type ?? this.type,
      properties: properties ?? Map.from(this.properties),
      children: children ?? List.from(this.children),
    );
  }
}

// Providers
final selectedElementIdProvider = StateProvider<String?>((ref) => null);

final layoutElementsProvider =
    StateNotifierProvider<LayoutElementsNotifier, List<LayoutElement>>((ref) {
      return LayoutElementsNotifier();
    });

class LayoutElementsNotifier extends StateNotifier<List<LayoutElement>> {
  LayoutElementsNotifier()
    : super([
        LayoutElement(
          type: 'container',
          properties: {
            'width': double.infinity,
            'height': 500.0,
            'color': Colors.grey[200]!.value,
            'padding': 16.0,
          },
        ),
      ]);

  void addElement(LayoutElement element, {String? parentId}) {
    if (parentId == null) {
      state = [...state, element];
      return;
    }

    state = _updateElements(state, parentId, (parent) {
      return parent.copyWith(children: [...parent.children, element]);
    });
  }

  void updateElement(String id, LayoutElement updated) {
    state = _updateElementById(state, id, updated);
  }

  void deleteElement(String id) {
    state = _removeElementById(state, id);
  }

  List<LayoutElement> _updateElements(
    List<LayoutElement> elements,
    String targetId,
    LayoutElement Function(LayoutElement) updater,
  ) {
    return elements.map((element) {
      if (element.id == targetId) {
        return updater(element);
      }
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _updateElements(element.children, targetId, updater),
        );
      }
      return element;
    }).toList();
  }

  List<LayoutElement> _updateElementById(
    List<LayoutElement> elements,
    String targetId,
    LayoutElement updated,
  ) {
    return elements.map((element) {
      if (element.id == targetId) {
        return updated;
      }
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _updateElementById(element.children, targetId, updated),
        );
      }
      return element;
    }).toList();
  }

  List<LayoutElement> _removeElementById(
    List<LayoutElement> elements,
    String targetId,
  ) {
    return elements.where((element) => element.id != targetId).map((element) {
      if (element.children.isNotEmpty) {
        return element.copyWith(
          children: _removeElementById(element.children, targetId),
        );
      }
      return element;
    }).toList();
  }
}

// UI Components
class WebsiteLayoutBuilder extends ConsumerWidget {
  const WebsiteLayoutBuilder({Key? key}) : super(key: key);

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
                        IconButton(
                          icon: const Icon(Icons.smartphone_outlined),
                          tooltip: 'Mobile View',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.tablet_outlined),
                          tooltip: 'Tablet View',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.desktop_windows_outlined),
                          tooltip: 'Desktop View',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          tooltip: 'Undo',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.redo),
                          tooltip: 'Redo',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text('Preview'),
                          onPressed: () {},
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

class ElementPaletteItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String elementType;

  const ElementPaletteItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.elementType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<String>(
      data: elementType,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(label)],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[800]),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}

class CanvasArea extends ConsumerWidget {
  const CanvasArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(layoutElementsProvider);

    return Container(
      width: 1200,
      height: 800,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: DragTarget<String>(
        onAccept: (elementType) {
          final element = _createDefaultElement(elementType);
          ref.read(layoutElementsProvider.notifier).addElement(element);
        },
        builder: (context, candidateData, rejectedData) {
          return ListView.builder(
            itemCount: elements.length,
            itemBuilder: (context, index) {
              return ElementRenderer(element: elements[index]);
            },
          );
        },
      ),
    );
  }

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
      default:
        return LayoutElement(
          type: type,
          properties: {'width': double.infinity, 'height': 100.0},
        );
    }
  }
}

class ElementRenderer extends ConsumerWidget {
  final LayoutElement element;

  const ElementRenderer({Key? key, required this.element}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedElementIdProvider);
    final isSelected = selectedId == element.id;

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
          child: element.children.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: element.children
                      .map((child) => ElementRenderer(element: child))
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

    return GestureDetector(
      onTap: () {
        ref.read(selectedElementIdProvider.notifier).state = element.id;
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
}

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedElementIdProvider);

    if (selectedId == null) {
      return const Center(child: Text('No element selected'));
    }

    LayoutElement? selectedElement;
    final elements = ref.watch(layoutElementsProvider);

    // Find the selected element (simplified approach)
    for (final element in elements) {
      if (element.id == selectedId) {
        selectedElement = element;
        break;
      }
    }

    if (selectedElement == null) {
      return const Center(child: Text('Element not found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Properties: ${selectedElement.type.capitalize()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref
                      .read(layoutElementsProvider.notifier)
                      .deleteElement(selectedId);
                  ref.read(selectedElementIdProvider.notifier).state = null;
                },
                tooltip: 'Delete Element',
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _buildPropertiesForElement(context, ref, selectedElement),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPropertiesForElement(
    BuildContext context,
    WidgetRef ref,
    LayoutElement element,
  ) {
    final List<Widget> properties = [];

    // Common properties
    if (element.type == 'container' || element.type == 'image') {
      properties.add(
        _buildNumberProperty(
          ref,
          element,
          'Width',
          'width',
          defaultValue: double.infinity,
        ),
      );

      properties.add(
        _buildNumberProperty(
          ref,
          element,
          'Height',
          'height',
          defaultValue: 100.0,
        ),
      );
    }

    // Type-specific properties
    switch (element.type) {
      case 'container':
        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Background Color',
            'color',
            defaultValue: Colors.grey[200]!.value,
          ),
        );

        properties.add(
          _buildNumberProperty(
            ref,
            element,
            'Padding',
            'padding',
            defaultValue: 16.0,
          ),
        );
        break;

      case 'text':
        properties.add(
          _buildTextProperty(
            ref,
            element,
            'Text Content',
            'text',
            defaultValue: 'Text Element',
          ),
        );

        properties.add(
          _buildNumberProperty(
            ref,
            element,
            'Font Size',
            'fontSize',
            defaultValue: 16.0,
          ),
        );

        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Text Color',
            'color',
            defaultValue: Colors.black.value,
          ),
        );
        break;

      case 'image':
        properties.add(
          _buildTextProperty(
            ref,
            element,
            'Image URL',
            'url',
            defaultValue: 'https://via.placeholder.com/150',
          ),
        );
        break;

      case 'button':
        properties.add(
          _buildTextProperty(
            ref,
            element,
            'Button Text',
            'text',
            defaultValue: 'Button',
          ),
        );

        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Button Color',
            'color',
            defaultValue: Colors.blue.value,
          ),
        );

        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Text Color',
            'textColor',
            defaultValue: Colors.white.value,
          ),
        );
        break;
    }

    return properties;
  }

  Widget _buildTextProperty(
    WidgetRef ref,
    LayoutElement element,
    String label,
    String property, {
    String defaultValue = '',
  }) {
    final value = element.properties[property] as String? ?? defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          controller: TextEditingController(text: value),
          onChanged: (newValue) {
            final updatedElement = element.copyWith(
              properties: {...element.properties, property: newValue},
            );
            ref
                .read(layoutElementsProvider.notifier)
                .updateElement(element.id, updatedElement);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNumberProperty(
    WidgetRef ref,
    LayoutElement element,
    String label,
    String property, {
    double defaultValue = 0.0,
  }) {
    final value = element.properties[property] as double? ?? defaultValue;
    final isInfinity = value == double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                controller: TextEditingController(
                  text: isInfinity ? 'auto' : value.toString(),
                ),
                enabled: !isInfinity,
                keyboardType: TextInputType.number,
                onChanged: (newValue) {
                  final parsed = double.tryParse(newValue);
                  if (parsed != null) {
                    final updatedElement = element.copyWith(
                      properties: {...element.properties, property: parsed},
                    );
                    ref
                        .read(layoutElementsProvider.notifier)
                        .updateElement(element.id, updatedElement);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            if (property == 'width')
              Checkbox(
                value: isInfinity,
                onChanged: (value) {
                  final updatedElement = element.copyWith(
                    properties: {
                      ...element.properties,
                      property: value == true ? double.infinity : 100.0,
                    },
                  );
                  ref
                      .read(layoutElementsProvider.notifier)
                      .updateElement(element.id, updatedElement);
                },
              ),
            if (property == 'width') const Text('Auto'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildColorProperty(
    WidgetRef ref,
    LayoutElement element,
    String label,
    String property, {
    int defaultValue = 0xFF000000,
  }) {
    final value = element.properties[property] as int? ?? defaultValue;
    final color = Color(value);

    // Pre-defined color options
    final colorOptions = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorOptions.map((colorOption) {
            return GestureDetector(
              onTap: () {
                final updatedElement = element.copyWith(
                  properties: {
                    ...element.properties,
                    property: colorOption.value,
                  },
                );
                ref
                    .read(layoutElementsProvider.notifier)
                    .updateElement(element.id, updatedElement);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorOption,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorOption == Colors.white
                        ? Colors.grey[300]!
                        : Colors.transparent,
                  ),
                ),
                child: color.value == colorOption.value
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: colorOption.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WebsiteLayoutBuilder(),
      ),
    ),
  );
}
