import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_cart_panel_config_editor.dart';
import 'component_function_panel_config_editor.dart';
import 'component_image_holder_config_editor.dart';
import 'component_numpad_config_editor.dart';
import 'component_product_grid_config_editor.dart';
import 'component_separator_config_editor.dart';
import 'component_text_formatting_config_editor.dart';

/// Routes a component to its built-in, type-specific inspector config panel.
class ComponentBuiltInConfigEditor extends StatelessWidget {
  final ComponentData component;

  const ComponentBuiltInConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    switch (component.type) {
      case ComponentType.buttonGrid:
        return ComponentProductGridConfigEditor(component: component);
      case ComponentType.cartPanel:
        return ComponentCartPanelConfigEditor(component: component);
      case ComponentType.customButton:
      case ComponentType.textLabel:
        return ComponentTextFormattingConfigEditor(component: component);
      case ComponentType.imageHolder:
        return ComponentImageHolderConfigEditor(component: component);
      case ComponentType.numpad:
        return ComponentNumpadConfigEditor(component: component);
      case ComponentType.functionPanel:
        return ComponentFunctionPanelConfigEditor(component: component);
      case ComponentType.separator:
        return ComponentSeparatorConfigEditor(component: component);
    }
  }
}

/// Renders the built-in config router with a sample cart panel component.
@Preview(name: 'Component built-in config editor')
Widget componentBuiltInConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-built-in-config',
    type: ComponentType.cartPanel,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'title': 'Cart',
        'showTitle': true,
        'showSubtotal': true,
        'showTax': true,
        'compact': false,
      },
    ),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentBuiltInConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}
