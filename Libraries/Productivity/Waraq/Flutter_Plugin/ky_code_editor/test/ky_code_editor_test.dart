import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_code_editor/ky_code_editor.dart';
import 'package:ky_code_editor/src/widgets/waraq_shell_previews.dart'
    as previews;

void main() {
  test('default destinations expose the Waraq sidebar contract', () {
    expect(defaultWaraqDestinations, hasLength(4));
    expect(defaultWaraqDestinations.map((spec) => spec.destination), [
      WaraqShellDestination.editor,
      WaraqShellDestination.artifactApi,
      WaraqShellDestination.readiness,
      WaraqShellDestination.contract,
    ]);
    expect(defaultWaraqArtifactApiInfo.title, 'Artifact API');
    expect(
      defaultWaraqArtifactApiInfo.items.map((item) => item.value),
      contains('editor_artifact_restore_preflight_result_json'),
    );
  });

  test('WaraqDestinationRegistry prunes and replaces destinations', () {
    const readinessLabel = 'Quality';

    final registry = const WaraqDestinationRegistry.defaults()
        .without(WaraqShellDestination.contract)
        .withDestination(
          const WaraqDestinationSpec(
            destination: WaraqShellDestination.readiness,
            label: readinessLabel,
            icon: Icons.verified_outlined,
            selectedIcon: Icons.verified,
            infoScreen: defaultWaraqReadinessInfo,
          ),
        );

    expect(registry.contains(WaraqShellDestination.contract), isFalse);
    expect(
      registry.find(WaraqShellDestination.readiness)?.label,
      readinessLabel,
    );
    expect(registry.destinations.map((spec) => spec.destination), [
      WaraqShellDestination.editor,
      WaraqShellDestination.artifactApi,
      WaraqShellDestination.readiness,
    ]);
  });

  test('WaraqDestinationRegistry reorders destinations safely', () {
    final registry = const WaraqDestinationRegistry.defaults().reorder([
      WaraqShellDestination.readiness,
      WaraqShellDestination.editor,
    ]);

    expect(registry.destinations.map((spec) => spec.destination), [
      WaraqShellDestination.readiness,
      WaraqShellDestination.editor,
      WaraqShellDestination.artifactApi,
      WaraqShellDestination.contract,
    ]);
  });

  test('WaraqDestinationRegistry derives ordered navigation commands', () {
    final commands = const WaraqDestinationRegistry.defaults()
        .without(WaraqShellDestination.contract)
        .navigationCommands;

    expect(commands.map((command) => command.id), [
      'waraq.shell.open.editor',
      'waraq.shell.open.artifactApi',
      'waraq.shell.open.readiness',
    ]);
    expect(commands.first.title, 'Open Editor');
    expect(commands.first.description, 'Show Editor in the Waraq shell.');
    expect(commands.first.destination, WaraqShellDestination.editor);
  });

  test('WaraqShellController notifies only when destination changes', () {
    final controller = WaraqShellController();
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.destination, WaraqShellDestination.editor);
    expect(controller.select(WaraqShellDestination.editor), isFalse);
    expect(notifyCount, 0);

    expect(controller.select(WaraqShellDestination.contract), isTrue);
    expect(controller.destination, WaraqShellDestination.contract);
    expect(notifyCount, 1);

    controller.dispose();
  });

  test('WaraqShellController executes navigation commands', () {
    final controller = WaraqShellController();
    final command = WaraqShellCommand.openDestination(
      defaultWaraqDestinations.last,
    );

    expect(controller.runCommand(command), isTrue);
    expect(controller.destination, WaraqShellDestination.contract);

    expect(controller.runCommand(command), isFalse);

    controller.dispose();
  });

  test('WaraqShellController reconciles unavailable destinations', () {
    final controller = WaraqShellController(
      initialDestination: WaraqShellDestination.contract,
    );
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.reconcileDestinations(_editorOnlyDestinations), isTrue);
    expect(controller.destination, WaraqShellDestination.editor);
    expect(notifyCount, 1);

    expect(controller.reconcileDestinations(_editorOnlyDestinations), isFalse);
    expect(notifyCount, 1);

    controller.dispose();
  });

  testWidgets('WaraqShell starts on the editor destination', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WaraqShell(editor: Text('Editor surface'))),
    );

    expect(find.text('Editor surface'), findsOneWidget);
    expect(find.text('Artifact API'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Contract'), findsOneWidget);
  });

  testWidgets('Waraq preview entries build key shell states', (tester) async {
    await tester.pumpWidget(previews.waraqShellDefaultPreview());
    await tester.pumpAndSettle();

    expect(find.text('main.waraq'), findsOneWidget);
    expect(find.text('Artifact API'), findsOneWidget);

    await tester.pumpWidget(previews.waraqShellEditorOnlyPreview());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('main.waraq'), findsOneWidget);

    await tester.pumpWidget(previews.waraqShellCommandsPreview());
    await tester.pumpAndSettle();

    expect(find.text('Open Editor'), findsOneWidget);
    await tester.tap(find.text('Open Contract'));
    await tester.pumpAndSettle();

    expect(find.text('Shared core + specialized engines'), findsOneWidget);
  });

  testWidgets('WaraqShell renders editor-only mode without destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WaraqShell(destinations: [], editor: Text('Editor surface')),
      ),
    );

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Editor surface'), findsOneWidget);
    expect(find.text('No Waraq surface registered'), findsNothing);
  });

  testWidgets('WaraqShell navigates to artifact API pane', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WaraqShell(editor: Text('Editor surface'))),
    );

    await tester.tap(find.byIcon(Icons.api_outlined));
    await tester.pumpAndSettle();

    expect(find.text('waraq.editor / API v25'), findsOneWidget);
    expect(find.text('Restore preflight'), findsOneWidget);
    expect(
      find.text('editor_artifact_restore_preflight_result_json'),
      findsOneWidget,
    );
    expect(find.text('Editor surface'), findsNothing);
  });

  testWidgets('WaraqShell can be driven by an external controller', (
    tester,
  ) async {
    final controller = WaraqShellController(
      initialDestination: WaraqShellDestination.readiness,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WaraqShell(
          controller: controller,
          editor: const Text('Editor surface'),
        ),
      ),
    );

    expect(find.text('Shared artifact lifecycle checks'), findsOneWidget);

    controller.select(WaraqShellDestination.contract);
    await tester.pumpAndSettle();

    expect(find.text('Shared core + specialized engines'), findsOneWidget);
    expect(find.text('Editor surface'), findsNothing);

    controller.dispose();
  });

  testWidgets('WaraqShell reconciles unavailable external selections', (
    tester,
  ) async {
    final controller = WaraqShellController(
      initialDestination: WaraqShellDestination.contract,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WaraqShell(
          controller: controller,
          destinations: _editorOnlyDestinations,
          editor: const Text('Editor surface'),
        ),
      ),
    );

    expect(controller.destination, WaraqShellDestination.editor);
    expect(find.text('Editor surface'), findsOneWidget);
    expect(find.text('No Waraq surface registered'), findsNothing);

    controller.select(WaraqShellDestination.contract);
    await tester.pumpAndSettle();

    expect(controller.destination, WaraqShellDestination.editor);
    expect(find.text('Editor surface'), findsOneWidget);
    expect(find.text('No Waraq surface registered'), findsNothing);

    controller.dispose();
  });

  testWidgets('WaraqShell reports destination changes', (tester) async {
    final changes = <WaraqShellDestination>[];

    await tester.pumpWidget(
      MaterialApp(
        home: WaraqShell(
          editor: const Text('Editor surface'),
          onDestinationChanged: changes.add,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.fact_check_outlined));
    await tester.pumpAndSettle();

    expect(changes, [WaraqShellDestination.readiness]);
    expect(find.text('Shared artifact lifecycle checks'), findsOneWidget);
  });

  testWidgets('WaraqShell allows hosts to override destination panes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WaraqShell(
          editor: const Text('Editor surface'),
          paneBuilder: (context, destination) {
            if (destination.destination == WaraqShellDestination.artifactApi) {
              return const ColoredBox(
                color: Colors.black,
                child: Center(child: Text('Custom artifact pane')),
              );
            }
            return null;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.api_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Custom artifact pane'), findsOneWidget);
    expect(find.text('Restore preflight'), findsNothing);
  });

  testWidgets('WaraqInfoScreen renders stable info rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WaraqInfoScreen(spec: defaultWaraqContractInfo)),
    );

    expect(find.text('Shared core + specialized engines'), findsOneWidget);
    expect(find.text('OperationEnvelope<Edit>'), findsOneWidget);
    expect(find.text('OperationLog<Edit>'), findsOneWidget);
    expect(find.text('OperationArtifact<Snapshot, Edit>'), findsOneWidget);
  });
}

const _editorOnlyDestinations = [
  WaraqDestinationSpec(
    destination: WaraqShellDestination.editor,
    label: 'Editor',
    icon: Icons.code_outlined,
    selectedIcon: Icons.code,
  ),
];
