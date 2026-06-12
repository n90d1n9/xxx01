// Legacy prototype retained for reference. The supported public API lives under
// lib/src and is exported from package:ky_restaurant/ky_restaurant.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

// Models
class Table {
  final String id;
  final String name;
  final int capacity;
  final Offset position;
  final double width;
  final double height;
  final TableStatus status;

  Table({
    String? id,
    required this.name,
    required this.capacity,
    required this.position,
    this.width = 80,
    this.height = 80,
    this.status = TableStatus.available,
  }) : id = id ?? const Uuid().v4();

  Table copyWith({
    String? name,
    int? capacity,
    Offset? position,
    double? width,
    double? height,
    TableStatus? status,
  }) {
    return Table(
      id: this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      status: status ?? this.status,
    );
  }
}

enum TableStatus { available, reserved, occupied }

class Floor {
  final String id;
  final String name;
  final List<Table> tables;
  final Size size;

  Floor({
    String? id,
    required this.name,
    required this.size,
    List<Table>? tables,
  }) : id = id ?? const Uuid().v4(),
       tables = tables ?? [];

  Floor copyWith({String? name, List<Table>? tables, Size? size}) {
    return Floor(
      id: this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
      size: size ?? this.size,
    );
  }
}

class Reservation {
  final String id;
  final String tableId;
  final String customerName;
  final int partySize;
  final DateTime dateTime;
  final Duration duration;

  Reservation({
    String? id,
    required this.tableId,
    required this.customerName,
    required this.partySize,
    required this.dateTime,
    this.duration = const Duration(hours: 2),
  }) : id = id ?? const Uuid().v4();
}

// Providers
final floorsProvider = StateNotifierProvider<FloorsNotifier, List<Floor>>((
  ref,
) {
  return FloorsNotifier();
});

final currentFloorProvider = StateProvider<String?>((ref) => null);

final reservationsProvider =
    StateNotifierProvider<ReservationsNotifier, List<Reservation>>((ref) {
      return ReservationsNotifier();
    });

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final appModeProvider = StateProvider<AppMode>((ref) {
  return AppMode.setup;
});

enum AppMode { setup, reservation }

// Notifiers
class FloorsNotifier extends StateNotifier<List<Floor>> {
  FloorsNotifier()
    : super([
        Floor(
          name: 'Main Floor',
          size: const Size(800, 600),
          tables: [
            Table(name: 'T1', capacity: 4, position: const Offset(100, 100)),
            Table(
              name: 'T2',
              capacity: 2,
              position: const Offset(250, 100),
              width: 60,
              height: 60,
            ),
          ],
        ),
        Floor(name: 'Outdoor', size: const Size(600, 400)),
      ]);

  void addFloor(Floor floor) {
    state = [...state, floor];
  }

  void updateFloor(Floor floor) {
    state = [
      for (final f in state)
        if (f.id == floor.id) floor else f,
    ];
  }

  void addTable(String floorId, Table table) {
    state = [
      for (final floor in state)
        if (floor.id == floorId)
          floor.copyWith(tables: [...floor.tables, table])
        else
          floor,
    ];
  }

  void updateTable(String floorId, Table table) {
    state = [
      for (final floor in state)
        if (floor.id == floorId)
          floor.copyWith(
            tables: [
              for (final t in floor.tables)
                if (t.id == table.id) table else t,
            ],
          )
        else
          floor,
    ];
  }

  void removeTable(String floorId, String tableId) {
    state = [
      for (final floor in state)
        if (floor.id == floorId)
          floor.copyWith(
            tables: floor.tables.where((t) => t.id != tableId).toList(),
          )
        else
          floor,
    ];
  }
}

class ReservationsNotifier extends StateNotifier<List<Reservation>> {
  ReservationsNotifier() : super([]);

  void addReservation(Reservation reservation) {
    state = [...state, reservation];
  }

  void removeReservation(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  List<Reservation> getReservationsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));

    return state
        .where((r) => r.dateTime.isAfter(day) && r.dateTime.isBefore(nextDay))
        .toList();
  }

  bool isTableReserved(String tableId, DateTime dateTime) {
    final reservation = state.where(
      (r) =>
          r.tableId == tableId &&
          r.dateTime.isBefore(dateTime.add(const Duration(hours: 2))) &&
          r.dateTime.add(r.duration).isAfter(dateTime),
    );

    return reservation.isNotEmpty;
  }
}

