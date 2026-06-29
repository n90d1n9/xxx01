import 'package:flutter/material.dart';
import '../models/proposal.dart';

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback onTap;
  final Widget? additionalInfo;

  const ProposalCard({
    Key? key,
    required this.proposal,
    required this.onTap,
    this.additionalInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    proposal.category,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proposal.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Funding Goal: \$${proposal.fundingGoal!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Expected Return: ${proposal.expectedReturn}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (additionalInfo != null) ...[
                const SizedBox(height: 8),
                additionalInfo!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
