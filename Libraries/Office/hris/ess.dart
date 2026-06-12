import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String imageUrl;
  final DateTime joinDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.imageUrl,
    required this.joinDate,
  });
}

class PayStub {
  final String id;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime payDate;
  final double grossAmount;
  final double netAmount;

  PayStub({
    required this.id,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.payDate,
    required this.grossAmount,
    required this.netAmount,
  });
}

class TimeOffRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // Pending, Approved, Rejected

  TimeOffRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });
}

// Providers
final employeeProvider = StateProvider<Employee>(
  (ref) => Employee(
    id: 'E123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    department: 'Engineering',
    position: 'Senior Developer',
    imageUrl: 'https://i.pravatar.cc/300',
    joinDate: DateTime(2020, 5, 15),
  ),
);

final payStubsProvider = StateProvider<List<PayStub>>(
  (ref) => [
    PayStub(
      id: 'PS001',
      payPeriodStart: DateTime(2025, 2, 1),
      payPeriodEnd: DateTime(2025, 2, 15),
      payDate: DateTime(2025, 2, 20),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
    PayStub(
      id: 'PS002',
      payPeriodStart: DateTime(2025, 2, 16),
      payPeriodEnd: DateTime(2025, 2, 28),
      payDate: DateTime(2025, 3, 5),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
    PayStub(
      id: 'PS003',
      payPeriodStart: DateTime(2025, 3, 1),
      payPeriodEnd: DateTime(2025, 3, 15),
      payDate: DateTime(2025, 3, 20),
      grossAmount: 3500.00,
      netAmount: 2800.00,
    ),
  ],
);

final timeOffRequestsProvider = StateProvider<List<TimeOffRequest>>(
  (ref) => [
    TimeOffRequest(
      id: 'TOR001',
      startDate: DateTime(2025, 4, 10),
      endDate: DateTime(2025, 4, 15),
      reason: 'Vacation',
      status: 'Approved',
    ),
    TimeOffRequest(
      id: 'TOR002',
      startDate: DateTime(2025, 5, 22),
      endDate: DateTime(2025, 5, 22),
      reason: 'Personal',
      status: 'Pending',
    ),
  ],
);

// UI Components
class EmployeeSelfServiceScreen extends ConsumerWidget {
  const EmployeeSelfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider);
    final payStubs = ref.watch(payStubsProvider);
    final timeOffRequests = ref.watch(timeOffRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: Colors.indigo,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Employee Self-Service',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo, Colors.indigo.shade800],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),

            // Employee Profile Section
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(employee.imageUrl),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                employee.position,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                employee.department,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Join Date',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(employee.joinDate),
                        ),
                        _buildQuickInfoItem(
                          icon: Icons.schedule_outlined,
                          label: 'Time Off',
                          value: '18 days',
                        ),
                        _buildQuickInfoItem(
                          icon: Icons.work_outline,
                          label: 'Status',
                          value: 'Active',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _buildActionCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Update Profile',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.receipt_long_outlined,
                      title: 'View Pay Stubs',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayStubsScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.event_available_outlined,
                      title: 'Request Time Off',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestTimeOffScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context: context,
                      icon: Icons.feedback_outlined,
                      title: 'Submit Feedback',
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Recent Pay Stubs
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Pay Stubs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PayStubsScreen(),
                          ),
                        );
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final payStub = payStubs[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Pay Period: ${DateFormat('MMM dd').format(payStub.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payStub.payPeriodEnd)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Paid on ${DateFormat('MMM dd, yyyy').format(payStub.payDate)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${payStub.netAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Net Pay',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              }, childCount: payStubs.length),
            ),

            // Time Off Requests
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Off Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeOffRequestsScreen(),
                          ),
                        );
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final request = timeOffRequests[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      request.reason,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat('MMM dd').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          request.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          color: _getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),
                );
              }, childCount: timeOffRequests.length),
            ),

            // Bottom padding
            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Time Off',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 110,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Edit Profile Screen
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(employee.imageUrl),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildTextField(
            label: 'Full Name',
            initialValue: employee.name,
            prefixIcon: Icons.person_outline,
          ),
          _buildTextField(
            label: 'Email',
            initialValue: employee.email,
            prefixIcon: Icons.email_outlined,
          ),
          _buildTextField(
            label: 'Department',
            initialValue: employee.department,
            prefixIcon: Icons.business_outlined,
            enabled: false,
          ),
          _buildTextField(
            label: 'Position',
            initialValue: employee.position,
            prefixIcon: Icons.work_outline,
            enabled: false,
          ),
          _buildTextField(
            label: 'Phone Number',
            initialValue: '+1 (555) 123-4567',
            prefixIcon: Icons.phone_outlined,
          ),
          _buildTextField(
            label: 'Address',
            initialValue: '123 Main St, Anytown, ST 12345',
            prefixIcon: Icons.home_outlined,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData prefixIcon,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
    );
  }
}

