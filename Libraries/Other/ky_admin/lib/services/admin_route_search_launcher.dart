import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/features/features_registry.dart';
import '../states/dashboard_provider.dart';
import 'admin_route_search_index.dart';
import '../widgets/admin_route_search.dart';

class AdminRouteSearchLauncher {
  const AdminRouteSearchLauncher._();

  static Future<void> open(BuildContext context, WidgetRef ref) async {
    final selected = await showAdminRouteSearch(
      context,
      entries: buildAdminRouteSearchEntries(FeaturesRegistry.getFeatures()),
    );

    if (!context.mounted || selected == null) return;

    final path = selected.path.trim();
    if (path.isEmpty) return;

    ref.read(currentPageProvider.notifier).state = selected.title;

    if (path != GoRouterState.of(context).uri.toString()) {
      context.go(path);
    }
  }
}
