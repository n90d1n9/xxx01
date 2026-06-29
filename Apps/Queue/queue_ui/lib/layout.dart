// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: LayoutEditorApp()));
}

class LayoutEditorApp extends StatelessWidget {
  const LayoutEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Layout Editor',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const EditorScreen(),
    );
  }
}

// Models
enum ComponentType {
  button,
  card,
  header,
  footer,
  menu,
  text,
  image,
  container,
  divider,
}

class ComponentData {
  final String id;
  final ComponentType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final Map<String, dynamic> properties;

  ComponentData({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 50,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  ComponentData copyWith({
    String? id,
    ComponentType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? properties,
  }) {
    return ComponentData(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      properties: properties ?? Map.from(this.properties),
    );
  }
}

// Providers
final selectedComponentProvider = StateProvider<String?>((ref) => null);

final componentsProvider =
    StateNotifierProvider<ComponentsNotifier, List<ComponentData>>((ref) {
      return ComponentsNotifier();
    });

class ComponentsNotifier extends StateNotifier<List<ComponentData>> {
  ComponentsNotifier() : super([]);

  void addComponent(ComponentType type, double x, double y) {
    final component = ComponentData(
      id: const Uuid().v4(),
      type: type,
      x: x,
      y: y,
      properties: _getDefaultPropertiesForType(type),
    );
    state = [...state, component];
  }

  void updateComponent(
    String id, {
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? properties,
  }) {
    state =
        state.map((component) {
          if (component.id == id) {
            return component.copyWith(
              x: x,
              y: y,
              width: width,
              height: height,
              properties: properties,
            );
          }
          return component;
        }).toList();
  }

  void removeComponent(String id) {
    state = state.where((component) => component.id != id).toList();
  }

  Map<String, dynamic> _getDefaultPropertiesForType(ComponentType type) {
    switch (type) {
      case ComponentType.button:
        return {'text': 'Button', 'color': Colors.blue.value};
      case ComponentType.card:
        return {'title': 'Card Title', 'content': 'Card Content'};
      case ComponentType.header:
        return {'title': 'Header', 'showBackButton': false};
      case ComponentType.footer:
        return {'text': 'Footer © 2025'};
      case ComponentType.menu:
        return {
          'items': ['Home', 'About', 'Contact'],
        };
      case ComponentType.text:
        return {'text': 'Text', 'fontSize': 16.0};
      case ComponentType.image:
        return {
          'url': 'https://placeholder.com/150',
          'fit': BoxFit.cover.toString(),
        };
      case ComponentType.container:
        return {'color': Colors.grey[200]!.value};
      case ComponentType.divider:
        return {'thickness': 1.0};
      default:
        return {};
    }
  }
}

// Editor Screen
class EditorScreen extends ConsumerWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Layout Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _showSaveDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () => _showGeneratedCode(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          // Component Palette
          SizedBox(width: 200, child: ComponentPalette()),
          // Canvas
          Expanded(child: LayoutCanvas()),
          // Properties Panel
          SizedBox(width: 300, child: PropertiesPanel()),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: 'my_layout');
        return AlertDialog(
          title: const Text('Save Layout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Layout Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement actual saving functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Layout "${controller.text}" saved!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showGeneratedCode(BuildContext context, WidgetRef ref) {
    final components = ref.read(componentsProvider);
    // Very basic code generation - would need to be much more sophisticated
    String generatedCode = '''
import 'package:flutter/material.dart';

class GeneratedScreen extends StatelessWidget {
  const GeneratedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
''';

    for (final component in components) {
      generatedCode += '''
          Positioned(
            left: ${component.x},
            top: ${component.y},
            width: ${component.width},
            height: ${component.height},
            child: ${_generateWidgetCode(component)},
          ),
''';
    }

    generatedCode += '''
        ],
      ),
    );
  }
}
''';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generated Code'),
          content: Container(
            width: double.maxFinite,
            height: 500,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                generatedCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Copy to clipboard
                // TODO: Implement clipboard functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied to clipboard!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  String _generateWidgetCode(ComponentData component) {
    switch (component.type) {
      case ComponentType.button:
        return 'ElevatedButton(onPressed: () {}, child: Text("${component.properties['text']}"))';
      case ComponentType.card:
        return 'Card(child: Padding(padding: EdgeInsets.all(8), child: Column(children: [Text("${component.properties['title']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("${component.properties['content']}")])))';
      case ComponentType.header:
        return 'AppBar(title: Text("${component.properties['title']}"), automaticallyImplyLeading: ${component.properties['showBackButton']})';
      case ComponentType.footer:
        return 'Container(color: Colors.grey[200], child: Center(child: Text("${component.properties['text']}")))';
      case ComponentType.menu:
        return 'Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [${(component.properties['items'] as List).map((item) => 'TextButton(onPressed: () {}, child: Text("$item"))').join(', ')}])';
      case ComponentType.text:
        return 'Text("${component.properties['text']}", style: TextStyle(fontSize: ${component.properties['fontSize']}))';
      case ComponentType.image:
        return 'Image.network("${component.properties['url']}")';
      case ComponentType.container:
        return 'Container(color: Color(${component.properties['color']}))';
      case ComponentType.divider:
        return 'Divider(thickness: ${component.properties['thickness']})';
      default:
        return 'Container()';
    }
  }
}

// Component Palette
class ComponentPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Components',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView(
              children:
                  ComponentType.values.map((type) {
                    return DraggableComponentItem(type: type);
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DraggableComponentItem extends StatelessWidget {
  final ComponentType type;

  const DraggableComponentItem({Key? key, required this.type})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentType>(
      data: type,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          width: 150,
          height: 50,
          child: Center(
            child: Text(
              type.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      child: ListTile(
        leading: _getIconForType(type),
        title: Text(type.name.capitalize()),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
      ),
    );
  }

  Icon _getIconForType(ComponentType type) {
    switch (type) {
      case ComponentType.button:
        return const Icon(Icons.smart_button);
      case ComponentType.card:
        return const Icon(Icons.credit_card);
      case ComponentType.header:
        return const Icon(Icons.headset_mic_rounded);
      case ComponentType.footer:
        return const Icon(Icons.call_to_action);
      case ComponentType.menu:
        return const Icon(Icons.menu);
      case ComponentType.text:
        return const Icon(Icons.text_fields);
      case ComponentType.image:
        return const Icon(Icons.image);
      case ComponentType.container:
        return const Icon(Icons.check_box_outline_blank);
      case ComponentType.divider:
        return const Icon(Icons.horizontal_rule);
      default:
        return const Icon(Icons.widgets);
    }
  }
}

// Canvas where components are placed
class LayoutCanvas extends ConsumerWidget {
  const LayoutCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(componentsProvider);
    final selectedComponentId = ref.watch(selectedComponentProvider);

    return DragTarget<ComponentType>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        ref
            .read(componentsProvider.notifier)
            .addComponent(
              details.data,
              localPosition.dx - 50, // Center the component at drop point
              localPosition.dy - 25,
            );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.grey[100],
          child: Stack(
            children: [
              // Grid background
              Positioned.fill(
                child: GridPaper(
                  color: Colors.black.withOpacity(0.1),
                  divisions: 1,
                  subdivisions: 1,
                  interval: 20,
                ),
              ),
              // Components
              ...components.map((component) {
                return EditableComponent(
                  component: component,
                  isSelected: component.id == selectedComponentId,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class EditableComponent extends ConsumerWidget {
  final ComponentData component;
  final bool isSelected;

  const EditableComponent({
    Key? key,
    required this.component,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: component.x,
      top: component.y,
      child: GestureDetector(
        onTap: () {
          ref.read(selectedComponentProvider.notifier).state = component.id;
        },
        onPanUpdate: (details) {
          ref
              .read(componentsProvider.notifier)
              .updateComponent(
                component.id,
                x: component.x + details.delta.dx,
                y: component.y + details.delta.dy,
              );
        },
        child: Container(
          width: component.width,
          height: component.height,
          decoration: BoxDecoration(
            border:
                isSelected
                    ? Border.all(color: Colors.blue, width: 2.0)
                    : Border.all(color: Colors.transparent),
          ),
          child: Stack(
            children: [
              // The actual component
              Positioned.fill(child: _buildComponentWidget()),
              // Resize handles (only show when selected)
              if (isSelected) ...[
                _buildResizeHandle(ref, ResizeHandlePosition.topLeft),
                _buildResizeHandle(ref, ResizeHandlePosition.topRight),
                _buildResizeHandle(ref, ResizeHandlePosition.bottomLeft),
                _buildResizeHandle(ref, ResizeHandlePosition.bottomRight),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentWidget() {
    switch (component.type) {
      case ComponentType.button:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(component.properties['color'] as int),
          ),
          child: Text(component.properties['text'] as String),
        );
      case ComponentType.card:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.properties['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(component.properties['content'] as String),
              ],
            ),
          ),
        );
      case ComponentType.header:
        return Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (component.properties['showBackButton'] as bool)
                  const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  component.properties['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      case ComponentType.footer:
        return Container(
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Text(component.properties['text'] as String),
        );
      case ComponentType.menu:
        final items = component.properties['items'] as List;
        return Container(
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(item.toString()),
                      ),
                    )
                    .toList(),
          ),
        );
      case ComponentType.text:
        return Text(
          component.properties['text'] as String,
          style: TextStyle(
            fontSize: component.properties['fontSize'] as double,
          ),
        );
      case ComponentType.image:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.grey[200],
          ),
          child: const Center(child: Icon(Icons.image)),
        );
      case ComponentType.container:
        return Container(color: Color(component.properties['color'] as int));
      case ComponentType.divider:
        return Center(
          child: Divider(
            thickness: component.properties['thickness'] as double,
            color: Colors.black,
          ),
        );
      default:
        return Container(color: Colors.red);
    }
  }

  Widget _buildResizeHandle(WidgetRef ref, ResizeHandlePosition position) {
    return Positioned(
      left:
          position == ResizeHandlePosition.topLeft ||
                  position == ResizeHandlePosition.bottomLeft
              ? 0
              : null,
      right:
          position == ResizeHandlePosition.topRight ||
                  position == ResizeHandlePosition.bottomRight
              ? 0
              : null,
      top:
          position == ResizeHandlePosition.topLeft ||
                  position == ResizeHandlePosition.topRight
              ? 0
              : null,
      bottom:
          position == ResizeHandlePosition.bottomLeft ||
                  position == ResizeHandlePosition.bottomRight
              ? 0
              : null,
      child: GestureDetector(
        onPanUpdate: (details) {
          _handleResize(ref, details, position);
        },
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }

  void _handleResize(
    WidgetRef ref,
    DragUpdateDetails details,
    ResizeHandlePosition position,
  ) {
    double newWidth = component.width;
    double newHeight = component.height;
    double newX = component.x;
    double newY = component.y;

    switch (position) {
      case ResizeHandlePosition.topLeft:
        newWidth = component.width - details.delta.dx;
        newHeight = component.height - details.delta.dy;
        newX = component.x + details.delta.dx;
        newY = component.y + details.delta.dy;
        break;
      case ResizeHandlePosition.topRight:
        newWidth = component.width + details.delta.dx;
        newHeight = component.height - details.delta.dy;
        newY = component.y + details.delta.dy;
        break;
      case ResizeHandlePosition.bottomLeft:
        newWidth = component.width - details.delta.dx;
        newHeight = component.height + details.delta.dy;
        newX = component.x + details.delta.dx;
        break;
      case ResizeHandlePosition.bottomRight:
        newWidth = component.width + details.delta.dx;
        newHeight = component.height + details.delta.dy;
        break;
    }

    // Ensure minimum size
    newWidth = newWidth.clamp(20.0, double.infinity);
    newHeight = newHeight.clamp(20.0, double.infinity);

    ref
        .read(componentsProvider.notifier)
        .updateComponent(
          component.id,
          x: newX,
          y: newY,
          width: newWidth,
          height: newHeight,
        );
  }
}

enum ResizeHandlePosition { topLeft, topRight, bottomLeft, bottomRight }

// Properties Panel
class PropertiesPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedComponentProvider);
    final components = ref.watch(componentsProvider);

    final selectedComponent = components.firstWhere(
      (comp) => comp.id == selectedId,
      orElse:
          () =>
              ComponentData(id: '', type: ComponentType.container, x: 0, y: 0),
    );

    if (selectedId == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey.shade300)),
        ),
        child: const Center(
          child: Text('Select a component to edit its properties'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedComponent.type.name.capitalize()} Properties',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(componentsProvider.notifier)
                        .removeComponent(selectedId);
                    ref.read(selectedComponentProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Position and size properties
                _buildSectionHeader(context, 'Position & Size'),
                _buildNumberProperty(
                  context,
                  ref,
                  selectedComponent,
                  'X Position',
                  selectedComponent.x,
                  (value) => ref
                      .read(componentsProvider.notifier)
                      .updateComponent(selectedId, x: value),
                ),
                _buildNumberProperty(
                  context,
                  ref,
                  selectedComponent,
                  'Y Position',
                  selectedComponent.y,
                  (value) => ref
                      .read(componentsProvider.notifier)
                      .updateComponent(selectedId, y: value),
                ),
                _buildNumberProperty(
                  context,
                  ref,
                  selectedComponent,
                  'Width',
                  selectedComponent.width,
                  (value) => ref
                      .read(componentsProvider.notifier)
                      .updateComponent(selectedId, width: value),
                ),
                _buildNumberProperty(
                  context,
                  ref,
                  selectedComponent,
                  'Height',
                  selectedComponent.height,
                  (value) => ref
                      .read(componentsProvider.notifier)
                      .updateComponent(selectedId, height: value),
                ),
                const SizedBox(height: 16),

                // Type-specific properties
                _buildSectionHeader(context, 'Component Properties'),
                ...buildPropertiesForType(
                  context,
                  ref,
                  selectedComponent,
                  selectedId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNumberProperty(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String label,
    double value,
    Function(double) onChanged,
  ) {
    final controller = TextEditingController(text: value.toStringAsFixed(0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPropertiesForType(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String componentId,
  ) {
    final List<Widget> propertyWidgets = [];

    switch (component.type) {
      case ComponentType.button:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'text',
            'Button Text',
          ),
          _buildColorProperty(
            context,
            ref,
            component,
            componentId,
            'color',
            'Button Color',
          ),
        ]);
        break;

      case ComponentType.card:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'title',
            'Card Title',
          ),
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'content',
            'Card Content',
          ),
        ]);
        break;

      case ComponentType.header:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'title',
            'Header Title',
          ),
          _buildBoolProperty(
            context,
            ref,
            component,
            componentId,
            'showBackButton',
            'Show Back Button',
          ),
        ]);
        break;

      case ComponentType.footer:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'text',
            'Footer Text',
          ),
        ]);
        break;

      case ComponentType.menu:
        final items = component.properties['items'] as List;
        propertyWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Menu Items'),
              const SizedBox(height: 8),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          //initialValue: item.toString(),
                          onChanged: (value) {
                            final newItems = List.from(items);
                            newItems[index] = value;
                            final newProperties = Map<String, dynamic>.from(
                              component.properties,
                            );
                            newProperties['items'] = newItems;

                            ref
                                .read(componentsProvider.notifier)
                                .updateComponent(
                                  componentId,
                                  properties: newProperties,
                                );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          final newItems = List.from(items)..removeAt(index);
                          final newProperties = Map<String, dynamic>.from(
                            component.properties,
                          );
                          newProperties['items'] = newItems;

                          ref
                              .read(componentsProvider.notifier)
                              .updateComponent(
                                componentId,
                                properties: newProperties,
                              );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: () {
                  final newItems = List.from(items)..add('New Item');
                  final newProperties = Map<String, dynamic>.from(
                    component.properties,
                  );
                  newProperties['items'] = newItems;

                  ref
                      .read(componentsProvider.notifier)
                      .updateComponent(componentId, properties: newProperties);
                },
              ),
            ],
          ),
        );
        break;

