import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import '../provider/review_state.dart';
import 'comp_prop_editor.dart';
import 'component_auto_grid_geometry_editor.dart';
import 'component_builtin_config_editor.dart';
import 'component_constraints_editor.dart';
import 'component_data_binding_editor.dart';
import 'component_geometry_editor.dart';
import 'component_grid_geometry_editor.dart';
import 'component_identity_editor.dart';
import 'component_responsive_override_editor.dart';
import 'component_tabular_geometry_editor.dart';
import 'layout_diagnostics_panel.dart';
import 'style_editor.dart';

/// Edits the complete inspector stack for one selected component.
class ComponentSinglePropertyEditor extends ConsumerWidget {
  final ComponentData component;
  final ResponsivePreviewState previewState;
  final LayoutConfig config;
  final double gridSize;

  const ComponentSinglePropertyEditor({
    super.key,
    required this.component,
    required this.previewState,
    required this.config,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(component.type.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                component.type.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ComponentIdentityEditor(component: component),
        ComponentDiagnosticsCard(componentId: component.id),
        ComponentDataBindingEditor(component: component),
        ComponentBuiltInConfigEditor(component: component),
        const SizedBox(height: 16),
        ComponentGeometryEditor(component: component, config: config),
        const SizedBox(height: 16),
        ComponentConstraintsEditor(component: component, config: config),
        if (config.layoutMechanism == LayoutMechanism.grid) ...[
          const SizedBox(height: 16),
          ComponentGridGeometryEditor(
            component: component,
            config: config,
            gridSize: gridSize,
          ),
        ],
        if (config.layoutMechanism == LayoutMechanism.tabularColumns) ...[
          const SizedBox(height: 16),
          ComponentTabularGeometryEditor(component: component, config: config),
        ],
        if (config.layoutMechanism == LayoutMechanism.autoGrid) ...[
          const SizedBox(height: 16),
          ComponentAutoGridGeometryEditor(component: component, config: config),
        ],
        const SizedBox(height: 16),
        ComponentResponsiveOverrideEditor(
          component: component,
          previewState: previewState,
        ),
        const SizedBox(height: 16),
        StyleEditor(
          style: _editableStyleMap(component),
          onStyleChanged: (newStyle) {
            final properties = component.properties.copyWith(style: newStyle);
            final notifier = ref.read(layoutStateProvider.notifier);
            notifier.updateComponentProperties(component.id, properties);
            notifier.updateComponentStyle(
              component.id,
              _styleFromMap(component.style, newStyle),
            );
          },
        ),
        const SizedBox(height: 16),
        ComponentPropertiesEditor(
          properties: component.properties,
          onPropertiesChanged: (newProperties) {
            ref
                .read(layoutStateProvider.notifier)
                .updateComponentProperties(component.id, newProperties);
          },
        ),
      ],
    );
  }

  ComponentStyle _styleFromMap(
    ComponentStyle current,
    Map<String, dynamic> style,
  ) {
    final borderWidth = _nonNegativeStyleValue(
      _doubleStyleValue(
        style['borderWidth'],
        fallback: current.border?.top.width ?? 0,
      ),
    );
    final borderColor =
        _styleColor(style['borderColor']) ??
        current.border?.top.color ??
        Colors.black26;
    final borderRadius = _nonNegativeStyleValue(
      _doubleStyleValue(
        style['borderRadius'],
        fallback: current.borderRadius.topLeft.x,
      ),
    );
    final padding = _nonNegativeStyleValue(
      _doubleStyleValue(style['padding'], fallback: current.padding.left),
    );

    return ComponentStyle(
      backgroundColor:
          _styleColor(style['backgroundColor']) ?? current.backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border:
          borderWidth <= 0
              ? null
              : Border.all(width: borderWidth, color: borderColor),
      shadows: current.shadows,
      padding: EdgeInsets.all(padding),
      isResizable: _boolStyleValue(
        style['isResizable'],
        fallback: current.isResizable,
      ),
      isDraggable: _boolStyleValue(
        style['isDraggable'],
        fallback: current.isDraggable,
      ),
    );
  }

  Map<String, dynamic> _editableStyleMap(ComponentData component) {
    final style = component.style;

    return {
      ...component.properties.style,
      'backgroundColor': style.backgroundColor.toARGB32(),
      'borderRadius': style.borderRadius.topLeft.x,
      'borderWidth': style.border?.top.width ?? 0,
      'borderColor':
          style.border?.top.color.toARGB32() ?? Colors.black26.toARGB32(),
      'padding': style.padding.left,
      'isResizable': style.isResizable,
      'isDraggable': style.isDraggable,
    };
  }

  Color? _styleColor(Object? value) {
    if (value is int) return Color(value);
    if (value is String && value.isNotEmpty) {
      final normalized = value.replaceAll('#', '');
      final parsed = int.tryParse(
        normalized.length == 6 ? 'FF$normalized' : normalized,
        radix: 16,
      );
      if (parsed != null) return Color(parsed);
    }

    return null;
  }

  double _doubleStyleValue(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _boolStyleValue(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  double _nonNegativeStyleValue(double value) => value < 0 ? 0 : value;
}

/// Renders the single component property editor with a sample button.
@Preview(name: 'Component single property editor')
Widget componentSinglePropertyEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-single-property-button',
    type: ComponentType.customButton,
    position: const Offset(40, 48),
    size: const Size(160, 56),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: ComponentSinglePropertyEditor(
            component: component,
            previewState: ResponsivePreviewState.mobile,
            config: const LayoutConfig(
              canvasWidth: 430,
              canvasHeight: 320,
              minComponentWidth: 40,
              minComponentHeight: 40,
            ),
            gridSize: 20,
          ),
        ),
      ),
    ),
  );
}
