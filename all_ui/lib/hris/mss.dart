import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Models
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final String status;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.status,
  });
}

class PendingRequest {
  final String id;
  final String employeeName;
  final String requestType;
  final DateTime requestDate;
  final String status;
  final String avatar;

  PendingRequest({
    required this.id,
    required this.employeeName,
    required this.requestType,
    required this.requestDate,
    required this.status,
    required this.avatar,
  });
}

// Providers
final isDarkModeProvider = StateProvider<bool>((ref) => false);

final teamMembersProvider = FutureProvider<List<TeamMember>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    TeamMember(
      id: '1',
      name: 'Alex Morgan',
      role: 'UX Designer',
      avatar: 'https://i.pravatar.cc/150?img=1',
      status: 'available',
    ),
    TeamMember(
      id: '2',
      name: 'Jamie Smith',
      role: 'Frontend Developer',
      avatar: 'https://i.pravatar.cc/150?img=2',
      status: 'busy',
    ),
    TeamMember(
      id: '3',
      name: 'Taylor Wilson',
      role: 'Backend Developer',
      avatar: 'https://i.pravatar.cc/150?img=3',
      status: 'leave',
    ),
    TeamMember(
      id: '4',
      name: 'Casey Johnson',
      role: 'QA Engineer',
      avatar: 'https://i.pravatar.cc/150?img=4',
      status: 'available',
    ),
  ];
});

final pendingRequestsProvider = FutureProvider<List<PendingRequest>>((
  ref,
) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    PendingRequest(
      id: '101',
      employeeName: 'Jamie Smith',
      requestType: 'Time Off',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'pending',
      avatar: 'https://i.pravatar.cc/150?img=2',
    ),
    PendingRequest(
      id: '102',
      employeeName: 'Taylor Wilson',
      requestType: 'Equipment Request',
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'pending',
      avatar: 'https://i.pravatar.cc/150?img=3',
    ),
    PendingRequest(
      id: '103',
      employeeName: 'Casey Johnson',
      requestType: 'Training Approval',
      requestDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'pending',
      avatar: 'https://i.pravatar.cc/150?img=4',
    ),
  ];
});

final teamMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return {
    'productivity': 87,
    'satisfaction': 92,
    'taskCompletion': 78,
    'weeklyData': [65, 70, 75, 82, 87, 85, 90],
  };
});

