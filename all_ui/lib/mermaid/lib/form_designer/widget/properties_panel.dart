import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../states/form_field_provider.dart';
import 'advanced_properties_tab.dart';
import 'style_properties_tab.dart';

class PropertiesPanel extends ConsumerStatefulWidget {
  final FormTheme theme;

  const PropertiesPanel({super.key, required this.theme});

  @override
  ConsumerState<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends ConsumerState<PropertiesPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedField = ref.watch(selectedFieldProvider);

    if (selectedField == null) {
      return Container(
        width: 320,
        color: widget.theme.colors.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app,
                size: 60,
                color: widget.theme.colors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a field to edit',
                style: TextStyle(color: widget.theme.colors.textSecondary),
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
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: widget.theme.colors.primary,
            unselectedLabelColor: widget.theme.colors.textSecondary,
            indicatorColor: widget.theme.colors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.settings, size: 20), text: 'Basic'),
              Tab(icon: Icon(Icons.palette, size: 20), text: 'Style'),
              Tab(icon: Icon(Icons.code, size: 20), text: 'Advanced'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BasicPropertiesTab(
                  theme: widget.theme,
                  field: selectedField!, // This can be null!
                ),
                StylePropertiesTab(
                  theme: widget.theme,
                  field: selectedField!, // This can be null!
                ),
                AdvancedPropertiesTab(
                  theme: widget.theme,
                  field: selectedField!, // This can be null!
                ),
              ],
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
