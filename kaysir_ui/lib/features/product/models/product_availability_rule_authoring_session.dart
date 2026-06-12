import 'product_availability_rule_authoring.dart';

class ProductAvailabilityRuleAuthoringSession {
  const ProductAvailabilityRuleAuthoringSession({
    required this.selectedSourceId,
    required this.selectedTemplateId,
    required this.selectedTarget,
  });

  static const defaults = ProductAvailabilityRuleAuthoringSession(
    selectedSourceId: productAvailabilityRuleTemplateAllSourceId,
    selectedTemplateId: ProductAvailabilityRuleTemplateId.counterService,
    selectedTarget: ProductAvailabilityRuleAuthoringTarget.unconfigured,
  );

  factory ProductAvailabilityRuleAuthoringSession.fromJson(
    Map<String, Object?> json,
  ) {
    return ProductAvailabilityRuleAuthoringSession(
      selectedSourceId:
          _nonEmptyString(json[_selectedSourceIdJsonKey]) ??
          defaults.selectedSourceId,
      selectedTemplateId: ProductAvailabilityRuleTemplateId(
        _nonEmptyString(json[_selectedTemplateIdJsonKey]) ??
            defaults.selectedTemplateId.value,
      ),
      selectedTarget:
          _targetFromJsonValue(json[_selectedTargetJsonKey]) ??
          defaults.selectedTarget,
    );
  }

  final String selectedSourceId;
  final ProductAvailabilityRuleTemplateId selectedTemplateId;
  final ProductAvailabilityRuleAuthoringTarget selectedTarget;

  bool get isDefault => this == defaults;

  ProductAvailabilityRuleAuthoringSession copyWith({
    String? selectedSourceId,
    ProductAvailabilityRuleTemplateId? selectedTemplateId,
    ProductAvailabilityRuleAuthoringTarget? selectedTarget,
  }) {
    return ProductAvailabilityRuleAuthoringSession(
      selectedSourceId: selectedSourceId ?? this.selectedSourceId,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      selectedTarget: selectedTarget ?? this.selectedTarget,
    );
  }

  Map<String, Object?> toJson() {
    return {
      _selectedSourceIdJsonKey: selectedSourceId,
      _selectedTemplateIdJsonKey: selectedTemplateId.value,
      _selectedTargetJsonKey: selectedTarget.name,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductAvailabilityRuleAuthoringSession &&
            other.selectedSourceId == selectedSourceId &&
            other.selectedTemplateId == selectedTemplateId &&
            other.selectedTarget == selectedTarget;
  }

  @override
  int get hashCode {
    return Object.hash(selectedSourceId, selectedTemplateId, selectedTarget);
  }
}

enum ProductAvailabilityRuleAuthoringSessionPersistencePhase {
  idle,
  hydrating,
  saving,
  saved,
  failed,
}

class ProductAvailabilityRuleAuthoringSessionPersistenceState {
  const ProductAvailabilityRuleAuthoringSessionPersistenceState({
    required this.phase,
    this.message,
  });

  static const idle = ProductAvailabilityRuleAuthoringSessionPersistenceState(
    phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.idle,
  );

  final ProductAvailabilityRuleAuthoringSessionPersistencePhase phase;
  final String? message;

  bool get isBusy {
    return phase ==
            ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating ||
        phase == ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving;
  }

  bool get hasFailed {
    return phase ==
        ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed;
  }

  String get label {
    if (message != null && message!.trim().isNotEmpty) {
      return message!.trim();
    }

    switch (phase) {
      case ProductAvailabilityRuleAuthoringSessionPersistencePhase.idle:
        return 'Ready';
      case ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating:
        return 'Loading session';
      case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving:
        return 'Saving session';
      case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved:
        return 'Session saved';
      case ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed:
        return 'Session save failed';
    }
  }
}

class ProductAvailabilityRuleAuthoringSessionSummary {
  const ProductAvailabilityRuleAuthoringSessionSummary({
    required this.sourceId,
    required this.sourceLabel,
    required this.sourceTemplateCount,
    required this.totalTemplateCount,
    required this.templateEntry,
    required this.target,
  });

  final String sourceId;
  final String sourceLabel;
  final int sourceTemplateCount;
  final int totalTemplateCount;
  final ProductAvailabilityRuleTemplateEntry? templateEntry;
  final ProductAvailabilityRuleAuthoringTarget target;

  ProductAvailabilityRuleTemplate? get template => templateEntry?.template;

  bool get isDefault {
    return sourceId == productAvailabilityRuleTemplateAllSourceId &&
        template?.id == ProductAvailabilityRuleTemplateId.counterService &&
        target == ProductAvailabilityRuleAuthoringTarget.unconfigured;
  }

  String get sessionLabel => isDefault ? 'Default session' : 'Custom session';

  String get sourceDisplayLabel {
    if (sourceId == productAvailabilityRuleTemplateAllSourceId) {
      return 'All templates';
    }

    return sourceLabel;
  }

  String get templateLabel => template?.title ?? 'No template';

  String get targetLabel {
    return productAvailabilityRuleAuthoringTargetTitle(target);
  }

  String get availableTemplateCountLabel {
    return _templateCountLabel(sourceTemplateCount, suffix: 'available');
  }

  String get totalTemplateCountLabel {
    return _templateCountLabel(totalTemplateCount, suffix: 'total');
  }
}

String _templateCountLabel(int count, {required String suffix}) {
  final templateLabel = count == 1 ? 'template' : 'templates';
  return '$count $templateLabel $suffix';
}

const _selectedSourceIdJsonKey = 'selectedSourceId';
const _selectedTemplateIdJsonKey = 'selectedTemplateId';
const _selectedTargetJsonKey = 'selectedTarget';

String? _nonEmptyString(Object? value) {
  if (value is! String) return null;

  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

ProductAvailabilityRuleAuthoringTarget? _targetFromJsonValue(Object? value) {
  final targetName = _nonEmptyString(value);
  if (targetName == null) return null;

  for (final target in ProductAvailabilityRuleAuthoringTarget.values) {
    if (target.name == targetName) return target;
  }

  return null;
}
