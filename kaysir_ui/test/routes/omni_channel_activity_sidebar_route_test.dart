import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';
import 'package:kaysir/routes/register_routes_screen.dart';

void main() {
  test('omni-channel activity route is reachable from commerce sidebar', () {
    final commerce = registerScreens().singleWhere(
      (route) => route.name == 'Commerce',
    );
    final activity = commerce.items.singleWhere(
      (route) => route.path == OmniChannelActivityRoutes.activityCenterPath,
    );

    expect(commerce.position, contains(MenuPosition.sidebar));
    expect(activity.position, contains(MenuPosition.sidebar));
    expect(activity.title, 'Omni-channel Activity');
    expect(activity.pageBuilder, isNotNull);
  });
}
