import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/calendar.dart';
import '../models/expense.dart';
import '../models/shopping_item.dart';
import '../states/provider.dart';

class CalendarViewPage extends ConsumerStatefulWidget {
  const CalendarViewPage({super.key});

  @override
  ConsumerState<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends ConsumerState<CalendarViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  CalendarView _currentView = CalendarView.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Month'),
            Tab(text: 'Week'),
            Tab(text: 'Day'),
          ],
          onTap: (index) {
            setState(() {
              _currentView = CalendarView.values[index];
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMonthView(), _buildWeekView(), _buildDayView()],
      ),
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildMonthHeader(),
        _buildWeekdayHeaders(),
        Expanded(child: _buildMonthGrid()),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map(
              (day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: (daysInMonth + startingWeekday - 1) > 35 ? 42 : 35,
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          final previousMonth = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            1,
          );
          final daysInPreviousMonth = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            0,
          ).day;
          final day = daysInPreviousMonth - (startingWeekday - 2 - index);
          final date = DateTime(previousMonth.year, previousMonth.month, day);
          return _buildDayCell(date, isCurrentMonth: false);
        } else if (index >= daysInMonth + startingWeekday - 1) {
          final day = index - daysInMonth - startingWeekday + 2;
          final nextMonth = DateTime(
            _selectedDate.year,
            _selectedDate.month + 1,
            1,
          );
          final date = DateTime(nextMonth.year, nextMonth.month, day);
          return _buildDayCell(date, isCurrentMonth: false);
        } else {
          final day = index - startingWeekday + 2;
          final date = DateTime(_selectedDate.year, _selectedDate.month, day);
          return _buildDayCell(date, isCurrentMonth: true);
        }
      },
    );
  }

  Widget _buildDayCell(DateTime date, {bool isCurrentMonth = true}) {
    final expenses = ref.watch(expensesByDateProvider(date));
    final shopping = ref.watch(shoppingByDateProvider(date));
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount) +
        shopping
            .where((item) => item.purchased)
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    final hasExpenses = expenses.isNotEmpty;
    final hasShopping = shopping.any((item) => item.purchased);

    return GestureDetector(
      onTap: () => _showDateDetails(date),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          color: _getDayCellColor(date, isCurrentMonth),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: _isToday(date)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _getDayTextColor(date, isCurrentMonth),
                      fontSize: 12,
                    ),
                  ),
                  if (totalAmount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '\$${totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasExpenses || hasShopping)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    (expenses.length +
                            shopping.where((item) => item.purchased).length)
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Column(
      children: [
        _buildWeekHeader(weekStart),
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = weekStart.add(Duration(days: index));
              return _buildDayRow(date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeWeek(-1),
          ),
          Text(
            '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(DateTime date) {
    final expenses = ref.watch(expensesByDateProvider(date));
    final shopping = ref.watch(shoppingByDateProvider(date));
    final dailyTotal = _getDailyTotal(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isToday(date) ? Colors.teal : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: _isToday(date) ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          DateFormat('EEEE').format(date),
          style: TextStyle(
            fontWeight: _isToday(date) ? FontWeight.bold : FontWeight.normal,
            color: _isToday(date) ? Colors.teal : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expenses.isNotEmpty)
              Text(
                '${expenses.length} expense${expenses.length > 1 ? 's' : ''}',
              ),
            if (shopping.any((item) => item.purchased))
              Text(
                '${shopping.where((item) => item.purchased).length} item${shopping.where((item) => item.purchased).length > 1 ? 's' : ''} purchased',
              ),
            if (expenses.isEmpty && !shopping.any((item) => item.purchased))
              const Text('No activities'),
          ],
        ),
        trailing: dailyTotal > 0
            ? Text(
                '\$${dailyTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              )
            : const Text('\$0.00', style: TextStyle(color: Colors.grey)),
        onTap: () => _showDateDetails(date),
      ),
    );
  }

  Widget _buildDayView() {
    return Column(
      children: [
        _buildDayHeader(),
        Expanded(child: _buildDayDetails()),
      ],
    );
  }

  Widget _buildDayHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDay(-1),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('MMMM d, yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDay(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetails() {
    final expenses = ref.watch(expensesByDateProvider(_selectedDate));
    final shopping = ref.watch(shoppingByDateProvider(_selectedDate));
    final dailyTotal = _getDailyTotal(_selectedDate);

    return ListView(
      children: [
        _buildDailySummary(_selectedDate),
        if (expenses.isNotEmpty) _buildExpensesSection(expenses),
        if (shopping.isNotEmpty) _buildShoppingSection(shopping),
        if (expenses.isEmpty && shopping.isEmpty) _buildNoActivities(),
      ],
    );
  }

  Widget _buildDailySummary(DateTime date) {
    final expenses = ref.watch(expensesByDateProvider(date));
    final shopping = ref.watch(shoppingByDateProvider(date));
    final dailyTotal = _getDailyTotal(date);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Expenses',
                  expenses.length.toString(),
                  Colors.red,
                ),
                _buildSummaryItem(
                  'Items Purchased',
                  shopping.where((item) => item.purchased).length.toString(),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Total',
                  '\$${dailyTotal.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getSummaryIcon(label), color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  IconData _getSummaryIcon(String label) {
    switch (label) {
      case 'Expenses':
        return Icons.receipt;
      case 'Items Purchased':
        return Icons.shopping_cart;
      case 'Total':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }

  Widget _buildExpensesSection(List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...expenses.map((expense) => _buildExpenseItem(expense)),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt, color: Colors.red, size: 20),
        ),
        title: Text(expense.description),
        subtitle: Text(expense.category),
        trailing: Text(
          '\$${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingSection(List<ShoppingItem> shopping) {
    final purchasedItems = shopping.where((item) => item.purchased).toList();

    if (purchasedItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Shopping Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...purchasedItems.map((item) => _buildShoppingItem(item)),
      ],
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_cart, color: Colors.green, size: 20),
        ),
        title: Text(item.name),
        subtitle: Text('${item.category} • Qty: ${item.quantity}'),
        trailing: Text(
          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNoActivities() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Activities',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'No expenses or shopping items for this day',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetailsForDialog(DateTime date) {
    final expenses = ref.watch(expensesByDateProvider(date));
    final shopping = ref.watch(shoppingByDateProvider(date));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailySummary(date),
          if (expenses.isNotEmpty) _buildExpensesSection(expenses),
          if (shopping.isNotEmpty) _buildShoppingSection(shopping),
          if (expenses.isEmpty && shopping.isEmpty) _buildNoActivities(),
        ],
      ),
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getDayCellColor(DateTime date, bool isCurrentMonth) {
    if (_isToday(date)) {
      return Colors.teal.withOpacity(0.1);
    } else if (!isCurrentMonth) {
      return Colors.grey.shade100;
    }
    return Colors.white;
  }

  Color _getDayTextColor(DateTime date, bool isCurrentMonth) {
    if (_isToday(date)) {
      return Colors.teal;
    } else if (!isCurrentMonth) {
      return Colors.grey.shade400;
    }
    return Colors.black;
  }

  double _getDailyTotal(DateTime date) {
    final expenses = ref.read(expensesByDateProvider(date));
    final shopping = ref.read(shoppingByDateProvider(date));

    return expenses.fold(0.0, (sum, expense) => sum + expense.amount) +
        shopping
            .where((item) => item.purchased)
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + delta,
        1,
      );
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7 * delta));
    });
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  void _showDateDetails(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('MMMM d, yyyy').format(date)),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildDayDetailsForDialog(date),
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
}