// Main App
class RestaurantTableApp extends StatelessWidget {
  const RestaurantTableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant Table Management',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

// Screens
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    final floors = ref.watch(floorsProvider);
    final currentFloorId = ref.watch(currentFloorProvider);

    final currentFloor = floors.firstWhere(
      (f) => f.id == currentFloorId,
      orElse: () => floors.first,
    );

    if (currentFloorId == null && floors.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentFloorProvider.notifier).state = floors.first.id;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appMode == AppMode.setup
              ? 'Table Setup: ${currentFloor.name}'
              : 'Reservations: ${currentFloor.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              appMode == AppMode.setup ? Icons.event_note : Icons.edit,
            ),
            onPressed: () {
              ref
                  .read(appModeProvider.notifier)
                  .state = appMode == AppMode.setup
                  ? AppMode.reservation
                  : AppMode.setup;
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Table & Reservation',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
            ),
            ExpansionTile(
              leading: const Icon(Icons.map),
              title: const Text('Floors'),
              initiallyExpanded: true,
              children: [
                for (final floor in floors)
                  ListTile(
                    leading: const Icon(Icons.grid_on, size: 20),
                    title: Text(floor.name),
                    selected: floor.id == currentFloorId,
                    onTap: () {
                      ref.read(currentFloorProvider.notifier).state = floor.id;
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.add, size: 20),
                  title: const Text('Add New Floor'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddFloorDialog(),
                    );
                  },
                ),
              ],
            ),
            const ListTile(
              leading: Icon(Icons.people),
              title: Text('Customers'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: appMode == AppMode.setup
          ? TableSetupView(floor: currentFloor)
          : ReservationView(floor: currentFloor),
      floatingActionButton: appMode == AppMode.setup
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AddTableDialog(floorId: currentFloor.id),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// Setup View
class TableSetupView extends ConsumerWidget {
  final Floor floor;

  const TableSetupView({Key? key, required this.floor}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 2.0,
        child: SizedBox(
          width: floor.size.width,
          height: floor.size.height,
          child: Stack(
            children: [
              // Background grid
              Positioned.fill(child: CustomPaint(painter: GridPainter())),

              // Tables
              for (final table in floor.tables)
                DraggableTable(table: table, floorId: floor.id),
            ],
          ),
        ),
      ),
    );
  }
}

class DraggableTable extends ConsumerWidget {
  final Table table;
  final String floorId;

