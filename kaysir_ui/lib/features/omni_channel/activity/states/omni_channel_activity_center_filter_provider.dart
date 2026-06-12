import 'package:flutter_riverpod/legacy.dart';

import '../models/omni_channel_activity_filter.dart';

/// Current filter state for the omni-channel activity center screen.
final omniChannelActivityCenterFilterProvider =
    StateProvider<OmniChannelActivityFilter>(
      (ref) => const OmniChannelActivityFilter(),
    );

/// Selected activity entry id for the activity center detail panel.
final omniChannelActivityCenterSelectedEntryIdProvider = StateProvider<String?>(
  (ref) => null,
);
