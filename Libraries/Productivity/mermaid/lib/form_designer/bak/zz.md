import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// STATE MANAGEMENT - RIVERPOD PROVIDERS
// ============================================================================

final formFieldsProvider =
    StateNotifierProvider<FormFieldsNotifier, List<FieldConfig>>((ref) {
      return FormFieldsNotifier();
    });

final selectedFieldProvider = StateProvider<FieldConfig?>((ref) => null);
final previewModeProvider = StateProvider<bool>((ref) => false);
final draggingIndexProvider = StateProvider<int?>((ref) => null);
final expandedContainersProvider = StateProvider<Set<String>>((ref) => {});

class FormFieldsNotifier extends StateNotifier<List<FieldConfig>> {
  FormFieldsNotifier() : super([]);

  void addField(FieldConfig field, {String? parentId}) {
    if (parentId != null) {
      state = _addFieldToContainer(state, parentId, field);
    } else {
      state = [...state, field];
    }
  }

  List<FieldConfig> _addFieldToContainer(
    List<FieldConfig> fields,
    String parentId,
    FieldConfig newField,
  ) {
    return fields.map((field) {
      if (field.id == parentId && field.children != null) {
        return field.copyWith(children: [...field.children!, newField]);
      } else if (field.children != null) {
        return field.copyWith(
          children: _addFieldToContainer(field.children!, parentId, newField),
        );
      }
      return field;
    }).toList();
  }

  void updateField(String id, FieldConfig updatedField) {
    state = _updateFieldRecursive(state, id, updatedField);
  }

  List<FieldConfig> _updateFieldRecursive(
    List<FieldConfig> fields,
    String id,
    FieldConfig updatedField,
  ) {
    return fields.map((field) {
      if (field.id == id) {
        return updatedField;
      } else if (field.children != null) {
        return field.copyWith(
          children: _updateFieldRecursive(field.children!, id, updatedField),
        );
      }
      return field;
    }).toList();
  }

  void deleteField(String id) {
    state = _deleteFieldRecursive(state, id);
  }

  List<FieldConfig> _deleteFieldRecursive(List<FieldConfig> fields, String id) {
    return fields.where((field) => field.id != id).map((field) {
      if (field.children != null) {
        return field.copyWith(
          children: _deleteFieldRecursive(field.children!, id),
        );
      }
      return field;
    }).toList();
  }

  void duplicateField(FieldConfig field) {
    final newField = _duplicateFieldRecursive(field);
    state = [...state, newField];
  }

  FieldConfig _duplicateFieldRecursive(FieldConfig field) {
    return field.copyWith(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      name: field.name != null ? '${field.name}_copy' : null,
      children: field.children
          ?.map((child) => _duplicateFieldRecursive(child))
          .toList(),
    );
  }

  void reorderField(int oldIndex, int newIndex) {
    final newState = List<FieldConfig>.from(state);
    final field = newState.removeAt(oldIndex);
    newState.insert(newIndex, field);
    state = newState;
  }

  void clear() {
    state = [];
  }

