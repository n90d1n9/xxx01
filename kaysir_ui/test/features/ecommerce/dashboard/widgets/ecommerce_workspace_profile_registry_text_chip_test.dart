import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_text_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ProfileRegistryTextChip renders text badge', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ProfileRegistryTextChip(label: 'Promise Policy'),
    );

    expect(find.byType(TextBadge), findsOneWidget);
    expect(find.text('Promise Policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
