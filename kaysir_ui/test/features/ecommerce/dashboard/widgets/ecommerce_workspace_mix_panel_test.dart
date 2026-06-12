import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/mix_panel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/order_breakdown_list.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  testWidgets('MixPanel uses reusable panel surface', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MixPanel(insights: OrderInsights.empty)),
      ),
    );

    expect(find.byType(PanelSurface), findsOneWidget);
    expect(find.byType(PanelHeader), findsOneWidget);
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(find.byType(OrderBreakdownList), findsNWidgets(2));
    expect(find.byType(InsetSurface), findsNWidgets(2));
    expect(find.byType(EmptyState), findsNWidgets(2));
    expect(find.text('Channel and fulfillment mix'), findsOneWidget);
    expect(find.text('No channel activity yet'), findsOneWidget);
    expect(find.text('No fulfillment activity yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
