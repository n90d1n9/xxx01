// pubspec.yaml dependencies needed:
// flutter_riverpod: ^2.4.0
// go_router: ^10.0.0
// fl_chart: ^0.63.0
// cached_network_image: ^3.3.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class SalesRep {
  final String id;
  final String name;
  final String avatar;
  final int points;
  final int rank;
  final double conversionRate;
  final int dealsWon;
  final int totalDeals;
  final List<String> badges;
  final double monthlyTarget;
  final double monthlyProgress;

  SalesRep({
    required this.id,
    required this.name,
    required this.avatar,
    required this.points,
    required this.rank,
    required this.conversionRate,
    required this.dealsWon,
    required this.totalDeals,
    required this.badges,
    required this.monthlyTarget,
    required this.monthlyProgress,
  });
}

class Activity {
  final String id;
  final String type;
  final String description;
  final int points;
  final DateTime timestamp;
  final String status;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.points,
    required this.timestamp,
    required this.status,
  });
}

class CoachingTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final bool isPersonalized;

  CoachingTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.isPersonalized,
  });
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String icon;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.icon,
    required this.isUnlocked,
  });
}

// Providers
final currentUserProvider = StateProvider<SalesRep>(
  (ref) => SalesRep(
    id: '1',
    name: 'Alex Johnson',
    avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    points: 2450,
    rank: 3,
    conversionRate: 0.68,
    dealsWon: 24,
    totalDeals: 35,
    badges: ['Top Performer', 'Deal Closer', 'Team Player'],
    monthlyTarget: 50000,
    monthlyProgress: 34500,
  ),
);

final leaderboardProvider = StateProvider<List<SalesRep>>(
  (ref) => [
    SalesRep(
      id: '2',
      name: 'Sarah Chen',
      avatar:
          'https://images.unsplash.com/photo-1494790108755-2616b332c1ef?w=150',
      points: 3200,
      rank: 1,
      conversionRate: 0.82,
      dealsWon: 32,
      totalDeals: 39,
      badges: ['Champion', 'MVP', 'Deal Master'],
      monthlyTarget: 55000,
      monthlyProgress: 48200,
    ),
    SalesRep(
      id: '3',
      name: 'Mike Rodriguez',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      points: 2890,
      rank: 2,
      conversionRate: 0.75,
      dealsWon: 28,
      totalDeals: 37,
      badges: ['Closer', 'Rising Star'],
      monthlyTarget: 45000,
      monthlyProgress: 39800,
    ),
    ref.read(currentUserProvider),
  ],
);

final activitiesProvider = StateProvider<List<Activity>>(
  (ref) => [
    Activity(
      id: '1',
      type: 'call',
      description: 'Follow-up call with TechCorp',
      points: 25,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      status: 'completed',
    ),
    Activity(
      id: '2',
      type: 'meeting',
      description: 'Demo presentation for StartupXYZ',
      points: 50,
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      status: 'completed',
    ),
    Activity(
      id: '3',
      type: 'deal',
      description: 'Closed deal with GlobalTech - \$25,000',
      points: 150,
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      status: 'won',
    ),
  ],
);

final coachingTipsProvider = StateProvider<List<CoachingTip>>(
  (ref) => [
    CoachingTip(
      id: '1',
      title: 'Improve Your Cold Calling',
      description:
          'Based on your recent call patterns, try starting with a question instead of a pitch.',
      category: 'Communication',
      priority: 1,
      isPersonalized: true,
    ),
    CoachingTip(
      id: '2',
      title: 'Follow-up Strategy',
      description:
          'You have 3 prospects who haven\'t responded in 5 days. Here\'s what to do next.',
      category: 'Follow-up',
      priority: 2,
      isPersonalized: true,
    ),
  ],
);

final rewardsProvider = StateProvider<List<Reward>>(
  (ref) => [
    Reward(
      id: '1',
      title: 'Premium Lunch',
      description: 'Expense-paid lunch at your favorite restaurant',
      pointsCost: 500,
      icon: '🍽️',
      isUnlocked: true,
    ),
    Reward(
      id: '2',
      title: 'Extra PTO Day',
      description: 'One additional day off',
      pointsCost: 1000,
      icon: '🏖️',
      isUnlocked: true,
    ),
    Reward(
      id: '3',
      title: 'Team Lead for a Day',
      description: 'Shadow the sales manager',
      pointsCost: 2000,
      icon: '👑',
      isUnlocked: true,
    ),
  ],
);

// Main App
class GamifiedCRMApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SalesGame CRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: DashboardScreen(),
    );
  }
}

// Router configuration would go here - simplified for this example
final _router = null; // In real app, use GoRouter

