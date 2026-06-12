// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RevenueTrackingScreen(),
    const ProfitLossScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                label: Text('Revenue Tracking'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance),
                label: Text('Profit/Loss Analysis'),
              ),
            ],
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// Revenue Tracking Screen
class RevenueTrackingScreen extends ConsumerWidget {
  const RevenueTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueState = ref.watch(revenueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(revenueProvider.notifier).refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
            },
          ),
        ],
      ),
      body: revenueState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) => _buildRevenueContent(context, data),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new invoice/client
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRevenueContent(BuildContext context, RevenueData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Revenue',
                    value:
                        '\$${NumberFormat('#,###').format(data.totalRevenue)}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                    change: '+12%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Outstanding Invoices',
                    value:
                        '\$${NumberFormat('#,###').format(data.outstandingAmount)}',
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                    change: data.outstandingCount.toString(),
                    changeLabel: 'invoices',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Upcoming Milestones',
                    value: data.upcomingMilestones.toString(),
                    icon: Icons.event,
                    color: Colors.blue,
                    change:
                        'Next: ${DateFormat('MMM d').format(data.nextMilestoneDate)}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Two column layout for main content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Outstanding Invoices'),
                      Expanded(
                        child: OutstandingInvoicesTable(
                          invoices: data.invoices,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Revenue Recognition Timeline',
                      ),
                      Expanded(
                        child: RevenueTimelineChart(data: data.revenueTimeline),
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Client Billing Status'),
                      Expanded(
                        child: ClientBillingStatusWidget(clients: data.clients),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Milestone payment schedule
          const SectionHeader(title: 'Milestone Payment Schedule'),
          SizedBox(
            height: 200,
            child: MilestonePaymentSchedule(milestones: data.milestones),
          ),
        ],
      ),
    );
  }
}

// Profit/Loss Analysis Screen
class ProfitLossScreen extends ConsumerWidget {
  const ProfitLossScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profitLossState = ref.watch(profitLossProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit/Loss Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Print report
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Show date range picker
            },
          ),
        ],
      ),
      body: profitLossState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) => _buildProfitLossContent(context, data),
      ),
    );
  }

  Widget _buildProfitLossContent(BuildContext context, ProfitLossData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Net Profit',
                    value: '\$${NumberFormat('#,###').format(data.netProfit)}',
                    icon: Icons.show_chart,
                    color: data.netProfit >= 0 ? Colors.green : Colors.red,
                    change: '${data.profitMargin.toStringAsFixed(1)}%',
                    changeLabel: 'margin',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Revenue',
                    value:
                        '\$${NumberFormat('#,###').format(data.totalRevenue)}',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                    change: '+${data.revenueGrowth.toStringAsFixed(1)}%',
                    changeLabel: 'YoY',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Expenses',
                    value:
                        '\$${NumberFormat('#,###').format(data.totalExpenses)}',
                    icon: Icons.trending_down,
                    color: Colors.orange,
                    change: '${data.expenseGrowth.toStringAsFixed(1)}%',
                    changeLabel: 'YoY',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Two column layout for main content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'P&L Statement'),
                      Expanded(child: PLStatementTable(data: data.plStatement)),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Break-even Visualization'),
                      Expanded(child: BreakEvenChart(data: data.breakEvenData)),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Profitability Forecast'),
                      Expanded(
                        child: ProfitabilityForecastChart(
                          data: data.profitabilityForecast,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Project phase margin analysis
          const SectionHeader(title: 'Margin Analysis by Project Phase'),
          SizedBox(
            height: 220,
            child: MarginAnalysisChart(data: data.marginByPhase),
          ),
        ],
      ),
    );
  }
}

// models/models.dart
class RevenueData {
  final double totalRevenue;
  final double outstandingAmount;
  final int outstandingCount;
  final int upcomingMilestones;
  final DateTime nextMilestoneDate;
  final List<Invoice> invoices;
  final List<Client> clients;
  final List<Milestone> milestones;
  final List<MonthlyRevenue> revenueTimeline;

  RevenueData({
    required this.totalRevenue,
    required this.outstandingAmount,
    required this.outstandingCount,
    required this.upcomingMilestones,
    required this.nextMilestoneDate,
    required this.invoices,
    required this.clients,
    required this.milestones,
    required this.revenueTimeline,
  });
}

