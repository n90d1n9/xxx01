import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/workflow/state/workflow_provider.dart';
import 'wayang_state.dart';

final wayangProvider = StateNotifierProvider<WayangNotifier, WayangState>((
  ref,
) {
  return WayangNotifier(ref);
});

class WayangNotifier extends StateNotifier<WayangState> {
  Ref ref;
  WayangNotifier(this.ref) : super(WayangState()) {
    _initialize();
  }

  void _initialize() {}

  String getJson() {
    return state.wayangConfig.toJson();
  }

  String getYaml() {
    return state.wayangConfig.toYaml();
  }

  saveWayang() {
    final wf = ref.watch(workflowProvider).nodes;
    mappingFromToWayang();
  }

  mappingFromToWayang() {}

  Future<void> saveWorkflow() async {
    final prefs = await SharedPreferences.getInstance();
    /* final workflowData =
        jsonEncode(state.metadataUI.nodes.map((n) => n.toJson()).toList());
    await prefs.setString('workflow', workflowData); */
  }
}
