import 'package:flutter_riverpod/legacy.dart';

import '../version.dart';
import 'version_control_state.dart';

final versionControlProvider =
    StateNotifierProvider<VersionControlManager, VersionControlState>((ref) {
      return VersionControlManager();
    });
