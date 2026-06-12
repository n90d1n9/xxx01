import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/promotion/models/promotion.dart';
import 'package:kaysir/features/point_of_sales/promotion/utils/promotion_policy.dart';

void main() {
  test('findPromotionByCode trims and ignores case', () {
    final promotion = _promotion(code: 'WELCOME15');

    expect(findPromotionByCode([promotion], ' welcome15 '), promotion);
    expect(findPromotionByCode([promotion], 'missing'), isNull);
  });

  test(
    'resolvePromotionAvailability distinguishes applied and expired promos',
    () {
      final now = DateTime(2026, 5, 30);
      final promotion = _promotion(id: 'promo', validUntil: now);

      expect(
        resolvePromotionAvailability(
          promotion: promotion,
          appliedIds: {'promo'},
          now: now,
        ),
        PromotionAvailability.applied,
      );

      expect(
        resolvePromotionAvailability(
          promotion: _promotion(validUntil: DateTime(2026, 5, 29)),
          appliedIds: const {},
          now: now,
        ),
        PromotionAvailability.expired,
      );
    },
  );

  test('sortPromotionsForPOS prioritizes active valid promotions', () {
    final now = DateTime(2026, 5, 30);
    final expired = _promotion(
      id: 'expired',
      validUntil: DateTime(2026, 5, 29),
    );
    final later = _promotion(id: 'later', validUntil: DateTime(2026, 6, 4));
    final sooner = _promotion(id: 'sooner', validUntil: DateTime(2026, 5, 31));

    final sorted = sortPromotionsForPOS([expired, later, sooner], now);

    expect(sorted.map((promotion) => promotion.id), [
      'sooner',
      'later',
      'expired',
    ]);
  });

  test('promotionBenefitLabel combines percentage and amount discounts', () {
    expect(
      promotionBenefitLabel(
        _promotion(discountPercentage: 10, discountAmount: 5000),
      ),
      '10% + Rp 5000 off',
    );
  });
}

Promotion _promotion({
  String id = 'promo',
  String code = 'PROMO',
  double discountPercentage = 10,
  double discountAmount = 0,
  bool isActive = true,
  DateTime? validUntil,
}) {
  return Promotion(
    id: id,
    name: 'Promotion',
    code: code,
    discountPercentage: discountPercentage,
    discountAmount: discountAmount,
    isActive: isActive,
    validUntil: validUntil ?? DateTime(2026, 6, 1),
  );
}
