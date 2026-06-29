import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class EnterpriseDashboardPage extends ConsumerWidget {
  const EnterpriseDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationProvider);
    final offlineSync = ref.watch(offlineSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: organizationAsync.when(
          data:
              (org) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    org.plan.name.toUpperCase(),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
          loading: () => const Text('Dashboard'),
          error: (_, __) => const Text('Dashboard'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (offlineSync.pendingCount > 0)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_sync),
                    onPressed: () => offlineSync.sync(),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${offlineSync.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _showQRScanner(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(organizationProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildQuickStats(ref),
            const SizedBox(height: 24),
            _buildRealtimeActivity(ref),
            const SizedBox(height: 24),
            _buildMiniCharts(ref),
            const SizedBox(height: 24),
            _buildTeamOverview(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(context),
        icon: const Icon(Icons.bolt),
        label: const Text('Quick Actions'),
      ),
    );
  }

  Widget _buildQuickStats(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Now',
            '24',
            Icons.circle,
            Colors.green,
            'users online',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Today',
            '18',
            Icons.event,
            Colors.blue,
            'meetings',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '12',
            Icons.pending_actions,
            Colors.orange,
            'tasks',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeActivity(WidgetRef ref) {
    final eventsAsync = ref.watch(realtimeEventsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Real-time Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            eventsAsync.when(
              data: (event) => _buildActivityItem(event),
              loading: () => const Text('Waiting for activity...'),
              error: (_, __) => const Text('No activity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(RealtimeEvent event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 16, child: Text(event.userName[0])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${event.type} • ${event.entityType}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            'just now',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCharts(WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: _buildMeetingsTrendCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildTasksCompletionCard()),
      ],
    );
  }

  Widget _buildMeetingsTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meeting Trend',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (i) => FlSpot(i.toDouble(), 5 + (i * 2).toDouble()),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+24% from last week',
              style: TextStyle(fontSize: 11, color: Colors.green.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCompletionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Completion',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    5,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: 10 + (i * 5).toDouble(),
                          color: Colors.green,
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '78% completion rate',
              style: TextStyle(fontSize: 11, color: Colors.green.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            _buildTeamMemberRow(
              'Sarah Johnson',
              'Product Manager',
              '5 tasks',
              Colors.blue,
            ),
            _buildTeamMemberRow(
              'Mike Chen',
              'Developer',
              '8 tasks',
              Colors.green,
            ),
            _buildTeamMemberRow(
              'Lisa Anderson',
              'Designer',
              '3 tasks',
              Colors.purple,
            ),
            _buildTeamMemberRow(
              'John Smith',
              'QA Engineer',
              '4 tasks',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberRow(
    String name,
    String role,
    String tasks,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tasks,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code Scanner'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text('Position QR code within frame'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildQuickActionTile(
                  'Instant Meeting',
                  Icons.video_call,
                  Colors.blue,
                  () {},
                ),
                _buildQuickActionTile(
                  'Quick Note',
                  Icons.note_add,
                  Colors.green,
                  () {},
                ),
                _buildQuickActionTile(
                  'Voice Recording',
                  Icons.mic,
                  Colors.red,
                  () {},
                ),
                _buildQuickActionTile(
                  'Scan Document',
                  Icons.document_scanner,
                  Colors.orange,
                  () {},
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildQuickActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// ==================== REALTIME COLLABORATION PAGE ====================

class RealtimeCollaborationPage extends ConsumerWidget {
  const RealtimeCollaborationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUsers = ref.watch(activeUsersProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Collaboration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          connectionStatus.when(
            data:
                (isConnected) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'Connected' : 'Offline',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActiveUsers(activeUsers),
          const SizedBox(height: 24),
          _buildLiveDocuments(),
          const SizedBox(height: 24),
          _buildRecentCollaborations(),
          const SizedBox(height: 24),
          _buildCollaborationFeatures(context),
        ],
      ),
    );
  }

  Widget _buildActiveUsers(List<ActiveUser> users) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Active Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${users.length + 5}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  8,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors
                                  .primaries[index % Colors.primaries.length]
                                  .withOpacity(0.3),
                              child: Text('U${index + 1}'),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ${index + 1}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDocuments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLiveDocItem('Q4 Planning Notes', 3, Colors.blue),
            _buildLiveDocItem('Marketing Strategy', 2, Colors.purple),
            _buildLiveDocItem('Product Roadmap', 5, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDocItem(String title, int collaborators, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 20,
                      child: Stack(
                        children: List.generate(
                          collaborators.clamp(0, 3),
                          (index) => Positioned(
                            left: index * 15.0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 9,
                                backgroundColor: color,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$collaborators editing',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildRecentCollaborations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Collaborations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCollaborationItem(
              'Sarah added a comment',
              '2 min ago',
              Icons.comment,
            ),
            _buildCollaborationItem(
              'Mike updated the timeline',
              '15 min ago',
              Icons.edit,
            ),
            _buildCollaborationItem(
              'Lisa shared new designs',
              '1 hour ago',
              Icons.share,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborationItem(String text, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationFeatures(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collaboration Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: const Text('Start Video Call'),
              subtitle: const Text('Instant team meeting'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.screen_share, color: Colors.green),
              title: const Text('Share Screen'),
              subtitle: const Text('Present to team'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.orange),
              title: const Text('Team Chat'),
              subtitle: const Text('Real-time messaging'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ADVANCED ANALYTICS PAGE ====================

class AdvancedAnalyticsPage extends ConsumerStatefulWidget {
  const AdvancedAnalyticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedAnalyticsPage> createState() =>
      _AdvancedAnalyticsPageState();
}

class _AdvancedAnalyticsPageState extends ConsumerState<AdvancedAnalyticsPage> {
  String _selectedPeriod = '30d';

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider(_selectedPeriod));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
                  const PopupMenuItem(
                    value: '30d',
                    child: Text('Last 30 Days'),
                  ),
                  const PopupMenuItem(
                    value: '90d',
                    child: Text('Last 90 Days'),
                  ),
                  const PopupMenuItem(value: '1y', child: Text('Last Year')),
                ],
          ),
        ],
      ),
      body: analyticsAsync.when(
        data:
            (analytics) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(analyticsDataProvider(_selectedPeriod));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildKPICards(analytics),
                  const SizedBox(height: 24),
                  _buildMainChart(analytics),
                  const SizedBox(height: 24),
                  _buildMetricComparison(analytics),
                  const SizedBox(height: 24),
                  _buildInsights(),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildKPICards(AnalyticsData analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Meeting Efficiency',
                '${(analytics.aggregates['completion_rate']! * 100).toInt()}%',
                Icons.speed,
                Colors.blue,
                '+5%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Task Velocity',
                '${analytics.aggregates['avg_activity']!.toInt()}',
                Icons.trending_up,
                Colors.green,
                '+12%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Team Productivity',
                '${(analytics.aggregates['efficiency_score']! * 100).toInt()}%',
                Icons.people,
                Colors.purple,
                '+8%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'On-Time Delivery',
                '75%',
                Icons.check_circle,
                Colors.orange,
                '+3%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    final isPositive = change.startsWith('+');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPositive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color:
                          isPositive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart(AnalyticsData analytics) {
    final meetingData = analytics.metrics['meetings'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meeting Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 7,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Day ${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          meetingData
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(e.key.toDouble(), e.value.value),
                              )
                              .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricComparison(AnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressMetric('Meeting Efficiency', 0.82, Colors.blue),
            _buildProgressMetric('Task Completion', 0.78, Colors.green),
            _buildProgressMetric('Team Collaboration', 0.85, Colors.purple),
            _buildProgressMetric('On-Time Delivery', 0.75, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'AI Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Peak productivity hours are between 10 AM - 12 PM',
              Icons.schedule,
              Colors.blue,
            ),
            _buildInsightItem(
              'Meeting efficiency improved by 24% this month',
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightItem(
              'Consider scheduling fewer meetings on Fridays',
              Icons.event_busy,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ==================== ORGANIZATION MANAGEMENT PAGE ====================

class OrganizationManagementPage extends ConsumerWidget {
  const OrganizationManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organization',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: organizationAsync.when(
        data:
            (org) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrganizationCard(org, context),
                const SizedBox(height: 24),
                _buildPlanCard(org),
                const SizedBox(height: 24),
                _buildUsageCard(org),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOrganizationCard(Organization org, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              child: Text(
                org.name[0],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              org.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              org.domain,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                org.plan.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Organization org) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPlanFeature('Unlimited Meetings', true),
            _buildPlanFeature('Advanced Analytics', true),
            _buildPlanFeature('API Access', true),
            _buildPlanFeature(
              'Priority Support',
              org.plan == OrganizationPlan.enterprise,
            ),
            _buildPlanFeature(
              'Custom Branding',
              org.plan == OrganizationPlan.enterprise,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Upgrade Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanFeature(String feature, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            color: included ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: included ? null : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(Organization org) {
    final usagePercent = org.currentUsers / org.userLimit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage & Limits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Team Members'),
                Text(
                  '${org.currentUsers} / ${org.userLimit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usagePercent,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  usagePercent > 0.8 ? Colors.orange : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Branding'),
            subtitle: const Text('Customize colors and logo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Settings'),
            subtitle: const Text('2FA, SSO, and access control'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.webhook),
            title: const Text('Webhooks'),
            subtitle: const Text('Configure integrations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Billing & Invoices'),
            subtitle: const Text('Manage subscription'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ==================== PERFORMANCE PAGE ====================

class PerformancePage extends ConsumerWidget {
  const PerformancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheService = ref.watch(cacheServiceProvider);
    final offlineSync = ref.watch(offlineSyncProvider);
    final cacheStats = cacheService.getStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Performance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPerformanceOverview(),
          const SizedBox(height: 24),
          _buildCacheStats(cacheStats),
          const SizedBox(height: 24),
          _buildOfflineSync(offlineSync),
          const SizedBox(height: 24),
          _buildOptimizationTips(),
          const SizedBox(height: 24),
          _buildSystemInfo(context),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    'App Start',
                    '1.2s',
                    Icons.speed,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    'Avg Load',
                    '250ms',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    'Memory',
                    '128 MB',
                    Icons.memory,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    'FPS',
                    '60',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStats(CacheStats stats) {
    final hitRate = (stats.hitRate * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cache Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Clear Cache')),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Requests', '${stats.totalRequests}'),
            _buildStatRow('Cache Hits', '${stats.hits}'),
            _buildStatRow('Hit Rate', '$hitRate%'),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.hitRate,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  hitRate > 70 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hitRate > 70
                  ? 'Excellent cache performance'
                  : 'Cache performance can be improved',
              style: TextStyle(
                fontSize: 12,
                color: hitRate > 70 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOfflineSync(OfflineSyncService sync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Offline Sync',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  sync.pendingCount > 0
                      ? Icons.sync_problem
                      : Icons.check_circle,
                  color: sync.pendingCount > 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sync.pendingCount > 0
                        ? '${sync.pendingCount} items pending sync'
                        : 'All changes synced',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (sync.pendingCount > 0)
                  ElevatedButton(
                    onPressed: () => sync.sync(),
                    child: const Text('Sync Now'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Optimization Tips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Enable offline mode for better performance in low connectivity',
              Icons.cloud_off,
            ),
            _buildTipItem(
              'Clear cache regularly to free up storage',
              Icons.cleaning_services,
            ),
            _buildTipItem(
              'Reduce image quality for faster loading',
              Icons.image,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSystemInfo(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Device Info'),
            subtitle: const Text('View device specifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeviceInfo(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Build 100)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Debug Mode'),
            trailing: Switch(value: false, onChanged: (value) {}),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Device Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Platform', 'Android 14'),
                _buildInfoRow('Device', 'Pixel 8 Pro'),
                _buildInfoRow('Screen', '1440 x 3120'),
                _buildInfoRow('RAM', '12 GB'),
                _buildInfoRow('Storage', '256 GB'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
} // pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// uuid: ^4.2.1
// intl: ^0.18.1
// shared_preferences: ^2.2.2
// fl_chart: ^0.65.0
// file_picker: ^6.1.1
// path_provider: ^2.1.1
// dio: ^5.4.0
// web_socket_channel: ^2.4.0
// connectivity_plus: ^5.0.2
// flutter_cache_manager: ^3.3.1
// image_picker: ^1.0.7
// device_info_plus: ^9.1.1
// package_info_plus: ^5.0.1
// flutter_local_notifications: ^16.3.0
// sqflite: ^2.3.0
// hive_flutter: ^1.1.0

// ==================== ENTERPRISE MODELS ====================

class Organization {
  final String id;
  final String name;
  final String domain;
  final OrganizationPlan plan;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> branding;
  final DateTime createdAt;
  final bool isActive;
  final int userLimit;
  final int currentUsers;

  Organization({
    required this.id,
    required this.name,
    required this.domain,
    required this.plan,
    required this.settings,
    required this.branding,
    required this.createdAt,
    this.isActive = true,
    required this.userLimit,
    required this.currentUsers,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'domain': domain,
    'plan': plan.name,
    'settings': settings,
    'branding': branding,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
    'userLimit': userLimit,
    'currentUsers': currentUsers,
  };

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json['id'],
    name: json['name'],
    domain: json['domain'],
    plan: OrganizationPlan.values.firstWhere((e) => e.name == json['plan']),
    settings: json['settings'] ?? {},
    branding: json['branding'] ?? {},
    createdAt: DateTime.parse(json['createdAt']),
    isActive: json['isActive'] ?? true,
    userLimit: json['userLimit'],
    currentUsers: json['currentUsers'],
  );
}

enum OrganizationPlan { free, starter, professional, enterprise }

class RealtimeEvent {
  final String id;
  final String type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final String userId;
  final String userName;
  final DateTime timestamp;

  RealtimeEvent({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'entityType': entityType,
    'entityId': entityId,
    'data': data,
    'userId': userId,
    'userName': userName,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) => RealtimeEvent(
    id: json['id'],
    type: json['type'],
    entityType: json['entityType'],
    entityId: json['entityId'],
    data: json['data'],
    userId: json['userId'],
    userName: json['userName'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class CollaborationSession {
  final String id;
  final String entityId;
  final String entityType;
  final List<ActiveUser> activeUsers;
  final DateTime startedAt;

  CollaborationSession({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.activeUsers,
    required this.startedAt,
  });
}

class ActiveUser {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final DateTime joinedAt;
  final String? currentAction;

  ActiveUser({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.joinedAt,
    this.currentAction,
  });
}

class AnalyticsData {
  final String period;
  final Map<String, List<DataPoint>> metrics;
  final Map<String, double> aggregates;
  final DateTime generatedAt;

  AnalyticsData({
    required this.period,
    required this.metrics,
    required this.aggregates,
    required this.generatedAt,
  });
}

class DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  DataPoint({required this.timestamp, required this.value, this.metadata});
}

class PerformanceMetrics {
  final double appStartTime;
  final double averageLoadTime;
  final int totalRequests;
  final int cachedRequests;
  final double cacheHitRate;
  final int errorCount;
  final DateTime measuredAt;

  PerformanceMetrics({
    required this.appStartTime,
    required this.averageLoadTime,
    required this.totalRequests,
    required this.cachedRequests,
    required this.cacheHitRate,
    required this.errorCount,
    required this.measuredAt,
  });
}

class OfflineQueue {
  final String id;
  final String action;
  final String entityType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  OfflineQueue({
    required this.id,
    required this.action,
    required this.entityType,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'entityType': entityType,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory OfflineQueue.fromJson(Map<String, dynamic> json) => OfflineQueue(
    id: json['id'],
    action: json['action'],
    entityType: json['entityType'],
    data: json['data'],
    createdAt: DateTime.parse(json['createdAt']),
    retryCount: json['retryCount'] ?? 0,
  );
}

// ==================== REALTIME SERVICE ====================

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final _eventController = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _eventController.stream;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool _isConnected = false;
  Timer? _heartbeatTimer;

  void connect() {
    // Simulate WebSocket connection
    _isConnected = true;
    _connectionController.add(true);
    _startHeartbeat();

    // Simulate receiving events
    _simulateEvents();
  }

  void disconnect() {
    _isConnected = false;
    _connectionController.add(false);
    _heartbeatTimer?.cancel();
  }

  void sendEvent(RealtimeEvent event) {
    if (!_isConnected) return;
    // Simulate sending event
    _eventController.add(event);
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        // Send heartbeat
      }
    });
  }

  void _simulateEvents() {
    // Simulate random collaboration events
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      final event = RealtimeEvent(
        id: const Uuid().v4(),
        type: 'user_active',
        entityType: 'meeting',
        entityId: 'demo-meeting',
        data: {'action': 'viewing'},
        userId: 'user-${DateTime.now().millisecond}',
        userName: 'Team Member',
        timestamp: DateTime.now(),
      );
      _eventController.add(event);
    });
  }

  void dispose() {
    _eventController.close();
    _connectionController.close();
    _heartbeatTimer?.cancel();
  }
}

// ==================== ANALYTICS SERVICE ====================

class AnalyticsService {
  static AnalyticsData generateAnalytics(String period, List<dynamic> data) {
    final now = DateTime.now();
    final metrics = <String, List<DataPoint>>{};

    // Generate meeting trends
    metrics['meetings'] = _generateTrendData(30, 5, 20);

    // Generate task completion
    metrics['tasks_completed'] = _generateTrendData(30, 10, 50);

    // Generate user activity
    metrics['user_activity'] = _generateTrendData(30, 20, 100);

    // Calculate aggregates
    final aggregates = {
      'total_meetings': metrics['meetings']!.fold<double>(
        0,
        (sum, point) => sum + point.value,
      ),
      'total_tasks': metrics['tasks_completed']!.fold<double>(
        0,
        (sum, point) => sum + point.value,
      ),
      'avg_activity':
          metrics['user_activity']!.fold<double>(
            0,
            (sum, point) => sum + point.value,
          ) /
          metrics['user_activity']!.length,
      'completion_rate': 0.78,
      'efficiency_score': 0.85,
    };

    return AnalyticsData(
      period: period,
      metrics: metrics,
      aggregates: aggregates,
      generatedAt: now,
    );
  }

  static List<DataPoint> _generateTrendData(int days, double min, double max) {
    final now = DateTime.now();
    final points = <DataPoint>[];

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = min + (max - min) * (0.3 + 0.7 * (1 - i / days));
      points.add(DataPoint(timestamp: date, value: value));
    }

    return points;
  }

  static Map<String, dynamic> calculateKPIs(
    List<dynamic> meetings,
    List<dynamic> tasks,
  ) {
    return {
      'meeting_efficiency': 0.82,
      'task_velocity': 12.5,
      'completion_rate': 0.78,
      'team_productivity': 0.88,
      'on_time_delivery': 0.75,
      'collaboration_score': 0.85,
    };
  }
}

// ==================== CACHE SERVICE ====================

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final _cache = <String, CacheEntry>{};
  final _cacheStats = CacheStats();

  Future<T?> get<T>(String key) async {
    _cacheStats.totalRequests++;

    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      return null;
    }

    _cacheStats.hits++;
    return entry.value as T;
  }

  Future<void> set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 30),
  }) async {
    _cache[key] = CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }

  void clear() {
    _cache.clear();
  }

  void remove(String key) {
    _cache.remove(key);
  }

  CacheStats getStats() => _cacheStats;
}

class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheStats {
  int totalRequests = 0;
  int hits = 0;

  double get hitRate => totalRequests > 0 ? hits / totalRequests : 0;
}

// ==================== OFFLINE SYNC SERVICE ====================

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final _queue = <OfflineQueue>[];
  bool _isSyncing = false;

  void addToQueue(String action, String entityType, Map<String, dynamic> data) {
    final item = OfflineQueue(
      id: const Uuid().v4(),
      action: action,
      entityType: entityType,
      data: data,
      createdAt: DateTime.now(),
    );
    _queue.add(item);
  }

  Future<void> sync() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    final itemsToSync = List<OfflineQueue>.from(_queue);

    for (final item in itemsToSync) {
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 100));
        _queue.remove(item);
      } catch (e) {
        // Retry logic
        if (item.retryCount < 3) {
          final updated = OfflineQueue(
            id: item.id,
            action: item.action,
            entityType: item.entityType,
            data: item.data,
            createdAt: item.createdAt,
            retryCount: item.retryCount + 1,
          );
          _queue.remove(item);
          _queue.add(updated);
        }
      }
    }

    _isSyncing = false;
  }

  int get pendingCount => _queue.length;
}

// ==================== STATE MANAGEMENT ====================

final realtimeServiceProvider = Provider((ref) => RealtimeService());

final connectionStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.connectionStatus;
});

final realtimeEventsProvider = StreamProvider<RealtimeEvent>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.events;
});

final activeUsersProvider = StateProvider<List<ActiveUser>>((ref) => []);

final analyticsDataProvider = FutureProvider.family<AnalyticsData, String>((
  ref,
  period,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return AnalyticsService.generateAnalytics(period, []);
});

final organizationProvider = FutureProvider<Organization>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return Organization(
    id: 'org-1',
    name: 'Acme Corporation',
    domain: 'acme.com',
    plan: OrganizationPlan.professional,
    settings: {},
    branding: {'primaryColor': '#6366F1', 'logo': null},
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    userLimit: 50,
    currentUsers: 12,
  );
});

final offlineSyncProvider = Provider((ref) => OfflineSyncService());

final cacheServiceProvider = Provider((ref) => CacheService());

// ==================== MAIN APP ====================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  RealtimeService().connect();

  runApp(const ProviderScope(child: EnterpriseApp()));
}

class EnterpriseApp extends StatelessWidget {
  const EnterpriseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Management Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

// ==================== MAIN NAVIGATION ====================

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() {
    // Simulate connectivity check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(offlineSyncProvider).sync();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: const [
              EnterpriseDashboardPage(),
              RealtimeCollaborationPage(),
              AdvancedAnalyticsPage(),
              OrganizationManagementPage(),
              PerformancePage(),
            ],
          ),
          connectionStatus.when(
            data:
                (isConnected) =>
                    !isConnected
                        ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.orange,
                            child: SafeArea(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_off,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Offline Mode',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Collaborate',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Organization',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Performance',
          ),
        ],
      ),
    );
  }
}

// ==================== ENTERPRISE DASHBOARD ====================
