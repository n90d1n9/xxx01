import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Room {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final int capacity;
  final List<String> amenities;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.capacity,
    required this.amenities,
  });
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class RoomReservation {
  final String id;
  final Room room;
  final Customer customer;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double totalPrice;
  final String status;

  RoomReservation({
    required this.id,
    required this.room,
    required this.customer,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });
}

// Providers
final roomsProvider = StateNotifierProvider<RoomsNotifier, List<Room>>((ref) {
  return RoomsNotifier();
});

class RoomsNotifier extends StateNotifier<List<Room>> {
  RoomsNotifier()
    : super([
        Room(
          id: '1',
          name: 'Deluxe Suite',
          imageUrl: 'https://example.com/deluxe-suite.jpg',
          price: 299.99,
          description: 'Spacious suite with king-size bed and ocean view',
          capacity: 2,
          amenities: [
            'Free WiFi',
            'Breakfast Included',
            'Pool Access',
            'Spa Access',
          ],
        ),
        Room(
          id: '2',
          name: 'Executive Room',
          imageUrl: 'https://example.com/executive-room.jpg',
          price: 199.99,
          description: 'Comfortable room with city view',
          capacity: 2,
          amenities: ['Free WiFi', 'Work Desk', 'Mini Bar'],
        ),
        Room(
          id: '3',
          name: 'Family Suite',
          imageUrl: 'https://example.com/family-suite.jpg',
          price: 399.99,
          description: 'Perfect for families with two bedrooms',
          capacity: 4,
          amenities: [
            'Free WiFi',
            'Breakfast Included',
            'Kids Play Area',
            'Connecting Rooms',
          ],
        ),
      ]);
}

final selectedRoomProvider = StateProvider<Room?>((ref) => null);

final selectedDatesProvider = StateProvider<DateTimeRange?>((ref) => null);

final guestsCountProvider = StateProvider<int>((ref) => 1);

final customerProvider = StateProvider<Customer?>(
  (ref) => Customer(
    id: 'c1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1 555-123-4567',
  ),
);

final reservationProvider = StateProvider<List<RoomReservation>>((ref) => []);

// Reservation Screen
class RoomReservationScreen extends ConsumerStatefulWidget {
  const RoomReservationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RoomReservationScreen> createState() =>
      _RoomReservationScreenState();
}

class _RoomReservationScreenState extends ConsumerState<RoomReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _makeReservation() {
    if (_formKey.currentState!.validate()) {
      final room = ref.read(selectedRoomProvider);
      final dateRange = ref.read(selectedDatesProvider);
      final guests = ref.read(guestsCountProvider);
      final customer = ref.read(customerProvider);

      if (room != null && dateRange != null && customer != null) {
        final nights = dateRange.end.difference(dateRange.start).inDays;
        final totalPrice = room.price * nights;

        final newReservation = RoomReservation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          room: room,
          customer: customer,
          checkInDate: dateRange.start,
          checkOutDate: dateRange.end,
          guests: guests,
          totalPrice: totalPrice,
          status: 'Confirmed',
        );

        // Add the new reservation to the list
        final reservations = ref.read(reservationProvider.notifier);
        reservations.state = [...ref.read(reservationProvider), newReservation];

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservation confirmed!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        ref.read(selectedRoomProvider.notifier).state = null;
        ref.read(selectedDatesProvider.notifier).state = null;
        ref.read(guestsCountProvider.notifier).state = 1;
        _specialRequestsController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomsProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);
    final selectedDates = ref.watch(selectedDatesProvider);
    final guestsCount = ref.watch(guestsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room Reservation'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Room selection
            Text(
              'Select Room',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final isSelected = selectedRoom?.id == room.id;

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedRoomProvider.notifier).state = room;
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.hotel,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      room.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\$${room.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capacity: ${room.capacity} people',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Date selection
            Text(
              'Select Dates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (dateRange != null) {
                  ref.read(selectedDatesProvider.notifier).state = dateRange;
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedDates == null
                          ? 'Select check-in and check-out dates'
                          : '${DateFormat('MMM dd, yyyy').format(selectedDates.start)} - ${DateFormat('MMM dd, yyyy').format(selectedDates.end)}',
                      style: TextStyle(
                        color: selectedDates == null
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Guest count
            Text(
              'Number of Guests',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Guests'),
                  Row(
                    children: [
                      IconButton(
                        onPressed: guestsCount > 1
                            ? () {
                                ref.read(guestsCountProvider.notifier).state--;
                              }
                            : null,
                        icon: Icon(Icons.remove),
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        '$guestsCount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(guestsCountProvider.notifier).state++;
                        },
                        icon: Icon(Icons.add),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Special requests
            Text(
              'Special Requests',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialRequestsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requests?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Summary
            if (selectedRoom != null && selectedDates != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservation Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Room:'), Text(selectedRoom.name)],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Check-in:'),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(selectedDates.start),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Check-out:'),
                        Text(
                          DateFormat('MMM dd, yyyy').format(selectedDates.end),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Guests:'), Text('$guestsCount')],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nights:'),
                        Text(
                          '${selectedDates.end.difference(selectedDates.start).inDays}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${(selectedRoom.price * selectedDates.end.difference(selectedDates.start).inDays).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Reservation button
            ElevatedButton(
              onPressed: selectedRoom != null && selectedDates != null
                  ? _makeReservation
                  : null,
              style: ElevatedButton.styleFrom(
                //primary: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Confirm Reservation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reservation List Screen
class ReservationListScreen extends ConsumerWidget {
  const ReservationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Reservations'),
        elevation: 0,
        centerTitle: true,
      ),
      body: reservations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_outlined,
                    size: 86,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reservations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your reservations will appear here',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ReservationCard(reservation: reservation);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RoomReservationScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

// Reservation Card Widget
class ReservationCard extends StatelessWidget {
  final RoomReservation reservation;

  const ReservationCard({Key? key, required this.reservation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reservation.room.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reservation.status,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Room image placeholder
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.hotel, size: 48, color: Colors.grey.shade400),
            ),
          ),

          // Reservation details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date and guest information
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(reservation.checkInDate),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 30,
                      child: VerticalDivider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        width: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-out',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(reservation.checkOutDate),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 30,
                      child: VerticalDivider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        width: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guests',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reservation.guests}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 16),

                // Customer information
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.customer.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.customer.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 16),

                // Payment information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total amount',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      '\$${reservation.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement cancel reservation functionality
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.red),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement modify reservation functionality
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Modify',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Main App
class HotelReservationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Hotel Reservations',
        theme: ThemeData(
          primaryColor: Colors.indigo,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.indigo,
            secondary: Colors.indigoAccent,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          fontFamily: 'Poppins',
        ),
        home: ReservationListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void main() {
  runApp(HotelReservationApp());
}
