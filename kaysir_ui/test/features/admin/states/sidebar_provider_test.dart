import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/states/sidebar_provider.dart';

void main() {
  test('nextSidebarMode cycles through expanded compact and hidden', () {
    expect(nextSidebarMode(SidebarMode.expanded), SidebarMode.compact);
    expect(nextSidebarMode(SidebarMode.compact), SidebarMode.hidden);
    expect(nextSidebarMode(SidebarMode.hidden), SidebarMode.expanded);
  });
}