      case ComponentType.text:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'text',
            'Text Content',
          ),
          _buildSliderProperty(
            context,
            ref,
            component,
            componentId,
            'fontSize',
            'Font Size',
            8,
            32,
          ),
        ]);
        break;

      case ComponentType.image:
        propertyWidgets.addAll([
          _buildTextProperty(
            context,
            ref,
            component,
            componentId,
            'url',
            'Image URL',
          ),
        ]);
        break;

      case ComponentType.container:
        propertyWidgets.addAll([
          _buildColorProperty(
            context,
            ref,
            component,
            componentId,
            'color',
            'Background Color',
          ),
        ]);
        break;

      case ComponentType.divider:
        propertyWidgets.addAll([
          _buildSliderProperty(
            context,
            ref,
            component,
            componentId,
            'thickness',
            'Thickness',
            1,
            10,
          ),
        ]);
        break;

      default:
        propertyWidgets.add(const Text('No properties available'));
    }

    return propertyWidgets;
  }

  Widget _buildTextProperty(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String componentId,
    String propertyName,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            controller: TextEditingController(
              text: component.properties[propertyName]?.toString() ?? '',
            ),
            onChanged: (value) {
              final newProperties = Map<String, dynamic>.from(
                component.properties,
              );
              newProperties[propertyName] = value;

              ref
                  .read(componentsProvider.notifier)
                  .updateComponent(componentId, properties: newProperties);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorProperty(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String componentId,
    String propertyName,
    String label,
  ) {
    final currentColor = Color(component.properties[propertyName] as int);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: currentColor,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
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
                      ].map((color) {
                        return GestureDetector(
                          onTap: () {
                            final newProperties = Map<String, dynamic>.from(
                              component.properties,
                            );
                            newProperties[propertyName] = color.value;

                            ref
                                .read(componentsProvider.notifier)
                                .updateComponent(
                                  componentId,
                                  properties: newProperties,
                                );
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: Colors.black,
                                width:
                                    currentColor.value == color.value ? 2 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoolProperty(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String componentId,
    String propertyName,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: component.properties[propertyName] as bool,
            onChanged: (value) {
              final newProperties = Map<String, dynamic>.from(
                component.properties,
              );
              newProperties[propertyName] = value;

              ref
                  .read(componentsProvider.notifier)
                  .updateComponent(componentId, properties: newProperties);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderProperty(
    BuildContext context,
    WidgetRef ref,
    ComponentData component,
    String componentId,
    String propertyName,
    String label,
    double min,
    double max,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${(component.properties[propertyName] as double).toStringAsFixed(1)}',
              ),
            ],
          ),
          Slider(
            value: component.properties[propertyName] as double,
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            label: (component.properties[propertyName] as double)
                .toStringAsFixed(1),
            onChanged: (value) {
              final newProperties = Map<String, dynamic>.from(
                component.properties,
              );
              newProperties[propertyName] = value;

              ref
                  .read(componentsProvider.notifier)
                  .updateComponent(componentId, properties: newProperties);
            },
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
