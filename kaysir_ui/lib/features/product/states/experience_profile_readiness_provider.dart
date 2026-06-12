import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/experience_profile.dart';
import '../models/experience_profile_readiness.dart';
import '../models/product_module_destination.dart';

/// Registry provider for reusable product experience profiles.
final productExperienceProfileRegistryProvider =
    Provider<ProductExperienceProfileRegistry>((ref) {
      return defaultProductExperienceProfileRegistry;
    });

/// Registry provider for product module destinations used by profiles.
final productModuleDestinationRegistryProvider =
    Provider<ProductModuleDestinationRegistry>((ref) {
      return defaultProductModuleDestinationRegistry;
    });

/// Readiness provider that validates profile metadata and destinations.
final productExperienceProfileReadinessProvider =
    Provider<ProductExperienceProfileRegistryReadiness>((ref) {
      return assessProductExperienceProfileRegistryReadiness(
        ref.watch(productExperienceProfileRegistryProvider),
        destinationRegistry: ref.watch(
          productModuleDestinationRegistryProvider,
        ),
      );
    });
