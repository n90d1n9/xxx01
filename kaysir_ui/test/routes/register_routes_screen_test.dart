import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';
import 'package:kaysir/routes/register_routes_screen.dart';

void main() {
  test('registers presentation editor as a sidebar route', () {
    final route = registerScreens().singleWhere(
      (route) => route.path == '/presentation-editor',
    );

    expect(route.name, 'Presentation Editor');
    expect(route.title, 'Presentation Editor');
    expect(route.subtitle, 'Slide deck canvas');
    expect(route.icon, 'presentation-editor');
    expect(route.position, contains(MenuPosition.sidebar));
    expect(route.pageBuilder, isNotNull);
  });

  test('registers website builder as a sidebar route', () {
    final route = registerScreens().singleWhere(
      (route) => route.path == '/website-builder',
    );

    expect(route.name, 'Website Builder');
    expect(route.title, 'Website Builder');
    expect(route.subtitle, 'Web page canvas');
    expect(route.icon, 'website-builder');
    expect(route.position, contains(MenuPosition.sidebar));
    expect(route.pageBuilder, isNotNull);
  });

  test('registers omni-channel activity center under commerce', () {
    final commerce = registerScreens().singleWhere(
      (route) => route.name == 'Commerce',
    );
    final route = commerce.items.singleWhere(
      (route) => route.path == OmniChannelActivityRoutes.activityCenterPath,
    );

    expect(route.name, 'Omni-channel Activity');
    expect(route.title, 'Omni-channel Activity');
    expect(route.subtitle, 'POS and ecommerce events');
    expect(route.icon, 'sync_alt');
    expect(route.position, contains(MenuPosition.sidebar));
    expect(route.pageBuilder, isNotNull);
  });
}
