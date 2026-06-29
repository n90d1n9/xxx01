import 'proposal.dart';

class Investment {
  final String id;
  final String userId;
  final Proposal proposal;
  final double amount;
  final String status;

  Investment({
    required this.id,
    required this.userId,
    required this.proposal,
    required this.amount,
    this.status = 'active',
  });
}
