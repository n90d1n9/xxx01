import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}

class Room {
  final String id;
  final String name;
  final int capacity;
  final bool isAvailable;
  final String? description;
  final String? imageUrl;

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.isAvailable,
    this.description,
    this.imageUrl,
  });
}

class RoomReservation {
  final String id;
  final Room room;
  final Customer customer;
  final DateTime reservationDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int guestCount;
  final String? specialRequests;
  final ReservationStatus status;

  RoomReservation({
    required this.id,
    required this.room,
    required this.customer,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    this.specialRequests,
    this.status = ReservationStatus.confirmed,
  });
}

enum ReservationStatus { pending, confirmed, cancelled, completed }

// Providers
final customersProvider = StateProvider<List<Customer>>((ref) {
  // Example data
  return [
    Customer(
      id: '1',
      name: 'John Doe',
      phone: '555-1234',
      email: 'john@example.com',
    ),
    Customer(
      id: '2',
      name: 'Jane Smith',
      phone: '555-5678',
      email: 'jane@example.com',
    ),
    Customer(
      id: '3',
      name: 'Robert Brown',
      phone: '555-9012',
      email: 'robert@example.com',
    ),
  ];
});

final roomsProvider = StateProvider<List<Room>>((ref) {
  // Example data
  return [
    Room(
      id: '1',
      name: 'VIP Lounge',
      capacity: 12,
      isAvailable: true,
      description: 'Private dining experience with premium service',
      imageUrl: 'assets/images/vip_lounge.jpg',
    ),
    Room(
      id: '2',
      name: 'Garden Room',
      capacity: 20,
      isAvailable: true,
      description: 'Beautiful view of our garden area',
      imageUrl: 'assets/images/garden_room.jpg',
    ),
    Room(
      id: '3',
      name: 'Conference Room',
      capacity: 30,
      isAvailable: false,
      description: 'Perfect for business meetings and presentations',
      imageUrl: 'assets/images/conference_room.jpg',
    ),
  ];
});

