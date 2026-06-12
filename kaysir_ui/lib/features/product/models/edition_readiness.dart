import 'edition.dart';
import 'experience_profile.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

/// Highest setup state reached by a product edition readiness assessment.
enum ProductEditionReadinessLevel { blocked, warning, ready }

/// Severity assigned to an issue found while validating an edition.
enum ProductEditionReadinessIssueSeverity { warning, blocking }

/// Machine-readable reason an edition is not fully launch ready.
enum ProductEditionReadinessIssueType {
  emptyTitle,
  emptySubtitle,
  emptyDescription,
  emptyCapabilitySet,
  duplicateEdition,
  missingExperienceProfile,
  missingManagementPack,
  unavailableChannelProfile,
}

/// Single validation issue that explains an edition setup problem.
class ProductEditionReadinessIssue {
  const ProductEditionReadinessIssue({
    required this.type,
    required this.severity,
    required this.message,
  });

  final ProductEditionReadinessIssueType type;
  final ProductEditionReadinessIssueSeverity severity;
  final String message;

  bool get isBlocking {
    return severity == ProductEditionReadinessIssueSeverity.blocking;
  }
}

/// Readiness result for one product edition.
class ProductEditionReadiness {
  ProductEditionReadiness({
    required this.edition,
    required List<ProductEditionReadinessIssue> issues,
  }) : issues = List.unmodifiable(issues);

  final ProductEdition edition;
  final List<ProductEditionReadinessIssue> issues;

  bool get hasIssues => issues.isNotEmpty;
  bool get hasBlockingIssues => issues.any((issue) => issue.isBlocking);

  Iterable<ProductEditionReadinessIssue> get blockingIssues {
    return issues.where((issue) => issue.isBlocking);
  }

  Iterable<ProductEditionReadinessIssue> get warningIssues {
    return issues.where((issue) => !issue.isBlocking);
  }

  ProductEditionReadinessLevel get level {
    if (hasBlockingIssues) return ProductEditionReadinessLevel.blocked;
    if (hasIssues) return ProductEditionReadinessLevel.warning;
    return ProductEditionReadinessLevel.ready;
  }

  String get statusLabel {
    return switch (level) {
      ProductEditionReadinessLevel.blocked => 'Blocked',
      ProductEditionReadinessLevel.warning => 'Needs review',
      ProductEditionReadinessLevel.ready => 'Ready',
    };
  }
}

/// Aggregated readiness result for the full product edition registry.
class ProductEditionRegistryReadiness {
  ProductEditionRegistryReadiness({
    required List<ProductEditionReadiness> editions,
  }) : editions = List.unmodifiable(editions);

  final List<ProductEditionReadiness> editions;

  bool get isEmpty => editions.isEmpty;
  bool get hasEditions => editions.isNotEmpty;
  bool get isReady {
    return editions.every(
      (edition) => edition.level == ProductEditionReadinessLevel.ready,
    );
  }

  int get blockedEditionCount {
    return editions
        .where(
          (edition) => edition.level == ProductEditionReadinessLevel.blocked,
        )
        .length;
  }

  int get warningEditionCount {
    return editions
        .where(
          (edition) => edition.level == ProductEditionReadinessLevel.warning,
        )
        .length;
  }

  int get issueCount {
    return editions.fold(0, (total, edition) => total + edition.issues.length);
  }

  String get statusLabel {
    if (editions.isEmpty) return 'No editions';
    if (blockedEditionCount > 0) return '$blockedEditionCount blocked';
    if (warningEditionCount > 0) return '$warningEditionCount need review';
    return 'All editions ready';
  }
}

/// Validates one product edition against registered profiles and packs.
ProductEditionReadiness assessProductEditionReadiness(
  ProductEdition edition, {
  ProductExperienceProfileRegistry experienceProfileRegistry =
      defaultProductExperienceProfileRegistry,
  ProductManagementPackRegistry? managementPackRegistry,
}) {
  return _assessProductEditionReadiness(
    edition,
    experienceProfileRegistry: experienceProfileRegistry,
    managementPackRegistry:
        managementPackRegistry ?? defaultProductManagementPackRegistry,
  );
}

