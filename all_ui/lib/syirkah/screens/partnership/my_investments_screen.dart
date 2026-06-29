import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/proposal.dart';
import '../../states/investment_provider.dart';
import '../../widgets/proposal_card.dart';
import '../proposal/proposal_detail_screen.dart';

class MyInvestmentsScreen extends ConsumerWidget {
  final String userId;

  const MyInvestmentsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(userInvestmentsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Investments'), centerTitle: true),
      body: investmentsAsync.when(
        data:
            (investments) =>
                investments.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: investments.length,
                      itemBuilder: (context, index) {
                        final investment = investments[index];
                        return ProposalCard(
                          proposal: investment.proposal,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProposalDetailScreen(
                                        proposalId: investment.proposal.id,
                                      ),
                                ),
                              ),
                          additionalInfo: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invested: \$${investment.amount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Status: ${investment.status}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading investments: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.abc, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Investments Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring and investing in exciting proposals',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to proposal list or marketplace
            },
            child: const Text('Explore Proposals'),
          ),
        ],
      ),
    );
  }
}
