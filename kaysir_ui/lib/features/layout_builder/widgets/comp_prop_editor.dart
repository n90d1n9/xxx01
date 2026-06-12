import 'package:flutter/material.dart';

import '../models/component_properties.dart';
import 'attribute_editor.dart';
import 'event_editor.dart';

class ComponentPropertiesEditor extends StatelessWidget {
  final ComponentProperties properties;
  final ValueChanged<ComponentProperties> onPropertiesChanged;

  const ComponentPropertiesEditor({
    super.key,
    required this.properties,
    required this.onPropertiesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttributesEditor(
          attributes: properties.attributes,
          onAttributesChanged: (newAttributes) {
            onPropertiesChanged(properties.copyWith(attributes: newAttributes));
          },
        ),
        const SizedBox(height: 16),
        EventsEditor(
          events: properties.events,
          onEventsChanged: (newEvents) {
            onPropertiesChanged(properties.copyWith(events: newEvents));
          },
        ),
      ],
    );
  }
}