final reservationsProvider = StateProvider<List<RoomReservation>>((ref) {
  // Example data
  final rooms = ref.watch(roomsProvider);
  final customers = ref.watch(customersProvider);

  return [
    RoomReservation(
      id: '1',
      room: rooms[0],
      customer: customers[0],
      reservationDate: DateTime.now().add(Duration(days: 1)),
      startTime: TimeOfDay(hour: 18, minute: 0),
      endTime: TimeOfDay(hour: 21, minute: 0),
      guestCount: 8,
      specialRequests: 'Birthday celebration',
      status: ReservationStatus.confirmed,
    ),
    RoomReservation(
      id: '2',
      room: rooms[1],
      customer: customers[1],
      reservationDate: DateTime.now().add(Duration(days: 3)),
      startTime: TimeOfDay(hour: 12, minute: 30),
      endTime: TimeOfDay(hour: 15, minute: 30),
      guestCount: 15,
      specialRequests: 'Wheelchair access needed',
      status: ReservationStatus.pending,
    ),
  ];
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final filteredReservationsProvider = Provider<List<RoomReservation>>((ref) {
  final reservations = ref.watch(reservationsProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return reservations.where((reservation) {
    return DateUtils.isSameDay(reservation.reservationDate, selectedDate);
  }).toList();
});

// UI
class RestaurantRoomReservationScreen extends ConsumerWidget {
  const RestaurantRoomReservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final reservations = ref.watch(filteredReservationsProvider);
    final rooms = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room Reservations'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddReservationModal(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector strip
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // Two weeks
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(date, selectedDate);

                return GestureDetector(
                  onTap:
                      () =>
                          ref.read(selectedDateProvider.notifier).state = date,
                  child: Container(
                    width: 70,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Stats Cards
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Reservations',
                  value: '${reservations.length}',
                  icon: Icons.book_online,
                  color: Colors.blue,
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Available Rooms',
                  value: '${rooms.where((room) => room.isAvailable).length}',
                  icon: Icons.meeting_room,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Reservation List
          Expanded(
            child:
                reservations.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reservations for this date',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add Reservation'),
                            onPressed:
                                () => _showAddReservationModal(context, ref),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: reservations.length,
                      padding: EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return _buildReservationCard(context, reservation);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddReservationModal(context, ref),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    RoomReservation reservation,
  ) {
    final statusColors = {
      ReservationStatus.pending: Colors.orange,
      ReservationStatus.confirmed: Colors.green,
      ReservationStatus.cancelled: Colors.red,
      ReservationStatus.completed: Colors.blue,
    };

    final statusText = {
      ReservationStatus.pending: 'Pending',
      ReservationStatus.confirmed: 'Confirmed',
      ReservationStatus.cancelled: 'Cancelled',
      ReservationStatus.completed: 'Completed',
    };

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image:
                        reservation.room.imageUrl != null
                            ? DecorationImage(
                              image: AssetImage(reservation.room.imageUrl!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      reservation.room.imageUrl == null
                          ? Icon(Icons.meeting_room, color: Colors.grey)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.room.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Capacity: ${reservation.room.capacity} people',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColors[reservation.status]!.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColors[reservation.status]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText[reservation.status]!,
                    style: TextStyle(
                      color: statusColors[reservation.status],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        reservation.customer.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        reservation.customer.phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_formatTimeOfDay(reservation.startTime)} - ${_formatTimeOfDay(reservation.endTime)}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Guests: ${reservation.guestCount}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reservation.specialRequests != null &&
                reservation.specialRequests!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Requests',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      reservation.specialRequests!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Edit'),
                  onPressed: () {},
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Cancel'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReservationModal(BuildContext context, WidgetRef ref) {
    // Implementation for adding a new reservation
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Reservation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Expanded(child: AddReservationForm(ref: ref)),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, WidgetRef ref) {
    // Implementation for filtering reservations
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Reservations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter options would go here
              Text('Filter options will be implemented here'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Apply'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// Add Reservation Form
class AddReservationForm extends StatefulWidget {
  final WidgetRef ref;

  const AddReservationForm({Key? key, required this.ref}) : super(key: key);

  @override
  State<AddReservationForm> createState() => _AddReservationFormState();
}

class _AddReservationFormState extends State<AddReservationForm> {
  late DateTime selectedDate;
  TimeOfDay startTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 20, minute: 0);
  String? selectedRoomId;
  String? selectedCustomerId;
  int guestCount = 4;
  final specialRequestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.ref.read(selectedDateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.ref.watch(roomsProvider);
    final customers = widget.ref.watch(customersProvider);

    final availableRooms = rooms.where((room) => room.isAvailable).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Picker
          Text(
            'Date',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 90)),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Time Range
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(startTime),
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.access_time),
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
                      'End Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(endTime),
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.access_time),
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

          // Room Selection
          Text(
            'Room',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Room'),
                value: selectedRoomId,
                items:
                    availableRooms.map((room) {
                      return DropdownMenuItem<String>(
                        value: room.id,
                        child: Text(
                          '${room.name} (Capacity: ${room.capacity})',
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoomId = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16),

          // Customer Selection
          Text(
            'Customer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Customer'),
                value: selectedCustomerId,
                items:
                    customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.id,
                        child: Text('${customer.name} (${customer.phone})'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomerId = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16),

          // Guest Count
          Text(
            'Number of Guests',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (guestCount > 1) {
                    setState(() {
                      guestCount--;
                    });
                  }
                },
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$guestCount', style: TextStyle(fontSize: 16)),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    guestCount++;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),

          // Special Requests
          Text(
            'Special Requests',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          TextField(
            controller: specialRequestsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter any special requests or notes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Save reservation logic would go here
                Navigator.pop(context);
              },
              child: Text(
                'Create Reservation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Restaurant Room Reservation',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[50],
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        home: RestaurantRoomReservationScreen(),
      ),
    ),
  );
}
