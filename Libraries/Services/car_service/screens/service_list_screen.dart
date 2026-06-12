import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/service.dart';
import '../states/appointment_provider.dart';
import '../states/service_provider.dart';
import '../states/vehicle_provider.dart';
import 'appointment_screen.dart';
import 'service_detail_screen.dart';
import 'vehicle_list_screen.dart';

class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final selectedVehicle = ref.watch(selectedVehicleProvider);

    final serviceCategories = <String, List<Service>>{
      'Maintenance': services
          .where((s) => s.tags.contains('Maintenance'))
          .toList(),
      'Repair': services.where((s) => s.tags.contains('Repair')).toList(),
      'Diagnostic': services
          .where((s) => s.tags.contains('Diagnostic'))
          .toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Column(
        children: [
          if (selectedVehicle != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
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
                          '${selectedVehicle.make} ${selectedVehicle.model}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                      ref.read(selectedVehicleProvider.notifier).state = null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleListScreen(),
                        ),
                      );
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.directions_car, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Select a vehicle to schedule service'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleListScreen(),
                        ),
                      );
                    },
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: serviceCategories.keys.length,
              itemBuilder: (context, index) {
                final category = serviceCategories.keys.elementAt(index);
                final categoryServices = serviceCategories[category] ?? [];

                if (categoryServices.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categoryServices.length,
                      itemBuilder: (context, serviceIndex) {
                        final service = categoryServices[serviceIndex];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailScreen(
                                    serviceId: service.id,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue.shade100,
                                      image: DecorationImage(
                                        image: AssetImage(service.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.description,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Est. time: ${service.estimatedTime.inMinutes} mins',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${service.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: selectedVehicle != null
                                            ? () {
                                                final appointmentForm = ref
                                                    .read(
                                                      appointmentFormProvider
                                                          .notifier,
                                                    );

                                                // Initialize appointment if needed
                                                if (ref.read(
                                                      appointmentFormProvider,
                                                    ) ==
                                                    null) {
                                                  appointmentForm.setVehicle(
                                                    selectedVehicle.id,
                                                  );
                                                }

                                                // Add service
                                                appointmentForm.addService(
                                                  service.id,
                                                );

                                                // Navigate to appointment screen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AppointmentScreen(),
                                                  ),
                                                );
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Book Now'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
