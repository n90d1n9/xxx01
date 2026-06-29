import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class ChooseDateWidget extends ConsumerWidget {
  const ChooseDateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateRangeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Date'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                ref.read(selectedDateRangeProvider.notifier).update((state) => [
                      date,
                      date,
                    ]);
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Selected Date: ${selectedDate.first.toString()} - ${selectedDate.last.toString()}',
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle the selected date
                print(
                    'Selected Date: ${selectedDate.first.toString()} - ${selectedDate.last.toString()}');
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

final selectedDateRangeProvider = StateProvider<List<DateTime>>((ref) => [
      DateTime.now(),
      DateTime.now(),
    ]);

class CalendarDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateChanged;

  const CalendarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<CalendarDatePicker> createState() => _CalendarDatePickerState();
}

class _CalendarDatePickerState extends State<CalendarDatePicker> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarGridView(
          selectedDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            widget.onDateChanged(date);
          },
        ),
      ],
    );
  }
}

class CalendarGridView extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateSelected;

  const CalendarGridView({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final days = List.generate(
      daysInMonth + firstDayOfWeek - 1,
      (index) {
        final day = index - firstDayOfWeek + 2;
        final date = DateTime(selectedDate.year, selectedDate.month, day);
        return CalendarDay(
          date: date,
          isSelected: date == selectedDate,
          onDateSelected: onDateSelected,
        );
      },
    );
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }
}

class CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final void Function(DateTime) onDateSelected;

  const CalendarDay({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onDateSelected(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            DateFormat('dd').format(date),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
