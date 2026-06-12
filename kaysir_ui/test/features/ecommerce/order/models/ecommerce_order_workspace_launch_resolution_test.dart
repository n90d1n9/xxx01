import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_resolution.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';

void main() {
  test('launch resolution applies a requested registered workspace view', () {
    final resolution = ecommerceOrderWorkspaceLaunchResolutionFor(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      launchContext: const OrderWorkspaceLaunchContext(
        sourceProfileId: 'marketplace_operations',
        sourceProfileLabel: 'Marketplace operations',
        orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
        workspaceViewId: 'marketplace_priority',
        workspaceViewLabel: 'Policy priority',
        reason: OrderWorkspaceLaunchReason.commerceWorkspace,
      ),
    );

    expect(resolution?.appliedWorkspaceView.id, 'marketplace_priority');
    expect(
      resolution?.status,
      OrderWorkspaceLaunchResolutionStatus.requestedViewApplied,
    );
    expect(resolution?.usedFallback, isFalse);
    expect(
      resolution?.detailLabel,
      'Commerce workspace - marketplace_ops - Policy priority',
    );
  });

  test('launch resolution falls back when a requested view is unavailable', () {
    final resolution = ecommerceOrderWorkspaceLaunchResolutionFor(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      launchContext: const OrderWorkspaceLaunchContext(
        sourceProfileId: 'marketplace_operations',
        sourceProfileLabel: 'Marketplace operations',
        orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
        workspaceViewId: 'legacy_priority',
        workspaceViewLabel: 'Legacy priority',
        reason: OrderWorkspaceLaunchReason.commerceWorkspace,
      ),
    );

    expect(resolution?.appliedWorkspaceView.id, 'marketplace_all');
    expect(
      resolution?.status,
      OrderWorkspaceLaunchResolutionStatus.requestedViewUnavailable,
    );
    expect(resolution?.usedFallback, isTrue);
    expect(
      resolution?.fallbackMessage,
      'Requested Legacy priority is unavailable. Opened Marketplace all.',
    );
  });

  test('launch resolution reports profile mismatches from stale links', () {
    final resolution = ecommerceOrderWorkspaceLaunchResolutionFor(
      profile: ecommerceDeliveryOrderWorkspaceProfile,
      launchContext: const OrderWorkspaceLaunchContext(
        sourceProfileId: 'wholesale',
        sourceProfileLabel: 'Wholesale profile',
        orderWorkspaceProfileId: ecommerceWholesaleOrderWorkspaceProfileId,
        workspaceViewId: 'delivery_ready',
        workspaceViewLabel: 'Courier ready',
        reason: OrderWorkspaceLaunchReason.commerceWorkspace,
      ),
    );

    expect(resolution?.appliedOrderProfileId, 'delivery_ops');
    expect(resolution?.appliedWorkspaceView.id, 'delivery_ready');
    expect(resolution?.usedProfileFallback, isTrue);
    expect(resolution?.usedWorkspaceViewFallback, isFalse);
    expect(resolution?.usedFallback, isTrue);
    expect(
      resolution?.detailLabel,
      'Commerce workspace - delivery_ops - Courier ready',
    );
    expect(
      resolution?.fallbackMessage,
      'Requested order profile wholesale_ops is unavailable here. Opened Delivery Orders.',
    );
  });
}
