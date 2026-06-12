import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/layout_element.dart';
import '../states/layout_element_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

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
    if ([
      'container',
      'image',
      'row',
      'column',
      'grid',
    ].contains(element.type)) {
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

      case 'row':
      case 'column':
        properties.add(
          _buildDropdownProperty(
            ref,
            element,
            'Main Axis Alignment',
            'mainAxisAlignment',
            [
              'start',
              'center',
              'end',
              'spaceBetween',
              'spaceAround',
              'spaceEvenly',
            ],
            defaultValue: 'start',
          ),
        );

        properties.add(
          _buildDropdownProperty(
            ref,
            element,
            'Cross Axis Alignment',
            'crossAxisAlignment',
            ['start', 'center', 'end', 'stretch', 'baseline'],
            defaultValue: element.type == 'row' ? 'center' : 'start',
          ),
        );

        properties.add(
          _buildNumberProperty(
            ref,
            element,
            'Spacing',
            'spacing',
            defaultValue: 8.0,
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

        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Background Color',
            'backgroundColor',
            defaultValue: Colors.transparent.value,
          ),
        );
        break;

      case 'grid':
        properties.add(
          _buildNumberProperty(
            ref,
            element,
            'Number of Columns',
            'columns',
            defaultValue: 3.0,
            isInteger: true,
          ),
        );

        properties.add(
          _buildNumberProperty(
            ref,
            element,
            'Spacing',
            'spacing',
            defaultValue: 8.0,
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

        properties.add(
          _buildColorProperty(
            ref,
            element,
            'Background Color',
            'backgroundColor',
            defaultValue: Colors.grey[50]!.value,
          ),
        );
        break;
    }

    return properties;
  }

  Widget _buildDropdownProperty(
    WidgetRef ref,
    LayoutElement element,
    String label,
    String property,
    List<String> options, {
    String defaultValue = '',
  }) {
    final value = element.properties[property] as String? ?? defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                final updatedElement = element.copyWith(
                  properties: {...element.properties, property: newValue},
                );
                ref
                    .read(layoutElementsProvider.notifier)
                    .updateElement(element.id, updatedElement);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
    bool isInteger = false,
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
                  text: isInfinity
                      ? 'auto'
                      : (isInteger
                            ? value.toInt().toString()
                            : value.toString()),
                ),
                enabled: !isInfinity,
                keyboardType: TextInputType.number,
                onChanged: (newValue) {
                  final parsed = double.tryParse(newValue);
                  if (parsed != null) {
                    final updatedElement = element.copyWith(
                      properties: {
                        ...element.properties,
                        property: isInteger
                            ? parsed.toInt().toDouble()
                            : parsed,
                      },
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
