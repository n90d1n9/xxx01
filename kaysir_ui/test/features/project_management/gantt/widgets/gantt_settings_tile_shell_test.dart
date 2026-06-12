import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_settings_tile_shell.dart';

void main() {
  testWidgets('gantt settings tile shell renders shared header and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttSettingsTileShell(
            title: 'Tile Title',
            subtitle: 'Tile subtitle',
            icon: Icons.tune_outlined,
            backgroundColor: Colors.white,
            child: const Text('Tile content'),
          ),
        ),
      ),
    );

    expect(find.text('Tile Title'), findsOneWidget);
    expect(find.text('Tile subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.tune_outlined), findsOneWidget);
    expect(find.text('Tile content'), findsOneWidget);
  });

  testWidgets('gantt settings tile shell dims disabled content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttSettingsTileShell(
            title: 'Disabled Tile',
            icon: Icons.lock_outline,
            backgroundColor: Colors.white,
            enabled: false,
            child: const Text('Disabled content'),
          ),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity));

    expect(opacity.opacity, 0.56);
    expect(find.text('Disabled Tile'), findsOneWidget);
    expect(find.text('Disabled content'), findsOneWidget);
  });
}
