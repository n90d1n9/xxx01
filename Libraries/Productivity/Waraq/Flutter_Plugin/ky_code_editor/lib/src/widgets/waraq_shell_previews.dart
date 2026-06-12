import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/waraq_shell_controller.dart';
import '../models/waraq_destination_registry.dart';
import '../models/waraq_shell_command.dart';
import '../models/waraq_shell_models.dart';
import 'waraq_info_screen.dart';
import 'waraq_shell.dart';
import 'waraq_sidebar.dart';

/// Preview entry for the default Waraq shell composition.
@Preview(name: 'Shell Default', group: 'Waraq')
Widget waraqShellDefaultPreview() {
  return const _WaraqPreviewFrame(
    child: WaraqShell(editor: _WaraqPreviewEditorSurface()),
  );
}

/// Preview entry for host-customized Waraq shell destinations.
@Preview(name: 'Shell Custom Destinations', group: 'Waraq')
Widget waraqShellCustomDestinationsPreview() {
  final destinations = const WaraqDestinationRegistry.defaults()
      .without(WaraqShellDestination.contract)
      .withDestination(
        const WaraqDestinationSpec(
          destination: WaraqShellDestination.readiness,
          label: 'Quality',
          icon: Icons.verified_outlined,
          selectedIcon: Icons.verified,
          infoScreen: defaultWaraqReadinessInfo,
        ),
      )
      .reorder([
        WaraqShellDestination.editor,
        WaraqShellDestination.readiness,
        WaraqShellDestination.artifactApi,
      ])
      .destinations;

  return _WaraqPreviewFrame(
    child: WaraqShell(
      destinations: destinations,
      editor: const _WaraqPreviewEditorSurface(),
      paneBuilder: (context, destination) {
        if (destination.destination == WaraqShellDestination.artifactApi) {
          return const _WaraqPreviewArtifactPane();
        }
        return null;
      },
    ),
  );
}

/// Preview entry for command-driven Waraq shell navigation.
@Preview(name: 'Shell Commands', group: 'Waraq')
Widget waraqShellCommandsPreview() {
  return const _WaraqPreviewFrame(child: _WaraqCommandShellPreview());
}

/// Preview entry for editor-only Waraq shell fallback.
@Preview(name: 'Shell Editor Only', group: 'Waraq')
Widget waraqShellEditorOnlyPreview() {
  return const _WaraqPreviewFrame(
    child: WaraqShell(destinations: [], editor: _WaraqPreviewEditorSurface()),
  );
}

/// Preview entry for the expanded Waraq sidebar.
@Preview(name: 'Sidebar Expanded', group: 'Waraq')
Widget waraqSidebarExpandedPreview() {
  return _WaraqPreviewFrame(
    child: Row(
      children: [
        WaraqSidebar(
          destinations: defaultWaraqDestinations,
          selectedDestination: WaraqShellDestination.readiness,
          expanded: true,
          onDestinationSelected: (_) {},
        ),
        const Expanded(child: _WaraqPreviewEditorSurface()),
      ],
    ),
  );
}

/// Preview entry for a Waraq information screen.
@Preview(name: 'Info Screen Contract', group: 'Waraq')
Widget waraqInfoScreenContractPreview() {
  return const _WaraqPreviewFrame(
    child: WaraqInfoScreen(spec: defaultWaraqContractInfo),
  );
}

/// Provides a fixed preview canvas for Waraq widget previews.
class _WaraqPreviewFrame extends StatelessWidget {
  /// Creates a preview frame around a Waraq widget.
  const _WaraqPreviewFrame({required this.child});

  /// Widget rendered in the preview canvas.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFF11131A),
        body: Center(child: SizedBox(width: 1040, height: 680, child: child)),
      ),
    );
  }
}

/// Shows a command strip wired to Waraq shell navigation commands.
class _WaraqCommandShellPreview extends StatefulWidget {
  /// Creates a command-driven shell preview.
  const _WaraqCommandShellPreview();

  @override
  State<_WaraqCommandShellPreview> createState() =>
      _WaraqCommandShellPreviewState();
}

/// State for the command-driven Waraq shell preview.
class _WaraqCommandShellPreviewState extends State<_WaraqCommandShellPreview> {
  late final WaraqShellController _controller;
  late final WaraqDestinationRegistry _registry;

  @override
  void initState() {
    super.initState();
    _controller = WaraqShellController();
    _registry = const WaraqDestinationRegistry.defaults();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WaraqCommandStrip(
          commands: _registry.navigationCommands,
          onCommandSelected: _controller.runCommand,
        ),
        Expanded(
          child: WaraqShell(
            controller: _controller,
            destinations: _registry.destinations,
            editor: const _WaraqPreviewEditorSurface(),
          ),
        ),
      ],
    );
  }
}

/// Renders Waraq shell commands as compact preview buttons.
class _WaraqCommandStrip extends StatelessWidget {
  /// Creates a command strip for Waraq shell previews.
  const _WaraqCommandStrip({
    required this.commands,
    required this.onCommandSelected,
  });

  /// Commands displayed in order.
  final List<WaraqShellCommand> commands;

  /// Called when a command is selected.
  final ValueChanged<WaraqShellCommand> onCommandSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF191A21),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final command in commands)
              Tooltip(
                message: command.description,
                child: OutlinedButton.icon(
                  onPressed: () => onCommandSelected(command),
                  icon: Icon(command.icon, size: 18),
                  label: Text(command.title),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Editor placeholder used by Waraq previews.
class _WaraqPreviewEditorSurface extends StatelessWidget {
  /// Creates a static editor preview surface.
  const _WaraqPreviewEditorSurface();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF282A36),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF191A21),
            border: Border.all(color: const Color(0xFF44475A)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WaraqPreviewEditorHeader(),
                SizedBox(height: 18),
                _WaraqPreviewCodeLine(number: '1', text: 'import waraq.core;'),
                _WaraqPreviewCodeLine(number: '2', text: ''),
                _WaraqPreviewCodeLine(
                  number: '3',
                  text: 'final surface = WaraqEditorSurface();',
                ),
                _WaraqPreviewCodeLine(
                  number: '4',
                  text: 'surface.restore(preflightResult);',
                ),
                _WaraqPreviewCodeLine(
                  number: '5',
                  text: 'surface.commit(operationEnvelope);',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header row for the preview editor surface.
class _WaraqPreviewEditorHeader extends StatelessWidget {
  /// Creates a compact editor header.
  const _WaraqPreviewEditorHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.code, color: Color(0xFF50FA7B), size: 18),
        const SizedBox(width: 8),
        Text(
          'main.waraq',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFF8F8F2),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// One static line in the preview editor surface.
class _WaraqPreviewCodeLine extends StatelessWidget {
  /// Creates a preview code line.
  const _WaraqPreviewCodeLine({required this.number, required this.text});

  /// Line number shown in the gutter.
  final String number;

  /// Code text shown after the gutter.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              number,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF6272A4), fontSize: 12),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF8F8F2),
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom artifact pane used by the host-customized shell preview.
class _WaraqPreviewArtifactPane extends StatelessWidget {
  /// Creates a custom artifact pane preview.
  const _WaraqPreviewArtifactPane();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF282A36),
      child: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.api, color: Color(0xFF8BE9FD), size: 32),
              SizedBox(height: 16),
              Text(
                'Custom Artifact Diagnostics',
                style: TextStyle(
                  color: Color(0xFFF8F8F2),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Host panes can replace default Waraq info screens while '
                'keeping the shared sidebar and command contract.',
                style: TextStyle(color: Color(0xFF9AA6C3), height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
