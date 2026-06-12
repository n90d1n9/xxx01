import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/enums.dart';
import '../states/promotion_provider.dart';
import '../widgets/customize_forrm.dart';
import '../widgets/discount_form.dart';
import '../widgets/coupon_form.dart';
import '../widgets/bogo_form.dart';
import '../widgets/bundling_form.dart';
import '../widgets/loyalty_form.dart';
import '../widgets/cashback_form.dart';

class PromotionFormScreen extends ConsumerWidget {
  const PromotionFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(promotionFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formState.isEditing ? 'Edit Promotion' : 'Create Promotion',
        ),
        actions: [
          TextButton(
            onPressed: () => _savePromotion(context, ref),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(context, ref, formState),
            const SizedBox(height: 24),
            _buildPromotionTypeSelector(context, ref, formState),
            const SizedBox(height: 24),
            _buildTypeSpecificForm(formState),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    WidgetRef ref,
    PromotionFormState formState,
  ) {
    final basePromotion = formState.basePromotion;
    if (basePromotion == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: basePromotion.originPrice.toString(),
              decoration: const InputDecoration(
                labelText: 'Original Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateBasePromotion(
                        originPrice: double.tryParse(value) ?? 0.0,
                      );
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: basePromotion.promoPrice.toString(),
              decoration: const InputDecoration(
                labelText: 'Promotional Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .updateBasePromotion(
                        promoPrice: double.tryParse(value) ?? 0.0,
                      );
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: basePromotion.uri ?? '',
              decoration: const InputDecoration(
                labelText: 'Promotion URL/URI (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateBasePromotion(uri: value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    value: basePromotion.isActive,
                    onChanged: (value) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateBasePromotion(isActive: value);
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Has Requirements'),
                    value: basePromotion.isRequirement,
                    onChanged: (value) {
                      ref
                          .read(promotionFormProvider.notifier)
                          .updateBasePromotion(isRequirement: value);
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Redeemable'),
              value: basePromotion.isRedeem ?? false,
              onChanged: (value) {
                ref
                    .read(promotionFormProvider.notifier)
                    .updateBasePromotion(isRedeem: value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionTypeSelector(
    BuildContext context,
    WidgetRef ref,
    PromotionFormState formState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promotion Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PromotionType>(
              value: formState.selectedType,
              decoration: const InputDecoration(
                labelText: 'Select Promotion Type',
                border: OutlineInputBorder(),
              ),
              items: PromotionType.values.map((type) {
                return DropdownMenuItem<PromotionType>(
                  value: type,
                  child: Text(_getPromotionTypeLabel(type)),
                );
              }).toList(),
              onChanged: (newType) {
                if (newType != null) {
                  ref
                      .read(promotionFormProvider.notifier)
                      .setPromotionType(newType);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificForm(PromotionFormState formState) {
    switch (formState.selectedType) {
      case PromotionType.Discount:
        return DiscountForm(discount: formState.discount);
      case PromotionType.Coupons:
        return CouponForm(coupon: formState.coupon);
      case PromotionType.Bogo:
        return BogoForm(bogo: formState.bogo);
      case PromotionType.Bundling:
        return BundlingForm(bundling: formState.bundling);
      case PromotionType.Loyalty:
        return LoyaltyForm(loyalty: formState.loyalty);
      case PromotionType.cashback:
        return CashbackForm(cashback: formState.cashback);
      case PromotionType.Customize:
        return CustomizeForm(customize: formState.customize);
      default:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Form for this promotion type not implemented yet.'),
          ),
        );
    }
  }

  String _getPromotionTypeLabel(PromotionType type) {
    switch (type) {
      case PromotionType.Discount:
        return 'Discount';
      case PromotionType.Coupons:
        return 'Coupons';
      case PromotionType.Bogo:
        return 'Buy One Get One (BOGO)';
      case PromotionType.Bundling:
        return 'Bundling';
      case PromotionType.Loyalty:
        return 'Loyalty Program';
      case PromotionType.cashback:
        return 'Cashback';
      case PromotionType.Customize:
        return 'Custom Promotion';
      case PromotionType.Point:
        return 'Point Achievement';
      case PromotionType.Flash_Sale:
        return 'Flash Sale';
      case PromotionType.Free_Shipping:
        return 'Free Shipping';
      default:
        return type.toString().split('.').last;
    }
  }

  void _savePromotion(BuildContext context, WidgetRef ref) {
    final formState = ref.read(promotionFormProvider);
    final promotion = formState.basePromotion;

    if (promotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Cannot save promotion')),
      );
      return;
    }

    ref.read(promotionStateProvider.notifier).savePromotion(promotion);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formState.isEditing
              ? 'Promotion updated successfully'
              : 'Promotion created successfully',
        ),
      ),
    );
  }
}
