import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/omni_channel_activity_registry_diagnostics.dart';
import 'omni_channel_activity_action_registry_provider.dart';
import 'omni_channel_activity_provider.dart';

/// Provides diagnostics for currently registered omni-channel activity modules.
final omniChannelActivityRegistryDiagnosticsProvider =
    Provider<OmniChannelActivityRegistryDiagnostics>((ref) {
      return OmniChannelActivityRegistryDiagnostics.fromFeed(
        feed: ref.watch(omniChannelActivityFeedProvider),
        actionRegistry: ref.watch(omniChannelActivityActionRegistryProvider),
        triageDimensions: ref.watch(
          omniChannelActivityTriageDimensionDefinitionsProvider,
        ),
        moduleManifests: ref.watch(omniChannelActivityModuleManifestsProvider),
      );
    });
