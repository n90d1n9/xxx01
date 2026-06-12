import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/routes/shell/route_search_index.dart';

void main() {
  test('buildRouteSearchEntries keeps visible navigable routes unique', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Inventory',
        path: '/inventory',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Movement History',
            subtitle: 'Inventory timeline',
            path: '/inventory/movements',
            child: const SizedBox.shrink(),
          ),
          FeatureRoutes(
            title: 'Duplicate Movement',
            path: '/inventory/movements',
            child: const SizedBox.shrink(),
          ),
          FeatureRoutes(
            title: 'Audit Node',
            path: '/inventory/audit',
            position: const [MenuPosition.node],
          ),
        ],
      ),
      FeatureRoutes(
        title: 'Login',
        path: '/login',
        position: const [MenuPosition.account],
      ),
      FeatureRoutes(title: 'Disabled', path: '/disabled', enabled: false),
    ]);

    expect(entries.map((entry) => entry.path), [
      '/inventory',
      '/inventory/movements',
    ]);
    expect(entries.first.isOverview, isTrue);
    expect(entries.first.displayTitle, 'Inventory Overview');
    expect(entries.first.subtitle, 'Overview | /inventory');
    expect(entries.last.section, 'Inventory');
    expect(entries.last.isOverview, isFalse);
    expect(entries.last.subtitle, 'Inventory | Inventory timeline');
  });

  test('filterRouteSearchEntries finds parent overview routes', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Restaurant',
        subtitle: 'Dining operations',
        path: '/restaurant',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Reservations',
            subtitle: 'Table bookings',
            path: '/restaurant/reservations',
            child: const SizedBox.shrink(),
          ),
        ],
      ),
      FeatureRoutes(
        title: 'Kitchen Display',
        path: '/kitchen',
        child: const SizedBox.shrink(),
      ),
    ]);

    final overviewMatches = filterRouteSearchEntries(
      entries,
      'restaurant overview',
    );

    expect(overviewMatches, hasLength(1));
    expect(overviewMatches.single.path, '/restaurant');
    expect(overviewMatches.single.displayTitle, 'Restaurant Overview');
  });

  test('buildRouteSearchEntries skips metadata leaves but keeps shortcuts', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(title: 'Metadata Only', path: '/metadata-only'),
      FeatureRoutes(
        title: 'Auditor Workspace',
        path: '/accounting?role=auditor',
        basePath: '/accounting',
      ),
    ]);

    expect(entries.map((entry) => entry.path), ['/accounting?role=auditor']);
  });

  test('buildRouteSearchEntries keeps nested route breadcrumbs', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Commerce',
        path: '/commerce',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Orders',
            path: '/commerce/orders',
            child: const SizedBox.shrink(),
            items: [
              FeatureRoutes(
                title: 'Evidence',
                subtitle: 'Proof workspace',
                path: '/commerce/orders/evidence',
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    ]);

    final evidenceEntry = entries.singleWhere(
      (entry) => entry.path == '/commerce/orders/evidence',
    );

    expect(evidenceEntry.section, 'Commerce / Orders');
    expect(evidenceEntry.subtitle, 'Commerce / Orders | Proof workspace');
  });

  test('filterRouteSearchEntries searches title subtitle section and path', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Commerce',
        path: '/commerce',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Order Workspace',
            subtitle: 'Fulfillment queue',
            path: '/commerce/orders',
            child: const SizedBox.shrink(),
          ),
        ],
      ),
      FeatureRoutes(
        title: 'Website Builder',
        path: '/website-builder',
        child: const SizedBox.shrink(),
      ),
    ]);

    expect(
      filterRouteSearchEntries(entries, 'fulfillment').single.title,
      'Order Workspace',
    );
    expect(
      filterRouteSearchEntries(entries, 'website-builder').single.title,
      'Website Builder',
    );
    expect(filterRouteSearchEntries(entries, 'missing'), isEmpty);
  });

  test('filterRouteSearchEntries ranks direct title matches first', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Commerce',
        description: 'Order workspace for every sales channel.',
        path: '/commerce',
        child: const SizedBox.shrink(),
      ),
      FeatureRoutes(
        title: 'Order Workspace',
        subtitle: 'Fulfillment queue',
        path: '/commerce/orders',
        child: const SizedBox.shrink(),
      ),
      FeatureRoutes(
        title: 'Sales Channels',
        description: 'Review order routing by channel.',
        path: '/commerce/channels',
        child: const SizedBox.shrink(),
      ),
    ]);

    expect(
      filterRouteSearchEntries(entries, 'order').map((entry) => entry.title),
      ['Order Workspace', 'Commerce', 'Sales Channels'],
    );
  });

  test(
    'filterRouteSearchEntries matches query terms across route metadata',
    () {
      final entries = buildRouteSearchEntries([
        FeatureRoutes(
          title: 'Commerce',
          path: '/commerce',
          child: const SizedBox.shrink(),
          items: [
            FeatureRoutes(
              title: 'Order Workspace',
              subtitle: 'Fulfillment queue',
              path: '/commerce/orders',
              child: const SizedBox.shrink(),
            ),
          ],
        ),
        FeatureRoutes(
          title: 'Inventory',
          path: '/inventory',
          child: const SizedBox.shrink(),
        ),
      ]);

      expect(
        filterRouteSearchEntries(entries, 'commerce fulfillment').single.title,
        'Order Workspace',
      );
    },
  );

  test('filterRouteSearchEntries matches nested breadcrumb terms', () {
    final entries = buildRouteSearchEntries([
      FeatureRoutes(
        title: 'Commerce',
        path: '/commerce',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Orders',
            path: '/commerce/orders',
            child: const SizedBox.shrink(),
            items: [
              FeatureRoutes(
                title: 'Evidence',
                path: '/commerce/orders/evidence',
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    ]);

    expect(
      filterRouteSearchEntries(entries, 'commerce orders evidence').single.path,
      '/commerce/orders/evidence',
    );
  });
}