  String exportConfig() {
    final config = {
      'fields': state.map((f) => f.toJson()).toList(),
      'actions': [
        {
          'id': 'submit',
          'label': 'Submit',
          'type': 'primary',
          'requiresValidation': true,
        },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(config);
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class FieldConfig {
  final String id;
  final String type;
  final String? name;
  final String? label;
  final String? title;
  final String? description;
  final String? content;
  final String? hint;
  final String? helperText;
  final bool required;
  final dynamic defaultValue;
  final List<dynamic>? options;
  final Map<String, dynamic>? validation;
  final String? visibleIf;
  final String? enabledIf;
  final String? requiredIf;
  final num? min;
  final num? max;
  final int? maxLines;
  final int? maxRating;

  // Layout properties
  final List<FieldConfig>? children;
  final String? layout; // 'column', 'row'
  final int? flex;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final int? columns; // For grid layout
  final double? spacing;
  final double? runSpacing;

  FieldConfig({
    required this.id,
    required this.type,
    this.name,
    this.label,
    this.title,
    this.description,
    this.content,
    this.hint,
    this.helperText,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validation,
    this.visibleIf,
    this.enabledIf,
    this.requiredIf,
    this.min,
    this.max,
    this.maxLines,
    this.maxRating,
    this.children,
    this.layout,
    this.flex,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
    this.decoration,
    this.columns,
    this.spacing,
    this.runSpacing,
  });

  bool get isContainer =>
      ['container', 'row', 'column', 'card', 'grid'].contains(type);

  FieldConfig copyWith({
    String? id,
    String? type,
    String? name,
    String? label,
    String? title,
    String? description,
    String? content,
    String? hint,
    String? helperText,
    bool? required,
    dynamic defaultValue,
    List<dynamic>? options,
    Map<String, dynamic>? validation,
    String? visibleIf,
    String? enabledIf,
    String? requiredIf,
    num? min,
    num? max,
    int? maxLines,
    int? maxRating,
    List<FieldConfig>? children,
    String? layout,
    int? flex,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? width,
    double? height,
    BoxDecoration? decoration,
    int? columns,
    double? spacing,
    double? runSpacing,
  }) {
    return FieldConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      label: label ?? this.label,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      hint: hint ?? this.hint,
      helperText: helperText ?? this.helperText,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      visibleIf: visibleIf ?? this.visibleIf,
      enabledIf: enabledIf ?? this.enabledIf,
      requiredIf: requiredIf ?? this.requiredIf,
      min: min ?? this.min,
      max: max ?? this.max,
      maxLines: maxLines ?? this.maxLines,
      maxRating: maxRating ?? this.maxRating,
      children: children ?? this.children,
      layout: layout ?? this.layout,
      flex: flex ?? this.flex,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      columns: columns ?? this.columns,
      spacing: spacing ?? this.spacing,
      runSpacing: runSpacing ?? this.runSpacing,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};

    if (name != null) json['name'] = name;
    if (label != null) json['label'] = label;
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (content != null) json['content'] = content;
    if (hint != null) json['hint'] = hint;
    if (helperText != null) json['helperText'] = helperText;
    if (required) json['required'] = required;
    if (defaultValue != null) json['defaultValue'] = defaultValue;
    if (options != null) json['options'] = options;
    if (validation != null) json['validation'] = validation;
    if (visibleIf != null && visibleIf!.isNotEmpty)
      json['visibleIf'] = visibleIf;
    if (enabledIf != null && enabledIf!.isNotEmpty)
      json['enabledIf'] = enabledIf;
    if (requiredIf != null && requiredIf!.isNotEmpty)
      json['requiredIf'] = requiredIf;
    if (min != null) json['min'] = min;
    if (max != null) json['max'] = max;
    if (maxLines != null) json['maxLines'] = maxLines;
    if (maxRating != null) json['maxRating'] = maxRating;

    // Layout properties
    if (children != null)
      json['children'] = children!.map((c) => c.toJson()).toList();
    if (layout != null) json['layout'] = layout;
    if (flex != null) json['flex'] = flex;
    if (padding != null) json['padding'] = _edgeInsetsToJson(padding!);
    if (margin != null) json['margin'] = _edgeInsetsToJson(margin!);
    if (backgroundColor != null)
      json['backgroundColor'] =
          '#${backgroundColor!.value.toRadixString(16).substring(2)}';
    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    if (columns != null) json['columns'] = columns;
    if (spacing != null) json['spacing'] = spacing;
    if (runSpacing != null) json['runSpacing'] = runSpacing;

    return json;
  }

  Map<String, double> _edgeInsetsToJson(EdgeInsets insets) {
    return {
      'left': insets.left,
      'top': insets.top,
      'right': insets.right,
      'bottom': insets.bottom,
    };
  }
}

class FieldTypeDefinition {
  final String type;
  final String label;
  final IconData icon;
  final String category;

  const FieldTypeDefinition({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
  });
}

// ============================================================================
// FIELD TYPE DEFINITIONS
// ============================================================================

const fieldTypes = [
  // Layout Containers
  FieldTypeDefinition(
    type: 'container',
    label: 'Container',
    icon: Icons.crop_square,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'row',
    label: 'Row Layout',
    icon: Icons.view_week,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'column',
    label: 'Column Layout',
    icon: Icons.view_agenda,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'card',
    label: 'Card',
    icon: Icons.credit_card,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'grid',
    label: 'Grid Layout',
    icon: Icons.grid_on,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'section',
    label: 'Section Header',
    icon: Icons.title,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'divider',
    label: 'Divider',
    icon: Icons.horizontal_rule,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'html',
    label: 'HTML/Text',
    icon: Icons.text_snippet,
    category: 'Layout',
  ),

  // Input Fields
  FieldTypeDefinition(
    type: 'text',
    label: 'Text Input',
    icon: Icons.text_fields,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'email',
    label: 'Email',
    icon: Icons.email,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'password',
    label: 'Password',
    icon: Icons.lock,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'number',
    label: 'Number',
    icon: Icons.numbers,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'tel',
    label: 'Phone',
    icon: Icons.phone,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'url',
    label: 'URL',
    icon: Icons.link,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'textarea',
    label: 'Text Area',
    icon: Icons.notes,
    category: 'Input',
  ),

  // Selection Fields
  FieldTypeDefinition(
    type: 'select',
    label: 'Dropdown',
    icon: Icons.arrow_drop_down_circle,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'radio',
    label: 'Radio Group',
    icon: Icons.radio_button_checked,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'checkbox',
    label: 'Checkbox',
    icon: Icons.check_box,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'switch',
    label: 'Switch',
    icon: Icons.toggle_on,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'chips',
    label: 'Chips',
    icon: Icons.label,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'slider',
    label: 'Slider',
    icon: Icons.linear_scale,
    category: 'Input',
  ),

  // DateTime
  FieldTypeDefinition(
    type: 'date',
    label: 'Date',
    icon: Icons.calendar_today,
    category: 'DateTime',
  ),
  FieldTypeDefinition(
    type: 'time',
    label: 'Time',
    icon: Icons.access_time,
    category: 'DateTime',
  ),

  // Special
  FieldTypeDefinition(
    type: 'rating',
    label: 'Rating',
    icon: Icons.star,
    category: 'Special',
  ),
  FieldTypeDefinition(
    type: 'tags',
    label: 'Tags',
    icon: Icons.local_offer,
    category: 'Special',
  ),
];

// ============================================================================
// MAIN DESIGNER SCREEN
// ============================================================================

class FormBuilderDesigner extends ConsumerWidget {
  const FormBuilderDesigner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewMode = ref.watch(previewModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('🎨 Enhanced Form Builder Designer'),
        backgroundColor: const Color(0xFF2D2D2D),
        actions: [
          IconButton(
            icon: Icon(previewMode ? Icons.edit : Icons.visibility),
            tooltip: previewMode ? 'Edit Mode' : 'Preview Mode',
            onPressed: () {
              ref.read(previewModeProvider.notifier).state = !previewMode;
              ref.read(selectedFieldProvider.notifier).state = null;
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export Config',
            onPressed: () => _showExportDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All',
            onPressed: () => _showClearDialog(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!previewMode) const ComponentPalette(),
          const Expanded(child: FormCanvas()),
          if (!previewMode) const PropertiesPanel(),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(formFieldsProvider.notifier).exportConfig();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          '📋 Form Configuration',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      config,
                      style: const TextStyle(
                        color: Color(0xFF4EC9B0),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: config));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Copied to clipboard!')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Clear All Fields?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove all fields. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(formFieldsProvider.notifier).clear();
              ref.read(selectedFieldProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENT PALETTE
// ============================================================================

class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = fieldTypes.map((f) => f.category).toSet().toList();

    return Container(
      width: 250,
      color: const Color(0xFF252526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'COMPONENTS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryFields = fieldTypes
                    .where((f) => f.category == category)
                    .toList();

                return ExpansionTile(
                  initiallyExpanded: category == 'Layout',
                  title: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  children: categoryFields.map((fieldType) {
                    return InkWell(
                      onTap: () => _addField(ref, fieldType),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(fieldType.icon, size: 18, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fieldType.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if ([
                              'container',
                              'row',
                              'column',
                              'card',
                              'grid',
                            ].contains(fieldType.type))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'LAYOUT',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addField(WidgetRef ref, FieldTypeDefinition fieldType) {
    final field = FieldConfig(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      type: fieldType.type,
      name:
          [
            'section',
            'divider',
            'html',
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? null
          : '${fieldType.type}_${ref.read(formFieldsProvider).length + 1}',
      label:
          [
            'section',
            'html',
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? null
          : fieldType.label,
      title: fieldType.type == 'section' ? 'Section Title' : null,
      description: fieldType.type == 'section' ? '' : null,
      content: fieldType.type == 'html' ? 'Your content here' : null,
      options: ['select', 'radio', 'chips'].contains(fieldType.type)
          ? ['Option 1', 'Option 2', 'Option 3']
          : null,
      min: ['number', 'slider'].contains(fieldType.type) ? 0 : null,
      max: ['number', 'slider'].contains(fieldType.type) ? 100 : null,
      maxLines: fieldType.type == 'textarea' ? 4 : null,
      maxRating: fieldType.type == 'rating' ? 5 : null,
      children:
          [
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? []
          : null,
      padding: ['container', 'card'].contains(fieldType.type)
          ? const EdgeInsets.all(16)
          : null,
      columns: fieldType.type == 'grid' ? 2 : null,
      spacing: fieldType.type == 'grid' ? 12 : null,
    );

    ref.read(formFieldsProvider.notifier).addField(field);
    ref.read(selectedFieldProvider.notifier).state = field;
  }
}

// ============================================================================
// FORM CANVAS
// ============================================================================

class FormCanvas extends ConsumerWidget {
  const FormCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(formFieldsProvider);
    final previewMode = ref.watch(previewModeProvider);

    if (fields.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Start Building Your Form',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add components from the left panel',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: previewMode
                  ? (_, __) {}
                  : (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      ref
                          .read(formFieldsProvider.notifier)
                          .reorderField(oldIndex, newIndex);
                    },
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                return FieldCardWrapper(
                  key: ValueKey(field.id),
                  field: field,
                  index: index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FIELD CARD WRAPPER
// ============================================================================

class FieldCardWrapper extends ConsumerWidget {
  final FieldConfig field;
  final int index;
  final String? parentId;
  final int depth;

  const FieldCardWrapper({
    Key? key,
    required this.field,
    required this.index,
    this.parentId,
    this.depth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (field.isContainer) {
      return ContainerFieldCard(field: field, depth: depth);
    }
    return FieldCard(field: field, index: index, depth: depth);
  }
}

// ============================================================================
// CONTAINER FIELD CARD
// ============================================================================

class ContainerFieldCard extends ConsumerWidget {
  final FieldConfig field;
  final int depth;

  const ContainerFieldCard({Key? key, required this.field, this.depth = 0})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final isSelected = selectedField?.id == field.id;
    final expandedContainers = ref.watch(expandedContainersProvider);
    final isExpanded = expandedContainers.contains(field.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: depth * 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border.all(
          color: isSelected ? Colors.purple : const Color(0xFF3D3D3D),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Container Header
          InkWell(
            onTap: () => ref.read(selectedFieldProvider.notifier).state = field,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getContainerIcon(field.type),
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getContainerLabel(field.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (field.children != null && field.children!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${field.children!.length} item${field.children!.length != 1 ? "s" : ""}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    color: Colors.white70,
                    onPressed: () {
                      final newSet = Set<String>.from(expandedContainers);
                      if (isExpanded) {
                        newSet.remove(field.id);
                      } else {
                        newSet.add(field.id);
                      }
                      ref.read(expandedContainersProvider.notifier).state =
                          newSet;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 20),
                    color: Colors.green,
                    tooltip: 'Add Field',
                    onPressed: () =>
                        _showAddFieldDialog(context, ref, field.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18),
                    color: Colors.white70,
                    tooltip: 'Duplicate',
                    onPressed: () => ref
                        .read(formFieldsProvider.notifier)
                        .duplicateField(field),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red,
                    tooltip: 'Delete',
                    onPressed: () {
                      ref
                          .read(formFieldsProvider.notifier)
                          .deleteField(field.id);
                      if (selectedField?.id == field.id) {
                        ref.read(selectedFieldProvider.notifier).state = null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Container Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: field.children == null || field.children!.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empty Container',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'Add Field',
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () =>
                                _showAddFieldDialog(context, ref, field.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              side: const BorderSide(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildContainerLayout(field, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildContainerLayout(FieldConfig container, WidgetRef ref) {
    final children = container.children!;

    if (container.type == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: container.columns ?? 2,
          crossAxisSpacing: container.spacing ?? 12,
          mainAxisSpacing: container.spacing ?? 12,
          childAspectRatio: 2,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return FieldCard(
            field: children[index],
            index: index,
            depth: depth + 1,
          );
        },
      );
    } else if (container.type == 'row') {
      return Row(
        crossAxisAlignment:
            container.crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisAlignment:
            container.mainAxisAlignment ?? MainAxisAlignment.start,
        children: children.map((child) {
          return Expanded(
            flex: child.flex ?? 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: container.spacing ?? 8),
              child: FieldCard(
                field: child,
                index: children.indexOf(child),
                depth: depth + 1,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        crossAxisAlignment:
            container.crossAxisAlignment ?? CrossAxisAlignment.stretch,
        mainAxisAlignment:
            container.mainAxisAlignment ?? MainAxisAlignment.start,
        children: children.map((child) {
          return FieldCard(
            field: child,
            index: children.indexOf(child),
            depth: depth + 1,
          );
        }).toList(),
      );
    }
  }

  void _showAddFieldDialog(
    BuildContext context,
    WidgetRef ref,
    String containerId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Add Field to Container',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView(
            children: fieldTypes
                .where(
                  (f) =>
                      f.category != 'Layout' ||
                      ![
                        'container',
                        'row',
                        'column',
                        'card',
                        'grid',
                      ].contains(f.type),
                )
                .map((fieldType) {
                  return ListTile(
                    leading: Icon(fieldType.icon, color: Colors.blue),
                    title: Text(
                      fieldType.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      final field = FieldConfig(
                        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
                        type: fieldType.type,
                        name:
                            [
                              'section',
                              'divider',
                              'html',
                            ].contains(fieldType.type)
                            ? null
                            : '${fieldType.type}_${DateTime.now().millisecondsSinceEpoch}',
                        label: ['section', 'html'].contains(fieldType.type)
                            ? null
                            : fieldType.label,
                        title: fieldType.type == 'section'
                            ? 'Section Title'
                            : null,
                        options:
                            [
                              'select',
                              'radio',
                              'chips',
                            ].contains(fieldType.type)
                            ? ['Option 1', 'Option 2', 'Option 3']
                            : null,
                      );
                      ref
                          .read(formFieldsProvider.notifier)
                          .addField(field, parentId: containerId);
                      Navigator.pop(context);
                    },
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }

  IconData _getContainerIcon(String type) {
    switch (type) {
      case 'row':
        return Icons.view_week;
      case 'column':
        return Icons.view_agenda;
      case 'card':
        return Icons.credit_card;
      case 'grid':
        return Icons.grid_on;
      default:
        return Icons.crop_square;
    }
  }

  String _getContainerLabel(String type) {
    switch (type) {
      case 'row':
        return 'Row Layout';
      case 'column':
        return 'Column Layout';
      case 'card':
        return 'Card';
      case 'grid':
        return 'Grid Layout';
      default:
        return 'Container';
    }
  }
}

// ============================================================================
// FIELD CARD
// ============================================================================

class FieldCard extends ConsumerWidget {
  final FieldConfig field;
  final int index;
  final int depth;

  const FieldCard({
    Key? key,
    required this.field,
    required this.index,
    this.depth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final isSelected = selectedField?.id == field.id;
    final previewMode = ref.watch(previewModeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: depth > 0 ? 0 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border.all(
          color: isSelected ? Colors.blue : const Color(0xFF3D3D3D),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: previewMode
            ? null
            : () {
                ref.read(selectedFieldProvider.notifier).state = field;
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!previewMode)
                Icon(
                  Icons.drag_indicator,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              if (!previewMode) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.label != null || field.title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              field.label ?? field.title ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (field.required)
                              const Text(
                                ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    _buildFieldPreview(field),
                    if (field.helperText != null &&
                        field.helperText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          field.helperText!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (field.visibleIf != null &&
                        field.visibleIf!.isNotEmpty &&
                        !previewMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Visible if: ${field.visibleIf}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!previewMode) ...[
                const SizedBox(width: 12),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      color: Colors.white70,
                      tooltip: 'Duplicate',
                      onPressed: () {
                        ref
                            .read(formFieldsProvider.notifier)
                            .duplicateField(field);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      tooltip: 'Delete',
                      onPressed: () {
                        ref
                            .read(formFieldsProvider.notifier)
                            .deleteField(field.id);
                        if (selectedField?.id == field.id) {
                          ref.read(selectedFieldProvider.notifier).state = null;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldPreview(FieldConfig field) {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'password':
      case 'url':
      case 'tel':
      case 'number':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.hint ?? 'Enter ${field.label?.toLowerCase()}',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        );

      case 'textarea':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          height: (field.maxLines ?? 4) * 24.0,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.hint ?? 'Enter text...',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        );

      case 'select':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select an option',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ],
          ),
        );

      case 'checkbox':
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              field.label ?? 'Checkbox',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );

      case 'switch':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field.label ?? 'Switch',
              style: const TextStyle(color: Colors.white),
            ),
            Container(
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              field.options?.map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        );

      case 'chips':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              field.options?.map<Widget>((option) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    option.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }).toList() ??
              [],
        );

      case 'slider':
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${field.min ?? 0}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${field.max ?? 100}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'date':
      case 'time':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.type == 'date' ? 'Select date' : 'Select time',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              Icon(
                field.type == 'date' ? Icons.calendar_today : Icons.access_time,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        );

      case 'rating':
        return Row(
          children: List.generate(
            field.maxRating ?? 5,
            (index) =>
                const Icon(Icons.star_border, color: Colors.amber, size: 28),
          ),
        );

      case 'tags':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Tag 1', style: TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {},
                  backgroundColor: const Color(0xFF3D3D3D),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF3D3D3D)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Add tag...',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        );

      case 'section':
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.blue, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.title ?? 'Section Title',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (field.description != null && field.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    field.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        );

      case 'divider':
        return const Divider(color: Color(0xFF3D3D3D), thickness: 1);

      case 'html':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.content ?? 'HTML content',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        );

      default:
        return Text(
          'Unknown type: ${field.type}',
          style: const TextStyle(color: Colors.red),
        );
    }
  }
}

// ============================================================================
// PROPERTIES PANEL
// ============================================================================

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);

    if (selectedField == null) {
      return Container(
        width: 320,
        color: const Color(0xFF252526),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No field selected',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 320,
      color: const Color(0xFF252526),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3D3D3D))),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Properties',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.white70,
                  onPressed: () =>
                      ref.read(selectedFieldProvider.notifier).state = null,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PropertyGroup(
                    title: 'Basic',
                    children: [
                      _PropertyLabel(label: 'Field Type'),
                      _PropertyTextField(
                        value: selectedField.type,
                        enabled: false,
                      ),
                      if (selectedField.name != null) ...[
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Field Name'),
                        _PropertyTextField(
                          value: selectedField.name ?? '',
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(name: value),
                          ),
                        ),
                      ],
                      if (selectedField.label != null) ...[
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Label'),
                        _PropertyTextField(
                          value: selectedField.label ?? '',
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(label: value),
                          ),
                        ),
                      ],
                      if (selectedField.title != null) ...[
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Title'),
                        _PropertyTextField(
                          value: selectedField.title ?? '',
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(title: value),
                          ),
                        ),
                      ],
                      if (selectedField.description != null) ...[
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Description'),
                        _PropertyTextField(
                          value: selectedField.description ?? '',
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(description: value),
                          ),
                          maxLines: 2,
                        ),
                      ],
                      if (selectedField.content != null) ...[
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Content'),
                        _PropertyTextField(
                          value: selectedField.content ?? '',
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(content: value),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                  if (selectedField.isContainer) ...[
                    const SizedBox(height: 20),
                    _PropertyGroup(
                      title: 'Layout Settings',
                      children: [
                        if (selectedField.type == 'grid') ...[
                          _PropertyLabel(label: 'Columns'),
                          _PropertyTextField(
                            value: (selectedField.columns ?? 2).toString(),
                            onChanged: (value) {
                              final num = int.tryParse(value) ?? 2;
                              _updateField(
                                ref,
                                selectedField.copyWith(columns: num),
                              );
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _PropertyLabel(label: 'Spacing'),
                        _PropertyTextField(
                          value: (selectedField.spacing ?? 12).toString(),
                          onChanged: (value) {
                            final num = double.tryParse(value) ?? 12;
                            _updateField(
                              ref,
                              selectedField.copyWith(spacing: num),
                            );
                          },
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _PropertyLabel(label: 'Padding (all sides)'),
                        _PropertyTextField(
                          value: (selectedField.padding?.left ?? 16).toString(),
                          onChanged: (value) {
                            final num = double.tryParse(value) ?? 16;
                            _updateField(
                              ref,
                              selectedField.copyWith(
                                padding: EdgeInsets.all(num),
                              ),
                            );
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ],
                  if (!selectedField.isContainer &&
                      selectedField.type != 'section' &&
                      selectedField.type != 'divider' &&
                      selectedField.type != 'html') ...[
                    const SizedBox(height: 20),
                    _PropertyGroup(
                      title: 'Field Settings',
                      children: [
                        if (selectedField.hint != null) ...[
                          _PropertyLabel(label: 'Placeholder'),
                          _PropertyTextField(
                            value: selectedField.hint ?? '',
                            onChanged: (value) => _updateField(
                              ref,
                              selectedField.copyWith(hint: value),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (selectedField.helperText != null) ...[
                          _PropertyLabel(label: 'Helper Text'),
                          _PropertyTextField(
                            value: selectedField.helperText ?? '',
                            onChanged: (value) => _updateField(
                              ref,
                              selectedField.copyWith(helperText: value),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        CheckboxListTile(
                          title: const Text(
                            'Required',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          value: selectedField.required,
                          onChanged: (value) => _updateField(
                            ref,
                            selectedField.copyWith(required: value),
                          ),
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                  if (selectedField.options != null) ...[
                    const SizedBox(height: 20),
                    _PropertyGroup(
                      title: 'Options',
                      children: [
                        _PropertyLabel(label: 'Options (one per line)'),
                        _PropertyTextField(
                          value: selectedField.options?.join('\n') ?? '',
                          onChanged: (value) {
                            final options = value
                                .split('\n')
                                .where((o) => o.trim().isNotEmpty)
                                .toList();
                            _updateField(
                              ref,
                              selectedField.copyWith(options: options),
                            );
                          },
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  _PropertyGroup(
                    title: 'CEL Conditions',
                    children: [
                      _PropertyLabel(label: 'Visible If', tooltip: 'age >= 18'),
                      _PropertyTextField(
                        value: selectedField.visibleIf ?? '',
                        onChanged: (value) => _updateField(
                          ref,
                          selectedField.copyWith(visibleIf: value),
                        ),
                        placeholder: 'age >= 18',
                      ),
                      const SizedBox(height: 12),
                      _PropertyLabel(
                        label: 'Enabled If',
                        tooltip: 'country == "USA"',
                      ),
                      _PropertyTextField(
                        value: selectedField.enabledIf ?? '',
                        onChanged: (value) => _updateField(
                          ref,
                          selectedField.copyWith(enabledIf: value),
                        ),
                        placeholder: 'country == "USA"',
                      ),
                      const SizedBox(height: 12),
                      _PropertyLabel(
                        label: 'Required If',
                        tooltip: 'accountType != "free"',
                      ),
                      _PropertyTextField(
                        value: selectedField.requiredIf ?? '',
                        onChanged: (value) => _updateField(
                          ref,
                          selectedField.copyWith(requiredIf: value),
                        ),
                        placeholder: 'accountType != "free"',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateField(WidgetRef ref, FieldConfig updatedField) {
    ref
        .read(formFieldsProvider.notifier)
        .updateField(updatedField.id, updatedField);
    ref.read(selectedFieldProvider.notifier).state = updatedField;
  }
}

// ============================================================================
// PROPERTY WIDGETS
// ============================================================================

class _PropertyGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PropertyGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _PropertyLabel extends StatelessWidget {
  final String label;
  final String? tooltip;

  const _PropertyLabel({required this.label, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (tooltip != null) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: tooltip!,
            child: Icon(
              Icons.help_outline,
              size: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}

class _PropertyTextField extends StatelessWidget {
  final String value;
  final Function(String)? onChanged;
  final String? placeholder;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;

  const _PropertyTextField({
    required this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white54,
        fontSize: 13,
        fontFamily: placeholder != null ? 'monospace' : null,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: enabled ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN APP
// ============================================================================

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        title: 'Form Builder Designer',
        debugShowCheckedModeBanner: false,
        home: FormBuilderDesigner(),
      ),
    ),
  );
}
