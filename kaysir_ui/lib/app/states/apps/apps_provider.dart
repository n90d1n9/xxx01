import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'apps_state.dart';

final appsProvider = StateNotifierProvider<AppsNotifier, AppsState>(
  (ref) => AppsNotifier(ref),
);

class AppsNotifier extends StateNotifier<AppsState> {
  final Ref ref;
  AppsNotifier(this.ref) : super(AppsState());

  void setCurrentStates({int featuresId = 0, String currentPath = '/'}) {
    state = state.copyWith(
      currentFeaturesId: featuresId,
      currentPath: currentPath,
    );
  }
}
