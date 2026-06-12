import 'package:flutter/foundation.dart';

import '../models/waraq_shell_command.dart';
import '../models/waraq_shell_models.dart';

/// Controls the selected destination in a [WaraqShell].
class WaraqShellController extends ChangeNotifier {
  /// Creates a controller with an initial selected destination.
  WaraqShellController({
    WaraqShellDestination initialDestination = WaraqShellDestination.editor,
  }) : _destination = initialDestination;

  WaraqShellDestination _destination;

  /// Currently selected Waraq shell destination.
  WaraqShellDestination get destination => _destination;

  /// Selects a destination and notifies listeners when it changes.
  bool select(WaraqShellDestination destination) {
    if (destination == _destination) {
      return false;
    }

    _destination = destination;
    notifyListeners();
    return true;
  }

  /// Executes a shell command and returns whether selection changed.
  bool runCommand(WaraqShellCommand command) {
    return select(command.destination);
  }

  /// Selects a valid fallback when the current destination is unavailable.
  ///
  /// The preferred fallback is used when it is present in [destinations];
  /// otherwise the first available destination is selected. Empty destination
  /// sets leave the current destination unchanged.
  bool reconcileDestinations(
    Iterable<WaraqDestinationSpec> destinations, {
    WaraqShellDestination fallbackDestination = WaraqShellDestination.editor,
  }) {
    final availableDestinations = destinations
        .map((spec) => spec.destination)
        .toList(growable: false);
    if (availableDestinations.contains(_destination) ||
        availableDestinations.isEmpty) {
      return false;
    }

    final nextDestination = availableDestinations.contains(fallbackDestination)
        ? fallbackDestination
        : availableDestinations.first;
    return select(nextDestination);
  }
}
