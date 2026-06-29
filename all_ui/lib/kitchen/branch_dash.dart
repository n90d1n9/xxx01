import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Models
class Branch {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final int capacity;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.capacity,
    required this.isActive,
  });
}

class Order {
  final String id;
  final String branchId;
  final DateTime createdAt;
  final String status;
  final double totalAmount;
  final String customerName;

  Order({
    required this.id,
    required this.branchId,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.customerName,
  });
}

class Reservation {
  final String id;
  final String branchId;
  final DateTime date;
  final String status;
  final int guestCount;
  final String customerName;
  final String customerPhone;

  Reservation({
    required this.id,
    required this.branchId,
    required this.date,
    required this.status,
    required this.guestCount,
    required this.customerName,
    required this.customerPhone,
  });
}

class RoomReservation {
  final String id;
  final String branchId;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int guestCount;
  final String customerName;
  final String customerPhone;

  RoomReservation({
    required this.id,
    required this.branchId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.guestCount,
    required this.customerName,
    required this.customerPhone,
  });
}

// Providers
final selectedBranchProvider = StateProvider<Branch?>((ref) => null);

final branchesProvider = FutureProvider<List<Branch>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    Branch(
      id: '1',
      name: 'Downtown Branch',
      address: '123 Main St',
      phoneNumber: '+1 555-123-4567',
      capacity: 120,
      isActive: true,
    ),
    Branch(
      id: '2',
      name: 'Waterfront Branch',
      address: '456 Bay Ave',
      phoneNumber: '+1 555-987-6543',
      capacity: 85,
      isActive: true,
    ),
    Branch(
      id: '3',
      name: 'Uptown Branch',
      address: '789 High St',
      phoneNumber: '+1 555-456-7890',
      capacity: 60,
      isActive: false,
    ),
  ];
});

final ordersProvider = FutureProvider.family<List<Order>, String>((
  ref,
  branchId,
) async {
  // Simulate API call
  await Future.delayed(const Duration(milliseconds: 800));
  return List.generate(
    10,
    (index) => Order(
      id: 'ORD${branchId}${1000 + index}',
      branchId: branchId,
      createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
      status: ['Completed', 'In Progress', 'Pending'][index % 3],
      totalAmount: (50 + index * 10).toDouble(),
      customerName: 'Customer ${1000 + index}',
    ),
  );
});

final reservationsProvider = FutureProvider.family<List<Reservation>, String>((
  ref,
  branchId,
) async {
  // Simulate API call
  await Future.delayed(const Duration(milliseconds: 800));
  return List.generate(
    8,
    (index) => Reservation(
      id: 'RES${branchId}${1000 + index}',
      branchId: branchId,
      date: DateTime.now().add(Duration(hours: 24 + index * 4)),
      status: ['Confirmed', 'Pending', 'Cancelled'][index % 3],
      guestCount: 2 + (index % 6),
      customerName: 'Guest ${1000 + index}',
      customerPhone: '+1 555-${100 + index}-${1000 + index}',
    ),
  );
});

final roomReservationsProvider =
    FutureProvider.family<List<RoomReservation>, String>((ref, branchId) async {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      return List.generate(
        5,
        (index) => RoomReservation(
          id: 'ROOM${branchId}${1000 + index}',
          branchId: branchId,
          roomName:
              [
                'Private Dining',
                'Conference Room',
                'Banquet Hall',
                'Wine Cellar',
                'Rooftop Lounge',
              ][index % 5],
          startTime: DateTime.now().add(Duration(days: index, hours: 17)),
          endTime: DateTime.now().add(Duration(days: index, hours: 20)),
          status: ['Confirmed', 'Pending', 'Paid'][index % 3],
          guestCount: 10 + (index * 5),
          customerName: 'Event Host ${1000 + index}',
          customerPhone: '+1 555-${200 + index}-${2000 + index}',
        ),
      );
    });

final dashboardStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, branchId) async {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return {
        'todayOrders': 24,
        'pendingOrders': 8,
        'todayRevenue': 3250.75,
        'todayReservations': 15,
        'pendingReservations': 7,
        'roomReservations': 3,
        'averageOrderValue': 135.45,
        'dailyRevenueStats': [
          2800.50,
          3100.25,
          2950.75,
          3250.75,
          3400.25,
          3150.50,
          3300.25,
        ],
        'reservationStats': [12, 15, 10, 18, 22, 16, 14],
      };
    });

// Dashboard screen

class RestaurantBranchDashboard extends ConsumerStatefulWidget {
  const RestaurantBranchDashboard({super.key});

  @override
  ConsumerState<RestaurantBranchDashboard> createState() =>
      _RestaurantBranchDashboardState();
}

