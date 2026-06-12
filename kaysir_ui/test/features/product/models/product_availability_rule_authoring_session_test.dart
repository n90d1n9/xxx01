import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring_session.dart';

void main() {
  test('availability authoring session serializes selected state', () {
    const session = ProductAvailabilityRuleAuthoringSession(
      selectedSourceId: 'freshness_availability_templates',
      selectedTemplateId: ProductAvailabilityRuleTemplateId.freshShelf,
      selectedTarget: ProductAvailabilityRuleAuthoringTarget.stockAttention,
    );

    expect(session.toJson(), {
      'selectedSourceId': 'freshness_availability_templates',
      'selectedTemplateId': 'fresh_shelf',
      'selectedTarget': 'stockAttention',
    });
    expect(
      ProductAvailabilityRuleAuthoringSession.fromJson(session.toJson()),
      session,
    );
  });

  test('availability authoring session falls back from incomplete json', () {
    final session = ProductAvailabilityRuleAuthoringSession.fromJson({
      'selectedSourceId': '  ',
      'selectedTemplateId': '',
      'selectedTarget': 'missing_target',
    });

    expect(session, ProductAvailabilityRuleAuthoringSession.defaults);
  });

  test('availability authoring session persistence state exposes labels', () {
    expect(
      ProductAvailabilityRuleAuthoringSessionPersistenceState.idle.label,
      'Ready',
    );
    expect(
      const ProductAvailabilityRuleAuthoringSessionPersistenceState(
        phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving,
      ).label,
      'Saving session',
    );
    expect(
      const ProductAvailabilityRuleAuthoringSessionPersistenceState(
        phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed,
        message: 'Custom failure',
      ).label,
      'Custom failure',
    );
  });
}
