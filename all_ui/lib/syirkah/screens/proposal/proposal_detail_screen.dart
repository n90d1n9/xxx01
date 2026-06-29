import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../states/proposal_provider.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String proposalId;

  const ProposalDetailScreen({super.key, required this.proposalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalAsync = ref.watch(proposalDetailProvider(proposalId));
    final currentUser = ref.watch(currentUserProvider);
    final isInvestor = currentUser?.userType == 'investor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Bookmark functionality
            },
          ),
        ],
      ),
      body: proposalAsync.when(
        data: (proposal) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project images
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: proposal.images!.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            proposal.images![index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and category
                          Text(
                            proposal.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              proposal.category,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Funding progress
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${proposal.currentFunding.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${proposal.fundingPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: proposal.fundingPercentage / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'of \$${proposal.fundingGoal!.toStringAsFixed(0)} goal',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Partner info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    proposal.partner!.profileImage != null
                                        ? NetworkImage(
                                          proposal.partner!.profileImage!,
                                        )
                                        : null,
                                child:
                                    proposal.partner!.profileImage == null
                                        ? Text(
                                          proposal.partner!.name.substring(
                                            0,
                                            1,
                                          ),
                                          style: const TextStyle(fontSize: 20),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proposal.partner!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Project Partner',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Tabs for different sections
                          DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                const TabBar(
                                  tabs: [
                                    Tab(text: 'Description'),
                                    Tab(text: 'Financial'),
                                    Tab(text: 'Syirkah Terms'),
                                  ],
                                  labelColor: Colors.green,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Colors.green,
                                ),
                                SizedBox(
                                  height: 300,
                                  child: TabBarView(
                                    children: [
                                      // Description tab
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Text(proposal.description),
                                      ),

                                      // Financial details tab
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            _buildDetailRow(
                                              'Expected Return',
                                              proposal
                                                  .financialDetails!['expectedReturn'],
                                            ),
                                            _buildDetailRow(
                                              'Timeframe',
                                              proposal
                                                  .financialDetails!['timeframe'],
                                            ),
                                            _buildDetailRow(
                                              'Initial Costs',
                                              '\$${proposal.financialDetails!['initialCosts']}',
                                            ),
                                            _buildDetailRow(
                                              'Operational Costs',
                                              '\$${proposal.financialDetails!['operationalCosts']} monthly',
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Syirkah terms tab
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            _buildDetailRow(
                                              'Contract Type',
                                              proposal
                                                  .syirkahTerms!['contractType'],
                                            ),
                                            _buildDetailRow(
                                              'Profit Sharing Ratio',
                                              proposal
                                                  .syirkahTerms!['profitSharingRatio'],
                                            ),
                                            _buildDetailRow(
                                              'Term Length',
                                              proposal
                                                  .syirkahTerms!['termLength'],
                                            ),
                                            _buildDetailRow(
                                              'Exit Terms',
                                              proposal
                                                  .syirkahTerms!['exitTerms'],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add space at the bottom for the button
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Invest button at the bottom
              if (isInvestor)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showInvestDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Invest Now'),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                'Error loading proposal: ${err.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showInvestDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invest in this Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Investment Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'By investing, you agree to the syirkah contract terms and conditions outlined in the proposal.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Investment submitted successfully!'),
                      ),
                    );
                  },
                  child: const Text('Confirm Investment'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
