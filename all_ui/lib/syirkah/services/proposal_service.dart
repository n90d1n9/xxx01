import '../models/proposal.dart';
import '../models/user.dart';

// Mock proposal service
class ProposalService {
  Future<List<Proposal>> getProposals() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      Proposal(
        id: 'prop1',
        title: 'Ethical Social Media Platform',
        category: 'Technology',
        description:
            'A social media platform following Islamic ethical guidelines, focusing on community building and authentic connections without inappropriate content.',
        partner: User(
          id: 'user456',
          name: 'Fatima Hassan',
          email: 'fatima@example.com',
          userType: 'partner',
          profileImage: 'https://example.com/fatima.jpg',
        ),
        fundingGoal: 50000,
        currentFunding: 15000,
        images: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        status: 'published',
        financialDetails: {
          'expectedReturn': '25%',
          'timeframe': '24 months',
          'initialCosts': 20000,
          'operationalCosts': 5000,
        },
        syirkahTerms: {
          'profitSharingRatio': '60:40', // Partner:Investor
          'contractType': 'Musharakah',
          'termLength': '3 years',
          'exitTerms': 'Mutually agreed valuation',
        },
      ),
      Proposal(
        id: 'prop2',
        title: 'Halal Food Delivery App',
        category: 'Food & Beverage',
        description:
            'An app connecting users with verified halal food vendors and offering efficient delivery services.',
        partner: User(
          id: 'user789',
          name: 'Muhammad Yusuf',
          email: 'muhammad@example.com',
          userType: 'partner',
          profileImage: 'https://example.com/muhammad.jpg',
        ),
        fundingGoal: 35000,
        currentFunding: 30000,
        images: [
          'https://example.com/food1.jpg',
          'https://example.com/food2.jpg',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        status: 'published',
        financialDetails: {
          'expectedReturn': '20%',
          'timeframe': '18 months',
          'initialCosts': 15000,
          'operationalCosts': 3000,
        },
        syirkahTerms: {
          'profitSharingRatio': '50:50', // Partner:Investor
          'contractType': 'Mudarabah',
          'termLength': '2 years',
          'exitTerms': 'Option to buy out at market value',
        },
      ),
      Proposal(
        id: 'prop3',
        title: 'Halal Food Delivery App',
        category: 'Food & Beverage',
        description:
            'An app connecting users with verified halal food vendors and offering efficient delivery services.',
        partner: User(
          id: 'user123',
          name: 'Muhammad Yusuf',
          email: 'muhammad@example.com',
          userType: 'partner',
          profileImage: 'https://example.com/muhammad.jpg',
        ),
        fundingGoal: 35000,
        currentFunding: 30000,
        images: [
          'https://example.com/food1.jpg',
          'https://example.com/food2.jpg',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        status: 'published',
        financialDetails: {
          'expectedReturn': '20%',
          'timeframe': '18 months',
          'initialCosts': 15000,
          'operationalCosts': 3000,
        },
        syirkahTerms: {
          'profitSharingRatio': '50:50', // Partner:Investor
          'contractType': 'Mudarabah',
          'termLength': '2 years',
          'exitTerms': 'Option to buy out at market value',
        },
      ),
    ];
  }

  Future<Proposal> getProposalById(String id) async {
    final proposals = await getProposals();
    return proposals.firstWhere((p) => p.id == id);
  }

  Future<Proposal> createProposal(Proposal proposal) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return proposal;
  }
}
