import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/proposal_provider.dart';
import '../../widgets/filter_options.dart';
import '../../widgets/proposal_card.dart';
import 'proposal_detail_screen.dart';

class ProposalListScreen extends ConsumerWidget {
  const ProposalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              showModalBottomSheet(
                context: context,
                builder: (context) => const FilterOptionsSheet(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search proposals...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Category chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', true),
                    _buildCategoryChip('Technology', false),
                    _buildCategoryChip('Food & Beverage', false),
                    _buildCategoryChip('Education', false),
                    _buildCategoryChip('Healthcare', false),
                    _buildCategoryChip('E-commerce', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Proposals list
              Expanded(
                child: proposalsAsync.when(
                  data: (proposals) {
                    return ListView.builder(
                      itemCount: proposals.length,
                      itemBuilder: (context, index) {
                        final proposal = proposals[index];
                        return ProposalCard(
                          proposal: proposal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProposalDetailScreen(
                                      proposalId: proposal.id,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, stack) => Center(
                        child: Text(
                          'Error loading proposals: ${err.toString()}',
                          style: const TextStyle(color: Colors.red),
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

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
