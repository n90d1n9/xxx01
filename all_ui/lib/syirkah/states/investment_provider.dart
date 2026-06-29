import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment.dart';
import '../models/proposal.dart';

class InvestmentNotifier extends StateNotifier<List<Investment>> {
  InvestmentNotifier() : super([]);

  Future<void> createInvestment(Investment investment) async {
    state = [...state, investment];
  }

  Future<void> removeInvestment(String investmentId) async {
    state = state.where((inv) => inv.id != investmentId).toList();
  }

  List<Investment> getUserInvestments(String userId) {
    return state.where((investment) => investment.userId == userId).toList();
  }
}

final investmentProvider =
    StateNotifierProvider<InvestmentNotifier, List<Investment>>((ref) {
      return InvestmentNotifier();
    });
final userInvestmentsProvider = FutureProvider.family<List<Investment>, String>(
  (ref, userId) async {
    final investments = ref.watch(investmentProvider);
    return investments
        .where((investment) => investment.userId == userId)
        .toList();
  },
);
/* final userInvestmentsProvider = Provider.family<List<Investment>, String>((
  ref,
  userId,
) {
  final investments = ref.watch(investmentProvider);
  return investments
      .where((investment) => investment.userId == userId)
      .toList();
}); */
