import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_domain_profile_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('status update domain profile maps retail projects to team rollout', () {
    final profile = projectStatusUpdateDomainProfileFor('Retail Operations');

    expect(profile.vocabulary, ProjectStatusUpdateVocabulary.retailOperations);
    expect(profile.audience, ProjectStatusUpdateAudience.team);
  });

  test('status update domain profile maps event domains to client updates', () {
    final music = projectStatusUpdateDomainProfileFor('Music Event');
    final wedding = projectStatusUpdateDomainProfileFor('Wedding Organizer');

    expect(music.vocabulary, ProjectStatusUpdateVocabulary.eventProduction);
    expect(music.audience, ProjectStatusUpdateAudience.client);
    expect(wedding.vocabulary, ProjectStatusUpdateVocabulary.wedding);
    expect(wedding.audience, ProjectStatusUpdateAudience.client);
  });

  test('status update domain profile falls back to general profile', () {
    final profile = projectStatusUpdateDomainProfileFor('Legal Casework');

    expect(profile.vocabulary, ProjectStatusUpdateVocabulary.general);
    expect(profile.audience, ProjectStatusUpdateAudience.stakeholder);
  });
}
