import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';
import '../services/project_domain_attribute_metadata_service.dart';
import 'project_custom_attribute_row_content.dart';

class ProjectCustomAttributeRow extends StatefulWidget {
  const ProjectCustomAttributeRow({
    required this.attribute,
    required this.isFocused,
    required this.metadata,
    required this.onChanged,
    required this.onRemoved,
    super.key,
  });

  final ProjectCustomAttribute attribute;
  final bool isFocused;
  final ProjectDomainAttributeMetadata metadata;
  final ValueChanged<ProjectCustomAttribute> onChanged;
  final VoidCallback onRemoved;

  @override
  State<ProjectCustomAttributeRow> createState() =>
      _ProjectCustomAttributeRowState();
}

class _ProjectCustomAttributeRowState extends State<ProjectCustomAttributeRow> {
  late final TextEditingController _labelController;
  late final FocusNode _valueFocusNode;
  String? _appliedFocusedAttributeKey;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.attribute.label);
    _valueFocusNode = FocusNode(
      debugLabel: 'Project attribute value ${widget.attribute.key}',
    );
    _scheduleFocusedAttribute();
  }

  @override
  void didUpdateWidget(ProjectCustomAttributeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_labelController.text != widget.attribute.label) {
      _labelController.text = widget.attribute.label;
    }
    if (!widget.isFocused) {
      _appliedFocusedAttributeKey = null;
    }
    if (oldWidget.isFocused != widget.isFocused ||
        oldWidget.attribute.key != widget.attribute.key) {
      _scheduleFocusedAttribute();
    }
  }

  @override
  void dispose() {
    _valueFocusNode.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        widget.isFocused ? colorScheme.primary : colorScheme.outlineVariant;
    final fillColor =
        widget.isFocused
            ? colorScheme.primaryContainer.withValues(alpha: 0.18)
            : colorScheme.surfaceContainerLow;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: widget.isFocused ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ProjectCustomAttributeRowContent(
          attribute: widget.attribute,
          metadata: widget.metadata,
          labelController: _labelController,
          valueFocusNode: _valueFocusNode,
          autofocusValueField: widget.isFocused,
          onChanged: widget.onChanged,
          onRemoved: widget.onRemoved,
        ),
      ),
    );
  }

  void _scheduleFocusedAttribute() {
    if (!widget.isFocused ||
        _appliedFocusedAttributeKey == widget.attribute.key) {
      return;
    }

    _appliedFocusedAttributeKey = widget.attribute.key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Scrollable.ensureVisible(
        context,
        alignment: 0.16,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      _valueFocusNode.requestFocus();
    });
  }
}
