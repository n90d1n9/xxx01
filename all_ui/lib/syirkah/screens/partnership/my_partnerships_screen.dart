import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/partnership.dart';
import '../../states/partnership_provider.dart';
import '../proposal/proposal_detail_screen.dart';

class MyPartnershipsScreen extends ConsumerWidget {
  final String userId;

  const MyPartnershipsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('---------------');
    print(this.userId);
    final partnershipsAsync = ref.watch(userPartnershipsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Partnerships'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create new partnership or proposal
            },
          ),
        ],
      ),
      body: partnershipsAsync.when(
        data:
            (partnerships) =>
                partnerships.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: partnerships.length,
                      itemBuilder: (context, index) {
                        final partnership = partnerships[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(partnership.proposal.title),
                            subtitle: Text(
                              'Partner: ${partnership.partner.name}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Text(
                              partnership.status,
                              style: TextStyle(
                                color: _getStatusColor(partnership.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProposalDetailScreen(
                                          proposalId: partnership.proposal.id,
                                        ),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading partnerships: $error')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.handshake_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Partnerships Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a proposal or join an existing partnership',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to create proposal screen
            },
            child: const Text('Create Proposal'),
          ),
        ],
      ),
    );
  }
}
