import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hris_features.dart';

void main() {
  test('HRIS routes use the canonical workspace registry', () {
    final featureRoot = HrisFeatures().registerScreens().single;
    final routes = featureRoot.items;
    final routePaths = routes.map((route) => route.path).whereType<String>();
    final workspaceRoutes =
        routes
            .where(
              (route) => hrisWorkspaces.any(
                (workspace) => workspace.path == route.path,
              ),
            )
            .toList();

    expect(featureRoot.name, 'Human Resources');
    expect(routePaths.toSet(), hasLength(routePaths.length));
    expect(workspaceRoutes.map((route) => route.path), [
      for (final workspace in hrisWorkspaces) workspace.path,
    ]);

    for (final workspace in hrisWorkspaces) {
      final route = workspaceRoutes.singleWhere(
        (route) => route.path == workspace.path,
      );
      expect(route.name, workspace.title);
      expect(route.pageBuilder, isNotNull);
    }
  });
}
