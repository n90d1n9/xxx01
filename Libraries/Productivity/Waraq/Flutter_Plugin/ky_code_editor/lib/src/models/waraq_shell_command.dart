import 'package:flutter/material.dart';

import 'waraq_shell_models.dart';

/// Immutable command description for host-driven Waraq shell actions.
///
/// Command palettes, menus, keyboard shortcuts, and toolbars can render this
/// model and pass it back to [WaraqShellController.runCommand] when invoked.
@immutable
class WaraqShellCommand {
  /// Creates a command that opens one Waraq shell destination.
  factory WaraqShellCommand.openDestination(WaraqDestinationSpec destination) {
    return WaraqShellCommand(
      id: 'waraq.shell.open.${destination.destination.name}',
      title: 'Open ${destination.label}',
      description: 'Show ${destination.label} in the Waraq shell.',
      icon: destination.icon,
      destination: destination.destination,
    );
  }

  /// Creates a Waraq shell command.
  const WaraqShellCommand({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.destination,
  });

  /// Stable command id for host command palettes and shortcuts.
  final String id;

  /// Human-readable command title.
  final String title;

  /// Short explanation of what the command does.
  final String description;

  /// Icon shown in menus or command palettes.
  final IconData icon;

  /// Destination selected when this command is executed.
  final WaraqShellDestination destination;
}
