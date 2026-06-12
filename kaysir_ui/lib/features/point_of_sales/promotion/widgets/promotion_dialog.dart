import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../../cashier/utils/pos_error_copy.dart';
import '../../order/states/current_order_provider.dart';
import '../models/promotion.dart';
import '../states/promotion_provider.dart';
import '../utils/promotion_policy.dart';
import 'promotion_card.dart';
import 'promotion_code_entry.dart';

class PromotionDialog extends ConsumerStatefulWidget {
  const PromotionDialog({super.key});

  @override
  ConsumerState<PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends ConsumerState<PromotionDialog> {
  final TextEditingController _codeController = TextEditingController();
  String? _feedback;
  bool _feedbackIsError = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promotionsAsync = ref.watch(promotionsProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const POSIconBadge(icon: Icons.local_offer_outlined),
                  const SizedBox(width: POSUiTokens.gapLarge),
                  Expanded(
                    child: Text(
                      'Promotions',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PromotionCodeEntry(
                controller: _codeController,
                message: _feedback,
                isError: _feedbackIsError,
                onChanged: (_) => _clearFeedback(),
                onApplyCode:
                    () => _applyCode(
                      promotionsAsync.maybeWhen(
                        data: (promotions) => promotions,
                        orElse: () => null,
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: promotionsAsync.when(
                  data: (promotions) {
                    final sorted = sortPromotionsForPOS(
                      promotions,
                      DateTime.now(),
                    );
                    if (sorted.isEmpty) {
                      return const POSEmptyState(
                        icon: Icons.local_offer_outlined,
                        title: 'No active promotions',
                        message: 'Available promotions will appear here.',
                      );
                    }

                    final appliedIds = appliedPromotionIds(
                      currentOrder?.appliedPromotions ?? const [],
                    );

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: sorted.length,
                      separatorBuilder:
                          (_, _) => const SizedBox(height: POSUiTokens.gap),
                      itemBuilder: (context, index) {
                        final promotion = sorted[index];
                        final availability = resolvePromotionAvailability(
                          promotion: promotion,
                          appliedIds: appliedIds,
                          now: DateTime.now(),
                        );

                        return PromotionCard(
                          promotion: promotion,
                          availability: availability,
                          onApply: () => _applyPromotion(promotion),
                          onRemove: () => _removePromotion(promotion),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) => POSEmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'Promotions unavailable',
                        message: friendlyPOSErrorMessage(
                          error,
                          fallbackMessage:
                              'Promotions could not be loaded. Check the connection and retry.',
                        ),
                        action: POSActionButton(
                          icon: const Icon(Icons.refresh),
                          label: 'Retry',
                          onPressed: () => ref.invalidate(promotionsProvider),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCode(List<Promotion>? promotions) {
    final code = _codeController.text;
    if (normalizePromotionCode(code).isEmpty) {
      _setFeedback('Enter a promo code.', isError: true);
      return;
    }

    if (promotions == null) {
      _setFeedback('Promotions are still loading.', isError: true);
      return;
    }

    final promotion = findPromotionByCode(promotions, code);
    if (promotion == null) {
      _setFeedback(
        'No promotion found for ${normalizePromotionCode(code)}.',
        isError: true,
      );
      return;
    }

    final currentOrder = ref.read(currentOrderProvider);
    final availability = resolvePromotionAvailability(
      promotion: promotion,
      appliedIds: appliedPromotionIds(
        currentOrder?.appliedPromotions ?? const [],
      ),
      now: DateTime.now(),
    );

    switch (availability) {
      case PromotionAvailability.available:
        _applyPromotion(promotion, fromCode: true);
      case PromotionAvailability.applied:
        _setFeedback('${promotion.code} is already applied.', isError: true);
      case PromotionAvailability.inactive:
        _setFeedback('${promotion.code} is not active.', isError: true);
      case PromotionAvailability.expired:
        _setFeedback('${promotion.code} has expired.', isError: true);
    }
  }

  void _applyPromotion(Promotion promotion, {bool fromCode = false}) {
    final currentOrder = ref.read(currentOrderProvider);
    if (currentOrder == null) {
      _setFeedback(
        'Start an order before applying a promotion.',
        isError: true,
      );
      return;
    }

    ref.read(currentOrderProvider.notifier).applyPromotion(promotion);
    if (fromCode) _codeController.clear();
    _setFeedback('${promotion.code} applied.', isError: false);
  }

  void _removePromotion(Promotion promotion) {
    ref.read(currentOrderProvider.notifier).removePromotion(promotion.id);
    _setFeedback('${promotion.code} removed.', isError: false);
  }

  void _clearFeedback() {
    if (_feedback == null) return;
    setState(() {
      _feedback = null;
      _feedbackIsError = false;
    });
  }

  void _setFeedback(String message, {required bool isError}) {
    setState(() {
      _feedback = message;
      _feedbackIsError = isError;
    });
  }
}
