import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'How to Use',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  _TutorialItem(
                    icon: Icons.search,
                    title: 'Search Events',
                    description:
                        'Use the search bar to find events by keyword, location, or quote.',
                  ),
                  _TutorialItem(
                    icon: Icons.filter_list,
                    title: 'Filter & Sort',
                    description:
                        'Filter events by category, date range, or impact score. Sort by popularity or chronologically.',
                  ),
                  _TutorialItem(
                    icon: Icons.view_module,
                    title: 'View Modes',
                    description:
                        'Switch between List, Grid, Timeline, Map, and Graph views for different perspectives.',
                  ),
                  _TutorialItem(
                    icon: Icons.favorite,
                    title: 'Favorites & Bookmarks',
                    description:
                        'Mark events as favorites or bookmarks for quick access later.',
                  ),
                  _TutorialItem(
                    icon: Icons.compare_arrows,
                    title: 'Compare Events',
                    description:
                        'Enable comparison mode to compare up to 3 events side by side.',
                  ),
                  _TutorialItem(
                    icon: Icons.quiz,
                    title: 'Take Quizzes',
                    description:
                        'Test your knowledge with history quizzes and earn points.',
                  ),
                  _TutorialItem(
                    icon: Icons.emoji_events,
                    title: 'Unlock Achievements',
                    description:
                        'Complete challenges to unlock achievements and earn rewards.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
