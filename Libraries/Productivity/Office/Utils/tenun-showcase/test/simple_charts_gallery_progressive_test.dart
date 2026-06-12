import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_example.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_families.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  testWidgets('simple charts gallery defers later groups on first frame', (
    tester,
  ) async {
    await pumpShowcaseBody(
      tester,
      width: 1000,
      height: 760,
      child: const SimpleChartsShowcaseExample(
        initialVisibleGalleryGroups: 1,
        galleryGroupRevealInterval: Duration(milliseconds: 250),
      ),
    );

    expect(find.text('API behavior'), findsOneWidget);
    expect(find.text('API Behavior'), findsOneWidget);
    expect(find.text('Core simple charts'), findsNothing);
    expect(find.text('Regional Growth'), findsNothing);
    expect(
      find.textContaining('Loading 7 more simple chart group'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('Core simple charts'), findsOneWidget);
    expect(find.text('Regional Growth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('simple charts gallery can load all deferred groups on demand', (
    tester,
  ) async {
    await pumpShowcaseBody(
      tester,
      width: 1000,
      height: 760,
      child: const SimpleChartsShowcaseExample(
        initialVisibleGalleryGroups: 1,
        galleryGroupRevealInterval: Duration(seconds: 30),
      ),
    );

    expect(find.text('Trend charts'), findsNothing);

    final loadAllButton = find.text('Load all now');
    await tester.ensureVisible(loadAllButton);
    await tester.pump();
    await tester.tap(loadAllButton);
    await tester.pump();

    expect(find.text('Trend charts'), findsOneWidget);
    expect(find.text('Revenue Trend'), findsOneWidget);
    expect(find.textContaining('Loading '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('simple charts gallery can focus the core tier', (tester) async {
    await pumpShowcaseBody(
      tester,
      width: 1000,
      height: 760,
      child: const SimpleChartsShowcaseExample(
        tierFilter: SimpleChartsShowcaseTierFilter.core,
        progressiveGalleryLoading: false,
      ),
    );

    expect(find.text('API behavior'), findsOneWidget);
    expect(find.text('Core simple charts'), findsOneWidget);
    expect(find.text('Regional Growth'), findsOneWidget);
    expect(find.text('Pro dashboard charts'), findsNothing);
    expect(find.text('Operating Targets'), findsNothing);
    expect(find.text('Trend charts'), findsNothing);
    expect(find.textContaining('Loading '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('simple charts gallery can focus the pro tier', (tester) async {
    await pumpShowcaseBody(
      tester,
      width: 1000,
      height: 760,
      child: const SimpleChartsShowcaseExample(
        tierFilter: SimpleChartsShowcaseTierFilter.pro,
        progressiveGalleryLoading: false,
      ),
    );

    expect(find.text('API behavior'), findsNothing);
    expect(find.text('API Behavior'), findsNothing);
    expect(find.text('Core simple charts'), findsNothing);
    expect(find.text('Regional Growth'), findsNothing);
    expect(find.text('Pro dashboard charts'), findsOneWidget);
    expect(find.text('Operating Targets'), findsOneWidget);
    expect(find.text('Trend charts'), findsOneWidget);
    expect(find.text('Revenue Trend'), findsOneWidget);
    expect(find.textContaining('Loading '), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
