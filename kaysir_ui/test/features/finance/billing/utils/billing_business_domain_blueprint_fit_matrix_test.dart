import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';

void main() {
  test('fit matrix compares standard billing product signals', () {
    final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
      BillingBusinessDomainBlueprintRegistry.forRegistry(
        standardBillingDomainModuleRegistry(),
      ),
    );

    final commerce = matrix.requireRowForDomain('commerce');
    final construction = matrix.requireRowForDomain('construction');
    final digital = matrix.requireRowForDomain('digital');

    expect(matrix.domainKeys, ['commerce', 'construction', 'digital']);
    expect(matrix.signalCount, 5);
    expect(matrix.supportedCellCount, 7);

    expect(
      commerce.supports(BillingBusinessDomainBlueprintFitSignal.checkout),
      isTrue,
    );
    expect(
      commerce.supports(BillingBusinessDomainBlueprintFitSignal.projects),
      isFalse,
    );
    expect(
      commerce
          .requireCell(BillingBusinessDomainBlueprintFitSignal.checkout)
          .detail,
      contains('Product catalog'),
    );

    expect(
      construction.supports(BillingBusinessDomainBlueprintFitSignal.projects),
      isTrue,
    );
    expect(
      construction.supports(BillingBusinessDomainBlueprintFitSignal.service),
      isTrue,
    );
    expect(
      construction.supports(
        BillingBusinessDomainBlueprintFitSignal.subscriptions,
      ),
      isFalse,
    );

    expect(
      digital.supports(BillingBusinessDomainBlueprintFitSignal.subscriptions),
      isTrue,
    );
    expect(
      digital.supports(BillingBusinessDomainBlueprintFitSignal.omniChannel),
      isTrue,
    );
    expect(
      digital
          .requireCell(BillingBusinessDomainBlueprintFitSignal.subscriptions)
          .detail,
      contains('Metered usage'),
    );
  });

  test('fit matrix returns normalized rows and missing row failures', () {
    final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
      BillingBusinessDomainBlueprintRegistry.forRegistry(
        standardBillingDomainModuleRegistry(),
      ),
    );

    expect(matrix.rowForDomain(' COMMERCE ')?.domainLabel, 'Commerce');
    expect(() => matrix.requireRowForDomain('service'), throwsStateError);
    expect(
      () => matrix
          .requireRowForDomain('commerce')
          .requireCell(BillingBusinessDomainBlueprintFitSignal.projects),
      returnsNormally,
    );
  });
}
