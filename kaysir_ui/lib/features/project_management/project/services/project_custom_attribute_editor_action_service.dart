import '../models/project_custom_attribute.dart';
import 'project_custom_attribute_extension_suggestion_service.dart';

class ProjectCustomAttributeEditorActionResult {
  const ProjectCustomAttributeEditorActionResult({
    required this.attributes,
    required this.focusedAttributeKey,
    required this.didChange,
  });

  final List<ProjectCustomAttribute> attributes;
  final String focusedAttributeKey;
  final bool didChange;

  bool get hasFocusTarget => focusedAttributeKey.isNotEmpty;
}

class ProjectCustomAttributeEditorActionService {
  const ProjectCustomAttributeEditorActionService();

  ProjectCustomAttributeEditorActionResult addCustomField(
    Iterable<ProjectCustomAttribute> attributes,
  ) {
    final current = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    if (current.length >= projectCustomAttributeLimit) {
      return _unchanged(current);
    }

    final candidate = ProjectCustomAttribute(
      key: 'custom-field-${current.length + 1}',
      label: 'Custom Field',
      type: ProjectCustomAttributeType.text,
    );

    return _append(current: current, attribute: candidate);
  }

  ProjectCustomAttributeEditorActionResult addSuggestedField({
    required Iterable<ProjectCustomAttribute> attributes,
    required ProjectCustomAttributeExtensionSuggestion suggestion,
  }) {
    final current = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    if (current.length >= projectCustomAttributeLimit) {
      return _unchanged(current);
    }

    final suggestionKey = normalizeProjectCustomAttributeKey(suggestion.key);
    final alreadyExists = current.any(
      (attribute) =>
          normalizeProjectCustomAttributeKey(attribute.key) == suggestionKey,
    );
    if (alreadyExists) {
      return _unchanged(current, focusedAttributeKey: suggestionKey);
    }

    return _append(current: current, attribute: suggestion.toAttribute());
  }

  ProjectCustomAttributeEditorActionResult replaceField({
    required Iterable<ProjectCustomAttribute> attributes,
    required int index,
    required ProjectCustomAttribute attribute,
  }) {
    final current = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    if (index < 0 || index >= current.length) {
      return _unchanged(current);
    }

    final next = current.toList();
    next[index] = attribute;

    return ProjectCustomAttributeEditorActionResult(
      attributes: normalizeProjectCustomAttributes(next, keepEmpty: true),
      focusedAttributeKey: '',
      didChange: true,
    );
  }

  ProjectCustomAttributeEditorActionResult removeField({
    required Iterable<ProjectCustomAttribute> attributes,
    required int index,
  }) {
    final current = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    if (index < 0 || index >= current.length) {
      return _unchanged(current);
    }

    final next = current.toList()..removeAt(index);

    return ProjectCustomAttributeEditorActionResult(
      attributes: normalizeProjectCustomAttributes(next, keepEmpty: true),
      focusedAttributeKey: '',
      didChange: true,
    );
  }

  ProjectCustomAttributeEditorActionResult _append({
    required List<ProjectCustomAttribute> current,
    required ProjectCustomAttribute attribute,
  }) {
    final next = normalizeProjectCustomAttributes([
      ...current,
      attribute,
    ], keepEmpty: true);

    return ProjectCustomAttributeEditorActionResult(
      attributes: next,
      focusedAttributeKey: next.last.key,
      didChange: true,
    );
  }

  ProjectCustomAttributeEditorActionResult _unchanged(
    List<ProjectCustomAttribute> attributes, {
    String focusedAttributeKey = '',
  }) {
    return ProjectCustomAttributeEditorActionResult(
      attributes: attributes,
      focusedAttributeKey: focusedAttributeKey,
      didChange: false,
    );
  }
}
