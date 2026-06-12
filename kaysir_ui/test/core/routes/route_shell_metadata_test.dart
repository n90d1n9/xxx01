import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/routes/shell/route_shell_metadata.dart';

void main() {
  test('routeShellRouteTrailForPath returns selected ancestors', () {
    final routes = [
      FeatureRoutes(
        title: 'Restaurant',
        path: '/restaurant',
        items: [
          FeatureRoutes(
            title: 'Reservations',
            path: '/restaurant/reservations',
          ),
        ],
      ),
    ];

    final trail = routeShellRouteTrailForPath(
      routes,
      '/restaurant/reservations',
    );

    expect(trail.map(routeShellLabel), ['Restaurant', 'Reservations']);
  });

  test('routeShellRouteTrailForPath matches dynamic route segments', () {
    final routes = [
      FeatureRoutes(
        title: 'Products',
        path: '/products',
        items: [
          FeatureRoutes(
            title: 'Edit Product',
            path: '/products/:productId/edit',
          ),
        ],
      ),
    ];

    final trail = routeShellRouteTrailForPath(routes, '/products/sku-1/edit');

    expect(trail.map(routeShellLabel), ['Products', 'Edit Product']);
  });

  test('routeShellRouteTrailForPath prefers query-specific shortcuts', () {
    final routes = [
      FeatureRoutes(
        title: 'Reports',
        items: [
          FeatureRoutes(title: 'Release', path: '/reports'),
          FeatureRoutes(title: 'Evidence', path: '/reports?focus=evidence'),
        ],
      ),
    ];

    final trail = routeShellRouteTrailForPath(
      routes,
      '/reports?focus=evidence',
    );

    expect(trail.map(routeShellLabel), ['Reports', 'Evidence']);
  });

  test('routeShellRouteTrailForPath falls back when query differs', () {
    final routes = [
      FeatureRoutes(
        title: 'Reports',
        items: [
          FeatureRoutes(title: 'Release', path: '/reports'),
          FeatureRoutes(title: 'Evidence', path: '/reports?focus=evidence'),
        ],
      ),
    ];

    final trail = routeShellRouteTrailForPath(routes, '/reports?focus=archive');

    expect(trail.map(routeShellLabel), ['Reports', 'Release']);
  });

  test('routeShellVisibleRouteForTrail returns nearest visible route', () {
    final routes = [
      FeatureRoutes(
        title: 'Products',
        path: '/products',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Edit Product',
            path: '/products/:productId/edit',
            position: const [MenuPosition.node],
          ),
        ],
      ),
    ];

    final trail = routeShellRouteTrailForPath(routes, '/products/sku-1/edit');
    final visibleRoute = routeShellVisibleRouteForTrail(trail);

    expect(routeShellLabel(visibleRoute!), 'Products');
  });

  test('routeShellSelectedVisibleRouteForPath resolves hidden details', () {
    final routes = [
      FeatureRoutes(
        title: 'Products',
        path: '/products',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Edit Product',
            path: '/products/:productId/edit',
            position: const [MenuPosition.node],
          ),
        ],
      ),
    ];

    final visibleRoute = routeShellSelectedVisibleRouteForPath(
      routes,
      '/products/sku-1/edit',
    );

    expect(routeShellLabel(visibleRoute!), 'Products');
  });

  test('routeShellVisibleNavigableRoutes flattens sidebar route order', () {
    final routes = [
      FeatureRoutes(
        title: 'Inventory',
        path: '/inventory',
        child: const SizedBox.shrink(),
        items: [
          FeatureRoutes(
            title: 'Movements',
            path: '/inventory/movements',
            child: const SizedBox.shrink(),
          ),
          FeatureRoutes(title: 'Path Only', path: '/inventory/path-only'),
          FeatureRoutes(
            title: 'Audit Node',
            path: '/inventory/audit',
            position: const [MenuPosition.node],
          ),
        ],
      ),
      FeatureRoutes(
        title: 'Hidden Parent',
        path: '/hidden-parent',
        enabled: false,
        items: [FeatureRoutes(title: 'Hidden Child', path: '/hidden-child')],
      ),
      FeatureRoutes(title: 'Route Group'),
    ];

    final flattened = routeShellVisibleNavigableRoutes(routes);

    expect(flattened.map(routeShellLabel), ['Inventory', 'Movements']);
    expect(flattened.map((route) => route.path), [
      '/inventory',
      '/inventory/movements',
    ]);
  });

  test('routeShellCanOpen supports route targets and base path shortcuts', () {
    final targetRoute = FeatureRoutes(
      title: 'Workspace',
      path: '/workspace',
      child: const SizedBox.shrink(),
    );
    final shortcutRoute = FeatureRoutes(
      title: 'Workspace Shortcut',
      path: '/workspace?mode=review',
      basePath: '/workspace',
    );
    final metadataRoute = FeatureRoutes(
      title: 'Metadata Only',
      path: '/metadata-only',
    );

    expect(routeShellIsNavigable(metadataRoute), isTrue);
    expect(routeShellCanOpen(targetRoute), isTrue);
    expect(routeShellCanOpen(shortcutRoute), isTrue);
    expect(routeShellCanOpen(metadataRoute), isFalse);
  });

  test('routeShellIsSelectedBranchForPath matches descendant routes', () {
    final route = FeatureRoutes(
      title: 'Reports',
      items: [
        FeatureRoutes(title: 'Release', path: '/reports'),
        FeatureRoutes(title: 'Evidence', path: '/reports?focus=evidence'),
      ],
    );

    expect(
      routeShellIsSelectedBranchForPath(route, '/reports?focus=archive'),
      isTrue,
    );
    expect(
      routeShellIsSelectedBranchForPath(route, '/reports?focus=evidence'),
      isTrue,
    );
    expect(routeShellIsSelectedBranchForPath(route, '/settings'), isFalse);
  });

  test('routeShellPathMatchesExactly supports dynamic segments', () {
    expect(
      routeShellPathMatchesExactly(
        '/products/sku-1/edit',
        '/products/:productId/edit',
      ),
      isTrue,
    );
    expect(
      routeShellPathMatchesExactly(
        '/products/sku-1/edit/audit',
        '/products/:productId/edit',
      ),
      isFalse,
    );
  });

  test('routeShellPathMatchesExactly respects route query parameters', () {
    expect(
      routeShellPathMatchesExactly(
        '/reports?focus=evidence&section=files',
        '/reports?focus=evidence',
      ),
      isTrue,
    );
    expect(
      routeShellPathMatchesExactly(
        '/reports?focus=archive',
        '/reports?focus=evidence',
      ),
      isFalse,
    );
  });
}
