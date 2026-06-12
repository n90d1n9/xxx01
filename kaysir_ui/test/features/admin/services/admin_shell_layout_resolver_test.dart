import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/models/admin_shell_layout.dart';
import 'package:kaysir/features/admin/services/admin_shell_layout_resolver.dart';
import 'package:kaysir/features/admin/states/sidebar_provider.dart';

void main() {
  group('resolveAdminShellLayout', () {
    test('uses compact density for narrow workspaces', () {
      final layout = resolveAdminShellLayout(500);

      expect(layout.density, AdminShellDensity.compact);
      expect(layout.useDrawerNavigation, isTrue);
      expect(layout.showExpandedSearch, isFalse);
      expect(layout.showAccountCopy, isFalse);
      expect(layout.showFooterStatus, isFalse);
      expect(layout.showFooterLinks, isFalse);
      expect(layout.headerHeight, 64);
      expect(layout.footerHeight, 44);
      expect(layout.horizontalPadding, 12);
    });

    test('keeps medium workspaces comfortable but drawer based', () {
      final layout = resolveAdminShellLayout(760);

      expect(layout.density, AdminShellDensity.comfortable);
      expect(layout.useDrawerNavigation, isTrue);
      expect(layout.showExpandedSearch, isFalse);
      expect(layout.showAccountCopy, isTrue);
      expect(layout.showFooterStatus, isTrue);
      expect(layout.showFooterLinks, isTrue);
      expect(layout.headerHeight, 72);
      expect(layout.footerHeight, 48);
      expect(layout.horizontalPadding, 16);
    });

    test('enables spacious desktop navigation at the desktop breakpoint', () {
      final layout = resolveAdminShellLayout(900);

      expect(layout.density, AdminShellDensity.spacious);
      expect(layout.useDrawerNavigation, isFalse);
      expect(layout.showExpandedSearch, isTrue);
      expect(layout.showAccountCopy, isTrue);
      expect(layout.showFooterStatus, isTrue);
      expect(layout.showFooterLinks, isTrue);
      expect(layout.horizontalPadding, 20);
    });
  });

  group('resolveAdminSidebarWidth', () {
    test('uses expanded width for drawer and expanded modes', () {
      expect(
        resolveAdminSidebarWidth(mode: SidebarMode.expanded, isDrawer: false),
        280,
      );
      expect(
        resolveAdminSidebarWidth(mode: SidebarMode.compact, isDrawer: true),
        280,
      );
    });

    test('uses compact width for compact shell navigation', () {
      expect(
        resolveAdminSidebarWidth(mode: SidebarMode.compact, isDrawer: false),
        76,
      );
      expect(
        resolveAdminSidebarWidth(mode: SidebarMode.hidden, isDrawer: false),
        76,
      );
    });
  });
}
