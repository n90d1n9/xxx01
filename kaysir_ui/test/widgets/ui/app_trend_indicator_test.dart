import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_trend_indicator.dart';

void main() {
  testWidgets('renders a compact positive pill with full tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppTrendIndicator(value: '+ 2% than last week')),
      ),
    );

    expect(find.byTooltip('+ 2% than last week'), findsOneWidget);
    expect(find.text('+ 2%'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('renders an inline negative trend with full label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTrendIndicator(
            value: '- 4.9% than last week',
            variant: AppTrendIndicatorVariant.inline,
            compactValue: false,
          ),
        ),
      ),
    );

    expect(find.text('- 4.9% than last week'), findsOneWidget);
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
  });

  testWidgets('can render an icon-only positive override', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTrendIndicator(
            value: '-2.5%',
            isPositive: true,
            variant: AppTrendIndicatorVariant.icon,
          ),
        ),
      ),
    );

    expect(find.byTooltip('-2.5%'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
    expect(find.text('-2.5%'), findsNothing);
  });
}