class ManagerSelfServiceScreen extends ConsumerWidget {
  const ManagerSelfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final pendingRequests = ref.watch(pendingRequestsProvider);
    final teamMetrics = ref.watch(teamMetricsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor:
                  isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Manager Dashboard',
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white : const Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDarkMode
                              ? [
                                const Color(0xFF1E1E1E),
                                const Color(0xFF121212),
                              ]
                              : [const Color(0xFFE2F0FF), Colors.white],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.white : const Color(0xFF333333),
                  ),
                  onPressed: () {
                    ref.read(isDarkModeProvider.notifier).state = !isDarkMode;
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDarkMode ? Colors.white : const Color(0xFF333333),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=7',
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCard(
                            context,
                            isDarkMode,
                            title: 'Team Members',
                            value: '4',
                            icon: Icons.people_alt_outlined,
                            color: const Color(0xFF4E7FFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCard(
                            context,
                            isDarkMode,
                            title: 'Pending Approvals',
                            value: '3',
                            icon: Icons.approval_outlined,
                            color: const Color(0xFFFF847C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      isDarkMode,
                      title: 'Team Performance',
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: teamMetrics.when(
                          data:
                              (data) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildMetricIndicator(
                                        isDarkMode,
                                        label: 'Productivity',
                                        value: data['productivity'],
                                        color: const Color(0xFF4E7FFF),
                                      ),
                                      _buildMetricIndicator(
                                        isDarkMode,
                                        label: 'Satisfaction',
                                        value: data['satisfaction'],
                                        color: const Color(0xFF6FCF97),
                                      ),
                                      _buildMetricIndicator(
                                        isDarkMode,
                                        label: 'Task Completion',
                                        value: data['taskCompletion'],
                                        color: const Color(0xFFFFB347),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                const days = [
                                                  'M',
                                                  'T',
                                                  'W',
                                                  'T',
                                                  'F',
                                                  'S',
                                                  'S',
                                                ];
                                                if (value >= 0 &&
                                                    value < days.length) {
                                                  return Text(
                                                    days[value.toInt()],
                                                    style: TextStyle(
                                                      color:
                                                          isDarkMode
                                                              ? Colors.grey
                                                              : Colors
                                                                  .grey
                                                                  .shade600,
                                                      fontSize: 10,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: List.generate(
                                              data['weeklyData'].length,
                                              (index) => FlSpot(
                                                index.toDouble(),
                                                data['weeklyData'][index]
                                                    .toDouble(),
                                              ),
                                            ),
                                            isCurved: true,
                                            color: const Color(0xFF4E7FFF),
                                            barWidth: 3,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: const Color(
                                                0xFF4E7FFF,
                                              ).withValues(alpha: 0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (_, __) => const Center(
                                child: Text('Error loading metrics'),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      isDarkMode,
                      title: 'Pending Approvals',
                      seeAllAction: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: pendingRequests.when(
                          data:
                              (requests) => ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: requests.length,
                                separatorBuilder:
                                    (context, index) => Divider(
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                      height: 1,
                                    ),
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        request.avatar,
                                      ),
                                    ),
                                    title: Text(
                                      request.employeeName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          request.requestType,
                                          style: TextStyle(
                                            color:
                                                isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat(
                                            'MMM d, h:mm a',
                                          ).format(request.requestDate),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.check_circle_outline,
                                            color: const Color(0xFF6FCF97),
                                          ),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.cancel_outlined,
                                            color: const Color(0xFFFF847C),
                                          ),
                                          onPressed: () {},
                                        ),
                                      ],
                                      //),
                                    ),
                                  );
                                },
                              ),
                          loading:
                              () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          error:
                              (_, __) => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('Error loading requests'),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      isDarkMode,
                      title: 'My Team',
                      seeAllAction: () {},
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: teamMembers.when(
                          data:
                              (members) => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  final member = members[index];
                                  return Container(
                                    width: 150,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          isDarkMode
                                              ? const Color(0xFF252525)
                                              : const Color(0xFFF9FAFC),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                member.avatar,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    member.status,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        isDarkMode
                                                            ? const Color(
                                                              0xFF252525,
                                                            )
                                                            : const Color(
                                                              0xFFF9FAFC,
                                                            ),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          member.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member.role,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildIconButton(
                                              icon: Icons.message_outlined,
                                              color: const Color(0xFF4E7FFF),
                                              isDarkMode: isDarkMode,
                                              onPressed: () {},
                                            ),
                                            const SizedBox(width: 8),
                                            _buildIconButton(
                                              icon: Icons.phone_outlined,
                                              color: const Color(0xFF6FCF97),
                                              isDarkMode: isDarkMode,
                                              onPressed: () {},
                                            ),
                                            const SizedBox(width: 8),
                                            _buildIconButton(
                                              icon: Icons.person_outline,
                                              color: const Color(0xFFFFB347),
                                              isDarkMode: isDarkMode,
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (_, __) => const Center(
                                child: Text('Error loading team members'),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      isDarkMode,
                      title: 'Quick Actions',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickAction(
                              context,
                              isDarkMode,
                              icon: Icons.work_outline,
                              label: 'Time Off',
                              color: const Color(0xFF4E7FFF),
                              onTap: () {},
                            ),
                            _buildQuickAction(
                              context,
                              isDarkMode,
                              icon: Icons.assessment_outlined,
                              label: 'Reports',
                              color: const Color(0xFFFFB347),
                              onTap: () {},
                            ),
                            _buildQuickAction(
                              context,
                              isDarkMode,
                              icon: Icons.person_add_outlined,
                              label: 'Recruiting',
                              color: const Color(0xFF6FCF97),
                              onTap: () {},
                            ),
                            _buildQuickAction(
                              context,
                              isDarkMode,
                              icon: Icons.monetization_on_outlined,
                              label: 'Budget',
                              color: const Color(0xFFFF847C),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFF4E7FFF),
        unselectedItemColor:
            isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            label: 'Approvals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4E7FFF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isDarkMode, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDarkMode, {
    required String title,
    required Widget child,
    Function()? seeAllAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (seeAllAction != null)
                TextButton(
                  onPressed: seeAllAction,
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF4E7FFF),
                    ),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildMetricIndicator(
    bool isDarkMode, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required bool isDarkMode,
    required Function() onPressed,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    bool isDarkMode, {
    required IconData icon,
    required String label,
    required Color color,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFF6FCF97);
      case 'busy':
        return const Color(0xFFFF847C);
      case 'leave':
        return const Color(0xFFFFB347);
      default:
        return Colors.grey;
    }
  }
}

// Main app widget
class ManagerSelfServiceApp extends StatelessWidget {
  const ManagerSelfServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Manager Self-Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF4E7FFF),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        darkTheme: ThemeData(
          primaryColor: const Color(0xFF4E7FFF),
          scaffoldBackgroundColor: const Color(0xFF121212),
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const ManagerSelfServiceScreen(),
      ),
    );
  }
}

void main() {
  runApp(const ManagerSelfServiceApp());
}
