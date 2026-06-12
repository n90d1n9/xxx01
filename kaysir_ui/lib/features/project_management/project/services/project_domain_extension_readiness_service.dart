import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';

enum ProjectDomainExtensionReadinessStatus { needsContext, inProgress, ready }

class ProjectDomainExtensionReadinessSummary {
  const ProjectDomainExtensionReadinessSummary({
    required this.businessDomain,
    required this.templateFieldCount,
    required this.completedTemplateFieldCount,
    required this.requiredFieldCount,
    required this.completedRequiredFieldCount,
    required this.recommendedFieldCount,
    required this.completedRecommendedFieldCount,
    required this.filledCustomFieldCount,
    required this.riskRuleCount,
    required this.watchedFieldCount,
    required this.missingTemplateFields,
    required this.missingRequiredFields,
    required this.missingRecommendedFields,
    required this.missingWatchedFields,
  });

  final String businessDomain;
  final int templateFieldCount;
  final int completedTemplateFieldCount;
  final int requiredFieldCount;
  final int completedRequiredFieldCount;
  final int recommendedFieldCount;
  final int completedRecommendedFieldCount;
  final int filledCustomFieldCount;
  final int riskRuleCount;
  final int watchedFieldCount;
  final List<ProjectDomainExtensionFieldSignal> missingTemplateFields;
  final List<ProjectDomainExtensionFieldSignal> missingRequiredFields;
  final List<ProjectDomainExtensionFieldSignal> missingRecommendedFields;
  final List<ProjectDomainExtensionFieldSignal> missingWatchedFields;

  int get readinessFieldCount => requiredFieldCount + recommendedFieldCount;

  int get completedReadinessFieldCount =>
      completedRequiredFieldCount + completedRecommendedFieldCount;

  double get completionRatio {
    if (readinessFieldCount == 0) return 1;
    return completedReadinessFieldCount / readinessFieldCount;
  }

  ProjectDomainExtensionReadinessStatus get status {
    if (missingRequiredFields.isNotEmpty) {
      return ProjectDomainExtensionReadinessStatus.needsContext;
    }
    if (missingRecommendedFields.isNotEmpty) {
      return ProjectDomainExtensionReadinessStatus.inProgress;
    }
    return ProjectDomainExtensionReadinessStatus.ready;
  }

  String get statusLabel {
    switch (status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return 'Needs Context';
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return 'In Progress';
      case ProjectDomainExtensionReadinessStatus.ready:
        return 'Ready';
    }
  }

  String get guidance {
    switch (status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return 'Complete required domain fields before the project enters execution.';
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return 'Complete recommended domain fields to improve handoff quality.';
      case ProjectDomainExtensionReadinessStatus.ready:
        return 'Domain context is ready for portfolio reporting and handoff.';
    }
  }
}

class ProjectDomainExtensionFieldSignal {
  const ProjectDomainExtensionFieldSignal({
    required this.key,
    required this.label,
    required this.type,
    required this.importance,
    required this.isRiskWatched,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final ProjectCustomAttributeImportance importance;
  final bool isRiskWatched;
}

class ProjectDomainExtensionReadinessService {
  const ProjectDomainExtensionReadinessService();

  ProjectDomainExtensionReadinessSummary build({
    required String businessDomain,
    required Iterable<ProjectCustomAttribute> attributes,
  }) {
    final pack = projectDomainPackForBusinessDomain(businessDomain);
    final normalizedAttributes = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    final attributesByKey = {
      for (final attribute in normalizedAttributes)
        normalizeProjectCustomAttributeKey(attribute.key): attribute,
    };
    final templateKeys = {
      for (final template in pack.customAttributeTemplates)
        normalizeProjectCustomAttributeKey(template.key),
    };
    final watchedKeys = {
      for (final rule in pack.riskRules)
        normalizeProjectCustomAttributeKey(rule.attributeKey),
    };
    final missingTemplateFields = <ProjectDomainExtensionFieldSignal>[];
    final missingRequiredFields = <ProjectDomainExtensionFieldSignal>[];
    final missingRecommendedFields = <ProjectDomainExtensionFieldSignal>[];
    final missingWatchedFields = <ProjectDomainExtensionFieldSignal>[];
    var completedTemplateFieldCount = 0;
    var requiredFieldCount = 0;
    var completedRequiredFieldCount = 0;
    var recommendedFieldCount = 0;
    var completedRecommendedFieldCount = 0;

    for (final template in pack.customAttributeTemplates) {
      final key = normalizeProjectCustomAttributeKey(template.key);
      final attribute = attributesByKey[key];
      final isRiskWatched = watchedKeys.contains(key);
      final signal = ProjectDomainExtensionFieldSignal(
        key: key,
        label: template.label,
        type: template.type,
        importance: template.importance,
        isRiskWatched: isRiskWatched,
      );
      final isReadinessField =
          template.importance != ProjectCustomAttributeImportance.optional;

      if (template.importance ==
          ProjectCustomAttributeImportance.requiredField) {
        requiredFieldCount += 1;
      } else if (template.importance ==
          ProjectCustomAttributeImportance.recommended) {
        recommendedFieldCount += 1;
      }

      if (attribute?.hasValue ?? false) {
        completedTemplateFieldCount += 1;
        if (template.importance ==
            ProjectCustomAttributeImportance.requiredField) {
          completedRequiredFieldCount += 1;
        } else if (template.importance ==
            ProjectCustomAttributeImportance.recommended) {
          completedRecommendedFieldCount += 1;
        }
      } else {
        if (isReadinessField) missingTemplateFields.add(signal);
        if (template.importance ==
            ProjectCustomAttributeImportance.requiredField) {
          missingRequiredFields.add(signal);
        } else if (template.importance ==
            ProjectCustomAttributeImportance.recommended) {
          missingRecommendedFields.add(signal);
        }
        if (isRiskWatched) missingWatchedFields.add(signal);
      }
    }

    final filledCustomFieldCount =
        normalizedAttributes.where((attribute) {
          final key = normalizeProjectCustomAttributeKey(attribute.key);
          return !templateKeys.contains(key) && attribute.hasValue;
        }).length;

    return ProjectDomainExtensionReadinessSummary(
      businessDomain: pack.businessDomain,
      templateFieldCount: pack.customAttributeTemplates.length,
      completedTemplateFieldCount: completedTemplateFieldCount,
      requiredFieldCount: requiredFieldCount,
      completedRequiredFieldCount: completedRequiredFieldCount,
      recommendedFieldCount: recommendedFieldCount,
      completedRecommendedFieldCount: completedRecommendedFieldCount,
      filledCustomFieldCount: filledCustomFieldCount,
      riskRuleCount: pack.riskRules.length,
      watchedFieldCount: watchedKeys.length,
      missingTemplateFields: List.unmodifiable(missingTemplateFields),
      missingRequiredFields: List.unmodifiable(missingRequiredFields),
      missingRecommendedFields: List.unmodifiable(missingRecommendedFields),
      missingWatchedFields: List.unmodifiable(missingWatchedFields),
    );
  }
}
