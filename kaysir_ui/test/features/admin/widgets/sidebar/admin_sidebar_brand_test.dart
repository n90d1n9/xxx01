import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/sidebar/admin_sidebar_brand.dart';

void main() {
  testWidgets('expanded brand shows workspace identity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminSidebarBrand(isCompact: false)),
      ),
    );

    expect(find.text('K'), findsOneWidget);
    expect(find.text('Kaysir'), findsOneWidget);
    expect(find.text('Commerce workspace'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('compact brand keeps identity accessible without copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminSidebarBrand(isCompact: true)),
      ),
    );

    expect(find.text('K'), findsOneWidget);
    expect(find.text('Kaysir'), findsNothing);
    expect(find.text('Commerce workspace'), findsNothing);
    expect(find.byTooltip('Kaysir - Commerce workspace'), findsOneWidget);
  });
}
