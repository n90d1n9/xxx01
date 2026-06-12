import '../product_routes.dart';
import 'management_pack.dart';
import 'product_workspace_recommendation.dart';
import 'product_workspace_setup_target.dart';

/// Origin of a setup action offered by the product workspace.
enum ProductWorkspaceSetupActionSource {
  recommendation,
  fallback,
  inactiveTarget,
}

/// Navigation or activation command offered for a product setup target.
class ProductWorkspaceSetupAction {
  const ProductWorkspaceSetupAction({
    required this.targetId,
    required this.label,
    required this.routePath,
    required this.source,
    this.activation,
  });

  final String targetId;
  final String label;
  final String routePath;
  final ProductWorkspaceSetupActionSource source;
  final ProductWorkspaceSetupActivation? activation;

  ProductManagementPackId? get activationPackId => activation?.packId;
  String? get activationPackTitle => activation?.packTitle;
  bool get hasActivationPack => activation != null;
  String? get activationFeedbackMessage {
    if (!hasActivationPack) return null;

    final normalizedTitle = activationPackTitle?.trim();
    if (normalizedTitle == null || normalizedTitle.isEmpty) return null;

    return '$normalizedTitle activated for setup.';
  }

  bool get usesRecommendation {
    return source == ProductWorkspaceSetupActionSource.recommendation;
  }

  bool get usesFallback {
    return source == ProductWorkspaceSetupActionSource.fallback;
  }

  bool get usesInactiveTarget {
    return source == ProductWorkspaceSetupActionSource.inactiveTarget;
  }

  static ProductWorkspaceSetupAction resolve({
    required ProductWorkspaceSetupTarget target,
    required List<ProductWorkspaceRecommendation> recommendations,
    List<ProductWorkspaceSetupActivation> activations = const [],
    ProductWorkspaceSetupTargetAvailability availability =
        ProductWorkspaceSetupTargetAvailability.active,
    String fallbackRoutePath = ProductRoutes.catalogPath,
  }) {
    if (availability == ProductWorkspaceSetupTargetAvailability.inactive) {
      final activation = _activationFor(target, activations);
      return ProductWorkspaceSetupAction(
        targetId: target.normalizedId,
        label:
            activation == null
                ? 'Review product pack'
                : 'Switch to ${activation.packTitle}',
        routePath: ProductRoutes.workspacePath,
        source: ProductWorkspaceSetupActionSource.inactiveTarget,
        activation: activation,
      );
    }

    final recommendation = _recommendationFor(target, recommendations);
    if (recommendation != null) {
      return ProductWorkspaceSetupAction(
        targetId: target.normalizedId,
        label: _actionLabelFor(target, recommendation),
        routePath: recommendation.routePath!.trim(),
        source: ProductWorkspaceSetupActionSource.recommendation,
      );
    }

    return ProductWorkspaceSetupAction(
      targetId: target.normalizedId,
      label: _actionLabelFor(target, null),
      routePath: _fallbackRoutePath(fallbackRoutePath),
      source: ProductWorkspaceSetupActionSource.fallback,
    );
  }

  static ProductWorkspaceRecommendation? _recommendationFor(
    ProductWorkspaceSetupTarget target,
    List<ProductWorkspaceRecommendation> recommendations,
  ) {
    final recommendationId = target.recommendationId?.trim();
    if (recommendationId == null || recommendationId.isEmpty) return null;

    for (final recommendation in recommendations) {
      if (recommendation.id.trim() == recommendationId &&
          recommendation.canNavigate) {
        return recommendation;
      }
    }

    return null;
  }

  static ProductWorkspaceSetupActivation? _activationFor(
    ProductWorkspaceSetupTarget target,
    List<ProductWorkspaceSetupActivation> activations,
  ) {
    final targetId = target.normalizedId;
    if (targetId.isEmpty) return null;

    for (final activation in activations) {
      if (activation.targetId.trim() == targetId) return activation;
    }

    return null;
  }
}

/// Resolves the best setup action for active, inactive, or custom targets.
class ProductWorkspaceSetupActionResolver {
  const ProductWorkspaceSetupActionResolver({
    required this.recommendations,
    this.activations = const [],
    this.fallbackRoutePath = ProductRoutes.catalogPath,
  });