class _RestaurantBranchDashboardState
    extends ConsumerState<RestaurantBranchDashboard> {
  @override
  void initState() {
    super.initState();
    // Delayed initialization to avoid build-time provider modifications
    Future.microtask(() {
      final branchesAsyncValue = ref.read(branchesProvider);
      branchesAsyncValue.whenData((branchList) {
        if (ref.read(selectedBranchProvider) == null && branchList.isNotEmpty) {
          ref.read(selectedBranchProvider.notifier).state = branchList.first;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchesProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            radius: 16,
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: branches.when(
        data: (branchList) {
          // No auto-selection here anymore - moved to initState with Future.microtask
          /*  if (selectedBranch == null && branchList.isNotEmpty) {
            ref.read(selectedBranchProvider.notifier).state = branchList.first;
          } */
          return Row(
            children: [
              // Sidebar
              NavigationRail(
                extended: true,
                minExtendedWidth: 200,
                selectedIndex: 0,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.03),
                onDestinationSelected: (index) {},
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    selectedIcon: Icon(Icons.restaurant_menu),
                    label: Text('Menu'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: Text('Orders'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event_outlined),
                    selectedIcon: Icon(Icons.event),
                    label: Text('Reservations'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: Text('Customers'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics),
                    label: Text('Analytics'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),

              // Main content
              Expanded(
                child:
                    selectedBranch != null
                        ? _buildDashboardContent(context, ref, selectedBranch)
                        : const Center(child: Text('Please select a branch')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider(branch.id));
    final theme = Theme.of(context);

    return dashboardStatsAsync.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch selector and info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Dashboard',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  _buildBranchSelector(ref, branch),
                ],
              ),
              const SizedBox(height: 32),

              // Stats summary cards
              Row(
                children: [
                  _buildStatCard(
                    context,
                    'Today\'s Orders',
                    stats['todayOrders'].toString(),
                    Icons.shopping_bag_outlined,
                    Colors.blue,
                    '+${stats['pendingOrders']} pending',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Today\'s Revenue',
                    '\$${stats['todayRevenue']}',
                    Icons.attach_money,
                    Colors.green,
                    'Avg. order: \$${stats['averageOrderValue']}',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Reservations',
                    stats['todayReservations'].toString(),
                    Icons.calendar_today_outlined,
                    Colors.orange,
                    '+${stats['pendingReservations']} pending',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Room Bookings',
                    stats['roomReservations'].toString(),
                    Icons.meeting_room_outlined,
                    Colors.purple,
                    'Today',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Charts row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue chart
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Revenue (Last 7 Days)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildRevenueChart(
                              stats['dailyRevenueStats'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Reservations chart
                  Expanded(
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reservations',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildReservationsChart(
                              stats['reservationStats'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent orders and upcoming reservations
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent orders
                  Expanded(
                    child: _buildRecentOrdersSection(context, ref, branch.id),
                  ),
                  const SizedBox(width: 24),

                  // Upcoming reservations
                  Expanded(
                    child: _buildUpcomingReservationsSection(
                      context,
                      ref,
                      branch.id,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Room reservations
              _buildRoomReservationsSection(context, ref, branch.id),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(child: Text('Error loading dashboard: $err')),
    );
  }

  Widget _buildBranchSelector(WidgetRef ref, Branch currentBranch) {
    final branchesAsync = ref.watch(branchesProvider);

    return branchesAsync.when(
      data: (branches) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentBranch.id,
              icon: const Icon(Icons.keyboard_arrow_down),
              borderRadius: BorderRadius.circular(12),
              items:
                  branches.map((Branch branch) {
                    return DropdownMenuItem<String>(
                      value: branch.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.store,
                            color: branch.isActive ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(branch.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? branchId) {
                if (branchId != null) {
                  final newBranch = branches.firstWhere(
                    (b) => b.id == branchId,
                  );
                  ref.read(selectedBranchProvider.notifier).state = newBranch;
                }
              },
            ),
          ),
        );
      },
      loading:
          () => const SizedBox(
            width: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      error: (_, __) => const Text('Error loading branches'),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value >= 0 && value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final formattedValue = (value / 1000).toStringAsFixed(1);
                return Text(
                  '\$$formattedValue',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 4000,
        lineBarsData: [
          LineChartBarData(
            spots:
                data.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsChart(List<dynamic> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 25,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value >= 0 && value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 5 == 0 && value != 0) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: Colors.orange,
                    width: 12,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRecentOrdersSection(
    BuildContext context,
    WidgetRef ref,
    String branchId,
  ) {
    final ordersAsync = ref.watch(ordersProvider(branchId));
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View All'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ordersAsync.when(
            data: (orders) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length > 5 ? 5 : orders.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          order.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.receipt_outlined,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ),
                    title: Text(
                      'Order #${order.id.substring(order.id.length - 4)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${order.customerName} • ${DateFormat('h:mm a').format(order.createdAt)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  );
                },
              );
            },
            loading:
                () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error loading orders: $err'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReservationsSection(
    BuildContext context,
    WidgetRef ref,
    String branchId,
  ) {
    final reservationsAsync = ref.watch(reservationsProvider(branchId));
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Reservations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View All'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          reservationsAsync.when(
            data: (reservations) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reservations.length > 5 ? 5 : reservations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          reservation.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.event_outlined,
                          color: _getStatusColor(reservation.status),
                        ),
                      ),
                    ),
                    title: Text(
                      reservation.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${reservation.guestCount} guests • ${DateFormat('MMM d, h:mm a').format(reservation.date)}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          reservation.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reservation.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(reservation.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {},
                  );
                },
              );
            },
            loading:
                () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error loading reservations: $err'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomReservationsSection(
    BuildContext context,
    WidgetRef ref,
    String branchId,
  ) {
    final roomReservationsAsync = ref.watch(roomReservationsProvider(branchId));
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room Reservations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View All'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          roomReservationsAsync.when(
            data: (roomReservations) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Room',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          'Customer',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Time',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Guests',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Status',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ...roomReservations.map((reservation) {
                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.meeting_room_outlined,
                                      color: Colors.purple,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reservation.roomName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(reservation.customerName),
                          Text(
                            '${DateFormat('h:mm a').format(reservation.startTime)} - ${DateFormat('h:mm a').format(reservation.endTime)}',
                          ),
                          Text(reservation.guestCount.toString()),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                reservation.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reservation.status,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(reservation.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            },
            loading:
                () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error loading room reservations: $err'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'confirmed':
      case 'paid':
        return Colors.green;
      case 'in progress':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// Main app widget
class RestaurantDashboardApp extends StatelessWidget {
  const RestaurantDashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Restaurant Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          fontFamily: 'Inter',
        ),
        home: const RestaurantBranchDashboard(),
      ),
    );
  }
}

// Entry point
void main() {
  runApp(const RestaurantDashboardApp());
}
