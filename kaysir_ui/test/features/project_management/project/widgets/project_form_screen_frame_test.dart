import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_screen_frame.dart';

void main() {
  testWidgets('project form screen frame centers guarded body states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFormScreenFrame(
          centerBody: true,
          actions: [
            IconButton(
              tooltip: 'Frame action',
              onPressed: null,
              icon: Icon(Icons.table_chart_outlined),
            ),
          ],
          child: Text('Loading slot'),
        ),
      ),
    );

    expect(find.text('Project Form'), findsOneWidget);
    expect(find.byTooltip('Frame action'), findsOneWidget);
    expect(find.text('Loading slot'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Loading slot'),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Loading slot'),
        matching: find.byType(Center),
      ),
      findsOneWidget,
    );
  });

  testWidgets('project form screen frame can delegate safe area content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFormScreenFrame(
          title: 'Custom Project Form',
          safeArea: false,
          child: Text('Scrollable form content'),
        ),
      ),
    );

    expect(find.text('Custom Project Form'), findsOneWidget);
    expect(find.text('Scrollable form content'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Scrollable form content'),
        matching: find.byType(SafeArea),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.text('Scrollable form content'),
        matching: find.byType(Center),
      ),
      findsNothing,
    );
  });
}
