import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/appointment_provider.dart';
import '../states/service_provider.dart';
import '../states/vehicle_provider.dart';
import 'appointment_screen.dart';
import 'vehicle_list_screen.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({Key? key, required this.serviceId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(serviceProvider(serviceId));
    final selectedVehicle = ref.watch(selectedVehicleProvider);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Details')),
        body: const Center(child: Text('Service not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(service.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. time: ${service.estimatedTime.inMinutes} mins',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(service.description),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: service.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (selectedVehicle != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(selectedVehicle.imageUrl),
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
                                  'Selected Vehicle',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${selectedVehicle.make} ${selectedVehicle.model}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${selectedVehicle.year} • ${selectedVehicle.licensePlate}',
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleListScreen(),
                                ),
                              );
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    )
                  else
                    Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleListScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.directions_car),
                              SizedBox(width: 16),
                              Text('Select a vehicle to continue'),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: selectedVehicle != null
                ? () {
                    final appointmentForm = ref.read(
                      appointmentFormProvider.notifier,
                    );

                    // Initialize appointment if needed
                    if (ref.read(appointmentFormProvider) == null) {
                      appointmentForm.setVehicle(selectedVehicle.id);
                    }

                    // Add service
                    appointmentForm.addService(service.id);

                    // Navigate to appointment screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Book This Service'),
          ),
        ),
      ),
    );
  }
}
