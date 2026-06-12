import '../models/project_custom_attribute.dart';
import 'project_domain_registry.dart';

List<ProjectCustomAttribute> defaultProjectCustomAttributesForDomain(
  String domain,
) {
  final templates =
      projectDomainPackForBusinessDomain(domain).customAttributeTemplates;

  return List.unmodifiable([
    for (final template in templates) template.toAttribute(),
  ]);
}

List<ProjectCustomAttribute> mergeProjectCustomAttributesForDomain({
  required String domain,
  required Iterable<ProjectCustomAttribute> currentAttributes,
}) {
  final current = normalizeProjectCustomAttributes(
    currentAttributes,
    keepEmpty: true,
  );
  final currentByKey = {
    for (final attribute in current) attribute.key: attribute,
  };
  final templates = defaultProjectCustomAttributesForDomain(domain);
  final templateKeys = templates.map((attribute) => attribute.key).toSet();
  final merged = <ProjectCustomAttribute>[
    for (final template in templates)
      (currentByKey[template.key] ?? template).copyWith(
        label: template.label,
        type: template.type,
        unit: template.unit,
        options: template.options,
        isPinned: template.isPinned,
      ),
    for (final attribute in current)
      if (!templateKeys.contains(attribute.key)) attribute,
  ];

  return normalizeProjectCustomAttributes(merged, keepEmpty: true);
}
