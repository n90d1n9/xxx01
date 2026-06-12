import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/appointment.dart';
import '../models/vehicle.dart';
import '../states/appointment_provider.dart';
import '../states/service_provider.dart';
import '../states/vehicle_provider.dart';
import 'add_vehicle_screen.dart';
import 'appointment_history_screen.dart';
import 'service_detail_screen.dart';
import 'service_list_screen.dart';
import 'vehicle_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming user ID for demo purposes
    const String userId = 'user123';

    // Access services and appointments
    final services = ref.watch(servicesProvider);
    final vehicles = ref.watch(userVehiclesProvider(userId));
    final appointments = ref.watch(userAppointmentsProvider(userId));

    // Filter upcoming appointments
    final upcomingAppointments = appointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Repair & Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: const DecorationImage(
                  image: AssetImage('assets/images/hero_image.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Professional Car Care',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServiceListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book Service Now'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming appointments
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Appointments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (upcomingAppointments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No upcoming appointments'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = upcomingAppointments[index];
                        final vehicle = vehicles.firstWhere(
                          (v) => v.id == appointment.vehicleId,
                          orElse: () => Vehicle(
                            id: '',
                            make: 'Unknown',
                            model: 'Vehicle',
                            year: 0,
                            licensePlate: '',
                            imageUrl: '',
                            ownerId: userId,
                          ),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${_formatDate(appointment.dateTime)}',
                                ),
                                Text(
                                  'Time: ${_formatTime(appointment.dateTime)}',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Services: ${appointment.serviceIds.length}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Services section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Our Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServiceListScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceDetailScreen(serviceId: service.id),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(right: 16),
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: AssetImage(service.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${service.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${service.estimatedTime.inMinutes} mins',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Vehicles section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Vehicles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleListScreen(),
                            ),
                          );
                        },
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (vehicles.isEmpty)
                    Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddVehicleScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline),
                              SizedBox(width: 16),
                              Text('Add a vehicle'),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: vehicles.length + 1, // +1 for the "Add" card
                        itemBuilder: (context, index) {
                          if (index == vehicles.length) {
                            // "Add" card
                            return Card(
                              margin: const EdgeInsets.only(right: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddVehicleScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.all(8),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Add Vehicle'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final vehicle = vehicles[index];

                          return Card(
                            margin: const EdgeInsets.only(right: 16),
                            child: InkWell(
                              onTap: () {
                                ref
                                        .read(selectedVehicleProvider.notifier)
                                        .state =
                                    vehicle;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceListScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 120,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: AssetImage(vehicle.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${vehicle.make} ${vehicle.model}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicle.year.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
