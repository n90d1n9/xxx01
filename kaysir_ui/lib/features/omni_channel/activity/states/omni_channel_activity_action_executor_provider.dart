import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../omni_channel_activity_action_executor.dart';
import '../services/omni_channel_activity_action_executor.dart';

/// Provides the handler-based executor used by Activity Center actions.
final omniChannelActivityActionExecutorProvider =
    Provider<OmniChannelActivityActionExecutor>(
      (ref) => omniChannelDefaultActivityActionExecutor,
    );
