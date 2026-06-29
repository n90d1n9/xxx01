import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for leaderboard entries
class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final int score;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.rank,
    this.isCurrentUser = false,
  });
}

// Providers
final leaderboardProvider = StateNotifierProvider<
  LeaderboardNotifier,
  AsyncValue<List<LeaderboardEntry>>
>((ref) {
  return LeaderboardNotifier();
});

final filterProvider = StateProvider<LeaderboardFilter>(
  (ref) => LeaderboardFilter.global,
);

enum LeaderboardFilter { global, friends, weekly }

// Notifier to manage leaderboard state
class LeaderboardNotifier
    extends StateNotifier<AsyncValue<List<LeaderboardEntry>>> {
  LeaderboardNotifier() : super(const AsyncValue.loading()) {
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    state = const AsyncValue.loading();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate API response - in a real app, replace with actual API call
      final entries = [
        LeaderboardEntry(
          id: '1',
          name: 'Alex Johnson',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          score: 9850,
          rank: 1,
        ),
        LeaderboardEntry(
          id: '2',
          name: 'Sarah Williams',
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          score: 8720,
          rank: 2,
        ),
        LeaderboardEntry(
          id: '3',
          name: 'Michael Brown',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          score: 8430,
          rank: 3,
        ),
        LeaderboardEntry(
          id: '4',
          name: 'You',
          avatarUrl: 'https://i.pravatar.cc/150?img=7',
          score: 7650,
          rank: 4,
          isCurrentUser: true,
        ),
        LeaderboardEntry(
          id: '5',
          name: 'Jessica Davis',
          avatarUrl: 'https://i.pravatar.cc/150?img=9',
          score: 7200,
          rank: 5,
        ),
        LeaderboardEntry(
          id: '6',
          name: 'David Miller',
          avatarUrl: 'https://i.pravatar.cc/150?img=6',
          score: 6980,
          rank: 6,
        ),
        LeaderboardEntry(
          id: '7',
          name: 'Lisa Thompson',
          avatarUrl: 'https://i.pravatar.cc/150?img=8',
          score: 6540,
          rank: 7,
        ),
        LeaderboardEntry(
          id: '8',
          name: 'Robert Wilson',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          score: 6320,
          rank: 8,
        ),
        LeaderboardEntry(
          id: '9',
          name: 'Emily Clark',
          avatarUrl: 'https://i.pravatar.cc/150?img=10',
          score: 5980,
          rank: 9,
        ),
        LeaderboardEntry(
          id: '10',
          name: 'Daniel Jones',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
          score: 5760,
          rank: 10,
        ),
      ];

      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void refreshLeaderboard(LeaderboardFilter filter) async {
    // In a real app, pass the filter to the API call
    fetchLeaderboard();
  }
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final selectedFilter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterChips(context, ref, selectedFilter),
            Expanded(
              child: leaderboardState.when(
                data: (entries) => _buildLeaderboardList(context, entries),
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                error:
                    (error, stackTrace) => Center(
                      child: Text(
                        'Error loading leaderboard',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Leaderboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () {
              // Show leaderboard info
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    LeaderboardFilter selectedFilter,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            context,
            ref,
            'Global',
            LeaderboardFilter.global,
            selectedFilter == LeaderboardFilter.global,
          ),
          _buildFilterChip(
            context,
            ref,
            'Friends',
            LeaderboardFilter.friends,
            selectedFilter == LeaderboardFilter.friends,
          ),
          _buildFilterChip(
            context,
            ref,
            'Weekly',
            LeaderboardFilter.weekly,
            selectedFilter == LeaderboardFilter.weekly,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    LeaderboardFilter filter,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(filterProvider.notifier).state = filter;
        ref.read(leaderboardProvider.notifier).refreshLeaderboard(filter);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(25),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    List<LeaderboardEntry> entries,
  ) {
    // Find current user for highlighting
    final currentUserEntry = entries.firstWhere(
      (entry) => entry.isCurrentUser,
      orElse: () => entries.first,
    );

    return Column(
      children: [
        _buildTopThree(context, entries.take(3).toList()),
        const SizedBox(height: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1D1E33),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _buildLeaderboardItem(
                    context,
                    entry,
                    currentUserEntry.id == entry.id,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopThree(
    BuildContext context,
    List<LeaderboardEntry> topEntries,
  ) {
    if (topEntries.isEmpty) return const SizedBox();

    final List<Widget> avatars = [];

    // Add 2nd place
    if (topEntries.length > 1) {
      avatars.add(
        Positioned(
          left: 20,
          child: _buildTopAvatar(context, topEntries[1], 2, 80),
        ),
      );
    }

    // Add 1st place (centered and larger)
    if (topEntries.isNotEmpty) {
      avatars.add(
        Positioned(
          left: 110,
          child: _buildTopAvatar(context, topEntries[0], 1, 100),
        ),
      );
    }

    // Add 3rd place
    if (topEntries.length > 2) {
      avatars.add(
        Positioned(
          right: 20,
          child: _buildTopAvatar(context, topEntries[2], 3, 80),
        ),
      );
    }

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(alignment: Alignment.center, children: avatars),
    );
  }

  Widget _buildTopAvatar(
    BuildContext context,
    LeaderboardEntry entry,
    int position,
    double size,
  ) {
    final Color borderColor;
    switch (position) {
      case 1:
        borderColor = const Color(0xFFFFD700); // Gold
        break;
      case 2:
        borderColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        borderColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        borderColor = Colors.transparent;
    }

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              entry.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.person, size: size * 0.6),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color:
                position == 1
                    ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                    : const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            entry.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: position == 1 ? 14 : 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.score} pts',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: position == 1 ? 12 : 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntry entry,
    bool isCurrentUser,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            isCurrentUser
                ? Border.all(color: const Color(0xFF6C63FF), width: 1)
                : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: _getRankColor(entry.rank),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(entry.avatarUrl),
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
        title: Text(
          entry.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isCurrentUser
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF0A0E21),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${entry.score}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white;
    }
  }
}

// Main entry point
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaderboard App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const LeaderboardScreen(),
    );
  }
}