// Pay Stubs Screen
class PayStubsScreen extends ConsumerWidget {
  const PayStubsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payStubs = ref.watch(payStubsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Pay Stubs'), backgroundColor: Colors.indigo),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: payStubs.length,
        itemBuilder: (context, index) {
          final payStub = payStubs[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                'Pay Period: ${DateFormat('MMM dd').format(payStub.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payStub.payPeriodEnd)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Paid on ${DateFormat('MMM dd, yyyy').format(payStub.payDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${payStub.netAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    'Net Pay',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              children: [
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPayStubDetail(
                        label: 'Gross Pay',
                        value: '\$${payStub.grossAmount.toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: 'Federal Tax',
                        value:
                            '-\$${(payStub.grossAmount * 0.15).toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: 'State Tax',
                        value:
                            '-\$${(payStub.grossAmount * 0.05).toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: 'Social Security',
                        value:
                            '-\$${(payStub.grossAmount * 0.062).toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: 'Medicare',
                        value:
                            '-\$${(payStub.grossAmount * 0.0145).toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: '401(k) Contribution',
                        value:
                            '-\$${(payStub.grossAmount * 0.05).toStringAsFixed(2)}',
                      ),
                      _buildPayStubDetail(
                        label: 'Health Insurance',
                        value: '-\$${(100).toStringAsFixed(2)}',
                      ),
                      Divider(),
                      _buildPayStubDetail(
                        label: 'Net Pay',
                        value: '\$${payStub.netAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.download_outlined),
                        label: Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayStubDetail({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: value.startsWith('-') ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Request Time Off Screen
class RequestTimeOffScreen extends ConsumerWidget {
  const RequestTimeOffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeOffTypes = [
      'Vacation',
      'Sick Leave',
      'Personal',
      'Bereavement',
      'Other',
    ];
    final selectedTimeOffType = StateProvider<String>((ref) => timeOffTypes[0]);
    final startDate = StateProvider<DateTime>(
      (ref) => DateTime.now().add(Duration(days: 7)),
    );
    final endDate = StateProvider<DateTime>(
      (ref) => DateTime.now().add(Duration(days: 9)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Time Off'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Off Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildTimeOffBalance(
                      label: 'Vacation',
                      used: '7 days',
                      total: '15 days',
                      color: Colors.blue,
                      percentage: 7 / 15,
                    ),
                    SizedBox(width: 16),
                    _buildTimeOffBalance(
                      label: 'Sick Leave',
                      used: '2 days',
                      total: '10 days',
                      color: Colors.green,
                      percentage: 2 / 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'New Request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Off Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: ref.watch(selectedTimeOffType),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: timeOffTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    ref.read(selectedTimeOffType.notifier).state = value!;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: ref.watch(startDate),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                ref.read(startDate.notifier).state = date;
                                // If end date is before start date, update end date
                                if (ref.watch(endDate).isBefore(date)) {
                                  ref.read(endDate.notifier).state = date;
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(ref.watch(startDate)),
                                  ),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.indigo,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: ref.watch(endDate),
                                firstDate: ref.watch(startDate),
                                lastDate: DateTime.now().add(
                                  Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                ref.read(endDate.notifier).state = date;
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(ref.watch(endDate)),
                                  ),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.indigo,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter reason for time off request',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Calculate days between start and end dates
                    final difference =
                        ref
                            .watch(endDate)
                            .difference(ref.watch(startDate))
                            .inDays +
                        1;

                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Request'),
                        content: Text(
                          'You are requesting ${difference} day(s) of ${ref.watch(selectedTimeOffType)} from ${DateFormat('MMM dd, yyyy').format(ref.watch(startDate))} to ${DateFormat('MMM dd, yyyy').format(ref.watch(endDate))}.\n\nDo you want to proceed?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Time off request submitted successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                            ),
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Submit Request'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOffBalance({
    required String label,
    required String used,
    required String total,
    required Color color,
    required double percentage,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            '$used used of $total',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

// Time Off Requests Screen
class TimeOffRequestsScreen extends ConsumerWidget {
  const TimeOffRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeOffRequests = ref.watch(timeOffRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Time Off Requests'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: timeOffRequests.length,
        itemBuilder: (context, index) {
          final request = timeOffRequests[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                request.reason,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${DateFormat('MMM dd').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: _getStatusColor(request.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              children: [
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRequestDetail(
                        label: 'Request ID',
                        value: request.id,
                      ),
                      _buildRequestDetail(label: 'Type', value: request.reason),
                      _buildRequestDetail(
                        label: 'Start Date',
                        value: DateFormat(
                          'MMM dd, yyyy',
                        ).format(request.startDate),
                      ),
                      _buildRequestDetail(
                        label: 'End Date',
                        value: DateFormat(
                          'MMM dd, yyyy',
                        ).format(request.endDate),
                      ),
                      _buildRequestDetail(
                        label: 'Duration',
                        value:
                            '${request.endDate.difference(request.startDate).inDays + 1} day(s)',
                      ),
                      _buildRequestDetail(
                        label: 'Status',
                        value: request.status,
                        valueColor: _getStatusColor(request.status),
                      ),
                      if (request.status == 'Pending')
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Request cancelled'),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Cancel Request'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestTimeOffScreen()),
          );
        },
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequestDetail({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Main App
class EmployeeSelfServiceApp extends StatelessWidget {
  const EmployeeSelfServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Employee Self-Service',
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
        home: const EmployeeSelfServiceScreen(),
      ),
    );
  }
}

void main() {
  runApp(const EmployeeSelfServiceApp());
}