class ProfitLossData {
  final double netProfit;
  final double profitMargin;
  final double totalRevenue;
  final double revenueGrowth;
  final double totalExpenses;
  final double expenseGrowth;
  final List<PLStatement> plStatement;
  final List<BreakEvenPoint> breakEvenData;
  final List<ProfitForecast> profitabilityForecast;
  final List<PhaseMargin> marginByPhase;

  ProfitLossData({
    required this.netProfit,
    required this.profitMargin,
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalExpenses,
    required this.expenseGrowth,
    required this.plStatement,
    required this.breakEvenData,
    required this.profitabilityForecast,
    required this.marginByPhase,
  });
}

class Invoice {
  final String id;
  final String clientName;
  final double amount;
  final DateTime dueDate;
  final DateTime issuedDate;
  final String status;

  Invoice({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.dueDate,
    required this.issuedDate,
    required this.status,
  });
}

class Client {
  final String name;
  final double totalBilled;
  final double paid;
  final double outstanding;
  final String status;

  Client({
    required this.name,
    required this.totalBilled,
    required this.paid,
    required this.outstanding,
    required this.status,
  });
}

class Milestone {
  final String projectName;
  final String description;
  final double amount;
  final DateTime dueDate;
  final String status;

  Milestone({
    required this.projectName,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

class MonthlyRevenue {
  final DateTime month;
  final double recognized;
  final double projected;

  MonthlyRevenue({
    required this.month,
    required this.recognized,
    required this.projected,
  });
}

class PLStatement {
  final String category;
  final double amount;
  final double previousAmount;
  final double change;
  final bool isTotal;

  PLStatement({
    required this.category,
    required this.amount,
    required this.previousAmount,
    required this.change,
    this.isTotal = false,
  });
}

class BreakEvenPoint {
  final double revenue;
  final double fixedCosts;
  final double variableCosts;
  final double units;

  BreakEvenPoint({
    required this.revenue,
    required this.fixedCosts,
    required this.variableCosts,
    required this.units,
  });
}

class ProfitForecast {
  final DateTime date;
  final double bestCase;
  final double expected;
  final double worstCase;

  ProfitForecast({
    required this.date,
    required this.bestCase,
    required this.expected,
    required this.worstCase,
  });
}

class PhaseMargin {
  final String phase;
  final double revenue;
  final double cost;
  final double margin;

  PhaseMargin({
    required this.phase,
    required this.revenue,
    required this.cost,
    required this.margin,
  });
}

// providers/providers.dart

final revenueProvider =
    StateNotifierProvider<RevenueNotifier, AsyncValue<RevenueData>>((ref) {
      return RevenueNotifier();
    });

class RevenueNotifier extends StateNotifier<AsyncValue<RevenueData>> {
  RevenueNotifier() : super(const AsyncLoading()) {
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockData = RevenueData(
        totalRevenue: 458750.0,
        outstandingAmount: 87500.0,
        outstandingCount: 5,
        upcomingMilestones: 8,
        nextMilestoneDate: DateTime.now().add(const Duration(days: 12)),
        invoices: _getMockInvoices(),
        clients: _getMockClients(),
        milestones: _getMockMilestones(),
        revenueTimeline: _getMockRevenueTimeline(),
      );

      state = AsyncData(mockData);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void refreshData() {
    state = const AsyncLoading();
    _fetchData();
  }

  List<Invoice> _getMockInvoices() {
    return [
      Invoice(
        id: 'INV-2025-001',
        clientName: 'Acme Corporation',
        amount: 25000.0,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        issuedDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'Pending',
      ),
      Invoice(
        id: 'INV-2025-002',
        clientName: 'TechGlobal Inc.',
        amount: 18500.0,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        issuedDate: DateTime.now().subtract(const Duration(days: 25)),
        status: 'Overdue',
      ),
      Invoice(
        id: 'INV-2025-003',
        clientName: 'Stark Industries',
        amount: 34000.0,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        issuedDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Pending',
      ),
      Invoice(
        id: 'INV-2025-004',
        clientName: 'Wayne Enterprises',
        amount: 10000.0,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        issuedDate: DateTime.now().subtract(const Duration(days: 32)),
        status: 'Overdue',
      ),
    ];
  }

  List<Client> _getMockClients() {
    return [
      Client(
        name: 'Acme Corporation',
        totalBilled: 120000.0,
        paid: 95000.0,
        outstanding: 25000.0,
        status: 'Active',
      ),
      Client(
        name: 'TechGlobal Inc.',
        totalBilled: 82500.0,
        paid: 64000.0,
        outstanding: 18500.0,
        status: 'Active',
      ),
      Client(
        name: 'Stark Industries',
        totalBilled: 98000.0,
        paid: 64000.0,
        outstanding: 34000.0,
        status: 'Active',
      ),
      Client(
        name: 'Wayne Enterprises',
        totalBilled: 35000.0,
        paid: 25000.0,
        outstanding: 10000.0,
        status: 'Inactive',
      ),
    ];
  }

  List<Milestone> _getMockMilestones() {
    return [
      Milestone(
        projectName: 'Acme Web Platform',
        description: 'Phase 1 Completion',
        amount: 40000.0,
        dueDate: DateTime.now().add(const Duration(days: 12)),
        status: 'Upcoming',
      ),
      Milestone(
        projectName: 'TechGlobal Mobile App',
        description: 'Beta Launch',
        amount: 25000.0,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: 'Upcoming',
      ),
      Milestone(
        projectName: 'Stark Industries Dashboard',
        description: 'Final Delivery',
        amount: 50000.0,
        dueDate: DateTime.now().add(const Duration(days: 45)),
        status: 'Upcoming',
      ),
      Milestone(
        projectName: 'Wayne Enterprises CRM',
        description: 'User Acceptance Testing',
        amount: 15000.0,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completed',
      ),
    ];
  }

  List<MonthlyRevenue> _getMockRevenueTimeline() {
    final now = DateTime.now();
    final List<MonthlyRevenue> data = [];

    for (int i = -5; i <= 6; i++) {
      final month = DateTime(now.year, now.month + i);
      final recognized = i <= 0
          ? 80000.0 + (i * 5000.0) + (10000.0 * (i.abs() % 3))
          : 0.0;
      final projected = i >= 0
          ? 80000.0 + (i * 6000.0) + (12000.0 * (i % 4))
          : 0.0;

      data.add(
        MonthlyRevenue(
          month: month,
          recognized: recognized,
          projected: projected,
        ),
      );
    }

    return data;
  }
}

final profitLossProvider =
    StateNotifierProvider<ProfitLossNotifier, AsyncValue<ProfitLossData>>((
      ref,
    ) {
      return ProfitLossNotifier();
    });

class ProfitLossNotifier extends StateNotifier<AsyncValue<ProfitLossData>> {
  ProfitLossNotifier() : super(const AsyncLoading()) {
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockData = ProfitLossData(
        netProfit: 125750.0,
        profitMargin: 27.4,
        totalRevenue: 458750.0,
        revenueGrowth: 18.7,
        totalExpenses: 333000.0,
        expenseGrowth: 14.2,
        plStatement: _getMockPLStatement(),
        breakEvenData: _getMockBreakEvenData(),
        profitabilityForecast: _getMockProfitForecast(),
        marginByPhase: _getMockMarginByPhase(),
      );

      state = AsyncData(mockData);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  List<PLStatement> _getMockPLStatement() {
    return [
      PLStatement(
        category: 'Revenue',
        amount: 458750.0,
        previousAmount: 386500.0,
        change: 18.7,
      ),
      PLStatement(
        category: 'Cost of Services',
        amount: 245000.0,
        previousAmount: 215000.0,
        change: 14.0,
      ),
      PLStatement(
        category: 'Gross Profit',
        amount: 213750.0,
        previousAmount: 171500.0,
        change: 24.6,
        isTotal: true,
      ),
      PLStatement(
        category: 'Operating Expenses',
        amount: 58000.0,
        previousAmount: 52000.0,
        change: 11.5,
      ),
      PLStatement(
        category: 'Administrative Expenses',
        amount: 30000.0,
        previousAmount: 28000.0,
        change: 7.1,
      ),
      PLStatement(
        category: 'Net Profit',
        amount: 125750.0,
        previousAmount: 91500.0,
        change: 37.4,
        isTotal: true,
      ),
    ];
  }

  List<BreakEvenPoint> _getMockBreakEvenData() {
    return List.generate(10, (index) {
      final units = (index + 1) * 25.0;
      final fixedCosts = 50000.0;
      final variableCostsPerUnit = 400.0;
      final pricePerUnit = 750.0;

      return BreakEvenPoint(
        units: units,
        fixedCosts: fixedCosts,
        variableCosts: variableCostsPerUnit * units,
        revenue: pricePerUnit * units,
      );
    });
  }

  List<ProfitForecast> _getMockProfitForecast() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month + index);
      final base = 20000.0 + (index * 5000.0);

      return ProfitForecast(
        date: month,
        worstCase: base * 0.6,
        expected: base,
        bestCase: base * 1.3,
      );
    });
  }

  List<PhaseMargin> _getMockMarginByPhase() {
    return [
      PhaseMargin(
        phase: 'Discovery',
        revenue: 80000.0,
        cost: 45000.0,
        margin: 43.75,
      ),
      PhaseMargin(
        phase: 'Design',
        revenue: 120000.0,
        cost: 65000.0,
        margin: 45.83,
      ),
      PhaseMargin(
        phase: 'Development',
        revenue: 180000.0,
        cost: 110000.0,
        margin: 38.89,
      ),
      PhaseMargin(
        phase: 'Testing',
        revenue: 50000.0,
        cost: 35000.0,
        margin: 30.0,
      ),
      PhaseMargin(
        phase: 'Deployment',
        revenue: 28750.0,
        cost: 18000.0,
        margin: 37.39,
      ),
    ];
  }
}

// widgets/widgets.dart

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final String? changeLabel;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    this.changeLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                      if (changeLabel != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          changeLabel!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
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

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }
}

