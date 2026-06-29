import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/sidebar_provider.dart';
import '../widgets/admin_footer.dart';
import '../widgets/admin_header.dart';
import '../widgets/sidebar/admin_sidebar.dart';
import '../../dashboard/dashboard_content_widget.dart';

class AdminScreen extends ConsumerWidget {
  final Widget? body;
  const AdminScreen({super.key, this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarMode = ref.watch(sidebarModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Conditionarlly show sidebar based on mode
            if (sidebarMode != SidebarMode.hidden) const AdminSidebar(),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Header
                  const AdminHeader(),

                  // Dynamic content
                  Expanded(child: body!),
                  // Footer
                  const AdminFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Drawer for mobile view
      drawer:
          MediaQuery.of(context).size.width < 600
              ? const Drawer(child: AdminSidebar(isDrawer: true))
              : null,
    );
  }
}
