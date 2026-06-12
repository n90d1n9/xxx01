import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/edition.dart';

/// Registry provider for reusable product editions.
final productEditionRegistryProvider = Provider<ProductEditionRegistry>((ref) {
  return defaultProductEditionRegistry;
});

/// Ordered list of product editions available to launch surfaces.
final productEditionsProvider = Provider<List<ProductEdition>>((ref) {
  return ref.watch(productEditionRegistryProvider).editions;
});
