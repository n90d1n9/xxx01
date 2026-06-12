import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_family_catalog.dart';

import 'support/chart_sample_test_fixtures.dart';
import 'support/chart_sample_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  testWidgets('family catalog renders overview tiles and handles selections', (
    WidgetTester tester,
  ) async {
    final selectedFamilies = <String>[];
    final selectedTypes = <String>[];

    await pumpChartSampleBody(
      tester,
      child: ChartSampleFamilyCatalog(
        families: testCatalogFamilies,
        selectedFamilyId: 'cartesian',
        onFamilySelected: (family) => selectedFamilies.add(family.id),
        onChartTypeSelected: selectedTypes.add,
      ),
    );

    expect(find.text('Cartesian'), findsOneWidget);
    expect(find.text('Distribution'), findsOneWidget);
    expect(find.text('Core'), findsNWidgets(2));
    expect(find.text('1 sample'), findsOneWidget);
    expect(find.text('2 samples'), findsOneWidget);
    expect(find.text('bar'), findsOneWidget);
    expect(find.text('histogram'), findsOneWidget);
    expect(find.text('violin'), findsOneWidget);

    await tester.tap(find.text('Distribution'));
    await tester.pump();

    await tester.tap(find.byTooltip('Filter histogram'));
    await tester.pump();

    expect(selectedFamilies, ['distribution']);
    expect(selectedTypes, ['histogram']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('family gallery can render samples without the family header', (
    WidgetTester tester,
  ) async {
    await pumpChartSampleBody(
      tester,
      child: const ChartSampleFamilyGallery(
        family: testCartesianFamily,
        showHeader: false,
        options: ChartSampleShowcaseOptions(
          showSampleJson: false,
          showSampleCode: false,
        ),
      ),
    );

    expect(find.text('Cartesian'), findsNothing);
    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Sample JSON'), findsNothing);
    expect(find.text('Dart Code'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
