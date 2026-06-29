import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/proposal.dart';
import '../services/auth_service.dart';
import '../services/proposal_service.dart';

final proposalServiceProvider = Provider<ProposalService>((ref) {
  return ProposalService();
});

final proposalsProvider = FutureProvider<List<Proposal>>((ref) {
  final proposalService = ref.watch(proposalServiceProvider);
  return proposalService.getProposals();
});

final proposalDetailProvider = FutureProvider.family<Proposal, String>((
  ref,
  id,
) {
  final proposalService = ref.watch(proposalServiceProvider);
  return proposalService.getProposalById(id);
});

final proposalTemplateProvider = Provider<Map<String, dynamic>>((ref) {
  // Template for new proposals
  return {
    'title': '',
    'category': 'Technology',
    'description': '',
    'fundingGoal': 0.0,
    'images': <String>[],
    'financialDetails': {
      'expectedReturn': '',
      'timeframe': '',
      'initialCosts': 0,
      'operationalCosts': 0,
    },
    'syirkahTerms': {
      'profitSharingRatio': '50:50',
      'contractType': 'Musharakah',
      'termLength': '2 years',
      'exitTerms': '',
    },
  };
});

class ProposalNotifier extends StateNotifier<List<Proposal>> {
  final Ref ref;

  ProposalNotifier(this.ref) : super([]);

  Future<void> createProposal(Map<String, dynamic> proposalData) async {
    try {
      // Add user ID to the proposal data
      final currentUser = ref.read(currentUserProvider);
      proposalData['userId'] = currentUser?.id;

      // Create Proposal object
      final newProposal = Proposal(
        id: DateTime.now().toString(), // Simple unique ID generation
        title: proposalData['title'],
        description: proposalData['description'],
        category: proposalData['category'],
        fundingGoal: proposalData['fundingGoal'],
        expectedReturn: proposalData['expectedReturn'],
        // Add other fields as needed
      );

      // Update local state
      state = [...state, newProposal];
    } catch (e) {
      print('Error creating proposal: $e');
      throw Exception('Failed to create proposal');
    }
  }

  Future<void> saveDraftProposal(Map<String, dynamic> draftData) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      draftData['userId'] = currentUser?.id;
      draftData['status'] = 'draft';

      // Similar logic to create proposal, but marked as draft
      final draftProposal = Proposal(
        id: DateTime.now().toString(),
        title: draftData['title'],
        description: draftData['description'],
        category: draftData['category'],
        status: 'draft',
        // Add other relevant fields
      );

      state = [...state, draftProposal];
    } catch (e) {
      print('Error saving draft: $e');
      throw Exception('Failed to save draft');
    }
  }

  List<Proposal> fetchProposals({String? category}) {
    if (category != null) {
      return state.where((proposal) => proposal.category == category).toList();
    }
    return state;
  }

  Proposal getProposalById(String proposalId) {
    return state.firstWhere((proposal) => proposal.id == proposalId);
  }
}

final proposalProvider =
    StateNotifierProvider<ProposalNotifier, List<Proposal>>((ref) {
      return ProposalNotifier(ref);
    });

/* final proposalsProvider = Provider<List<Proposal>>((ref) {
  return ref.watch(proposalProvider);
});

final proposalDetailProvider = Provider.family<Proposal, String>((ref, proposalId) {
  return ref.read(proposalProvider.notifier).getProposalById(proposalId);
}); */
