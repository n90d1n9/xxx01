import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../utils/pos_command_actions.dart';
import 'pos_product_runtime_pack_provider.dart';

final posCommandActionRegistryProvider = Provider<POSCommandActionRegistry>(
  (ref) => ref.watch(posProductRuntimePackProvider).commandActionRegistry,
);

final posCommandActionRegistryIssuesProvider =
    Provider<List<POSCommandActionRegistryIssue>>(
      (ref) => ref.watch(posCommandActionRegistryProvider).validate(),
    );
