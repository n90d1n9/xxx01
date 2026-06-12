import '../data/project_domain_registry.dart';
import 'project_status_update_preferences_service.dart';
import 'project_status_update_service.dart';

class ProjectStatusUpdateDomainProfile {
  const ProjectStatusUpdateDomainProfile({
    required this.vocabulary,
    required this.audience,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
}

ProjectStatusUpdateDomainProfile projectStatusUpdateDomainProfileFor(
  String businessDomain,
) {
  final pack = projectDomainPackForBusinessDomain(businessDomain);
  return ProjectStatusUpdateDomainProfile(
    vocabulary: resolveStatusUpdateVocabulary(
      availableVocabularies: ProjectStatusUpdateVocabulary.defaults,
      vocabularyId: pack.statusVocabularyId,
    ),
    audience: resolveStatusUpdateAudience(
      availableAudiences: ProjectStatusUpdateAudience.values,
      audienceId: pack.statusAudienceId,
    ),
  );
}
