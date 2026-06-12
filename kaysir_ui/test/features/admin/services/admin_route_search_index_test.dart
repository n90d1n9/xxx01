import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/admin/services/admin_route_search_index.dart';

void main() {
  test('buildAdminRouteSearchEntries indexes enabled sidebar routes once', () {
    final entries = buildAdminRouteSearchEntries([
      FeatureRoutes(
        title: 'Operations',
        path: '/operations',
        items: [
          FeatureRoutes(
            title: 'Cashier',
            name: 'Legacy POS',
            subtitle: 'Point of sale',
            description: 'Counter checkout and register workflow',
            path: '/operations/cashier',
          ),
          FeatureRoutes(
            title: 'Duplicate cashier',
            path: '/operations/cashier',
          ),
          FeatureRoutes(
            title: 'Header only',
            path: '/header-only',
            position: const [MenuPosition.header],
          ),
          FeatureRoutes(title: 'Disabled', path: '/disabled', enabled: false),
          FeatureRoutes(title: 'Blank', path: '   '),
        ],
      ),
      FeatureRoutes(title: 'Dashboard', path: '/dashboard'),
    ]);

    expect(entries.map((entry) => entry.path), [
      '/operations/cashier',
      '/dashboard',
      '/operations',
    ]);
    expect(entries.first.section, 'Operations');
    expect(entries.any((entry) => entry.title == 'Header only'), isFalse);
    expect(entries.any((entry) => entry.title == 'Disabled'), isFalse);
    expect(entries.any((entry) => entry.title == 'Blank'), isFalse);
  });

  test(
    'filterAdminRouteSearchEntries matches title section subtitle and path',
    () {
      final entries = buildAdminRouteSearchEntries([
        FeatureRoutes(
          title: 'Operations',
          path: '/operations',
          items: [
            FeatureRoutes(
              title: 'Cashier',
              name: 'Legacy POS',
              subtitle: 'Point of sale',
              description: 'Counter checkout and register workflow',
              path: '/operations/cashier',
            ),
          ],
        ),
        FeatureRoutes(title: 'Inventory', path: '/stock'),
      ]);

      expect(
        filterAdminRouteSearchEntries(
          entries,
          'legacy',
        ).map((entry) => entry.title),
        ['Cashier'],
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          'register',
        ).map((entry) => entry.title),
        ['Cashier'],
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          'operations',
        ).map((entry) => entry.title),
        ['Cashier', 'Operations'],
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          '/stock',
        ).map((entry) => entry.title),
        ['Inventory'],
      );
      expect(filterAdminRouteSearchEntries(entries, 'missing'), isEmpty);
    },
  );
}
