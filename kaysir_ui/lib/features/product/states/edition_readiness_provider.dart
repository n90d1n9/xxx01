import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/edition_readiness.dart';
import 'edition_provider.dart';
import 'experience_profile_readiness_provider.dart';
import 'management_pack_provider.dart';

/// Readiness provider that validates edition setup against profile and pack registries.
final productEditionReadinessProvider =
    Provider<ProductEditionRegistryReadiness>((ref) {
      return assessProductEditionRegistryReadiness(
        ref.watch(productEditionRegistryProvider),
        experienceProfileRegistry: ref.watch(
          productExperienceProfileRegistryProvider,
        ),
        managementPackRegistry: ref.watch(
          productManagementPackRegistryProvider,
        ),
      );
    });
