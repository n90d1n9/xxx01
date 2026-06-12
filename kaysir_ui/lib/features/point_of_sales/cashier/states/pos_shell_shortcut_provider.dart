import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../utils/pos_shell_shortcuts.dart';
import 'pos_product_runtime_pack_provider.dart';

final posShellShortcutRegistryProvider = Provider<POSShellShortcutRegistry>(
  (ref) => ref.watch(posProductRuntimePackProvider).shortcutRegistry,
);

final posShellShortcutRegistryIssuesProvider =
    Provider<List<POSShellShortcutRegistryIssue>>(
      (ref) => ref.watch(posShellShortcutRegistryProvider).validate(),
    );