/// Validates all registered editions and detects duplicate edition IDs.
ProductEditionRegistryReadiness assessProductEditionRegistryReadiness(
  ProductEditionRegistry registry, {
  ProductExperienceProfileRegistry experienceProfileRegistry =
      defaultProductExperienceProfileRegistry,
  ProductManagementPackRegistry? managementPackRegistry,
}) {
  final seenEditionIds = <ProductEditionId>{};
  final resolvedManagementPackRegistry =
      managementPackRegistry ?? defaultProductManagementPackRegistry;

  return ProductEditionRegistryReadiness(
    editions: [
      for (final edition in registry.editions)
        _assessProductEditionReadiness(
          edition,
          experienceProfileRegistry: experienceProfileRegistry,
          managementPackRegistry: resolvedManagementPackRegistry,
          duplicateEdition: !seenEditionIds.add(edition.id),
        ),
    ],
  );
}

ProductEditionReadiness _assessProductEditionReadiness(
  ProductEdition edition, {
  required ProductExperienceProfileRegistry experienceProfileRegistry,
  required ProductManagementPackRegistry managementPackRegistry,
  bool duplicateEdition = false,
}) {
  final issues = <ProductEditionReadinessIssue>[];

  if (edition.title.trim().isEmpty) {
    issues.add(
      const ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.emptyTitle,
        severity: ProductEditionReadinessIssueSeverity.blocking,
        message: 'Edition title is required.',
      ),
    );
  }
  if (edition.subtitle.trim().isEmpty) {
    issues.add(
      const ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.emptySubtitle,
        severity: ProductEditionReadinessIssueSeverity.warning,
        message: 'Edition subtitle is empty.',
      ),
    );
  }
  if (edition.description.trim().isEmpty) {
    issues.add(
      const ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.emptyDescription,
        severity: ProductEditionReadinessIssueSeverity.warning,
        message: 'Edition description is empty.',
      ),
    );
  }
  if (edition.capabilityLabels.isEmpty) {
    issues.add(
      const ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.emptyCapabilitySet,
        severity: ProductEditionReadinessIssueSeverity.warning,
        message: 'At least one capability label helps explain the edition.',
      ),
    );
  }
  if (duplicateEdition) {
    issues.add(
      ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.duplicateEdition,
        severity: ProductEditionReadinessIssueSeverity.blocking,
        message: 'Edition ${edition.id.value} appears more than once.',
      ),
    );
  }
  if (experienceProfileRegistry.profileForId(edition.experienceProfileId) ==
      null) {
    issues.add(
      ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.missingExperienceProfile,
        severity: ProductEditionReadinessIssueSeverity.blocking,
        message:
            'Experience profile ${edition.experienceProfileId.value} is not registered.',
      ),
    );
  }

  final managementPack = managementPackRegistry.packOrNull(
    edition.managementPackId,
  );
  if (managementPack == null) {
    issues.add(
      ProductEditionReadinessIssue(
        type: ProductEditionReadinessIssueType.missingManagementPack,
        severity: ProductEditionReadinessIssueSeverity.blocking,
        message:
            'Management pack ${edition.managementPackId.value} is not registered.',
      ),
    );
  } else {
    final channelRegistry = ProductSalesChannelProfileRegistry.fromPacks(
      managementPack.profilePacks,
      fallbackProfileId: managementPack.defaultChannelProfileId,
    );
    if (!channelRegistry.contains(edition.channelProfileId)) {
      issues.add(
        ProductEditionReadinessIssue(
          type: ProductEditionReadinessIssueType.unavailableChannelProfile,
          severity: ProductEditionReadinessIssueSeverity.blocking,
          message:
              'Channel profile ${edition.channelProfileId.value} is not available for ${managementPack.title}.',
        ),
      );
    }
  }

  return ProductEditionReadiness(edition: edition, issues: issues);
}
