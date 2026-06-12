import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_availability_rule_authoring.dart';
import 'management_pack_provider.dart';
import 'product_module_contribution_manifest_provider.dart';

final productAvailabilityRuleTemplateContributionsProvider =
    Provider<List<ProductAvailabilityRuleTemplateContribution>>((ref) {
      return ref
          .watch(productModuleContributionRegistryProvider)
          .availabilityRuleTemplateContributions;
    });

final productAvailabilityRuleTemplateRegistryProvider =
    Provider<ProductAvailabilityRuleTemplateRegistry>((ref) {
      return ProductAvailabilityRuleTemplateRegistry(
        pack: ref.watch(productManagementPackProvider),
        contributions: ref.watch(
          productAvailabilityRuleTemplateContributionsProvider,
        ),
      );
    });

final productAvailabilityRuleTemplatesProvider =
    Provider<List<ProductAvailabilityRuleTemplate>>((ref) {
      return ref
          .watch(productAvailabilityRuleTemplateRegistryProvider)
          .templates;
    });

final productAvailabilityRuleTemplateEntriesProvider =
    Provider<List<ProductAvailabilityRuleTemplateEntry>>((ref) {
      return ref.watch(productAvailabilityRuleTemplateRegistryProvider).entries;
    });

final productAvailabilityRuleTemplateSourceSummariesProvider =
    Provider<List<ProductAvailabilityRuleTemplateSourceSummary>>((ref) {
      return ref
          .watch(productAvailabilityRuleTemplateRegistryProvider)
          .sourceSummaries;
    });
