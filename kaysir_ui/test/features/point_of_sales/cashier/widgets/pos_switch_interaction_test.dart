import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_interaction.dart';

void main() {
  testWidgets('switch compact sheet returns the selected value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? selected;
    double? observedHeight;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    selected = await showPOSSwitchCompactSheet<String>(
                      context: context,
                      builder:
                          (sheetContext) => LayoutBuilder(
                            builder: (context, constraints) {
                              observedHeight = constraints.maxHeight;

                              return Center(
                                child: TextButton(
                                  onPressed:
                                      () => Navigator.of(
                                        sheetContext,
                                      ).pop('picked'),
                                  child: const Text('Pick option'),
                                ),
                              );
                            },
                          ),
                    );
                  },
                  child: const Text('Open sheet'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Pick option'), findsOneWidget);
    expect(observedHeight, moreOrLessEquals(720));

    await tester.tap(find.text('Pick option'));
    await tester.pumpAndSettle();

    expect(selected, 'picked');
  });

  testWidgets('switch confirmation dialog returns confirmation decisions', (
    tester,
  ) async {
    bool? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    confirmed = await showPOSSwitchConfirmationDialog(
                      context: context,
                      title: 'Review switch',
                      message: 'This switch changes the active workflow.',
                      confirmLabel: 'Switch',
                    );
                  },
                  child: const Text('Open confirmation'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();

    expect(find.text('Review switch'), findsOneWidget);
    expect(
      find.text('This switch changes the active workflow.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('switch confirmation dialog renders optional details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    await showPOSSwitchConfirmationDialog(
                      context: context,
                      title: 'Review switch',
                      message: 'This switch changes the active workflow.',
                      confirmLabel: 'Switch',
                      details: const Text('Order stays active'),
                    );
                  },
                  child: const Text('Open detailed confirmation'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open detailed confirmation'));
    await tester.pumpAndSettle();

    expect(find.text('Review switch'), findsOneWidget);
    expect(
      find.text('This switch changes the active workflow.'),
      findsOneWidget,
    );
    expect(find.text('Order stays active'), findsOneWidget);
  });

  testWidgets('switch confirmation dialog can gate confirmation', (
    tester,
  ) async {
    final canConfirm = ValueNotifier<bool>(false);
    addTearDown(canConfirm.dispose);
    bool? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    confirmed = await showPOSSwitchConfirmationDialog(
                      context: context,
                      title: 'Review switch',
                      message: 'This switch needs more detail.',
                      confirmLabel: 'Switch',
                      canConfirmListenable: canConfirm,
                    );
                  },
                  child: const Text('Open gated confirmation'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open gated confirmation'));
    await tester.pumpAndSettle();

    expect(find.text('Review switch'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Switch'))
          .onPressed,
      isNull,
    );

    canConfirm.value = true;
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Switch'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('switch notice dialog closes after acknowledgement', (
    tester,
  ) async {
    var acknowledged = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    await showPOSSwitchNoticeDialog(
                      context: context,
                      title: 'Switch blocked',
                      message: 'Complete the current order first.',
                      confirmLabel: 'Got it',
                    );
                    acknowledged = true;
                  },
                  child: const Text('Open notice'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open notice'));
    await tester.pumpAndSettle();

    expect(find.text('Switch blocked'), findsOneWidget);
    expect(find.text('Complete the current order first.'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(acknowledged, isTrue);
    expect(find.text('Switch blocked'), findsNothing);
  });
}
