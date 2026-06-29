import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class LeaveRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String leaveType;

  LeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.leaveType,
  });
}

enum LeaveStatus { pending, approved, rejected }

// Providers
final leaveRequestsProvider =
    StateNotifierProvider<LeaveRequestNotifier, List<LeaveRequest>>((ref) {
      return LeaveRequestNotifier();
    });

class LeaveRequestNotifier extends StateNotifier<List<LeaveRequest>> {
  LeaveRequestNotifier()
    : super([
        LeaveRequest(
          id: '1',
          startDate: DateTime.now().add(Duration(days: 5)),
          endDate: DateTime.now().add(Duration(days: 7)),
          reason: 'Family vacation',
          status: LeaveStatus.pending,
          leaveType: 'Vacation',
        ),
        LeaveRequest(
          id: '2',
          startDate: DateTime.now().add(Duration(days: 15)),
          endDate: DateTime.now().add(Duration(days: 16)),
          reason: 'Medical appointment',
          status: LeaveStatus.approved,
          leaveType: 'Sick Leave',
        ),
      ]);

  void addLeaveRequest(LeaveRequest request) {
    state = [...state, request];
  }

  void updateLeaveRequest(LeaveRequest request) {
    state = [
      for (final item in state)
        if (item.id == request.id) request else item,
    ];
  }

  void deleteLeaveRequest(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final selectedLeaveTypeProvider = StateProvider<String>((ref) => 'Vacation');

// Main Screen
class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isFormVisible = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequests = ref.watch(leaveRequestsProvider);
    final selectedLeaveType = ref.watch(selectedLeaveTypeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Leave Management'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Summary
              _buildDashboardSummary(leaveRequests),
              SizedBox(height: 24),

              // Form toggle
              AnimatedCrossFade(
                firstChild: _buildFormToggleButton(),
                secondChild: _buildLeaveRequestForm(selectedLeaveType),
                crossFadeState:
                    _isFormVisible
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 300),
              ),
              SizedBox(height: 24),

              // Leave Requests List
              Text(
                'Your Leave Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...leaveRequests.map(
                (request) => _buildLeaveRequestCard(request),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSummary(List<LeaveRequest> requests) {
    final pendingCount =
        requests.where((r) => r.status == LeaveStatus.pending).length;
    final approvedCount =
        requests.where((r) => r.status == LeaveStatus.approved).length;
    final rejectedCount =
        requests.where((r) => r.status == LeaveStatus.rejected).length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '15 days',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusIndicator('Pending', pendingCount, Colors.amber),
              _buildStatusIndicator('Approved', approvedCount, Colors.green),
              _buildStatusIndicator('Rejected', rejectedCount, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFormToggleButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.add),
        label: Text('Request Leave'),
        onPressed: () {
          setState(() {
            _isFormVisible = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestForm(String selectedLeaveType) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Leave',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isFormVisible = false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Leave Type
            DropdownButtonFormField<String>(
              value: selectedLeaveType,
              decoration: InputDecoration(
                labelText: 'Leave Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  ['Vacation', 'Sick Leave', 'Personal Leave', 'Work From Home']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedLeaveTypeProvider.notifier).state = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select leave type';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text:
                              _startDate != null
                                  ? DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_startDate!)
                                  : '',
                        ),
                        validator: (value) {
                          if (_startDate == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? (_startDate ?? DateTime.now()),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text:
                              _endDate != null
                                  ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                  : '',
                        ),
                        validator: (value) {
                          if (_endDate == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
            SizedBox(height: 24),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newLeaveRequest = LeaveRequest(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      startDate: _startDate!,
                      endDate: _endDate!,
                      reason: _reasonController.text,
                      status: LeaveStatus.pending,
                      leaveType: selectedLeaveType,
                    );

                    ref
                        .read(leaveRequestsProvider.notifier)
                        .addLeaveRequest(newLeaveRequest);

                    setState(() {
                      _isFormVisible = false;
                      _startDate = null;
                      _endDate = null;
                      _reasonController.clear();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Leave request submitted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case LeaveStatus.pending:
        statusColor = Colors.amber;
        statusIcon = Icons.pending;
        break;
      case LeaveStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case LeaveStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLeaveTypeColor(
                          request.leaveType,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLeaveTypeIcon(request.leaveType),
                        color: _getLeaveTypeColor(request.leaveType),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      request.leaveType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        request.status.toString().split('.').last,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM dd').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '(${_calculateDuration(request.startDate, request.endDate)} days)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.reason,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (request.status == LeaveStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(leaveRequestsProvider.notifier)
                          .deleteLeaveRequest(request.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Leave request cancelled'),
                          backgroundColor: Colors.grey[700],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  Color _getLeaveTypeColor(String leaveType) {
    switch (leaveType) {
      case 'Vacation':
        return Colors.blue;
      case 'Sick Leave':
        return Colors.purple;
      case 'Personal Leave':
        return Colors.orange;
      case 'Work From Home':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getLeaveTypeIcon(String leaveType) {
    switch (leaveType) {
      case 'Vacation':
        return Icons.beach_access;
      case 'Sick Leave':
        return Icons.healing;
      case 'Personal Leave':
        return Icons.person;
      case 'Work From Home':
        return Icons.home_work;
      default:
        return Icons.event_note;
    }
  }
}

// Main App
class LeaveManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Leave Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.teal),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        home: LeaveManagementScreen(),
      ),
    );
  }
}

// Entry point
void main() {
  runApp(LeaveManagementApp());
}
