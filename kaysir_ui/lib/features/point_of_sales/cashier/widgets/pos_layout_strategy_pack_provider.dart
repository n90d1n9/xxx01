import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/pos_product_runtime_pack_provider.dart';
import 'pos_layout_strategy_pack.dart';

final posLayoutStrategyPackProvider = Provider<POSLayoutStrategyPack>(
  (ref) => ref.watch(posProductRuntimePackProvider).layoutStrategyPack,
);

final posLayoutStrategyPackValidationProvider =
    Provider<POSLayoutStrategyPackValidation>((ref) {
      return ref.watch(posLayoutStrategyPackProvider).validate();
    });
