import 'user.dart';

enum ProposalStatus { draft, published, funded, closed }

class Proposal {
  final String id;
  final String title;
  final String category;
  final String description;
  final User? partner;
  final double? fundingGoal;
  final double currentFunding;
  final List<String>? images;
  final DateTime createdAt;
  final String? status; //
  final Map<String, dynamic>? financialDetails;
  final Map<String, dynamic>? syirkahTerms;

  final String? expectedReturn;

  Proposal({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.partner,
    this.fundingGoal,
    this.currentFunding = 0.0,
    this.images,
    DateTime? createdAt,
    this.status,
    this.financialDetails,
    this.syirkahTerms,
    this.expectedReturn,
  }) : createdAt = DateTime.now();

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      partner: User.fromJson(json['partner']),
      fundingGoal: json['fundingGoal'],
      currentFunding: json['currentFunding'] ?? 0.0,
      images: List<String>.from(json['images']),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      financialDetails: Map<String, dynamic>.from(json['financialDetails']),
      syirkahTerms: Map<String, dynamic>.from(json['syirkahTerms']),
      expectedReturn: json['expectedReturn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'partner': partner!.toJson(),
      'fundingGoal': fundingGoal,
      'currentFunding': currentFunding,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'financialDetails': financialDetails,
      'syirkahTerms': syirkahTerms,
      'expectedReturn': expectedReturn,
    };
  }

  double get fundingPercentage => (currentFunding / fundingGoal!) * 100;

  bool get isFunded => status == 'funded' || status == 'closed';
}
