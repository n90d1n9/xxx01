import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/destination_card.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('DestinationCard renders route chrome', (tester) async {
    var opened = false;

    await tester.pumpWorkspaceWidget(
      DestinationCard(
        width: 320,
        destination: _destination,
        onPressed: () => opened = true,
      ),
    );

    expect(find.byKey(const ValueKey('destination_catalog')), findsOneWidget);
    expect(find.text('Catalog workspace'), findsOneWidget);
    expect(
      find.text('Review product health and sales readiness.'),
      findsOneWidget,
    );
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('4 gaps'), findsOneWidget);
    expect(find.byType(DetailRow), findsOneWidget);
    expect(find.byType(MetricBlock), findsOneWidget);
    expect(find.byType(PanelSurface), findsOneWidget);
    expect(find.byType(ActionButton), findsOneWidget);

    await tester.tap(find.text('Open catalog'));
    await tester.pump();

    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
}

const _destination = Destination(
  id: 'catalog',
  title: 'Catalog workspace',
  subtitle: 'Review product health and sales readiness.',
  routePath: '/catalog',
  metricLabel: 'Readiness',
  metricValue: '4 gaps',
  actionLabel: 'Open catalog',
  icon: Icons.inventory_2_outlined,
  tone: DestinationTone.warning,
);
