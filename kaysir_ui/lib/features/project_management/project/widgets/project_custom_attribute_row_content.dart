import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../models/project_custom_attribute.dart';
import '../services/project_domain_attribute_metadata_service.dart';
import 'project_custom_attribute_type_ui.dart';
import 'project_custom_attribute_value_field.dart';
import 'project_domain_attribute_metadata_chip_bar.dart';

class ProjectCustomAttributeRowContent extends StatelessWidget {
  const ProjectCustomAttributeRowContent({
    required this.attribute,
    required this.metadata,
    required this.labelController,
    required this.valueFocusNode,
    required this.autofocusValueField,
    required this.onChanged,
    required this.onRemoved,
    super.key,
  });

  final ProjectCustomAttribute attribute;
  final ProjectDomainAttributeMetadata metadata;
  final TextEditingController labelController;
  final FocusNode valueFocusNode;
  final bool autofocusValueField;
  final ValueChanged<ProjectCustomAttribute> onChanged;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 780;
        final typeField = SizedBox(
          width: isWide ? 170 : constraints.maxWidth,
          child: AppSelectField<ProjectCustomAttributeType>(
            key: ValueKey('project-custom-attribute-type-${attribute.key}'),
            label: 'Type',
            value: attribute.type,
            icon: attribute.type.icon,
            options: [
              for (final type in ProjectCustomAttributeType.values)
                AppSelectOption(value: type, label: type.label),
            ],
            onChanged: (type) => onChanged(attribute.copyWith(type: type)),
          ),
        );
        final labelField = _ProjectAttributeTextField(
          key: ValueKey('project-custom-attribute-label-${attribute.key}'),
          label: 'Attribute',
          controller: labelController,
          icon: Icons.label_outline,
          onChanged: (value) => onChanged(attribute.copyWith(label: value)),
        );
        final valueField = ProjectCustomAttributeValueField(
          key: ValueKey('project-custom-attribute-value-${attribute.key}'),
          attribute: attribute,
          focusNode: valueFocusNode,
          autofocus: autofocusValueField,
          onChanged: (value) => onChanged(attribute.copyWith(value: value)),
        );
        final removeButton = IconButton(
          key: ValueKey('project-custom-attribute-remove-${attribute.key}'),
          tooltip: 'Remove ${attribute.label}',
          icon: const Icon(Icons.close_rounded),
          onPressed: onRemoved,
        );
        final metadataBar = ProjectDomainAttributeMetadataChipBar(
          metadata: metadata,
        );

        if (!isWide) {
          return Column(
            key: ValueKey('project-custom-attribute-narrow-${attribute.key}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              metadataBar,
              const SizedBox(height: 10),
              typeField,
              const SizedBox(height: 10),
              labelField,
              const SizedBox(height: 10),
              valueField,
              Align(alignment: Alignment.centerRight, child: removeButton),
            ],
          );
        }

        return Column(
          key: ValueKey('project-custom-attribute-wide-${attribute.key}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            metadataBar,
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                typeField,
                const SizedBox(width: 10),
                Expanded(child: labelField),
                const SizedBox(width: 10),
                Expanded(child: valueField),
                const SizedBox(width: 4),
                removeButton,
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProjectAttributeTextField extends StatelessWidget {
  const _ProjectAttributeTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.icon,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: colorScheme.surface,
        border: border,
        enabledBorder: border,
      ),
      onChanged: onChanged,
    );
  }
}
