import 'package:flutter/material.dart';

import '../controllers/waraq_shell_controller.dart';
import '../models/waraq_shell_models.dart';
import 'waraq_info_screen.dart';
import 'waraq_sidebar.dart';

/// Builds a custom pane for one Waraq shell destination.
typedef WaraqShellPaneBuilder =
    Widget? Function(BuildContext context, WaraqDestinationSpec destination);

/// Desktop-style shell that makes Waraq editor surfaces reachable by sidebar.
class WaraqShell extends StatefulWidget {
  /// Creates a reusable Waraq shell around an editor widget.
  const WaraqShell({
    super.key,
    required this.editor,
    this.destinations = defaultWaraqDestinations,
    this.initialDestination = WaraqShellDestination.editor,
    this.expandedSidebarBreakpoint = 840,
    this.controller,
    this.paneBuilder,
    this.onDestinationChanged,
  });

  /// Widget rendered for the editor destination.
  final Widget editor;

  /// Destinations displayed in the sidebar.
  final List<WaraqDestinationSpec> destinations;

  /// Initial destination selected by the shell.
  final WaraqShellDestination initialDestination;

  /// Width at which sidebar labels become visible.
  final double expandedSidebarBreakpoint;

  /// Optional external controller for programmatic shell navigation.
  ///
  /// When omitted, the shell owns an internal controller seeded by
  /// [initialDestination].
  final WaraqShellController? controller;

  /// Optional host renderer for destinations beyond the editor surface.
  ///
  /// Return null to fall back to the destination's built-in information pane.
  final WaraqShellPaneBuilder? paneBuilder;

  /// Called after the selected destination changes.
  final ValueChanged<WaraqShellDestination>? onDestinationChanged;

  @override
  State<WaraqShell> createState() => _WaraqShellState();
}

class _WaraqShellState extends State<WaraqShell> {
  late WaraqShellController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant WaraqShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    } else {
      _reconcileControllerDestination();
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        WaraqShellController(initialDestination: widget.initialDestination);
    _controller.reconcileDestinations(widget.destinations);
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _handleControllerChanged() {
    if (_controller.reconcileDestinations(widget.destinations)) {
      return;
    }

    setState(() {});
    widget.onDestinationChanged?.call(_controller.destination);
  }

  void _reconcileControllerDestination() {
    _controller.reconcileDestinations(widget.destinations);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDestination = _controller.destination;
    final hasDestinations = widget.destinations.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedSidebar =
            constraints.maxWidth >= widget.expandedSidebarBreakpoint;

        return Scaffold(
          backgroundColor: const Color(0xFF191A21),
          body: Row(
            children: [
              if (hasDestinations) ...[
                WaraqSidebar(
                  destinations: widget.destinations,
                  selectedDestination: selectedDestination,
                  expanded: expandedSidebar,
                  onDestinationSelected: _controller.select,
                ),
                const VerticalDivider(width: 1, color: Color(0xFF303241)),
              ],
              Expanded(
                child: _WaraqShellPane(
                  destination: selectedDestination,
                  destinations: widget.destinations,
                  editor: widget.editor,
                  paneBuilder: widget.paneBuilder,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Chooses the active Waraq shell pane from destination metadata.
class _WaraqShellPane extends StatelessWidget {
  /// Creates a pane selector for a Waraq shell.
  const _WaraqShellPane({
    required this.destination,
    required this.destinations,
    required this.editor,
    this.paneBuilder,
  });

  /// Currently selected destination.
  final WaraqShellDestination destination;

  /// Available destinations and optional info screen specs.
  final List<WaraqDestinationSpec> destinations;

  /// Editor widget rendered for the editor destination.
  final Widget editor;

  /// Optional host renderer for the selected destination.
  final WaraqShellPaneBuilder? paneBuilder;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) {
      return editor;
    }

    final destinationSpec = destinations
        .where((candidate) => candidate.destination == destination)
        .firstOrNull;
    if (destinationSpec == null) {
      return const _MissingWaraqPane();
    }

    final customPane = paneBuilder?.call(context, destinationSpec);
    if (customPane != null) {
      return customPane;
    }

    if (destinationSpec.destination == WaraqShellDestination.editor) {
      return editor;
    }

    if (destinationSpec.infoScreen != null) {
      return WaraqInfoScreen(spec: destinationSpec.infoScreen!);
    }

    return const _MissingWaraqPane();
  }
}

/// Fallback pane shown when a destination has no renderer.
class _MissingWaraqPane extends StatelessWidget {
  /// Creates an empty-state pane for incomplete shell destinations.
  const _MissingWaraqPane();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF282A36),
      child: Center(
        child: Text(
          'No Waraq surface registered',
          style: TextStyle(color: Color(0xFF9AA6C3), fontSize: 13),
        ),
      ),
    );
  }
}