  final List<ProductWorkspaceRecommendation> recommendations;
  final List<ProductWorkspaceSetupActivation> activations;
  final String fallbackRoutePath;

  ProductWorkspaceSetupAction resolve(ProductWorkspaceSetupTarget target) {
    return ProductWorkspaceSetupAction.resolve(
      target: target,
      recommendations: recommendations,
      activations: activations,
      fallbackRoutePath: fallbackRoutePath,
    );
  }

  ProductWorkspaceSetupPrompt promptFor(
    ProductWorkspaceSetupTarget target, {
    ProductWorkspaceSetupTargetAvailability availability =
        ProductWorkspaceSetupTargetAvailability.active,
  }) {
    return ProductWorkspaceSetupPrompt(
      target: target,
      action: ProductWorkspaceSetupAction.resolve(
        target: target,
        recommendations: recommendations,
        activations: activations,
        availability: availability,
        fallbackRoutePath: fallbackRoutePath,
      ),
      availability: availability,
    );
  }

  ProductWorkspaceSetupPrompt promptForResolution(
    ProductWorkspaceSetupTargetResolution resolution,
  ) {
    return promptFor(resolution.target, availability: resolution.availability);
  }
}

/// Presentation-ready setup prompt combining a target with its action state.
class ProductWorkspaceSetupPrompt {
  const ProductWorkspaceSetupPrompt({
    required this.target,
    required this.action,
    this.availability = ProductWorkspaceSetupTargetAvailability.active,
  });

  final ProductWorkspaceSetupTarget target;
  final ProductWorkspaceSetupAction action;
  final ProductWorkspaceSetupTargetAvailability availability;

  String get targetId => target.normalizedId;
  String get title {
    if (isInactive) return '${target.title} unavailable';

    return target.title;
  }

  String get subtitle {
    if (isInactive) {
      final activationTitle = action.activationPackTitle?.trim();
      if (activationTitle != null && activationTitle.isNotEmpty) {
        final focusLabel = action.activation?.packFocusLabel.trim();
        if (focusLabel != null && focusLabel.isNotEmpty) {
          return 'Switch to $activationTitle to activate this setup target. $focusLabel.';
        }

        return 'Switch to $activationTitle to activate this setup target.';
      }

      return 'This setup target is not active for the current product pack.';
    }

    return target.subtitle;
  }

  String get actionLabel => action.label;
  String get routePath => action.routePath;
  String get statusLabel {
    return switch (availability) {
      ProductWorkspaceSetupTargetAvailability.active => 'Active setup',
      ProductWorkspaceSetupTargetAvailability.inactive => 'Not in pack',
      ProductWorkspaceSetupTargetAvailability.custom => 'Custom setup',
    };
  }

  bool get usesRecommendation => action.usesRecommendation;
  bool get usesFallback => action.usesFallback;
  bool get isInactive {
    return availability == ProductWorkspaceSetupTargetAvailability.inactive;
  }

  bool get isCustom {
    return availability == ProductWorkspaceSetupTargetAvailability.custom;
  }
}

/// Pack activation metadata needed before a setup target can be opened.
class ProductWorkspaceSetupActivation {
  const ProductWorkspaceSetupActivation({
    required this.targetId,
    required this.packId,
    required this.packTitle,
    this.packFocusLabel = '',
  });

  final String targetId;
  final ProductManagementPackId packId;
  final String packTitle;
  final String packFocusLabel;
}

String _actionLabelFor(
  ProductWorkspaceSetupTarget target,
  ProductWorkspaceRecommendation? recommendation,
) {
  final targetLabel = target.actionLabel.trim();
  if (targetLabel.isNotEmpty) return targetLabel;

  final recommendationLabel = recommendation?.actionLabel.trim();
  if (recommendationLabel != null && recommendationLabel.isNotEmpty) {
    return recommendationLabel;
  }

  return 'Open setup';
}

String _fallbackRoutePath(String fallbackRoutePath) {
  final normalizedRoutePath = fallbackRoutePath.trim();
  return normalizedRoutePath.isEmpty
      ? ProductRoutes.catalogPath
      : normalizedRoutePath;
}
