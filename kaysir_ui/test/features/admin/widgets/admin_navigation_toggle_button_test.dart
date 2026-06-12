import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/states/sidebar_provider.dart';
import 'package:kaysir/features/admin/widgets/admin_navigation_toggle_button.dart';

void main() {
  testWidgets('drawer navigation button opens the drawer path', (tester) async {
    var openedDrawer = false;
    var toggledSidebar = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminNavigationToggleButton(
            sidebarMode: SidebarMode.expanded,
            useDrawerNavigation: true,
            onOpenDrawer: () => openedDrawer = true,
            onToggleSidebar: () => toggledSidebar = true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Open navigation'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pump();

    expect(openedDrawer, isTrue);
    expect(toggledSidebar, isFalse);
  });

  testWidgets('desktop navigation button toggles sidebar mode', (tester) async {
    var openedDrawer = false;
    var toggledSidebar = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminNavigationToggleButton(
            sidebarMode: SidebarMode.expanded,
            useDrawerNavigation: false,
            onOpenDrawer: () => openedDrawer = true,
            onToggleSidebar: () => toggledSidebar = true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Toggle navigation'), findsOneWidget);
    expect(find.byIcon(Icons.menu_open), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle navigation'));
    await tester.pump();

    expect(openedDrawer, isFalse);
    expect(toggledSidebar, isTrue);
  });
}
