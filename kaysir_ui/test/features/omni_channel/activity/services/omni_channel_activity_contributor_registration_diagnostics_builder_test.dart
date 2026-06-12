import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_registry_issue.dart';
import 'package:kaysir/features/omni_channel/activity/services/omni_channel_activity_contributor_registration_diagnostics_builder.dart';

void main() {
  test('contributor registration diagnostics detect duplicate ids', () {
    final issues =
        const OmniChannelActivityContributorRegistrationDiagnosticsBuilder()
            .build(const [
              OmniChannelActivityActionContributorDescriptor(
                id: 'commerce',
                label: 'Commerce actions',
              ),
              OmniChannelActivityActionContributorDescriptor(
                id: 'commerce',
                label: 'Marketplace actions',
              ),
            ]);

    expect(issues, hasLength(1));

    final issue = issues.single;
    expect(
      issue.type,
      OmniChannelActivityActionContributorRegistrationIssueType.duplicateId,
    );
    expect(issue.key, 'duplicate-id-commerce');
    expect(issue.id, 'commerce');
    expect(issue.labels, ['Commerce actions', 'Marketplace actions']);
    expect(issue.contributorCount, 2);
    expect(
      issue.detail,
      'ID "commerce" is shared by Commerce actions / Marketplace actions.',
    );
  });

  test('contributor registration diagnostics detect missing metadata', () {
    final issues =
        const OmniChannelActivityContributorRegistrationDiagnosticsBuilder()
            .build(const [
              OmniChannelActivityActionContributorDescriptor(id: '', label: ''),
              OmniChannelActivityActionContributorDescriptor(
                id: 'inventory',
                label: '',
              ),
            ]);

    expect(issues.map((issue) => issue.type), [
      OmniChannelActivityActionContributorRegistrationIssueType.missingId,
      OmniChannelActivityActionContributorRegistrationIssueType.missingLabel,
      OmniChannelActivityActionContributorRegistrationIssueType.missingLabel,
    ]);
    expect(issues.map((issue) => issue.key), [
      'missing-id-0',
      'missing-label-0',
      'missing-label-1',
    ]);
    expect(issues.first.label, 'Contributor 1');
    expect(issues.last.label, 'inventory');
  });
}
