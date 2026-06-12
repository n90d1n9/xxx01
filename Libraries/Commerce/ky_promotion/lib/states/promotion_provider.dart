// lib/state/promotion_state.dart
import 'package:flutter_riverpod/legacy.dart';
import '../models/by_any.dart';
import '../models/coupon.dart';
import '../models/promotion.dart';
import '../models/discount.dart';
import '../models/bogo.dart';
import '../models/bundling.dart';
import '../models/cashback.dart';
import '../models/loyalty.dart';
import '../models/customize.dart';
import '../models/enums.dart';

// State classes
class PromotionState {
  final List<Promotion> promotions;
  final bool isLoading;
  final String? errorMessage;

  PromotionState({
    this.promotions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PromotionState copyWith({
    List<Promotion>? promotions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PromotionState(
      promotions: promotions ?? this.promotions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PromotionFormState {
  final Promotion? basePromotion;
  final PromotionType selectedType;
  final bool isEditing;

  // Type-specific properties
  final Discount? discount;
  final Coupons? coupon;
  final Bogo? bogo;
  final Bundling? bundling;
  final Cashback? cashback;
  final Loyalty? loyalty;
  final Customize? customize;
  final BuyAnyWithAny? buyAnyWithAny;

  PromotionFormState({
    this.basePromotion,
    this.selectedType = PromotionType.Discount,
    this.isEditing = false,
    this.discount,
    this.coupon,
    this.bogo,
    this.bundling,
    this.cashback,
    this.loyalty,
    this.customize,
    this.buyAnyWithAny,
  });

  PromotionFormState copyWith({
    Promotion? basePromotion,
    PromotionType? selectedType,
    bool? isEditing,
    Discount? discount,
    Coupons? coupon,
    Bogo? bogo,
    Bundling? bundling,
    Cashback? cashback,
    Loyalty? loyalty,
    Customize? customize,
    BuyAnyWithAny? buyAnyWithAny,
  }) {
    return PromotionFormState(
      basePromotion: basePromotion ?? this.basePromotion,
      selectedType: selectedType ?? this.selectedType,
      isEditing: isEditing ?? this.isEditing,
      discount: discount ?? this.discount,
      coupon: coupon ?? this.coupon,
      bogo: bogo ?? this.bogo,
      bundling: bundling ?? this.bundling,
      cashback: cashback ?? this.cashback,
      loyalty: loyalty ?? this.loyalty,
      customize: customize ?? this.customize,
      buyAnyWithAny: buyAnyWithAny ?? this.buyAnyWithAny,
    );
  }

  // Reset promotion-specific data when type changes
  PromotionFormState resetTypeSpecificData(PromotionType newType) {
    return PromotionFormState(
      basePromotion: basePromotion,
      selectedType: newType,
      isEditing: isEditing,
    );
  }
}

// Providers
final promotionStateProvider =
    StateNotifierProvider<PromotionNotifier, PromotionState>((ref) {
      return PromotionNotifier();
    });

final promotionFormProvider =
    StateNotifierProvider<PromotionFormNotifier, PromotionFormState>((ref) {
      return PromotionFormNotifier();
    });

// Notifiers
class PromotionNotifier extends StateNotifier<PromotionState> {
  PromotionNotifier() : super(PromotionState());

  Future<void> fetchPromotions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      // TODO: Replace with actual API call
      final List<Promotion> promotions = []; // Get from repository
      state = state.copyWith(promotions: promotions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> savePromotion(Promotion promotion) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      // TODO: Replace with actual API call

      // Update local state
      final newPromotions = [...state.promotions];
      final index = newPromotions.indexWhere((p) => p.id == promotion.id);

      if (index >= 0) {
        newPromotions[index] = promotion;
      } else {
        newPromotions.add(promotion);
      }

      state = state.copyWith(promotions: newPromotions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deletePromotion(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      // TODO: Replace with actual API call

      final newPromotions = state.promotions.where((p) => p.id != id).toList();
      state = state.copyWith(promotions: newPromotions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void togglePromotionStatus(int id) {
    final newPromotions = [...state.promotions];
    final index = newPromotions.indexWhere((p) => p.id == id);

    if (index >= 0) {
      final promotion = newPromotions[index];
      newPromotions[index] = Promotion(
        id: promotion.id,
        type: promotion.type,
        originPrice: promotion.originPrice,
        promoPrice: promotion.promoPrice,
        isActive: !promotion.isActive,
        isRequirement: promotion.isRequirement,
        isRedeem: promotion.isRedeem,
        uri: promotion.uri,
      );

      state = state.copyWith(promotions: newPromotions);
    }
  }
}

class PromotionFormNotifier extends StateNotifier<PromotionFormState> {
  PromotionFormNotifier() : super(PromotionFormState());

  void setPromotionType(PromotionType type) {
    state = state.resetTypeSpecificData(type);
  }

  void initNewPromotion() {
    state = PromotionFormState(
      isEditing: false,
      selectedType: PromotionType.Discount,
      basePromotion: Promotion(
        id: 0, // Will be assigned by backend
        type: PromotionType.Discount,
        originPrice: 0.0,
        promoPrice: 0.0,
        isActive: false,
        isRequirement: false,
        isRedeem: false,
      ),
    );
  }

  void initEditPromotion(Promotion promotion) {
    state = PromotionFormState(
      isEditing: true,
      selectedType: promotion.type,
      basePromotion: promotion,
    );

    // Load type-specific data
    // This would be done after fetching the full promotion data
  }

  void updateBasePromotion({
    double? originPrice,
    double? promoPrice,
    bool? isActive,
    bool? isRequirement,
    bool? isRedeem,
    String? uri,
  }) {
    if (state.basePromotion == null) return;

    final updatedPromotion = Promotion(
      id: state.basePromotion!.id,
      type: state.selectedType,
      originPrice: originPrice ?? state.basePromotion!.originPrice,
      promoPrice: promoPrice ?? state.basePromotion!.promoPrice,
      isActive: isActive ?? state.basePromotion!.isActive,
      isRequirement: isRequirement ?? state.basePromotion!.isRequirement,
      isRedeem: isRedeem ?? state.basePromotion!.isRedeem,
      uri: uri ?? state.basePromotion!.uri,
    );

    state = state.copyWith(basePromotion: updatedPromotion);
  }

  // Type-specific update methods
  void updateDiscount({
    String? name,
    DiscountType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    double? value,
  }) {
    final currentDiscount =
        state.discount ??
        Discount(
          id: 0,
          name: '',
          type: DiscountType.Value,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          value: 0,
        );

    final updatedDiscount = Discount(
      id: currentDiscount.id,
      name: name ?? currentDiscount.name,
      type: type ?? currentDiscount.type,
      startDate: startDate ?? currentDiscount.startDate,
      endDate: endDate ?? currentDiscount.endDate,
      description: description ?? currentDiscount.description,
      value: value ?? currentDiscount.value,
    );

    state = state.copyWith(discount: updatedDiscount);
  }

  void updateCoupon({
    String? code,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    DiscountType? type,
    String? description,
  }) {
    final currentCoupon =
        state.coupon ??
        Coupons(
          code: '',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          value: 0,
          type: DiscountType.Value,
        );

    final updatedCoupon = Coupons(
      code: code ?? currentCoupon.code,
      startDate: startDate ?? currentCoupon.startDate,
      endDate: endDate ?? currentCoupon.endDate,
      value: value ?? currentCoupon.value,
      type: type ?? currentCoupon.type,
      description: description ?? currentCoupon.description,
    );

    state = state.copyWith(coupon: updatedCoupon);
  }

  // Similar update methods for other promotion types...

  Promotion? buildCompletePromotion() {
    if (state.basePromotion == null) return null;

    // The base promotion already has the common fields
    return state.basePromotion;

    // In a real implementation, you would need to combine the
    // basePromotion with the type-specific data and return
    // a complete promotion object that can be saved
  }
}
