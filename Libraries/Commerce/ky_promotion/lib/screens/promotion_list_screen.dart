import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/enums.dart';
import '../models/promotion.dart';
import '../states/promotion_provider.dart';
import 'promotion_form_screen.dart';
import 'promotion_list_item.dart';

class PromotionListScreen extends ConsumerStatefulWidget {
  const PromotionListScreen({super.key});

  @override
  ConsumerState<PromotionListScreen> createState() =>
      _PromotionListScreenState();
}

class _PromotionListScreenState extends ConsumerState<PromotionListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(promotionStateProvider.notifier).fetchPromotions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promotionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(promotionStateProvider.notifier).fetchPromotions(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text('Error: ${state.errorMessage}'))
          : state.promotions.isEmpty
          ? const Center(child: Text('No promotions found. Add one!'))
          : ListView.builder(
              itemCount: state.promotions.length,
              itemBuilder: (context, index) {
                final promotion = state.promotions[index];
                return PromotionListItem(
                  promotion: promotion,
                  onEdit: () => _navigateToEditScreen(promotion),
                  onToggleStatus: () => ref
                      .read(promotionStateProvider.notifier)
                      .togglePromotionStatus(promotion.id),
                  onDelete: () => _showDeleteConfirmation(promotion),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        child: const Icon(Icons.add),
        tooltip: 'Add Promotion',
      ),
    );
  }

  void _navigateToCreateScreen() {
    ref.read(promotionFormProvider.notifier).initNewPromotion();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PromotionFormScreen()),
    );
  }

  void _navigateToEditScreen(Promotion promotion) {
    ref.read(promotionFormProvider.notifier).initEditPromotion(promotion);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PromotionFormScreen()),
    );
  }

  void _showDeleteConfirmation(Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promotion'),
        content: const Text('Are you sure you want to delete this promotion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(promotionStateProvider.notifier)
                  .deletePromotion(promotion.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
