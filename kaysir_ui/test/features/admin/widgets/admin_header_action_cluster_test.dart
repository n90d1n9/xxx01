import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/models/auth/user.dart';
import 'package:kaysir/features/admin/services/admin_shell_layout_resolver.dart';
import 'package:kaysir/features/admin/widgets/account_widget.dart';
import 'package:kaysir/features/admin/widgets/admin_header_action_cluster.dart';
import 'package:kaysir/features/admin/widgets/admin_search_trigger.dart';

void main() {
  const user = User(
    id: 1,
    firstName: 'Aisyah',
    lastName: 'Rahman',
    username: 'aisyah',
    email: 'aisyah@example.com',
    role: UserRole.admin,
  );

  testWidgets(
    'wide action cluster exposes search notifications theme account',
    (tester) async {
      var searches = 0;
      var notifications = 0;
      var themeToggles = 0;
      AccountMenuAction? selectedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1000, 720)),
            child: Scaffold(
              body: Center(
                child: AdminHeaderActionCluster(
                  layout: resolveAdminShellLayout(1000),
                  unreadNotifications: 12,
                  themeMode: ThemeMode.light,
                  user: user,
                  onSearchPressed: () => searches += 1,
                  onNotificationsPressed: () => notifications += 1,
                  onThemeTogglePressed: () => themeToggles += 1,
                  onAccountActionSelected: (action) => selectedAction = action,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search pages...'), findsOneWidget);
      expect(find.text('9+'), findsOneWidget);
      expect(find.text('Aisyah Rahman'), findsOneWidget);

      await tester.tap(find.byType(AdminSearchTrigger));
      await tester.tap(find.byTooltip('Notifications'));
      await tester.tap(find.byTooltip('Toggle theme'));
      await tester.pump();

      expect(searches, 1);
      expect(notifications, 1);
      expect(themeToggles, 1);

      await tester.tap(find.byType(AccountWidget));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(selectedAction, AccountMenuAction.settings);
    },
  );

  testWidgets('compact action cluster collapses search and account copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(500, 720)),
          child: Scaffold(
            body: Center(
              child: AdminHeaderActionCluster(
                layout: resolveAdminShellLayout(500),
                unreadNotifications: 0,
                themeMode: ThemeMode.dark,
                user: user,
                onSearchPressed: () {},
                onNotificationsPressed: () {},
                onThemeTogglePressed: () {},
                onAccountActionSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search pages...'), findsNothing);
    expect(find.byTooltip('Search pages'), findsOneWidget);
    expect(find.text('Aisyah Rahman'), findsNothing);
    expect(find.text('AR'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
