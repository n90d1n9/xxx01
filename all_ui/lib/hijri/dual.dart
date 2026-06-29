import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DualCalendarScreen extends StatefulWidget {
  const DualCalendarScreen({Key? key}) : super(key: key);

  @override
  _DualCalendarScreenState createState() => _DualCalendarScreenState();
}

class _DualCalendarScreenState extends State<DualCalendarScreen> {
  HijriCalendar _hijriDate = HijriCalendar.now();
  DateTime _gregorianDate = DateTime.now();
  int _adjustment = 0;

  // For keeping track of displayed months
  late HijriCalendar _displayedHijriMonth;
  late DateTime _displayedGregorianMonth;

  @override
  void initState() {
    super.initState();
    _displayedHijriMonth = HijriCalendar.now();
    _displayedGregorianMonth = DateTime.now();
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adjustment = prefs.getInt('hijri_adjustment') ?? 0;
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
    // Update displayed months if they are the current month
    if (_displayedHijriMonth.hMonth == HijriCalendar.now().hMonth &&
        _displayedHijriMonth.hYear == HijriCalendar.now().hYear) {
      _displayedHijriMonth = _hijriDate;
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

  List<Widget> _buildHijriCalendarGrid() {
    // Get first day of displayed month
    HijriCalendar firstDay = HijriCalendar();
    firstDay.hYear = _displayedHijriMonth.hYear;
    firstDay.hMonth = _displayedHijriMonth.hMonth;
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
    int daysInMonth = _displayedHijriMonth.lengthOfMonth;

    List<Widget> calendarCells = [];

    // Add day headers (Sat to Fri)
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (String day in weekDays) {
      calendarCells.add(
        Container(
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green[100],
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
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
      bool isToday =
          day == _hijriDate.hDay &&
          _displayedHijriMonth.hMonth == _hijriDate.hMonth &&
          _displayedHijriMonth.hYear == _hijriDate.hYear;

      // Create a HijriCalendar for this day
      HijriCalendar thisDay = HijriCalendar();
      thisDay.hYear = _displayedHijriMonth.hYear;
      thisDay.hMonth = _displayedHijriMonth.hMonth;
      thisDay.hDay = day;

      // Convert to Gregorian for the date selection
      final DateTime correspondingGregorianDate = thisDay.hijriToGregorian(
        thisDay.hYear,
        thisDay.hMonth,
        thisDay.hDay,
      );

      calendarCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _hijriDate = thisDay;
              _gregorianDate = correspondingGregorianDate;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? Colors.green : Colors.transparent,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: isToday ? BorderRadius.circular(4) : null,
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isToday ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return calendarCells;
  }

  List<Widget> _buildGregorianCalendarGrid() {
    // Get the first day of the month
    DateTime firstDay = DateTime(
      _displayedGregorianMonth.year,
      _displayedGregorianMonth.month,
      1,
    );

    // Calculate the weekday of the first day (0 = Monday, 6 = Sunday)
    int firstDayWeekday = firstDay.weekday % 7;

    // Calculate days in month
    int daysInMonth =
        DateTime(
          _displayedGregorianMonth.year,
          _displayedGregorianMonth.month + 1,
          0,
        ).day;

    List<Widget> calendarCells = [];

    // Add day headers (Sat to Fri)
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (String day in weekDays) {
      calendarCells.add(
        Container(
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
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
      bool isToday =
          day == _gregorianDate.day &&
          _displayedGregorianMonth.month == _gregorianDate.month &&
          _displayedGregorianMonth.year == _gregorianDate.year;

      // Create a date for this day
      DateTime thisDay = DateTime(
        _displayedGregorianMonth.year,
        _displayedGregorianMonth.month,
        day,
      );

      // Convert to Hijri for the date selection
      final HijriCalendar correspondingHijriDate = HijriCalendar.fromDate(
        thisDay,
      );

      calendarCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _gregorianDate = thisDay;
              _hijriDate = correspondingHijriDate;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : Colors.transparent,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: isToday ? BorderRadius.circular(4) : null,
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isToday ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return calendarCells;
  }

  void _navigateHijriMonth(int monthDelta) {
    setState(() {
      int newMonth = _displayedHijriMonth.hMonth + monthDelta;
      int yearDelta = 0;

      if (newMonth > 12) {
        newMonth = 1;
        yearDelta = 1;
      } else if (newMonth < 1) {
        newMonth = 12;
        yearDelta = -1;
      }

      _displayedHijriMonth.hMonth = newMonth;
      _displayedHijriMonth.hYear += yearDelta;
    });
  }

  void _navigateGregorianMonth(int monthDelta) {
    setState(() {
      _displayedGregorianMonth = DateTime(
        _displayedGregorianMonth.year,
        _displayedGregorianMonth.month + monthDelta,
        1,
      );
    });
  }

  void _navigateHijriYear(int yearDelta) {
    setState(() {
      _displayedHijriMonth.hYear += yearDelta;
    });
  }

  void _navigateGregorianYear(int yearDelta) {
    setState(() {
      _displayedGregorianMonth = DateTime(
        _displayedGregorianMonth.year + yearDelta,
        _displayedGregorianMonth.month,
        1,
      );
    });
  }

  // Replace the _showHijriDatePicker method with this updated version
  void _showHijriDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = _displayedHijriMonth.hYear;
        int selectedMonth = _displayedHijriMonth.hMonth;

        // List of Hijri month names
        List<String> hijriMonthNames = [
          'Muharram',
          'Safar',
          'Rabi\' al-awwal',
          'Rabi\' al-thani',
          'Jumada al-awwal',
          'Jumada al-thani',
          'Rajab',
          'Sha\'ban',
          'Ramadan',
          'Shawwal',
          'Dhu al-Qi\'dah',
          'Dhu al-Hijjah',
        ];

        return AlertDialog(
          title: const Text("Select Hijri Date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year selector
              Row(
                children: [
                  const Text("Year: "),
                  Expanded(
                    child: Slider(
                      value: selectedYear.toDouble(),
                      min: 1400.0,
                      max: 1500.0,
                      divisions: 100,
                      label: selectedYear.toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(selectedYear.toString()),
                ],
              ),

              // Month selector
              Row(
                children: [
                  const Text("Month: "),
                  Expanded(
                    child: Slider(
                      value: selectedMonth.toDouble(),
                      min: 1.0,
                      max: 12.0,
                      divisions: 11,
                      label: hijriMonthNames[selectedMonth - 1],
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(selectedMonth.toString()),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _displayedHijriMonth.hYear = selectedYear;
                  _displayedHijriMonth.hMonth = selectedMonth;
                });
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showGregorianDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _displayedGregorianMonth,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _displayedGregorianMonth = DateTime(
            pickedDate.year,
            pickedDate.month,
            1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual Calendar'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _displayedHijriMonth = HijriCalendar.now();
                _displayedGregorianMonth = DateTime.now();
                _hijriDate = HijriCalendar.now();
                _gregorianDate = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCalibrationDialog,
            tooltip: 'Calibrate',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date display section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Row(
              children: [
                // Hijri date display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear} AH',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${_hijriDate.toFormat("dd MMMM yyyy")}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                // Gregorian date display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d MMMM yyyy').format(_gregorianDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE').format(_gregorianDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Calendar grids
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hijri calendar
                Expanded(
                  child: Column(
                    children: [
                      // Month navigation
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.green[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _navigateHijriYear(-1),
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigate_before),
                              onPressed: () => _navigateHijriMonth(-1),
                              iconSize: 20,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showHijriDatePicker,
                                child: Text(
                                  '${_displayedHijriMonth.longMonthName} ${_displayedHijriMonth.hYear}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigate_next),
                              onPressed: () => _navigateHijriMonth(1),
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _navigateHijriYear(1),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),

                      // Calendar grid
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GridView.count(
                            crossAxisCount: 7,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: _buildHijriCalendarGrid(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(width: 1, color: Colors.grey[300]),

                // Gregorian calendar
                Expanded(
                  child: Column(
                    children: [
                      // Month navigation
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.blue[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _navigateGregorianYear(-1),
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigate_before),
                              onPressed: () => _navigateGregorianMonth(-1),
                              iconSize: 20,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showGregorianDatePicker,
                                child: Text(
                                  DateFormat(
                                    'MMMM yyyy',
                                  ).format(_displayedGregorianMonth),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigate_next),
                              onPressed: () => _navigateGregorianMonth(1),
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _navigateGregorianYear(1),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),

                      // Calendar grid
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GridView.count(
                            crossAxisCount: 7,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: _buildGregorianCalendarGrid(),
                          ),
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
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calibrate Hijri Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Adjust the Hijri date if it differs from your local calendar',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveCalibration(_adjustment - 1);
                      Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: DualCalendarScreen()));
}
