import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_assets_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_assets_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee asset access profile highlights onboarding work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeAssetAccessProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.pendingAssetCount, 2);
    expect(profile.accessReviewCount, 1);
    expect(profile.nextAction, 'Complete 2 asset provisioning items.');
  });

  test('employee asset assignment draft validates and appends asset', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeAssetAssignmentDraftProvider('1').notifier,
    );
    draftNotifier.setType(EmployeeAssetType.software);
    draftNotifier.setLabel('Security key');
    draftNotifier.setAssetTag('KEY-1001');
    draftNotifier.setOwner('IT Operations');

    final draft = container.read(employeeAssetAssignmentDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeAssetAccessProfileProvider('1').notifier,
    );
    final asset = profileNotifier.addAsset(draft);

    expect(asset.id, 'AST-1-004');
    expect(asset.status, EmployeeAssetStatus.provisioning);
    expect(
      container
          .read(employeeAssetAccessProfileProvider('1'))!
          .pendingAssetCount,
      1,
    );
  });

  test('employee asset actions resolve provisioning and access review', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeAssetAccessProfileProvider('5').notifier,
    );

    notifier.completeProvisioning('5-asset-laptop');
    notifier.completeProvisioning('5-asset-badge');
    notifier.approveAccess('5-access-productivity');

    final updatedProfile =
        container.read(employeeAssetAccessProfileProvider('5'))!;

    expect(updatedProfile.pendingAssetCount, 0);
    expect(updatedProfile.accessReviewCount, 0);
    expect(updatedProfile.nextAction, 'Assets and access are current.');
  });
}
