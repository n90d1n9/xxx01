import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({Key? key}) : super(key: key);

  @override
  _HijriCalendarScreenState createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  HijriCalendar _hijriDate = HijriCalendar.now();
  DateTime _gregorianDate = DateTime.now();
  int _adjustment = 0;

  @override
  void initState() {
    super.initState();
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adjustment = prefs.getInt('hijri_adjustment') ?? 0;
      // Apply the adjustment
      _updateHijriDate();
    });
  }

  void _updateHijriDate() {
    // Create a new date with the adjustment
    _hijriDate = HijriCalendar.now();
    if (_adjustment != 0) {
      _hijriDate = HijriCalendar.fromDate(
        DateTime.now().add(Duration(days: _adjustment)),
      );
    }
  }

  Future<void> _saveCalibration(int adjustment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hijri_adjustment', adjustment);
    setState(() {
      _adjustment = adjustment;
      _updateHijriDate();
    });
  }

  List<Widget> _buildCalendarGrid() {
    // Get first day of current month
    HijriCalendar firstDay = HijriCalendar();
    firstDay.hYear = _hijriDate.hYear;
    firstDay.hMonth = _hijriDate.hMonth;
    firstDay.hDay = 1;

    // Convert to gregorian to get first day of week
    DateTime firstDayGregorian = firstDay.hijriToGregorian(
      firstDay.hYear,
      firstDay.hMonth,
      firstDay.hDay,
    );
    int firstDayWeekday =
        firstDayGregorian.weekday %
        7; // 0 = Sunday, 6 = Saturday in our display

    // Get total days in current month
    int daysInMonth = _hijriDate.lengthOfMonth;

    List<Widget> calendarCells = [];

    // Add day headers (Sat to Fri)
    final weekDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    for (String day in weekDays) {
      calendarCells.add(
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green[100],
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Add empty cells for days before the 1st of month
    for (int i = 0; i < firstDayWeekday; i++) {
      calendarCells.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
      );
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      bool isCurrentDay = day == _hijriDate.hDay;

      calendarCells.add(
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrentDay ? Colors.green : Colors.transparent,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: isCurrentDay ? BorderRadius.circular(8) : null,
          ),
          child: Text(
            day.toString(),
            style: TextStyle(
              color: isCurrentDay ? Colors.white : Colors.black,
              fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return calendarCells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijri Calendar'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Date display section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                Text(
                  '${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear} AH',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_gregorianDate),
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                children: _buildCalendarGrid(),
              ),
            ),
          ),

          // Calibration controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                const Text(
                  'Calibrate Hijri Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _saveCalibration(_adjustment - 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Adjustment: $_adjustment days',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveCalibration(_adjustment + 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Use +/- buttons to adjust if the Hijri date differs from your local calendar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: HijriCalendarScreen()));
}
