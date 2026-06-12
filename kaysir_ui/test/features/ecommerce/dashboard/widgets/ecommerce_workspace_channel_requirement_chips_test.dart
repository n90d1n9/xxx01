import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_requirement.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_requirement_chips.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ChannelRequirementChips renders rules', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ChannelRequirementChips(
        requirements: [
          ...defaultChannelCoverageRequirements,
          ecommerceMarketplacePriceListChannelCoverageRequirement,
        ],
        maxVisible: 3,
      ),
    );

    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Price lists'), findsNothing);
    expect(find.text('+1 rules'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsNWidgets(3));
    expect(find.byType(TextBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
