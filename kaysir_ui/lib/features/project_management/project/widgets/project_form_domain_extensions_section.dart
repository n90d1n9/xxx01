import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';
import 'project_custom_attributes_editor.dart';

class ProjectFormDomainExtensionsSection extends StatelessWidget {
  const ProjectFormDomainExtensionsSection({
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
  Widget build(BuildContext context) {
    return ProjectCustomAttributesEditor(
      businessDomain: businessDomain,
      attributes: attributes,
      focusedAttributeKey: focusedAttributeKey,
      onChanged: onChanged,
    );
  }
}
