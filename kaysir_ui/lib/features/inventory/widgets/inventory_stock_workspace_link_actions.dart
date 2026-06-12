import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_filter_deep_link.dart';

Future<void> copyInventoryStockWorkspaceFilteredLink({
  required BuildContext context,
  required String route,
  required bool Function() isMounted,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  await Clipboard.setData(ClipboardData(text: inventoryBrowserDeepLink(route)));
  if (!isMounted()) return;

  messenger.showSnackBar(
    const SnackBar(content: Text('Filtered inventory link copied')),
  );
}
