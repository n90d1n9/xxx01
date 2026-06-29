import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component_type.dart';
import '../models/design_component.dart';
import '../states/provider.dart';

class ComponentPropertyEditor extends ConsumerWidget {
  final DesignComponent component;

  const ComponentPropertyEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(designerProvider.notifier);

    switch (component.type) {
      case ComponentType.text:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Text'),
              controller: TextEditingController(
                text: component.properties['text'],
              ),
              onChanged:
                  (v) =>
                      notifier.updateComponentProperty(component.id, 'text', v),
            ),
          ],
        );
      case ComponentType.button:
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Button Text'),
              controller: TextEditingController(
                text: component.properties['text'],
              ),
              onChanged:
                  (v) =>
                      notifier.updateComponentProperty(component.id, 'text', v),
            ),
          ],
        );
      default:
        return const Text('No editable properties');
    }
  }
}
