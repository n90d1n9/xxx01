import 'project_custom_attribute.dart';

enum ProjectFormPanelFocus { none, domainExtensions }

const projectFormFocusQueryKey = 'focus';
const projectFormAttributesFocusQueryValue = 'attributes';
const projectFormFocusedAttributeQueryKey = 'attribute';

ProjectFormPanelFocus projectFormPanelFocusFromQuery(String? value) {
  switch (value?.trim().toLowerCase()) {
    case projectFormAttributesFocusQueryValue:
    case 'domainextensions':
    case 'domain_extensions':
      return ProjectFormPanelFocus.domainExtensions;
    default:
      return ProjectFormPanelFocus.none;
  }
}

String? projectFormPanelFocusQueryValue(ProjectFormPanelFocus focus) {
  switch (focus) {
    case ProjectFormPanelFocus.domainExtensions:
      return projectFormAttributesFocusQueryValue;
    case ProjectFormPanelFocus.none:
      return null;
  }
}

String? projectFormFocusedAttributeKeyFromQuery(String? value) {
  final normalized = normalizeProjectCustomAttributeKey(value ?? '');
  return normalized.isEmpty ? null : normalized;
}
