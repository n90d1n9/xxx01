import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_saved_view.dart';

void main() {
  test('release workspace controller selects saved views by id', () {
    final controller = BillingReleaseWorkspaceController();
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    final selected = controller.selectById(
      id: billingReleaseWorkspaceLaunchSavedViewId,
    );

    expect(selected, isTrue);
    expect(
      controller.selectedSavedView?.id,
      billingReleaseWorkspaceLaunchSavedViewId,
    );
    expect(notificationCount, 1);

    final selectedAgain = controller.selectById(
      id: billingReleaseWorkspaceLaunchSavedViewId,
    );

    expect(selectedAgain, isTrue);
    expect(notificationCount, 1);
  });

  test('release workspace controller rejects missing saved view ids', () {
    final controller = BillingReleaseWorkspaceController();

    final selected = controller.selectById(id: 'missing-view');

    expect(selected, isFalse);
    expect(controller.selectedSavedView, isNull);
  });

  test('release workspace controller clears selected saved view', () {
    final controller = BillingReleaseWorkspaceController(
      selectedSavedView: billingReleaseWorkspacePackageSavedView,
    );
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    controller.clearSelection();

    expect(controller.selectedSavedView, isNull);
    expect(controller.hasSelection, isFalse);
    expect(notificationCount, 1);

    controller.clearSelection();

    expect(notificationCount, 1);
  });

  test('release workspace controller composes visible workspace state', () {
    final controller = BillingReleaseWorkspaceController(
      selectedSavedView: billingReleaseWorkspaceLaunchSavedView,
    );

    final composition = controller.compose(
      businessDomain: 'commerce',
      registry: standardBillingReleaseWorkspaceRegistry(),
    );

    expect(
      composition.activeSavedView.id,
      billingReleaseWorkspaceLaunchSavedViewId,
    );
    expect(composition.visibleRegistry.deckIds, [
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
  });
}
