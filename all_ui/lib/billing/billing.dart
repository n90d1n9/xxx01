import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Tenant {
  final String id;
  final String name;
  final String logoUrl;
  final String planName;
  final double currentBalance;

  Tenant({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.planName,
    required this.currentBalance,
  });
}

class BillingInvoice {
  final String id;
  final String tenantId;
  final double amount;
  final DateTime date;
  final String status;

  BillingInvoice({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.date,
    required this.status,
  });
}

// Providers
final currentTenantProvider = StateProvider<String>((ref) => '');

final tenantsProvider = FutureProvider<List<Tenant>>((ref) async {
  // In a real app, fetch from API
  await Future.delayed(Duration(seconds: 1));
  return [
    Tenant(
      id: 'tenant-001',
      name: 'Acme Corporation',
      logoUrl:
          'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon',
      planName: 'Enterprise',
      currentBalance: 4750.50,
    ),
    Tenant(
      id: 'tenant-002',
      name: 'Globex Industries',
      logoUrl:
          'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon',
      planName: 'Professional',
      currentBalance: 2300.75,
    ),
    Tenant(
      id: 'tenant-003',
      name: 'Stark Enterprises',
      logoUrl:
          'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon',
      planName: 'Standard',
      currentBalance: 950.25,
    ),
  ];
});

final invoicesProvider = FutureProvider.family<List<BillingInvoice>, String>((
  ref,
  tenantId,
) async {
  // In a real app, fetch from API based on tenantId
  await Future.delayed(Duration(seconds: 1));

  return [
    BillingInvoice(
      id: 'inv-101',
      tenantId: tenantId,
      amount: 1500.00,
      date: DateTime.now().subtract(Duration(days: 5)),
      status: 'Paid',
    ),
    BillingInvoice(
      id: 'inv-102',
      tenantId: tenantId,
      amount: 1250.50,
      date: DateTime.now().subtract(Duration(days: 35)),
      status: 'Paid',
    ),
    BillingInvoice(
      id: 'inv-103',
      tenantId: tenantId,
      amount: 2000.00,
      date: DateTime.now().add(Duration(days: 10)),
      status: 'Pending',
    ),
  ];
});

final billingStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tenantId) async {
      // In a real app, fetch from API based on tenantId
      await Future.delayed(Duration(seconds: 1));

      return {
        'totalBilled': 5750.50,
        'pendingAmount': 2000.00,
        'overdue': 0.00,
        'nextBillingDate': DateTime.now().add(Duration(days: 10)),
        'usageData': [
          {'date': 'Jan', 'amount': 800},
          {'date': 'Feb', 'amount': 1200},
          {'date': 'Mar', 'amount': 1000},
          {'date': 'Apr', 'amount': 1500},
          {'date': 'May', 'amount': 1750},
        ],
      };
    });

// UI Components
class BillingDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTenantId = ref.watch(currentTenantProvider);
    final tenantsAsync = ref.watch(tenantsProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Billing Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6366F1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MultiTenant Billing',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your tenants billing',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
              selected: true,
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_outlined),
              title: Text('Invoices'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('Tenants'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.payments_outlined),
              title: Text('Payment Methods'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.insights_outlined),
              title: Text('Reports'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: tenantsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading tenants')),
        data: (tenants) {
          // Set a default tenant if none is selected
          if (currentTenantId.isEmpty && tenants.isNotEmpty) {
            Future.microtask(
              () =>
                  ref.read(currentTenantProvider.notifier).state =
                      tenants.first.id,
            );
          }

          // Get the selected tenant
          final selectedTenant = tenants.firstWhere(
            (t) => t.id == currentTenantId,
            orElse:
                () =>
                    tenants.isNotEmpty
                        ? tenants.first
                        : Tenant(
                          id: '',
                          name: 'No Tenant',
                          logoUrl: '',
                          planName: '',
                          currentBalance: 0,
                        ),
          );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tenant selector
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Current Tenant: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: selectedTenant.id,
                                isExpanded: true,
                                underline: SizedBox(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    ref
                                        .read(currentTenantProvider.notifier)
                                        .state = newValue;
                                  }
                                },
                                items:
                                    tenants.map<DropdownMenuItem<String>>((
                                      Tenant tenant,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: tenant.id,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundImage: NetworkImage(
                                                tenant.logoUrl,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(tenant.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Tenant info card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedTenant.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${selectedTenant.planName} Plan',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    selectedTenant.logoUrl,
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${selectedTenant.currentBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text('Pay Now'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF6366F1),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: Text('Invoice History'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Stats section
                      Text(
                        'Billing Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  height: 120,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final statsAsync = ref.watch(
                        billingStatsProvider(selectedTenant.id),
                      );

                      return statsAsync.when(
                        loading:
                            () => Center(child: CircularProgressIndicator()),
                        error:
                            (err, stack) =>
                                Center(child: Text('Error loading stats')),
                        data: (stats) {
                          final formatter = NumberFormat.currency(symbol: '\$');
                          final nextBillingDate = DateFormat(
                            'MMM d, yyyy',
                          ).format(stats['nextBillingDate']);

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _buildStatCard(
                                title: 'Total Billed',
                                value: formatter.format(stats['totalBilled']),
                                color: Color(0xFF10B981),
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                              _buildStatCard(
                                title: 'Pending',
                                value: formatter.format(stats['pendingAmount']),
                                color: Color(0xFFF59E0B),
                                icon: Icons.pending_actions_outlined,
                              ),
                              _buildStatCard(
                                title: 'Overdue',
                                value: formatter.format(stats['overdue']),
                                color: Color(0xFFEF4444),
                                icon: Icons.warning_amber_outlined,
                              ),
                              _buildStatCard(
                                title: 'Next Billing',
                                value: nextBillingDate,
                                color: Color(0xFF6366F1),
                                icon: Icons.event_outlined,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Invoices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Recent invoices
              Consumer(
                builder: (context, ref, child) {
                  final invoicesAsync = ref.watch(
                    invoicesProvider(selectedTenant.id),
                  );

                  return invoicesAsync.when(
                    loading:
                        () => SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    error:
                        (err, stack) => SliverToBoxAdapter(
                          child: Center(child: Text('Error loading invoices')),
                        ),
                    data: (invoices) {
                      return SliverList.builder(
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          final dateFormatted = DateFormat(
                            'MMM d, yyyy',
                          ).format(invoice.date);

                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                'Invoice #${invoice.id}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(dateFormatted),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${invoice.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          invoice.status == 'Paid'
                                              ? Color(
                                                0xFF10B981,
                                              ).withValues(alpha: 0.1)
                                              : Color(
                                                0xFFF59E0B,
                                              ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      invoice.status,
                                      style: TextStyle(
                                        color:
                                            invoice.status == 'Paid'
                                                ? Color(0xFF10B981)
                                                : Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // View invoice details
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new invoice
        },
        backgroundColor: Color(0xFF6366F1),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              Spacer(),
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }
}

// Main app
void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'MultiTenant Billing',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color(0xFFF7F9FC),
          fontFamily: 'Inter',
        ),
        debugShowCheckedModeBanner: false,
        home: BillingDashboardScreen(),
      ),
    ),
  );
}