// Dashboard Screen
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user.avatar),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, ${user.name.split(' ')[0]}!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rank #${user.rank} • ${user.points} points',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            _buildStatCard(
                              'Points',
                              user.points.toString(),
                              '🏆',
                            ),
                            SizedBox(width: 12),
                            _buildStatCard(
                              'Deals Won',
                              user.dealsWon.toString(),
                              '💼',
                            ),
                            SizedBox(width: 12),
                            _buildStatCard(
                              'Win Rate',
                              '${(user.conversionRate * 100).toInt()}%',
                              '🎯',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressCard(user),
                SizedBox(height: 16),
                _buildQuickActions(),
                SizedBox(height: 16),
                _buildRecentActivities(activities),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(SalesRep user) {
    final progress = user.monthlyProgress / user.monthlyTarget;

    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Monthly Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
              minHeight: 8,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${(user.monthlyProgress / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                Text(
                  '\$${(user.monthlyTarget / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% of monthly target',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton('Log Call', Icons.phone, Color(0xFF3B82F6)),
                SizedBox(width: 12),
                _buildActionButton(
                  'Add Deal',
                  Icons.handshake,
                  Color(0xFF10B981),
                ),
                SizedBox(width: 12),
                _buildActionButton(
                  'Schedule',
                  Icons.calendar_today,
                  Color(0xFF8B5CF6),
                ),
                SizedBox(width: 12),
                _buildActionButton('Follow Up', Icons.mail, Color(0xFFF59E0B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(List<Activity> activities) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: Text('View All')),
              ],
            ),
            SizedBox(height: 16),
            ...activities
                .take(3)
                .map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'call':
        icon = Icons.phone;
        color = Color(0xFF3B82F6);
        break;
      case 'meeting':
        icon = Icons.videocam;
        color = Color(0xFF8B5CF6);
        break;
      case 'deal':
        icon = Icons.handshake;
        color = Color(0xFF10B981);
        break;
      default:
        icon = Icons.work;
        color = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  _formatTime(activity.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${activity.points}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
}

// Leaderboard Screen
class LeaderboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('Leaderboard'),
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFED7AA), Color(0xFFF97316)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTopThree(leaderboard.take(3).toList()),
                SizedBox(height: 24),
                _buildLeaderboardList(leaderboard),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 1),
    );
  }

  Widget _buildTopThree(List<SalesRep> topThree) {
    return Container(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topThree.length > 1) _buildPodiumPosition(topThree[1], 2, 160),
          if (topThree.isNotEmpty) _buildPodiumPosition(topThree[0], 1, 200),
          if (topThree.length > 2) _buildPodiumPosition(topThree[2], 3, 140),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(SalesRep rep, int position, double height) {
    Color color;
    switch (position) {
      case 1:
        color = Color(0xFFFFD700);
        break;
      case 2:
        color = Color(0xFFC0C0C0);
        break;
      default:
        color = Color(0xFFCD7F32);
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(rep.avatar)),
          SizedBox(height: 8),
          Text(
            rep.name.split(' ')[0],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            '${rep.points} pts',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 8),
          Container(
            height: height * 0.6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                '#$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<SalesRep> reps) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Text(
                  'Full Rankings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...reps.asMap().entries.map((entry) {
            final index = entry.key;
            final rep = entry.value;
            return _buildLeaderboardItem(rep, index == reps.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(SalesRep rep, bool isLast) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom:
              isLast ? BorderSide.none : BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  rep.rank <= 3
                      ? Color(0xFFF59E0B).withOpacity(0.1)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '#${rep.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rep.rank <= 3 ? Color(0xFFF59E0B) : Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(rep.avatar)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rep.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  '${rep.dealsWon} deals won • ${(rep.conversionRate * 100).toInt()}% rate',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rep.points}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
              Text(
                'points',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Coaching Screen
class CoachingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(coachingTipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Coaching'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoachingHeader(),
            SizedBox(height: 24),
            _buildPersonalizedTips(tips),
            SizedBox(height: 24),
            _buildPerformanceInsights(),
            SizedBox(height: 24),
            _buildSkillsRadar(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _buildCoachingHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your AI Coach',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personalized insights based on your performance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips(List<CoachingTip> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Tips',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...tips.map((tip) => _buildTipCard(tip)),
      ],
    );
  }

  Widget _buildTipCard(CoachingTip tip) {
    Color categoryColor;
    IconData categoryIcon;

    switch (tip.category) {
      case 'Communication':
        categoryColor = Color(0xFF3B82F6);
        categoryIcon = Icons.chat;
        break;
      case 'Follow-up':
        categoryColor = Color(0xFF10B981);
        categoryIcon = Icons.follow_the_signs;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.lightbulb;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tip.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tip.isPersonalized)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'FOR YOU',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              tip.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.play_arrow, size: 16),
                  label: Text('Start Training'),
                  style: TextButton.styleFrom(foregroundColor: categoryColor),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.bookmark_border, size: 16),
                  label: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceInsights() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Performance Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInsightItem(
              'Call-to-Meeting Rate',
              '24%',
              '+3% from last month',
              Color(0xFF10B981),
              Icons.trending_up,
            ),
            _buildInsightItem(
              'Average Deal Size',
              '\$12.5K',
              '+\$2.1K from last month',
              Color(0xFF3B82F6),
              Icons.trending_up,
            ),
            _buildInsightItem(
              'Sales Cycle Length',
              '18 days',
              '+2 days from last month',
              Color(0xFFF59E0B),
              Icons.trending_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsRadar() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text(
                  'Skills Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: Color(0xFF8B5CF6).withOpacity(0.2),
                      borderColor: Color(0xFF8B5CF6),
                      entryRadius: 3,
                      dataEntries: [
                        RadarEntry(value: 85), // Prospecting
                        RadarEntry(value: 72), // Qualifying
                        RadarEntry(value: 68), // Presenting
                        RadarEntry(value: 91), // Closing
                        RadarEntry(value: 76), // Follow-up
                      ],
                    ),
                  ],
                  radarTouchData: RadarTouchData(enabled: false),
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: BorderSide(color: Colors.grey[300]!),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0:
                        return RadarChartTitle(text: 'Prospecting');
                      case 1:
                        return RadarChartTitle(text: 'Qualifying');
                      case 2:
                        return RadarChartTitle(text: 'Presenting');
                      case 3:
                        return RadarChartTitle(text: 'Closing');
                      case 4:
                        return RadarChartTitle(text: 'Follow-up');
                      default:
                        return RadarChartTitle(text: '');
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your strongest skill is closing deals. Consider improving your presentation skills for better conversion rates.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rewards Screen
class RewardsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards Store'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: Color(0xFF6366F1), size: 16),
                SizedBox(width: 4),
                Text(
                  '${user.points}',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardsHeader(user),
            SizedBox(height: 24),
            _buildRewardsGrid(rewards, user.points),
            SizedBox(height: 24),
            _buildRecentRedemptions(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
    );
  }

  Widget _buildRewardsHeader(SalesRep user) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Redeem your points for amazing rewards',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Available Points: ${user.points}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsGrid(List<Reward> rewards, int userPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Rewards',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            final canAfford = userPoints >= reward.pointsCost;

            return Card(
              elevation: 0,
              child: InkWell(
                onTap:
                    canAfford ? () => _showRedeemDialog(context, reward) : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(reward.icon, style: TextStyle(fontSize: 32)),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  canAfford
                                      ? Color(0xFF10B981).withOpacity(0.1)
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${reward.pointsCost}',
                              style: TextStyle(
                                color:
                                    canAfford
                                        ? Color(0xFF10B981)
                                        : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        reward.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.black : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          reward.description,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                canAfford ? Colors.grey[600] : Colors.grey[400],
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              canAfford
                                  ? () => _showRedeemDialog(context, reward)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canAfford
                                    ? Color(0xFF6366F1)
                                    : Colors.grey[300],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            canAfford ? 'Redeem' : 'Not enough points',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentRedemptions() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Redemptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildRedemptionItem('Premium Lunch', '500 points', '2 days ago'),
            _buildRedemptionItem(
              'Coffee with CEO',
              '1500 points',
              '1 week ago',
            ),
            _buildRedemptionItem('Extra PTO Day', '1000 points', '2 weeks ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionItem(String title, String points, String date) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '$points • $date',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Redeem Reward'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reward.icon, style: TextStyle(fontSize: 48)),
                SizedBox(height: 16),
                Text(
                  reward.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  reward.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cost: ${reward.pointsCost} points',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${reward.title} redeemed successfully!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                ),
                child: Text('Redeem'),
              ),
            ],
          ),
    );
  }
}

// Bottom Navigation
Widget _buildBottomNav(BuildContext context, int currentIndex) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF6366F1),
      unselectedItemColor: Colors.grey[400],
      elevation: 0,
      backgroundColor: Colors.transparent,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard_outlined),
          activeIcon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Coaching',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard_outlined),
          activeIcon: Icon(Icons.card_giftcard),
          label: 'Rewards',
        ),
      ],
    ),
  );
}

// Main function to run the app
void main() {
  runApp(ProviderScope(child: GamifiedCRMApp()));
}
