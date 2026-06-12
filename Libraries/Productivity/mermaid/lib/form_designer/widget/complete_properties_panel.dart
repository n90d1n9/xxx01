import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../states/form_field_provider.dart';

class CompletePropertiesPanel extends ConsumerWidget {
  final FormTheme theme;
  final int phase;

  const CompletePropertiesPanel({
    super.key,
    required this.theme,
    required this.phase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);

    return Container(
      width: 320,
      color: theme.colors.surface,
      child: selectedField == null
          ? _buildEmptyState()
          : _buildPropertiesContent(selectedField, ref),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 60,
            color: theme.colors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a field to edit',
            style: TextStyle(color: theme.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesContent(FieldConfig field, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: theme.colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Properties',
              style: TextStyle(
                color: theme.colors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Basic properties
        _PropertyField(
          theme: theme,
          label: 'Label',
          value: field.label ?? '',
          onChanged: (value) {
            ref
                .read(formFieldsProvider.notifier)
                .updateField(field.id, field.copyWith(label: value));
          },
        ),
        const SizedBox(height: 16),

        _PropertyField(
          theme: theme,
          label: 'Name',
          value: field.name ?? '',
          onChanged: (value) {
            ref
                .read(formFieldsProvider.notifier)
                .updateField(field.id, field.copyWith(name: value));
          },
        ),
        const SizedBox(height: 16),

        _PropertyField(
          theme: theme,
          label: 'Placeholder',
          value: field.hint ?? '',
          onChanged: (value) {
            ref
                .read(formFieldsProvider.notifier)
                .updateField(field.id, field.copyWith(hint: value));
          },
        ),
        const SizedBox(height: 16),

        // Required toggle
        _PropertyToggle(
          theme: theme,
          label: 'Required',
          value: field.required,
          onChanged: (value) {
            ref
                .read(formFieldsProvider.notifier)
                .updateField(field.id, field.copyWith(required: value));
          },
        ),
        const SizedBox(height: 24),

        // Phase-specific properties
        if (phase == 2) ..._buildAdvancedProperties(field, ref),
        if (phase == 3) ..._buildIntegrationProperties(field, ref),

        // Actions
        const Divider(),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.content_copy, size: 18),
          label: const Text('Duplicate Field'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colors.primary,
          ),
          onPressed: () {
            ref.read(formFieldsProvider.notifier).duplicateField(field);
          },
        ),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Delete Field'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () {
            ref.read(formFieldsProvider.notifier).deleteField(field.id);
            ref.read(selectedFieldProvider.notifier).state = null;
          },
        ),
      ],
    );
  }

  List<Widget> _buildAdvancedProperties(FieldConfig field, WidgetRef ref) {
    return [
      Text(
        'Validation Rules',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      _ValidationRuleItem(theme: theme, label: 'Min Length', onTap: () {}),
      _ValidationRuleItem(theme: theme, label: 'Max Length', onTap: () {}),
      _ValidationRuleItem(theme: theme, label: 'Pattern (Regex)', onTap: () {}),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Validation Rule'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),

      Text(
        'Conditional Logic',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        icon: const Icon(Icons.rule, size: 16),
        label: const Text('Add Condition'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildIntegrationProperties(FieldConfig field, WidgetRef ref) {
    return [
      Text(
        'API Integration',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      _PropertyField(
        theme: theme,
        label: 'Endpoint URL',
        value: '',
        onChanged: (value) {},
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.link, size: 16),
        label: const Text('Configure API'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),
    ];
  }
}

class _PropertyField extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final String value;
  final Function(String) onChanged;

  const _PropertyField({
    required this.theme,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          style: TextStyle(color: theme.colors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PropertyToggle extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _PropertyToggle({
    required this.theme,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colors.primary,
        ),
      ],
    );
  }
}

class _ValidationRuleItem extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final VoidCallback onTap;

  const _ValidationRuleItem({
    required this.theme,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: theme.colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colors.text, fontSize: 13),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
