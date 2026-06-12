import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';

void main() {
  test('launch context serializes and parses query parameters', () {
    const context = OrderWorkspaceLaunchContext(
      sourceProfileId: 'marketplace_operations',
      sourceProfileLabel: 'Marketplace operations',
      orderWorkspaceProfileId: 'marketplace_ops',
      workspaceViewId: 'marketplace_priority',
      workspaceViewLabel: 'Policy priority',
      reason: OrderWorkspaceLaunchReason.profileDetails,
    );

    final location = context.locationForPath('/commerce/orders/marketplace');
    final parsed = Uri.parse(location);
    final restored = OrderWorkspaceLaunchContext.fromQueryParameters(
      parsed.queryParameters,
    );

    expect(parsed.path, '/commerce/orders/marketplace');
    expect(restored?.sourceProfileId, 'marketplace_operations');
    expect(restored?.sourceProfileDisplayLabel, 'Marketplace operations');
    expect(restored?.orderProfileDisplayLabel, 'marketplace_ops');
    expect(restored?.workspaceViewId, 'marketplace_priority');
    expect(restored?.workspaceViewDisplayLabel, 'Policy priority');
    expect(restored?.reason, OrderWorkspaceLaunchReason.profileDetails);
  });

  test('launch context stays absent without query parameters', () {
    expect(OrderWorkspaceLaunchContext.fromQueryParameters(const {}), isNull);
    expect(
      ecommerceOrderWorkspaceLaunchReasonFromCode('missing'),
      OrderWorkspaceLaunchReason.commerceWorkspace,
    );
  });
}
