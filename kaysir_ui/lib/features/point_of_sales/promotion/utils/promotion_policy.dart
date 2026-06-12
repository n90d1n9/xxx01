import '../models/promotion.dart';

enum PromotionAvailability { available, applied, inactive, expired }

String normalizePromotionCode(String code) {
  return code.trim().toUpperCase();
}

bool promotionCodeMatches(Promotion promotion, String code) {
  return normalizePromotionCode(promotion.code) == normalizePromotionCode(code);
}

Promotion? findPromotionByCode(List<Promotion> promotions, String code) {
  final normalizedCode = normalizePromotionCode(code);
  if (normalizedCode.isEmpty) return null;

  for (final promotion in promotions) {
    if (normalizePromotionCode(promotion.code) == normalizedCode) {
      return promotion;
    }
  }

  return null;
}

Set<String> appliedPromotionIds(Iterable<Promotion> promotions) {
  return promotions.map((promotion) => promotion.id).toSet();
}

bool isPromotionExpired(Promotion promotion, DateTime now) {
  return promotion.validUntil.isBefore(DateTime(now.year, now.month, now.day));
}

PromotionAvailability resolvePromotionAvailability({
  required Promotion promotion,
  required Set<String> appliedIds,
  required DateTime now,
}) {
  if (appliedIds.contains(promotion.id)) {
    return PromotionAvailability.applied;
  }
  if (!promotion.isActive) return PromotionAvailability.inactive;
  if (isPromotionExpired(promotion, now)) return PromotionAvailability.expired;
  return PromotionAvailability.available;
}

List<Promotion> sortPromotionsForPOS(List<Promotion> promotions, DateTime now) {
  final sorted = [...promotions];
  sorted.sort((a, b) {
    final aActive = a.isActive && !isPromotionExpired(a, now);
    final bActive = b.isActive && !isPromotionExpired(b, now);
    if (aActive != bActive) return aActive ? -1 : 1;
    return a.validUntil.compareTo(b.validUntil);
  });
  return sorted;
}

String promotionBenefitLabel(Promotion promotion) {
  final parts = <String>[];
  if (promotion.discountPercentage > 0) {
    parts.add('${_trimDecimal(promotion.discountPercentage)}%');
  }
  if (promotion.discountAmount > 0) {
    parts.add('Rp ${promotion.discountAmount.round()}');
  }
  if (parts.isEmpty) return 'No discount';
  return '${parts.join(' + ')} off';
}

String promotionAvailabilityLabel(PromotionAvailability availability) {
  switch (availability) {
    case PromotionAvailability.available:
      return 'Available';
    case PromotionAvailability.applied:
      return 'Applied';
    case PromotionAvailability.inactive:
      return 'Inactive';
    case PromotionAvailability.expired:
      return 'Expired';
  }
}

String formatPromotionDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _trimDecimal(double value) {
  if (value % 1 == 0) return value.round().toString();
  return value.toStringAsFixed(1);
}
