import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/omni_channel_activity_action.dart';
import '../omni_channel_activity_action_registry.dart';

/// Provides the product-module action registry used by the Activity Center.
final omniChannelActivityActionRegistryProvider =
    Provider<OmniChannelActivityActionRegistry>(
      (ref) => omniChannelDefaultActivityActionRegistry,
    );
