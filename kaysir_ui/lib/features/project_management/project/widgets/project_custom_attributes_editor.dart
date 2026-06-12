import 'package:flutter/material.dart';

import '../data/project_custom_attribute_templates.dart';
import '../models/project_custom_attribute.dart';
import '../services/project_custom_attribute_editor_action_service.dart';
import '../services/project_custom_attribute_editor_context_service.dart';
import '../services/project_custom_attribute_extension_suggestion_service.dart';
import 'project_custom_attribute_rows_list.dart';
import 'project_custom_attributes_editor_guidance.dart';
import 'project_custom_attributes_editor_header.dart';

class ProjectCustomAttributesEditor extends StatefulWidget {
  const ProjectCustomAttributesEditor({
    required this.businessDomain,
    required this.attributes,
    required this.onChanged,
    this.focusedAttributeKey,
    super.key,
  });

  final String businessDomain;
  final List<ProjectCustomAttribute> attributes;
  final ValueChanged<List<ProjectCustomAttribute>> onChanged;
  final String? focusedAttributeKey;

  @override
  State<ProjectCustomAttributesEditor> createState() =>
      _ProjectCustomAttributesEditorState();
}

class _ProjectCustomAttributesEditorState
    extends State<ProjectCustomAttributesEditor> {
  static const _actionService = ProjectCustomAttributeEditorActionService();
  static const _contextService = ProjectCustomAttributeEditorContextService();

  late String _focusedAttributeKey;

  @override
  void initState() {
    super.initState();
    _focusedAttributeKey = _normalizedFocusedAttributeKey();
  }

  @override
  void didUpdateWidget(ProjectCustomAttributesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedAttributeKey != widget.focusedAttributeKey) {
      _focusedAttributeKey = _normalizedFocusedAttributeKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorContext = _contextService.build(
      businessDomain: widget.businessDomain,
      attributes: widget.attributes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectCustomAttributesEditorHeader(
          businessDomain: widget.businessDomain,
          canAddAttribute: editorContext.canAddAttribute,
          onApplyDomainDefaults: _applyDomainDefaults,
          onAddAttribute: _addAttribute,
        ),
        const SizedBox(height: 12),
        ProjectCustomAttributesEditorGuidance(
          editorContext: editorContext,
          onFocusField: _focusAttribute,
          onAddSuggestion: _addSuggestedAttribute,
        ),
        const SizedBox(height: 12),
        ProjectCustomAttributeRowsList(
          rows: editorContext.rows,
          focusedAttributeKey: _focusedAttributeKey,
          onChanged: _replaceAttribute,
          onRemoved: _removeAttribute,
        ),
      ],
    );
  }

  void _applyDomainDefaults() {
    widget.onChanged(
      mergeProjectCustomAttributesForDomain(
        domain: widget.businessDomain,
        currentAttributes: widget.attributes,
      ),
    );
  }

  void _addAttribute() {
    _applyActionResult(_actionService.addCustomField(widget.attributes));
  }

  void _addSuggestedAttribute(
    ProjectCustomAttributeExtensionSuggestion suggestion,
  ) {
    _applyActionResult(
      _actionService.addSuggestedField(
        attributes: widget.attributes,
        suggestion: suggestion,
      ),
    );
  }

  void _applyActionResult(ProjectCustomAttributeEditorActionResult result) {
    if (!result.didChange && !result.hasFocusTarget) return;

    if (result.hasFocusTarget) {
      setState(() {
        _focusedAttributeKey = result.focusedAttributeKey;
      });
    }
    if (result.didChange) widget.onChanged(result.attributes);
  }

  void _replaceAttribute(int index, ProjectCustomAttribute attribute) {
    _applyActionResult(
      _actionService.replaceField(
        attributes: widget.attributes,
        index: index,
        attribute: attribute,
      ),
    );
  }

  void _removeAttribute(int index) {
    _applyActionResult(
      _actionService.removeField(attributes: widget.attributes, index: index),
    );
  }

  void _focusAttribute(String key) {
    final normalizedKey = normalizeProjectCustomAttributeKey(key);
    if (normalizedKey.isEmpty) return;

    setState(() => _focusedAttributeKey = normalizedKey);
  }

  String _normalizedFocusedAttributeKey() {
    return normalizeProjectCustomAttributeKey(widget.focusedAttributeKey ?? '');
  }
}
