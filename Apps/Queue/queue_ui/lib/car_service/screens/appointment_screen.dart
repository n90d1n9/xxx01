import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../models/vehicle.dart';
import '../states/appointment_provider.dart';
import '../states/service_provider.dart';
import '../states/vehicle_provider.dart';
import 'service_list_screen.dart';
import 'vehicle_list_screen.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0 ? '$hours hr $minutes min' : '$minutes min';
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      ref
          .read(appointmentFormProvider.notifier)
          .setDateTime(
            DateTime(
              picked.year,
              picked.month,
              picked.day,
              initialDate.hour,
              initialDate.minute,
            ),
          );
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (picked != null) {
      ref
          .read(appointmentFormProvider.notifier)
          .setDateTime(
            DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day,
              picked.hour,
              picked.minute,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointment = ref.watch(appointmentFormProvider);
    final availableServices = ref.watch(servicesProvider);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule Appointment')),
        body: const Center(child: Text('No appointment data available')),
      );
    }

    // Get vehicle
    const String userId = 'user123'; // Assuming user ID for demo purposes
    final vehicles = ref.watch(userVehiclesProvider(userId));
    final vehicle = vehicles.firstWhere(
      (v) => v.id == appointment.vehicleId,
      orElse:
          () => Vehicle(
            id: '',
            make: 'Unknown',
            model: 'Vehicle',
            year: 0,
            licensePlate: '',
            imageUrl: '',
            ownerId: userId,
          ),
    );

    // Get selected services
    final selectedServices =
        appointment.serviceIds
            .map(
              (id) => availableServices.firstWhere(
                (s) => s.id == id,
                orElse:
                    () => Service(
                      id: '',
                      name: 'Unknown Service',
                      description: '',
                      price: 0,
                      imageUrl: '',
                      estimatedTime: const Duration(),
                      tags: [],
                    ),
              ),
            )
            .toList();

    // Calculate total price
    final totalPrice = selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );

    // Calculate total time
    final totalMinutes = selectedServices.fold<int>(
      0,
      (sum, service) => (sum + service.estimatedTime.inMinutes).toInt(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Appointment')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Vehicle section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                  image: AssetImage(vehicle.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle.make} ${vehicle.model}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${vehicle.year} • ${vehicle.licensePlate}',
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const VehicleListScreen(),
                                  ),
                                );
                              },
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Date & Time section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Appointment Date'),
                          subtitle: Text(_formatDate(appointment.dateTime)),
                          trailing: TextButton(
                            onPressed: () {
                              _selectDate(context, ref, appointment.dateTime);
                            },
                            child: const Text('Change'),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time),
                          title: const Text('Appointment Time'),
                          subtitle: Text(_formatTime(appointment.dateTime)),
                          trailing: TextButton(
                            onPressed: () {
                              _selectTime(context, ref, appointment.dateTime);
                            },
                            child: const Text('Change'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Services section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ServiceListScreen(),
                                  ),
                                );
                              },
                              child: const Text('Add More'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (selectedServices.isEmpty)
                          const Text('No services selected yet')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedServices.length,
                            itemBuilder: (context, index) {
                              final service = selectedServices[index];

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.shade100,
                                    image: DecorationImage(
                                      image: AssetImage(service.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(service.name),
                                subtitle: Text(
                                  'Est. time: ${service.estimatedTime.inMinutes} mins',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${service.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        ref
                                            .read(
                                              appointmentFormProvider.notifier,
                                            )
                                            .removeService(service.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Time:'),
                            Text(
                              _formatDuration(Duration(minutes: totalMinutes)),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price:'),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: appointment.notes,
                          decoration: const InputDecoration(
                            hintText:
                                'Add any special instructions or notes here',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            ref
                                .read(appointmentFormProvider.notifier)
                                .setNotes(value.trim().isEmpty ? null : value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          selectedServices.isEmpty
                              ? null
                              : () {
                                // Submit the appointment
                                // Navigate to confirmation screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Appointment scheduled successfully',
                                    ),
                                  ),
                                );
                                // Reset form and navigate back to home screen
                                ref
                                    .read(appointmentFormProvider.notifier)
                                    .reset();
                                Navigator.pop(context);
                              },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Schedule Appointment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