  const DraggableTable({Key? key, required this.table, required this.floorId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: table.position.dx,
      top: table.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          final newPosition = Offset(
            table.position.dx + details.delta.dx,
            table.position.dy + details.delta.dy,
          );

          ref
              .read(floorsProvider.notifier)
              .updateTable(floorId, table.copyWith(position: newPosition));
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) =>
                EditTableDialog(floorId: floorId, table: table),
          );
        },
        child: Container(
          width: table.width,
          height: table.height,
          decoration: BoxDecoration(
            color: _getTableColor(table.status),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${table.capacity} seats',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTableColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.teal;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.occupied:
        return Colors.redAccent;
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const spacing = 20.0;

    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Reservation View
class ReservationView extends ConsumerWidget {
  final Floor floor;

  const ReservationView({Key? key, required this.floor}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final reservations = ref.watch(reservationsProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DatePickerWidget(
                      selectedDate: selectedDate,
                      onDateChanged: (date) {
                        ref.read(selectedDateProvider.notifier).state = date;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TimeOfDay>(
                          value: TimeOfDay(
                            hour: selectedDate.hour,
                            minute: selectedDate.minute,
                          ),
                          onChanged: (TimeOfDay? time) {
                            if (time != null) {
                              final newDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                time.hour,
                                time.minute,
                              );
                              ref.read(selectedDateProvider.notifier).state =
                                  newDate;
                            }
                          },
                          items: [
                            for (int hour = 8; hour < 22; hour++)
                              DropdownMenuItem(
                                value: TimeOfDay(hour: hour, minute: 0),
                                child: Text(
                                  '${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}',
                                ),
                              ),
                            for (int hour = 8; hour < 22; hour++)
                              DropdownMenuItem(
                                value: TimeOfDay(hour: hour, minute: 30),
                                child: Text(
                                  '${hour % 12 == 0 ? 12 : hour % 12}:30 ${hour < 12 ? 'AM' : 'PM'}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reservations on ${_formatDate(selectedDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              reservations.isEmpty
                  ? const Text('No reservations for this date')
                  : SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          return Card(
                            margin: const EdgeInsets.only(right: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reservation.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('${reservation.partySize} guests'),
                                  Text('${_formatTime(reservation.dateTime)}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2.0,
              child: SizedBox(
                width: floor.size.width,
                height: floor.size.height,
                child: Stack(
                  children: [
                    // Background grid
                    Positioned.fill(child: CustomPaint(painter: GridPainter())),

                    // Tables
                    for (final table in floor.tables)
                      ReservationTable(
                        table: table,
                        floorId: floor.id,
                        selectedDateTime: selectedDate,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class ReservationTable extends ConsumerWidget {
  final Table table;
  final String floorId;
  final DateTime selectedDateTime;

  const ReservationTable({
    Key? key,
    required this.table,
    required this.floorId,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationsProvider);

    final isReserved = reservations
        .where(
          (r) =>
              r.tableId == table.id &&
              r.dateTime.day == selectedDateTime.day &&
              r.dateTime.month == selectedDateTime.month &&
              r.dateTime.year == selectedDateTime.year &&
              r.dateTime.hour <= selectedDateTime.hour + 2 &&
              r.dateTime.hour + r.duration.inHours >= selectedDateTime.hour,
        )
        .isNotEmpty;

    final tableStatus = isReserved
        ? TableStatus.reserved
        : TableStatus.available;

    return Positioned(
      left: table.position.dx,
      top: table.position.dy,
      child: GestureDetector(
        onTap: () {
          if (!isReserved) {
            showDialog(
              context: context,
              builder: (context) => AddReservationDialog(
                tableId: table.id,
                tableName: table.name,
                capacity: table.capacity,
                selectedDateTime: selectedDateTime,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This table is already reserved at this time'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Container(
          width: table.width,
          height: table.height,
          decoration: BoxDecoration(
            color: _getTableColor(tableStatus),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${table.capacity} seats',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              if (isReserved)
                Icon(
                  Icons.event_busy,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTableColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.teal;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.occupied:
        return Colors.redAccent;
    }
  }
}

// Dialogs
class AddTableDialog extends ConsumerStatefulWidget {
  final String floorId;

  const AddTableDialog({Key? key, required this.floorId}) : super(key: key);

  @override
  _AddTableDialogState createState() => _AddTableDialogState();
}

class _AddTableDialogState extends ConsumerState<AddTableDialog> {
  final _nameController = TextEditingController();
  int _capacity = 4;
  double _width = 80;
  double _height = 80;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Table'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Table Name',
                hintText: 'e.g. T1, Table 1',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Capacity: '),
                Expanded(
                  child: Slider(
                    value: _capacity.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: _capacity.toString(),
                    onChanged: (value) {
                      setState(() {
                        _capacity = value.toInt();
                      });
                    },
                  ),
                ),
                Text(_capacity.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Width: '),
                Expanded(
                  child: Slider(
                    value: _width,
                    min: 40,
                    max: 200,
                    divisions: 16,
                    label: _width.toString(),
                    onChanged: (value) {
                      setState(() {
                        _width = value;
                      });
                    },
                  ),
                ),
                Text(_width.toInt().toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Height: '),
                Expanded(
                  child: Slider(
                    value: _height,
                    min: 40,
                    max: 200,
                    divisions: 16,
                    label: _height.toString(),
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),
                ),
                Text(_height.toInt().toString()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              ref
                  .read(floorsProvider.notifier)
                  .addTable(
                    widget.floorId,
                    Table(
                      name: _nameController.text,
                      capacity: _capacity,
                      position: const Offset(100, 100),
                      width: _width,
                      height: _height,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditTableDialog extends ConsumerStatefulWidget {
  final String floorId;
  final Table table;

  const EditTableDialog({Key? key, required this.floorId, required this.table})
    : super(key: key);

  @override
  _EditTableDialogState createState() => _EditTableDialogState();
}

class _EditTableDialogState extends ConsumerState<EditTableDialog> {
  late TextEditingController _nameController;
  late int _capacity;
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.table.name);
    _capacity = widget.table.capacity;
    _width = widget.table.width;
    _height = widget.table.height;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Table'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Table Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Capacity: '),
                Expanded(
                  child: Slider(
                    value: _capacity.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: _capacity.toString(),
                    onChanged: (value) {
                      setState(() {
                        _capacity = value.toInt();
                      });
                    },
                  ),
                ),
                Text(_capacity.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Width: '),
                Expanded(
                  child: Slider(
                    value: _width,
                    min: 40,
                    max: 200,
                    divisions: 16,
                    label: _width.toString(),
                    onChanged: (value) {
                      setState(() {
                        _width = value;
                      });
                    },
                  ),
                ),
                Text(_width.toInt().toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Height: '),
                Expanded(
                  child: Slider(
                    value: _height,
                    min: 40,
                    max: 200,
                    divisions: 16,
                    label: _height.toString(),
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),
                ),
                Text(_height.toInt().toString()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Table'),
                content: const Text(
                  'Are you sure you want to delete this table?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(floorsProvider.notifier)
                          .removeTable(widget.floorId, widget.table.id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              ref
                  .read(floorsProvider.notifier)
                  .updateTable(
                    widget.floorId,
                    widget.table.copyWith(
                      name: _nameController.text,
                      capacity: _capacity,
                      width: _width,
                      height: _height,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class AddFloorDialog extends ConsumerStatefulWidget {
  const AddFloorDialog({Key? key}) : super(key: key);

  @override
  _AddFloorDialogState createState() => _AddFloorDialogState();
}

class _AddFloorDialogState extends ConsumerState<AddFloorDialog> {
  final _nameController = TextEditingController();
  double _width = 800;
  double _height = 600;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Floor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Floor Name',
                hintText: 'e.g. Main, Terrace, VIP',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Width: '),
                Expanded(
                  child: Slider(
                    value: _width,
                    min: 400,
                    max: 1200,
                    divisions: 8,
                    label: _width.toString(),
                    onChanged: (value) {
                      setState(() {
                        _width = value;
                      });
                    },
                  ),
                ),
                Text(_width.toInt().toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Height: '),
                Expanded(
                  child: Slider(
                    value: _height,
                    min: 300,
                    max: 900,
                    divisions: 6,
                    label: _height.toString(),
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),
                ),
                Text(_height.toInt().toString()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              ref
                  .read(floorsProvider.notifier)
                  .addFloor(
                    Floor(
                      name: _nameController.text,
                      size: Size(_width, _height),
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (pickedDate != null) {
                onDateChanged(
                  DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    selectedDate.hour,
                    selectedDate.minute,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class AddReservationDialog extends ConsumerStatefulWidget {
  final String tableId;
  final String tableName;
  final int capacity;
  final DateTime selectedDateTime;

  const AddReservationDialog({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.capacity,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  _AddReservationDialogState createState() => _AddReservationDialogState();
}

class _AddReservationDialogState extends ConsumerState<AddReservationDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late int _partySize;
  late DateTime _dateTime;
  int _duration = 2;

  @override
  void initState() {
    super.initState();
    _partySize = widget.capacity > 1 ? widget.capacity - 1 : 1;
    _dateTime = widget.selectedDateTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book Table ${widget.tableName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter full name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter contact number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Text('Date: ${_formatDate(_dateTime)}'),
            Text('Time: ${_formatTime(_dateTime)}'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Party Size: '),
                Expanded(
                  child: Slider(
                    value: _partySize.toDouble(),
                    min: 1,
                    max: widget.capacity.toDouble(),
                    divisions: widget.capacity - 1,
                    label: _partySize.toString(),
                    onChanged: (value) {
                      setState(() {
                        _partySize = value.toInt();
                      });
                    },
                  ),
                ),
                Text(_partySize.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Duration: '),
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 1,
                    max: 4,
                    divisions: 3,
                    label: '$_duration hours',
                    onChanged: (value) {
                      setState(() {
                        _duration = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_duration hrs'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _phoneController.text.isNotEmpty) {
              final reservation = Reservation(
                tableId: widget.tableId,
                customerName: _nameController.text,
                partySize: _partySize,
                dateTime: _dateTime,
                duration: Duration(hours: _duration),
              );

              ref
                  .read(reservationsProvider.notifier)
                  .addReservation(reservation);

              // Update table status to reserved
              final floors = ref.read(floorsProvider);
              final currentFloorId = ref.read(currentFloorProvider);

              if (currentFloorId != null) {
                final floor = floors.firstWhere((f) => f.id == currentFloorId);
                final table = floor.tables.firstWhere(
                  (t) => t.id == widget.tableId,
                );

                ref
                    .read(floorsProvider.notifier)
                    .updateTable(
                      currentFloorId,
                      table.copyWith(status: TableStatus.reserved),
                    );
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reservation created for ${_nameController.text}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Book Now'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// Main entry point
void main() {
  runApp(const RestaurantTableApp());
}
