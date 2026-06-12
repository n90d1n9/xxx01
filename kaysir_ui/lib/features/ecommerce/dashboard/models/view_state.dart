import 'action.dart';
import 'channel_strategy.dart';
import 'destination.dart';
import 'health.dart';
import 'overview.dart';
import 'order_workspace_bridge.dart';
import 'product_profile.dart';
import 'registry_diagnostics.dart';

class ViewState {
  final ProductProfile productProfile;
  final ChannelStrategy channelStrategy;
  final Overview overview;
  final HealthSummary health;
  final List<Destination> destinations;
  final List<Action> actions;
  final RegistryDiagnostics registryDiagnostics;

  const ViewState({
    required this.productProfile,
    required this.channelStrategy,
    required this.overview,
    required this.health,
    required this.destinations,
    required this.actions,
    required this.registryDiagnostics,
  });

  bool get hasDestinations => destinations.isNotEmpty;

  bool get hasChannelStrategy => channelStrategy.hasChannels;

  bool get hasPriorityActions => actions.isNotEmpty;

  bool get hasRegistryIssues => registryDiagnostics.hasIssues;

  String get primaryOrderRoutePath {
    return primaryOrderRoutePathFor(
      productProfile: productProfile,
      destinations: destinations,
      actions: actions,
    );
  }

  String get primaryOrderLaunchLocation {
    return primaryOrderLaunchLocationFor(
      productProfile: productProfile,
      destinations: destinations,
      actions: actions,
    );
  }
}
