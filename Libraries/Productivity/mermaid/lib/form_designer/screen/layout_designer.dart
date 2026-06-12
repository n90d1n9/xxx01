import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/accordion_panel_config.dart';
import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../model/step_config.dart';
import '../model/tab_config.dart';
import '../states/form_field_provider.dart';

class AdvancedLayoutDesigner extends ConsumerStatefulWidget {
  final FieldConfig field;
  final FormTheme theme;

  const AdvancedLayoutDesigner({
    super.key,
    required this.field,
    required this.theme,
  });

  @override
  ConsumerState<AdvancedLayoutDesigner> createState() =>
      _AdvancedLayoutDesignerState();
}

class _AdvancedLayoutDesignerState
    extends ConsumerState<AdvancedLayoutDesigner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.view_module,
                color: widget.theme.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Layout Designer',
                style: TextStyle(
                  color: widget.theme.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.field.type == 'tabs')
            _TabsDesigner(field: widget.field, theme: widget.theme)
          else if (widget.field.type == 'stepper')
            _StepperDesigner(field: widget.field, theme: widget.theme)
          else if (widget.field.type == 'accordion')
            _AccordionDesigner(field: widget.field, theme: widget.theme),
        ],
      ),
    );
  }
}

class _TabsDesigner extends ConsumerWidget {
  final FieldConfig field;
  final FormTheme theme;

  const _TabsDesigner({required this.field, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = field.tabs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tabs (${tabs.length})',
              style: TextStyle(color: theme.colors.text),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Tab', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colors.primary,
                side: BorderSide(color: theme.colors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: () => _addTab(ref),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.tab, color: theme.colors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: theme.colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${tab.fields.length} fields',
                        style: TextStyle(
                          color: theme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: theme.colors.textSecondary,
                  onPressed: () => _editTab(ref, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: theme.colors.error,
                  onPressed: () => _deleteTab(ref, index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _addTab(WidgetRef ref) {
    final tabs = field.tabs ?? [];
    final newTab = TabConfig(
      id: 'tab_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Tab ${tabs.length + 1}',
      fields: [],
    );

    // Convert existing options to a map first
    final existingOptions = optionsToMap(field.options);
    final updatedOptions = {
      ...existingOptions,
      'tabs': [...tabs, newTab].map((t) => t.toJson()).toList(),
    };

    final updatedField = field.copyWith(options: [updatedOptions]);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }

  void _editTab(WidgetRef ref, int index) {
    // Open tab editor dialog
  }

  void _deleteTab(WidgetRef ref, int index) {
    final tabs = field.tabs ?? [];
    final updatedTabs = [...tabs]..removeAt(index);

    // Convert existing options to a map first
    final existingOptions = optionsToMap(field.options);
    final updatedOptions = {
      ...existingOptions,
      'tabs': updatedTabs.map((t) => t.toJson()).toList(),
    };

    final updatedField = field.copyWith(options: [updatedOptions]);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }
}

// Helper method to convert List<dynamic> options to Map<String, dynamic>
Map<String, dynamic> optionsToMap(List<dynamic>? options) {
  if (options == null || options.isEmpty) return {};

  // If options contains a map, use the first one
  for (final item in options) {
    if (item is Map<String, dynamic>) {
      return Map<String, dynamic>.from(item);
    }
  }

  return {};
}

class _StepperDesigner extends ConsumerWidget {
  final FieldConfig field;
  final FormTheme theme;

  const _StepperDesigner({required this.field, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = field.steps ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Steps (${steps.length})',
              style: TextStyle(color: theme.colors.text),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Step', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colors.primary,
                side: BorderSide(color: theme.colors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: () => _addStep(ref),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: theme.colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (step.subtitle != null)
                        Text(
                          step.subtitle!,
                          style: TextStyle(
                            color: theme.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        '${step.fields.length} fields',
                        style: TextStyle(
                          color: theme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: theme.colors.error,
                  onPressed: () => _deleteStep(ref, index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _addStep(WidgetRef ref) {
    final steps = field.steps ?? [];
    final newStep = StepConfig(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Step ${steps.length + 1}',
      fields: [],
    );

    // Convert existing options to a map first
    final existingOptions = optionsToMap(field.options);
    final updatedOptions = {
      ...existingOptions,
      'steps': [...steps, newStep].map((s) => s.toJson()).toList(),
    };

    final updatedField = field.copyWith(options: [updatedOptions]);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }

  void _deleteStep(WidgetRef ref, int index) {
    final steps = field.steps ?? [];
    final updatedSteps = [...steps]..removeAt(index);

    // Convert existing options to a map first
    final existingOptions = optionsToMap(field.options);
    final updatedOptions = {
      ...existingOptions,
      'steps': updatedSteps.map((s) => s.toJson()).toList(),
    };

    final updatedField = field.copyWith(options: [updatedOptions]);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }
}

class _AccordionDesigner extends ConsumerWidget {
  final FieldConfig field;
  final FormTheme theme;

  const _AccordionDesigner({required this.field, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panels = field.panels ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Panels (${panels.length})',
              style: TextStyle(color: theme.colors.text),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Panel', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colors.primary,
                side: BorderSide(color: theme.colors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: () => _addPanel(ref),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...panels.asMap().entries.map((entry) {
          final index = entry.key;
          final panel = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.expand_more, color: theme.colors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        panel.header,
                        style: TextStyle(
                          color: theme.colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (panel.description != null)
                        Text(
                          panel.description!,
                          style: TextStyle(
                            color: theme.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        '${panel.fields.length} fields',
                        style: TextStyle(
                          color: theme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: theme.colors.error,
                  onPressed: () => _deletePanel(ref, index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _addPanel(WidgetRef ref) {
    final panels = field.panels ?? [];
    final newPanel = AccordionPanelConfig(
      id: 'panel_${DateTime.now().millisecondsSinceEpoch}',
      header: 'Panel ${panels.length + 1}',
      fields: [],
    );

    final updatedOptions = _updateOptionsList(
      field.options,
      'panels',
      [...panels, newPanel].map((p) => p.toJson()).toList(),
    );

    final updatedField = field.copyWith(options: updatedOptions);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }

  void _deletePanel(WidgetRef ref, int index) {
    final panels = field.panels ?? [];
    final updatedPanels = [...panels]..removeAt(index);

    final updatedOptions = _updateOptionsList(
      field.options,
      'panels',
      updatedPanels.map((p) => p.toJson()).toList(),
    );

    final updatedField = field.copyWith(options: updatedOptions);
    ref.read(formFieldsProvider.notifier).updateField(field.id, updatedField);
  }

  // Helper method to update a specific key in the options list
  List<dynamic> _updateOptionsList(
    List<dynamic>? options,
    String key,
    dynamic value,
  ) {
    final List<dynamic> result = [];
    bool found = false;

    if (options != null) {
      for (final item in options) {
        if (item is Map<String, dynamic> && item.containsKey(key)) {
          // Update existing entry
          result.add({...item, key: value});
          found = true;
        } else {
          // Keep other entries as-is
          result.add(item);
        }
      }
    }

    // If no existing entry was found, add a new one
    if (!found) {
      result.add({key: value});
    }

    return result;
  }
}
