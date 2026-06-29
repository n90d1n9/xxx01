import 'user.dart';
import 'proposal.dart';

class Partnership {
  final String id;
  final Proposal proposal;
  final User investor;
  final double investmentAmount;
  final DateTime investmentDate;
  final String status; // 'active', 'completed', 'terminated'
  final Map<String, dynamic> contractDetails;

  var partner;

  Partnership({
    required this.id,
    required this.proposal,
    required this.investor,
    required this.investmentAmount,
    required this.investmentDate,
    required this.status,
    required this.contractDetails,
  });

  factory Partnership.fromJson(Map<String, dynamic> json) {
    return Partnership(
      id: json['id'],
      proposal: Proposal.fromJson(json['proposal']),
      investor: User.fromJson(json['investor']),
      investmentAmount: json['investmentAmount'],
      investmentDate: DateTime.parse(json['investmentDate']),
      status: json['status'],
      contractDetails: Map<String, dynamic>.from(json['contractDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proposal': proposal.toJson(),
      'investor': investor.toJson(),
      'investmentAmount': investmentAmount,
      'investmentDate': investmentDate.toIso8601String(),
      'status': status,
      'contractDetails': contractDetails,
    };
  }
}
