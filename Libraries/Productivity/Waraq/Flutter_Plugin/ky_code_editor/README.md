# ky_code_editor

## Features

Reusable Flutter presentation widgets for Waraq editor surfaces:

- `WaraqShell` wraps an editor widget with an adaptive sidebar.
- `WaraqSidebar` exposes Editor, Artifact API, Readiness, and Contract surfaces.
- `WaraqInfoScreen` renders stable Waraq artifact API, readiness, and contract
  summaries from immutable display models.
- `WaraqShellController` lets hosts drive sidebar navigation from app state,
  deep links, or command palette actions.
- `WaraqDestinationRegistry` lets hosts compose sidebar destinations from the
  shared defaults without mutating package-owned metadata.
- `WaraqShellCommand` gives command palettes, menus, and shortcuts a stable
  navigation command model.
- `paneBuilder` lets hosts override any destination with a custom pane while
  keeping the shared sidebar and fallback info screens.
- Empty `destinations` render an editor-only shell so host composition mistakes
  do not hide the required editor surface.
- Flutter widget previews cover default, customized, command-driven, sidebar,
  info-screen, and editor-only shell states.

## Getting started

Add the package to a Flutter app and provide the live editor widget that should
render inside the `Editor` destination. Native Waraq FFI wiring is intentionally
kept outside this package layer until the generated binding is packaged.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:ky_code_editor/ky_code_editor.dart';

class WaraqHostScreen extends StatelessWidget {
  const WaraqHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WaraqShell(
      editor: ColoredBox(
        color: Color(0xFF282A36),
        child: Center(child: Text('Editor surface')),
      ),
    );
  }
}
```

```dart
WaraqShell(
  editor: const Text('Editor surface'),
  onDestinationChanged: (destination) {
    debugPrint('selected Waraq destination: $destination');
  },
  paneBuilder: (context, destination) {
    if (destination.destination == WaraqShellDestination.artifactApi) {
      return const Center(child: Text('Custom artifact diagnostics'));
    }
    return null;
  },
)
```

```dart
final controller = WaraqShellController(
  initialDestination: WaraqShellDestination.readiness,
);

WaraqShell(
  controller: controller,
  editor: const Text('Editor surface'),
);

controller.select(WaraqShellDestination.contract);
```

```dart
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
    .destinations;

WaraqShell(
  destinations: destinations,
  editor: const Text('Editor surface'),
);
```

```dart
final controller = WaraqShellController();
final registry = const WaraqDestinationRegistry.defaults();
final commands = registry.navigationCommands;

WaraqShell(
  controller: controller,
  destinations: registry.destinations,
  editor: const Text('Editor surface'),
);

controller.runCommand(commands.first);
```

## Previews

Widget previews live in `lib/src/widgets/waraq_shell_previews.dart` and expose
the `Waraq` preview group:

- `Shell Default`
- `Shell Custom Destinations`
- `Shell Commands`
- `Shell Editor Only`
- `Sidebar Expanded`
- `Info Screen Contract`

## Additional information

The default shell metadata mirrors the Waraq core artifact API v25 surface,
including `editor_artifact_restore_preflight_result_json`.
