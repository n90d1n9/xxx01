import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Employee {
  final String id;
  final String name;
  final String position;
  final double salary;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
    required this.imageUrl,
  });
}

class PayrollDetails {
  final double grossSalary;
  final double federalTax;
  final double stateTax;
  final double socialSecurity;
  final double medicare;
  final double retirement401k;
  final double healthInsurance;
  final double netSalary;

  PayrollDetails({
    required this.grossSalary,
    required this.federalTax,
    required this.stateTax,
    required this.socialSecurity,
    required this.medicare,
    required this.retirement401k,
    required this.healthInsurance,
    required this.netSalary,
  });

  factory PayrollDetails.fromSalary(double salary) {
    final federalTax = salary * 0.15;
    final stateTax = salary * 0.05;
    final socialSecurity = salary * 0.062;
    final medicare = salary * 0.0145;
    final retirement401k = salary * 0.05;
    final healthInsurance = 250.0;

    final netSalary =
        salary -
        federalTax -
        stateTax -
        socialSecurity -
        medicare -
        retirement401k -
        healthInsurance;

    return PayrollDetails(
      grossSalary: salary,
      federalTax: federalTax,
      stateTax: stateTax,
      socialSecurity: socialSecurity,
      medicare: medicare,
      retirement401k: retirement401k,
      healthInsurance: healthInsurance,
      netSalary: netSalary,
    );
  }
}

