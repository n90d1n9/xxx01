import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/routes/shell/route_shell_header_state.dart';

void main() {
  test('fromRouteTrail uses workspace fallback without route context', () {
    final state = RouteShellHeaderState.fromRouteTrail(const []);

    expect(state.title, 'Workspace');
    expect(state.subtitle, 'Kaysir operations');
    expect(state.hasRouteContext, isFalse);
    expect(state.breadcrumbs, isEmpty);
  });

  test('fromRouteTrail includes parent context for child routes', () {
    final state = RouteShellHeaderState.fromRouteTrail([
      FeatureRoutes(title: 'Restaurant', path: '/restaurant'),
      FeatureRoutes(
        title: 'Reservations',
        subtitle: 'Table bookings',
        path: '/restaurant/reservations',
      ),
    ]);

    expect(state.title, 'Reservations');
    expect(state.subtitle, 'Restaurant / Table bookings');
    expect(state.hasRouteContext, isTrue);
    expect(state.breadcrumbs, ['Restaurant', 'Reservations']);
  });

  test('fromRouteTrail falls back to selected label without a subtitle', () {
    final state = RouteShellHeaderState.fromRouteTrail([
      FeatureRoutes(title: 'Products', path: '/products'),
      FeatureRoutes(title: 'Scan Product', path: '/products/scan'),
    ]);

    expect(state.title, 'Scan Product');
    expect(state.subtitle, 'Products / Scan Product');
    expect(state.breadcrumbs, ['Products', 'Scan Product']);
  });
}
