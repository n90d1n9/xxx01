import 'package:ky_core/core/features/feature_routes.dart';
import '../models/admin_route_search_entry.dart';

List<AdminRouteSearchEntry> buildAdminRouteSearchEntries(
  List<FeatureRoutes> features,
) {
  final entries = <AdminRouteSearchEntry>[];
  final seenPaths = <String>{};

  void visit(List<FeatureRoutes> items, String? section) {
    for (final item in items) {
      final path = item.path?.trim();
      final title = (item.title ?? item.name ?? path ?? '').trim();
      final isSidebarItem = item.position.contains(MenuPosition.sidebar);

      if (item.enabled != false &&
          isSidebarItem &&
          path != null &&
          path.isNotEmpty &&
          seenPaths.add(path)) {
        entries.add(
          AdminRouteSearchEntry(
            route: item,
            title: title.isEmpty ? path : title,
            section: section,
          ),
        );
      }

      if (item.items.isNotEmpty) {
        visit(item.items, title.isEmpty ? section : title);
      }
    }
  }

  visit(features, null);
  entries.sort(
    (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  );
  return List.unmodifiable(entries);
}

List<AdminRouteSearchEntry> filterAdminRouteSearchEntries(
  List<AdminRouteSearchEntry> entries,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return entries;

  return List.unmodifiable(
    entries.where((entry) => entry.searchText.contains(normalizedQuery)),
  );
}