// Providers
final employeesProvider = StateProvider<List<Employee>>((ref) {
  return [
    Employee(
      id: '1',
      name: 'Alex Johnson',
      position: 'Senior Developer',
      salary: 8500,
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Employee(
      id: '2',
      name: 'Sarah Williams',
      position: 'UI/UX Designer',
      salary: 7200,
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Employee(
      id: '3',
      name: 'Michael Chen',
      position: 'Project Manager',
      salary: 9800,
      imageUrl: 'https://randomuser.me/api/portraits/men/59.jpg',
    ),
  ];
});

final selectedEmployeeProvider = StateProvider<Employee?>((ref) => null);

final payrollDetailsProvider = Provider<PayrollDetails?>((ref) {
  final selectedEmployee = ref.watch(selectedEmployeeProvider);
  if (selectedEmployee == null) return null;

  return PayrollDetails.fromSalary(selectedEmployee.salary);
});

final paymentStatusProvider = StateProvider<Map<String, bool>>((ref) {
  return {'1': false, '2': false, '3': false};
});

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);
    final selectedEmployee = ref.watch(selectedEmployeeProvider);
    final payrollDetails = ref.watch(payrollDetailsProvider);
    final paymentStatus = ref.watch(paymentStatusProvider);

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Payroll Dashboard'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Show payroll calendar
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'March 2025 Payroll',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment Date: March 15, 2025',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Employee List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final isSelected = selectedEmployee?.id == employee.id;
                final isPaid = paymentStatus[employee.id] ?? false;

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedEmployeeProvider.notifier).state =
                        employee;
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.indigo.withValues(alpha: 0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.indigo : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(employee.imageUrl),
                            ),
                            if (isPaid)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.position,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedEmployee != null && payrollDetails != null) ...[
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: 12,
              ),
              child: Text(
                'Payroll Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              selectedEmployee.imageUrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedEmployee.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedEmployee.position,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Gross Salary',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(
                                  payrollDetails.grossSalary,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildPayrollItem(
                            'Federal Tax',
                            payrollDetails.federalTax,
                            currencyFormat,
                            Colors.red.shade400,
                          ),
                          _buildPayrollItem(
                            'State Tax',
                            payrollDetails.stateTax,
                            currencyFormat,
                            Colors.red.shade300,
                          ),
                          _buildPayrollItem(
                            'Social Security',
                            payrollDetails.socialSecurity,
                            currencyFormat,
                            Colors.orange.shade300,
                          ),
                          _buildPayrollItem(
                            'Medicare',
                            payrollDetails.medicare,
                            currencyFormat,
                            Colors.orange.shade200,
                          ),
                          _buildPayrollItem(
                            '401(k) Retirement',
                            payrollDetails.retirement401k,
                            currencyFormat,
                            Colors.blue.shade300,
                          ),
                          _buildPayrollItem(
                            'Health Insurance',
                            payrollDetails.healthInsurance,
                            currencyFormat,
                            Colors.blue.shade200,
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Net Salary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                currencyFormat.format(payrollDetails.netSalary),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed:
                            paymentStatus[selectedEmployee.id] ?? false
                                ? null
                                : () {
                                  final currentStatus = Map<String, bool>.from(
                                    ref.read(paymentStatusProvider),
                                  );
                                  currentStatus[selectedEmployee.id] = true;
                                  ref
                                      .read(paymentStatusProvider.notifier)
                                      .state = currentStatus;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Payment to ${selectedEmployee.name} processed successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          paymentStatus[selectedEmployee.id] ?? false
                              ? 'Payment Processed'
                              : 'Process Direct Deposit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select an employee to view payroll details',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollItem(
    String label,
    double amount,
    NumberFormat formatter,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
          Text(
            formatter.format(amount),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Main application
class PayrollApp extends ConsumerWidget {
  const PayrollApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Payroll System',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: const PayrollScreen(),
    );
  }
}

// Payroll History Screen
class PayrollHistoryScreen extends ConsumerWidget {
  const PayrollHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmployee = ref.watch(selectedEmployeeProvider);
    if (selectedEmployee == null) {
      return const Center(child: Text('Please select an employee'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${selectedEmployee.name} - Payroll History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          final month = DateTime.now().month - index;
          final year = DateTime.now().year - (month <= 0 ? 1 : 0);
          final adjustedMonth = month <= 0 ? month + 12 : month;

          final monthName = DateFormat(
            'MMMM',
          ).format(DateTime(2025, adjustedMonth, 1));

          // Generate a slightly different salary amount for historical months
          final historicalSalary =
              selectedEmployee.salary * (0.98 + (index * 0.005));
          final payrollDetails = PayrollDetails.fromSalary(historicalSalary);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text(
                '$monthName $year',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Net: ${NumberFormat.currency(symbol: '\$').format(payrollDetails.netSalary)}',
                style: TextStyle(color: Colors.green[700]),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHistoryItem(
                        'Gross Salary',
                        payrollDetails.grossSalary,
                      ),
                      _buildHistoryItem(
                        'Federal Tax',
                        payrollDetails.federalTax,
                      ),
                      _buildHistoryItem('State Tax', payrollDetails.stateTax),
                      _buildHistoryItem(
                        'Social Security',
                        payrollDetails.socialSecurity,
                      ),
                      _buildHistoryItem('Medicare', payrollDetails.medicare),
                      _buildHistoryItem(
                        '401(k)',
                        payrollDetails.retirement401k,
                      ),
                      _buildHistoryItem(
                        'Health Insurance',
                        payrollDetails.healthInsurance,
                      ),
                      const Divider(),
                      _buildHistoryItem(
                        'Net Salary',
                        payrollDetails.netSalary,
                        isNet: true,
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

  Widget _buildHistoryItem(String label, double amount, {bool isNet = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              fontWeight: isNet ? FontWeight.bold : FontWeight.normal,
              color: isNet ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Tax Calculator Screen
class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({Key? key}) : super(key: key);

  @override
  _TaxCalculatorScreenState createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final _salaryController = TextEditingController();
  double _grossSalary = 0;
  PayrollDetails? _calculatedDetails;

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    final salary = double.tryParse(_salaryController.text) ?? 0;
    if (salary > 0) {
      setState(() {
        _grossSalary = salary;
        _calculatedDetails = PayrollDetails.fromSalary(salary);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Gross Monthly Salary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Gross Salary',
                      prefix: const Text('\$ '),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateTax,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
            if (_calculatedDetails != null) ...[
              const SizedBox(height: 24),
              Text(
                'Tax Breakdown for \$${_grossSalary.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTaxBreakdownCard(_calculatedDetails!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxBreakdownCard(PayrollDetails details) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTaxRow('Federal Tax (15%)', details.federalTax, currencyFormat),
          _buildTaxRow('State Tax (5%)', details.stateTax, currencyFormat),
          _buildTaxRow(
            'Social Security (6.2%)',
            details.socialSecurity,
            currencyFormat,
          ),
          _buildTaxRow('Medicare (1.45%)', details.medicare, currencyFormat),
          _buildTaxRow('401(k) (5%)', details.retirement401k, currencyFormat),
          _buildTaxRow(
            'Health Insurance',
            details.healthInsurance,
            currencyFormat,
          ),
          const Divider(),
          _buildTaxRow(
            'Total Deductions',
            details.grossSalary - details.netSalary,
            currencyFormat,
            color: Colors.red[700],
          ),
          _buildTaxRow(
            'Net Salary',
            details.netSalary,
            currencyFormat,
            color: Colors.green[700],
            bold: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTaxRow(
    String label,
    double amount,
    NumberFormat formatter, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatter.format(amount),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: PayrollApp()));
}
