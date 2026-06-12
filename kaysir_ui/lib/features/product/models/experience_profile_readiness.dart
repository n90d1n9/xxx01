import 'experience_profile.dart';
import 'product_module_destination.dart';

/// Highest setup state reached by an experience profile readiness assessment.
enum ProductExperienceProfileReadinessLevel { blocked, warning, ready }

/// Severity assigned to a profile readiness issue.
enum ProductExperienceProfileReadinessIssueSeverity { warning, blocking }

/// Machine-readable reason an experience profile is not fully ready.
enum ProductExperienceProfileReadinessIssueType {
  emptyWorkspaceTitle,
  emptyWorkspaceSubtitle,
  emptyWorkspaceDescription,
  emptyDestinationSet,
  duplicateDestination,
  missingDestination,
}

/// Single validation issue that explains an experience profile setup gap.
class ProductExperienceProfileReadinessIssue {
  const ProductExperienceProfileReadinessIssue({
    required this.type,
    required this.severity,
    required this.message,
    this.destinationId,
  });

  final ProductExperienceProfileReadinessIssueType type;
  final ProductExperienceProfileReadinessIssueSeverity severity;
  final String message;
  final ProductModuleDestinationId? destinationId;

  bool get isBlocking {
    return severity == ProductExperienceProfileReadinessIssueSeverity.blocking;
  }
}

/// Readiness result for one product experience profile.
class ProductExperienceProfileReadiness {
  ProductExperienceProfileReadiness({
    required this.profile,
    required this.resolvedDestinationCount,
    required List<ProductExperienceProfileReadinessIssue> issues,
  }) : issues = List.unmodifiable(issues);

  final ProductExperienceProfile profile;
  final int resolvedDestinationCount;
  final List<ProductExperienceProfileReadinessIssue> issues;

  int get expectedDestinationCount => profile.destinationIds.length;
  bool get hasIssues => issues.isNotEmpty;
  bool get hasBlockingIssues => issues.any((issue) => issue.isBlocking);

  Iterable<ProductExperienceProfileReadinessIssue> get blockingIssues {
    return issues.where((issue) => issue.isBlocking);
  }

  Iterable<ProductExperienceProfileReadinessIssue> get warningIssues {
    return issues.where((issue) => !issue.isBlocking);
  }

  ProductExperienceProfileReadinessLevel get level {
    if (hasBlockingIssues) {
      return ProductExperienceProfileReadinessLevel.blocked;
    }
    if (hasIssues) {
      return ProductExperienceProfileReadinessLevel.warning;
    }
    return ProductExperienceProfileReadinessLevel.ready;
  }

  String get statusLabel {
    switch (level) {
      case ProductExperienceProfileReadinessLevel.blocked:
        return 'Blocked';
      case ProductExperienceProfileReadinessLevel.warning:
        return 'Needs review';
      case ProductExperienceProfileReadinessLevel.ready:
        return 'Ready';
    }
  }

  String get destinationCoverageLabel {
    return '$resolvedDestinationCount/$expectedDestinationCount destinations';
  }
}

/// Aggregated readiness result for the full experience profile registry.
class ProductExperienceProfileRegistryReadiness {
  ProductExperienceProfileRegistryReadiness({
    required List<ProductExperienceProfileReadiness> profiles,
  }) : profiles = List.unmodifiable(profiles);

  final List<ProductExperienceProfileReadiness> profiles;

  bool get isEmpty => profiles.isEmpty;
  bool get hasProfiles => profiles.isNotEmpty;
  bool get isReady {
    return profiles.every(
      (profile) =>
          profile.level == ProductExperienceProfileReadinessLevel.ready,
    );
  }

  int get blockedProfileCount {
    return profiles
        .where(
          (profile) =>
              profile.level == ProductExperienceProfileReadinessLevel.blocked,
        )
        .length;
  }

  int get warningProfileCount {
    return profiles
        .where(
          (profile) =>
              profile.level == ProductExperienceProfileReadinessLevel.warning,
        )
        .length;
  }

  String get statusLabel {
    if (profiles.isEmpty) return 'No profiles';
    if (blockedProfileCount > 0) return '$blockedProfileCount blocked';
    if (warningProfileCount > 0) return '$warningProfileCount need review';
    return 'All profiles ready';
  }
}

/// Validates one experience profile against registered module destinations.
ProductExperienceProfileReadiness assessProductExperienceProfileReadiness(
  ProductExperienceProfile profile, {
  ProductModuleDestinationRegistry destinationRegistry =
      defaultProductModuleDestinationRegistry,
}) {
  final issues = <ProductExperienceProfileReadinessIssue>[];

  if (profile.workspaceTitle.trim().isEmpty) {
    issues.add(
      const ProductExperienceProfileReadinessIssue(
        type: ProductExperienceProfileReadinessIssueType.emptyWorkspaceTitle,
        severity: ProductExperienceProfileReadinessIssueSeverity.blocking,
        message: 'Workspace title is required.',
      ),
    );
  }
  if (profile.workspaceSubtitle.trim().isEmpty) {
    issues.add(
      const ProductExperienceProfileReadinessIssue(
        type: ProductExperienceProfileReadinessIssueType.emptyWorkspaceSubtitle,
        severity: ProductExperienceProfileReadinessIssueSeverity.warning,
        message: 'Workspace subtitle is empty.',
      ),
    );
  }
  if (profile.workspaceDescription.trim().isEmpty) {
    issues.add(
      const ProductExperienceProfileReadinessIssue(
        type:
            ProductExperienceProfileReadinessIssueType
                .emptyWorkspaceDescription,
        severity: ProductExperienceProfileReadinessIssueSeverity.warning,
        message: 'Workspace description is empty.',
      ),
    );
  }
  if (profile.destinationIds.isEmpty) {
    issues.add(
      const ProductExperienceProfileReadinessIssue(
        type: ProductExperienceProfileReadinessIssueType.emptyDestinationSet,
        severity: ProductExperienceProfileReadinessIssueSeverity.blocking,
        message: 'At least one product destination is required.',
      ),
    );
  }

  final seenDestinationIds = <ProductModuleDestinationId>{};
  for (final id in profile.destinationIds) {
    if (!seenDestinationIds.add(id)) {
      issues.add(
        ProductExperienceProfileReadinessIssue(
          type: ProductExperienceProfileReadinessIssueType.duplicateDestination,
          severity: ProductExperienceProfileReadinessIssueSeverity.warning,
          message: 'Destination ${id.name} appears more than once.',
          destinationId: id,
        ),
      );
    }
    if (!destinationRegistry.containsId(id)) {
      issues.add(
        ProductExperienceProfileReadinessIssue(
          type: ProductExperienceProfileReadinessIssueType.missingDestination,
          severity: ProductExperienceProfileReadinessIssueSeverity.blocking,
          message: 'Destination ${id.name} is not registered.',
          destinationId: id,
        ),
      );
    }
  }

  return ProductExperienceProfileReadiness(
    profile: profile,
    resolvedDestinationCount:
        profile.destinationsIn(destinationRegistry).toSet().length,
    issues: issues,
  );
}

/// Validates all registered experience profiles.
ProductExperienceProfileRegistryReadiness
assessProductExperienceProfileRegistryReadiness(
  ProductExperienceProfileRegistry registry, {
  ProductModuleDestinationRegistry destinationRegistry =
      defaultProductModuleDestinationRegistry,
}) {
  return ProductExperienceProfileRegistryReadiness(
    profiles: [
      for (final profile in registry.profiles)
        assessProductExperienceProfileReadiness(
          profile,
          destinationRegistry: destinationRegistry,
        ),
    ],
  );
}
