import 'package:ky_core/core/features/feature_routes.dart';

class AdminRouteSearchEntry {
  const AdminRouteSearchEntry({
    required this.route,
    required this.title,
    required this.section,
  });

  final FeatureRoutes route;
  final String title;
  final String? section;

  String get path => route.path ?? '';

  String get searchText =>
      '$title ${route.name ?? ''} ${section ?? ''} ${route.subtitle ?? ''} ${route.description ?? ''} $path'
          .toLowerCase();
}
