import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';

class ProjectDomainAttributeMetadata {
  const ProjectDomainAttributeMetadata({
    required this.key,
    required this.label,
    required this.type,
    required this.importance,
    required this.isDomainTemplate,
    required this.isRiskWatched,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final ProjectCustomAttributeImportance importance;
  final bool isDomainTemplate;
  final bool isRiskWatched;

  String get sourceLabel => isDomainTemplate ? importance.label : 'Custom';
}

class ProjectDomainAttributeMetadataService {
  const ProjectDomainAttributeMetadataService();

  List<ProjectDomainAttributeMetadata> build({
    required String businessDomain,
    required Iterable<ProjectCustomAttribute> attributes,
  }) {
    final pack = projectDomainPackForBusinessDomain(businessDomain);
    final templatesByKey = {
      for (final template in pack.customAttributeTemplates)
        normalizeProjectCustomAttributeKey(template.key): template,
    };
    final watchedKeys = {
      for (final rule in pack.riskRules)
        normalizeProjectCustomAttributeKey(rule.attributeKey),
    };

    return List.unmodifiable(
      normalizeProjectCustomAttributes(attributes, keepEmpty: true).map((
        attribute,
      ) {
        final key = normalizeProjectCustomAttributeKey(attribute.key);
        final template = templatesByKey[key];

        return ProjectDomainAttributeMetadata(
          key: key,
          label: template?.label ?? attribute.label,
          type: template?.type ?? attribute.type,
          importance:
              template?.importance ?? ProjectCustomAttributeImportance.optional,
          isDomainTemplate: template != null,
          isRiskWatched: watchedKeys.contains(key),
        );
      }),
    );
  }
}
