import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_saved_lens_service.dart';

void main() {
  test('project delivery command view preferences serialize filters', () {
    const preferences = ProjectDeliveryCommandViewPreferences(
      profile: ProjectDeliverySavedLensProfile.financePartner,
      filter: ProjectDeliveryCommandFilter(
        level: ProjectDeliveryCommandLevel.critical,
        kind: ProjectDeliveryCommandKind.budget,
      ),
    );

    final restored = ProjectDeliveryCommandViewPreferences.fromJson(
      preferences.toJson(),
    );

    expect(restored, preferences);
  });

  test(
    'project delivery command view preferences tolerate stale snapshots',
    () {
      final restored = ProjectDeliveryCommandViewPreferences.fromJson({
        'profile': 'missing-profile',
        'filter': {'level': 'missing-level', 'kind': 'risk'},
      });

      expect(restored.profile, ProjectDeliverySavedLensProfile.deliveryLead);
      expect(restored.filter.level, isNull);
      expect(restored.filter.kind, ProjectDeliveryCommandKind.risk);
    },
  );
}