class OutstandingInvoicesTable extends StatelessWidget {
  final List<Invoice> invoices;

  const OutstandingInvoicesTable({Key? key, required this.invoices})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Invoice',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Client',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Due Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(invoice.id)),
                        Expanded(flex: 3, child: Text(invoice.clientName)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${NumberFormat('#,###').format(invoice.amount)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('MMM d, yyyy').format(invoice.dueDate),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: invoice.status == 'Pending'
                                    ? Colors.blue.withOpacity(0.2)
                                    : invoice.status == 'Overdue'
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                invoice.status,
                                style: TextStyle(
                                  color: invoice.status == 'Pending'
                                      ? Colors.blue
                                      : invoice.status == 'Overdue'
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                            tooltip: 'More options',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientBillingStatusWidget extends StatelessWidget {
  final List<Client> clients;

  const ClientBillingStatusWidget({Key? key, required this.clients})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: clients.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final client = clients[index];
            final paidPercentage = client.paid / client.totalBilled * 100;

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: \$${NumberFormat('#,###').format(client.totalBilled)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${paidPercentage.toStringAsFixed(1)}% Paid',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '\$${NumberFormat('#,###').format(client.outstanding)} outstanding',
                            style: TextStyle(
                              color: client.outstanding > 0
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: client.paid / client.totalBilled,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RevenueTimelineChart extends StatelessWidget {
  final List<MonthlyRevenue> data;

  const RevenueTimelineChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 20000,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('MMM').format(data[value.toInt()].month),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '\$${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            minX: 0,
            maxX: data.length.toDouble() - 1,
            minY: 0,
            maxY: 150000,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].recognized);
                }),
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].projected);
                }),
                isCurved: true,
                color: Colors.grey.shade500,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MilestonePaymentSchedule extends StatelessWidget {
  final List<Milestone> milestones;

  const MilestonePaymentSchedule({Key? key, required this.milestones})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Project',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Milestone',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Due Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  final daysUntilDue = milestone.dueDate
                      .difference(DateTime.now())
                      .inDays;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(milestone.projectName)),
                        Expanded(flex: 3, child: Text(milestone.description)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${NumberFormat('#,###').format(milestone.amount)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MMM d').format(milestone.dueDate),
                              ),
                              const SizedBox(width: 4),
                              if (milestone.status == 'Upcoming' &&
                                  daysUntilDue <= 14)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: daysUntilDue <= 7
                                        ? Colors.red.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    daysUntilDue <= 0
                                        ? 'Today'
                                        : '$daysUntilDue days',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: daysUntilDue <= 7
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: milestone.status == 'Upcoming'
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                milestone.status,
                                style: TextStyle(
                                  color: milestone.status == 'Upcoming'
                                      ? Colors.blue
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PLStatementTable extends StatelessWidget {
  final List<PLStatement> data;

  const PLStatementTable({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Previous',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Change',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontWeight: item.isTotal
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${NumberFormat('#,###').format(item.amount)}',
                            style: TextStyle(
                              fontWeight: item.isTotal
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${NumberFormat('#,###').format(item.previousAmount)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: item.isTotal
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item.change != 0)
                                Icon(
                                  item.change > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                      item.category == 'Cost of Services' ||
                                          item.category ==
                                              'Operating Expenses' ||
                                          item.category ==
                                              'Administrative Expenses'
                                      ? (item.change > 0
                                            ? Colors.red
                                            : Colors.green)
                                      : (item.change > 0
                                            ? Colors.green
                                            : Colors.red),
                                  size: 16,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.change.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color:
                                      item.category == 'Cost of Services' ||
                                          item.category ==
                                              'Operating Expenses' ||
                                          item.category ==
                                              'Administrative Expenses'
                                      ? (item.change > 0
                                            ? Colors.red
                                            : Colors.green)
                                      : (item.change > 0
                                            ? Colors.green
                                            : Colors.red),
                                  fontWeight: item.isTotal
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreakEvenChart extends StatelessWidget {
  final List<BreakEvenPoint> data;

  const BreakEvenChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find break-even point
    double? breakEvenUnits;
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i].revenue < data[i].fixedCosts + data[i].variableCosts &&
          data[i + 1].revenue >=
              data[i + 1].fixedCosts + data[i + 1].variableCosts) {
        breakEvenUnits = data[i + 1].units;
        break;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() % 2 == 0 &&
                        value.toInt() >= 0 &&
                        value.toInt() < data.length) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          data[value.toInt()].units.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '\$${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            minX: 0,
            maxX: data.length.toDouble() - 1,
            minY: 0,
            maxY: 200000,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                //tooltipBgColor: Colors.blueGrey.shade800,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final dataPoint = data[spot.x.toInt()];
                    String tooltipText = '';

                    if (spot.bar.color ==
                        Theme.of(context).colorScheme.primary) {
                      tooltipText =
                          'Revenue: \$${NumberFormat('#,###').format(dataPoint.revenue)}';
                    } else if (spot.bar.color == Colors.red) {
                      tooltipText =
                          'Total Cost: \$${NumberFormat('#,###').format(dataPoint.fixedCosts + dataPoint.variableCosts)}';
                    } else if (spot.bar.color == Colors.orange) {
                      tooltipText =
                          'Fixed Cost: \$${NumberFormat('#,###').format(dataPoint.fixedCosts)}';
                    }

                    return LineTooltipItem(
                      tooltipText,
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            extraLinesData: ExtraLinesData(
              verticalLines: breakEvenUnits != null
                  ? [
                      VerticalLine(
                        x: data
                            .indexWhere((d) => d.units >= breakEvenUnits!)
                            .toDouble(),
                        color: Colors.green.shade800,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: VerticalLineLabel(
                          show: true,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(bottom: 8),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                          labelResolver: (_) => 'Break-even',
                        ),
                      ),
                    ]
                  : [],
            ),
            lineBarsData: [
              // Revenue line
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].revenue);
                }),
                isCurved: false,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
              // Total Cost line
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(
                    i.toDouble(),
                    data[i].fixedCosts + data[i].variableCosts,
                  );
                }),
                isCurved: false,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
              // Fixed Cost line
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].fixedCosts);
                }),
                isCurved: false,
                color: Colors.orange,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfitabilityForecastChart extends StatelessWidget {
  final List<ProfitForecast> data;

  const ProfitabilityForecastChart({Key? key, required this.data})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('MMM').format(data[value.toInt()].date),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '\$${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            minX: 0,
            maxX: data.length.toDouble() - 1,
            minY: 0,
            maxY: 60000,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                //tooltipBgColor: Colors.blueGrey.shade800,
              ),
            ),
            lineBarsData: [
              // Best case
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].bestCase);
                }),
                isCurved: true,
                color: Colors.green,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                dashArray: [5, 5],
              ),
              // Expected case
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].expected);
                }),
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              // Worst case
              LineChartBarData(
                spots: List.generate(data.length, (i) {
                  return FlSpot(i.toDouble(), data[i].worstCase);
                }),
                isCurved: true,
                color: Colors.orange,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarginAnalysisChart extends StatelessWidget {
  final List<PhaseMargin> data;

  const MarginAnalysisChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side - Bar chart
            Expanded(
              flex: 3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      data
                          .map((e) => e.revenue)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barGroups: List.generate(
                    data.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index].revenue,
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data[index].cost,
                          color: Theme.of(context).colorScheme.error,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < data.length) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                data[value.toInt()].phase,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '\$${(value / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    drawVerticalLine: false,
                  ),
                ),
              ),
            ),

            // Right side - Margin percentages
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Revenue'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Cost'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Profit Margins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.phase),
                                Text(
                                  '${item.margin.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: item.margin >= 40
                                        ? Colors.green
                                        : item.margin >= 30
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Average Margin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(data.map((e) => e.margin).reduce((a, b) => a + b) / data.length).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
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
}
