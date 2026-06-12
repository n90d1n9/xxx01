import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/current_profile_badge.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('CurrentProfileBadge renders selected state', (tester) async {
    await tester.pumpWorkspaceWidget(const CurrentProfileBadge());

    expect(find.text('Current'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Current'), matching: find.byType(TextBadge)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
