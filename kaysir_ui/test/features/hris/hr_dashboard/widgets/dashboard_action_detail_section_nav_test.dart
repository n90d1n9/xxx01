import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_section_nav.dart';

void main() {
  testWidgets('section nav exposes accessible jump targets', (tester) async {
    final selectedSections = <String>[];
    final semanticsHandle = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardActionDetailSectionNav(
              sections: [
                DashboardActionDetailSectionLink(
                  label: 'Overview',
                  icon: Icons.dashboard_customize_outlined,
                  onSelected: () => selectedSections.add('overview'),
                ),
                DashboardActionDetailSectionLink(
                  label: 'Evidence',
                  icon: Icons.timeline_outlined,
                  selected: true,
                  onSelected: () => selectedSections.add('evidence'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Overview section')),
        isSemantics(
          label: 'Overview section',
          isButton: true,
          isFocusable: true,
          isSelected: false,
          hasTapAction: true,
          onTapHint: 'Jump to overview section',
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Evidence section')),
        isSemantics(
          label: 'Evidence section',
          value: 'Current section',
          isButton: true,
          isFocusable: true,
          isSelected: true,
          hasTapAction: true,
          onTapHint: 'Jump to evidence section',
        ),
      );

      await tester.tap(find.byTooltip('Jump to overview'));
      await tester.pump();

      expect(selectedSections, ['overview']);
    } finally {
      semanticsHandle.dispose();
    }
  });
}
