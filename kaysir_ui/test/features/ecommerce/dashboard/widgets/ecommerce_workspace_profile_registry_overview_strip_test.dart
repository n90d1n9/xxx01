import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_registry_overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_overview_strip.dart';

void main() {
  testWidgets('ProfileRegistryOverviewStrip renders metrics', (tester) async {
    final overview = ProfileRegistryOverview.fromProfiles(
      defaultProductProfiles,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfileRegistryOverviewStrip(overview: overview)),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_registry_overview_strip')),
      findsOneWidget,
    );
    expect(find.text('6 profiles'), findsOneWidget);
    expect(find.text('6 channels'), findsOneWidget);
    expect(find.text('7 capabilities'), findsOneWidget);
    expect(find.text('7 modules'), findsOneWidget);
    expect(find.text('11 rules'), findsOneWidget);
    expect(find.text('25 keywords'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });
}
