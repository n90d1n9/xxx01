import 'package:flutter/material.dart';

import '../models/component_type.dart';
import '../models/design_component.dart';

class ComponentWidget extends StatelessWidget {
  final DesignComponent component;

  const ComponentWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    switch (component.type) {
      case ComponentType.container:
        return Container(
          decoration: BoxDecoration(
            color: Color(component.properties['backgroundColor']),
            borderRadius: BorderRadius.circular(
              component.properties['borderRadius'],
            ),
            border: Border.all(
              color: Color(component.properties['borderColor']),
              width: component.properties['borderWidth'],
            ),
          ),
          padding: EdgeInsets.all(component.properties['padding']),
        );
      case ComponentType.text:
        return Text(
          component.properties['text'],
          style: TextStyle(
            fontSize: component.properties['fontSize'],
            color: Color(component.properties['color']),
            fontWeight:
                component.properties['fontWeight'] == 'bold'
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        );
      case ComponentType.button:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(component.properties['backgroundColor']),
            foregroundColor: Color(component.properties['textColor']),
          ),
          onPressed: () {},
          child: Text(component.properties['text']),
        );
      case ComponentType.icon:
        return Icon(
          Icons.star,
          color: Color(component.properties['color']),
          size: component.properties['size'],
        );
      default:
        return Container(color: Colors.grey.shade200);
    }
  }
}
