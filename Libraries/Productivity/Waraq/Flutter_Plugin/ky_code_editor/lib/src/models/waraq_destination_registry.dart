import 'package:flutter/foundation.dart';

import 'waraq_shell_command.dart';
import 'waraq_shell_models.dart';

/// Immutable helper for composing Waraq shell destination lists.
///
/// Hosts can start from the shared defaults, remove destinations they do not
/// expose, replace metadata for a destination, and reorder the sidebar without
/// mutating package-owned defaults.
@immutable
class WaraqDestinationRegistry {
  /// Creates a registry from destination metadata.
  ///
  /// Duplicate destination ids are deduplicated by keeping the latest metadata
  /// in the first position where that destination appeared.
  factory WaraqDestinationRegistry(
    Iterable<WaraqDestinationSpec> destinations,
  ) {
    return WaraqDestinationRegistry._(_deduplicate(destinations));
  }

  /// Creates a registry with the default Waraq shell destinations.
  const WaraqDestinationRegistry.defaults()
    : destinations = defaultWaraqDestinations;

  const WaraqDestinationRegistry._(this.destinations);

  /// Sidebar destinations in rendering order.
  final List<WaraqDestinationSpec> destinations;

  /// Navigation commands derived from the current destination order.
  List<WaraqShellCommand> get navigationCommands {
    return List.unmodifiable(
      destinations.map(WaraqShellCommand.openDestination),
    );
  }

  /// Returns true when [destination] is present in this registry.
  bool contains(WaraqShellDestination destination) {
    return destinations.any((spec) => spec.destination == destination);
  }

  /// Finds metadata for [destination], or null when it is not present.
  WaraqDestinationSpec? find(WaraqShellDestination destination) {
    for (final spec in destinations) {
      if (spec.destination == destination) {
        return spec;
      }
    }
    return null;
  }

  /// Returns a registry without one destination.
  WaraqDestinationRegistry without(WaraqShellDestination destination) {
    return withoutAll([destination]);
  }

  /// Returns a registry without every destination in [destinationsToRemove].
  WaraqDestinationRegistry withoutAll(
    Iterable<WaraqShellDestination> destinationsToRemove,
  ) {
    final removed = destinationsToRemove.toSet();
    return WaraqDestinationRegistry(
      destinations.where((spec) => !removed.contains(spec.destination)),
    );
  }

  /// Returns a registry containing only the requested destinations.
  ///
  /// The existing registry order is preserved.
  WaraqDestinationRegistry only(
    Iterable<WaraqShellDestination> destinationsToKeep,
  ) {
    final kept = destinationsToKeep.toSet();
    return WaraqDestinationRegistry(
      destinations.where((spec) => kept.contains(spec.destination)),
    );
  }

  /// Adds or replaces destination metadata.
  ///
  /// Existing destinations keep their current position when replaced. New
  /// destinations are appended to the end of the registry.
  WaraqDestinationRegistry withDestination(WaraqDestinationSpec destination) {
    final nextDestinations = [...destinations];
    final existingIndex = nextDestinations.indexWhere(
      (spec) => spec.destination == destination.destination,
    );
    if (existingIndex < 0) {
      nextDestinations.add(destination);
    } else {
      nextDestinations[existingIndex] = destination;
    }
    return WaraqDestinationRegistry(nextDestinations);
  }

  /// Reorders destinations by placing [preferredOrder] first.
  ///
  /// Destinations not mentioned in [preferredOrder] keep their relative order
  /// after the preferred destinations.
  WaraqDestinationRegistry reorder(
    Iterable<WaraqShellDestination> preferredOrder,
  ) {
    final nextDestinations = <WaraqDestinationSpec>[];
    final added = <WaraqShellDestination>{};

    for (final destination in preferredOrder) {
      final spec = find(destination);
      if (spec == null || !added.add(destination)) {
        continue;
      }
      nextDestinations.add(spec);
    }

    for (final spec in destinations) {
      if (added.add(spec.destination)) {
        nextDestinations.add(spec);
      }
    }

    return WaraqDestinationRegistry(nextDestinations);
  }

  static List<WaraqDestinationSpec> _deduplicate(
    Iterable<WaraqDestinationSpec> destinations,
  ) {
    final nextDestinations = <WaraqDestinationSpec>[];
    for (final destination in destinations) {
      final existingIndex = nextDestinations.indexWhere(
        (spec) => spec.destination == destination.destination,
      );
      if (existingIndex < 0) {
        nextDestinations.add(destination);
      } else {
        nextDestinations[existingIndex] = destination;
      }
    }
    return List.unmodifiable(nextDestinations);
  }
}
