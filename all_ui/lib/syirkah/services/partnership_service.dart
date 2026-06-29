import '../models/partnership.dart';
import '../models/proposal.dart';
import '../models/user.dart';

// Mock partnership service
class PartnershipService {
  Future<List<Partnership>> getPartnerships(String userId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      Partnership(
        id: 'part1',
        proposal: Proposal(
          id: 'prop1',
          title: 'Ethical Social Media Platform',
          category: 'Technology',
          description:
              'A social media platform following Islamic ethical guidelines.',
          partner: User(
            id: 'user456',
            name: 'Fatima Hassan',
            email: 'fatima@example.com',
            userType: 'partner',
          ),
          fundingGoal: 50000,
          currentFunding: 15000,
          images: ['https://example.com/image1.jpg'],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          status: 'published',
          financialDetails: {'expectedReturn': '25%', 'timeframe': '24 months'},
          syirkahTerms: {
            'profitSharingRatio': '60:40',
            'contractType': 'Musharakah',
          },
        ),
        investor: User(
          id: 'user123',
          name: 'Ahmed Ali',
          email: 'ahmed@example.com',
          userType: 'investor',
        ),
        investmentAmount: 15000,
        investmentDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'active',
        contractDetails: {
          'contractDate':
              DateTime.now()
                  .subtract(const Duration(days: 10))
                  .toIso8601String(),
          'signedBy': ['Ahmed Ali', 'Fatima Hassan'],
          'paymentMethod': 'Bank Transfer',
        },
      ),
    ];
  }

  Future<Partnership> createPartnership(
    Proposal proposal,
    User investor,
    double amount,
  ) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return Partnership(
      id: 'new_part_${DateTime.now().millisecondsSinceEpoch}',
      proposal: proposal,
      investor: investor,
      investmentAmount: amount,
      investmentDate: DateTime.now(),
      status: 'active',
      contractDetails: {
        'contractDate': DateTime.now().toIso8601String(),
        'signedBy': [investor.name, proposal.partner!.name],
        'paymentMethod': 'Bank Transfer',
      },
    );
  }
}
