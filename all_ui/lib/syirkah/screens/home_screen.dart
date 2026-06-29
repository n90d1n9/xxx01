import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../widgets/dashboard_card.dart';
import 'partnership/my_investments_screen.dart';
import 'partnership/my_partnerships_screen.dart';
import 'proposal/create_proposal_screen.dart';
import 'proposal/proposal_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isInvestor = currentUser?.userType == 'investor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syirkah Partnership'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
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
              // Greeting and User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        currentUser?.profileImage != null
                            ? NetworkImage(currentUser!.profileImage!)
                            : null,
                    child:
                        currentUser?.profileImage == null
                            ? Text(
                              currentUser?.name.substring(0, 1) ?? 'U',
                              style: const TextStyle(fontSize: 24),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamu Alaikum, ${currentUser?.name ?? 'User'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isInvestor ? 'Investor Account' : 'Partner Account',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Dashboard Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Browse Proposals Card
                    DashboardCard(
                      title: 'Browse Projects',
                      icon: Icons.search,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProposalListScreen(),
                          ),
                        );
                      },
                    ),

                    // My Investments / My Projects Card
                    DashboardCard(
                      title: isInvestor ? 'My Investments' : 'My Projects',
                      icon: isInvestor ? Icons.attach_money : Icons.business,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    !isInvestor
                                        ? MyInvestmentsScreen(
                                          userId: currentUser!.id,
                                        )
                                        : MyPartnershipsScreen(
                                          userId: currentUser!.id,
                                        ),
                          ),
                        );
                      },
                    ),
                    // Create Proposal Card (for partners only)
                    if (!isInvestor)
                      DashboardCard(
                        title: 'Create Proposal',
                        icon: Icons.add_circle,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const CreateProposalScreen(),
                            ),
                          );
                        },
                      ),

                    // Profile / Settings Card
                    DashboardCard(
                      title: 'My Profile',
                      icon: Icons.person,
                      color: Colors.purple,
                      onTap: () {
                        // Navigate to profile screen
                      },
                    ),

                    // Islamic Finance Guide Card
                    DashboardCard(
                      title: 'Finance Guide',
                      icon: Icons.book,
                      color: Colors.teal,
                      onTap: () {
                        // Navigate to Islamic finance guide
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
