import 'package:flutter_riverpod/legacy.dart';

import '../models/service.dart';

class ServiceRepository {
  List<Service> getServices() {
    // This would typically come from an API or database
    return [
      Service(
        id: '1',
        name: 'Oil Change',
        description: 'Complete oil change with filter replacement',
        price: 49.99,
        imageUrl: 'assets/images/oil_change.jpg',
        estimatedTime: const Duration(minutes: 30),
        tags: ['Maintenance', 'Quick Service'],
      ),
      Service(
        id: '2',
        name: 'Brake Pad Replacement',
        description: 'Front or rear brake pad replacement',
        price: 129.99,
        imageUrl: 'assets/images/brake_pads.jpg',
        estimatedTime: const Duration(hours: 1, minutes: 30),
        tags: ['Repair', 'Safety'],
      ),
      Service(
        id: '3',
        name: 'Tire Rotation',
        description: 'Tire rotation to ensure even wear',
        price: 29.99,
        imageUrl: 'assets/images/tire_rotation.jpg',
        estimatedTime: const Duration(minutes: 45),
        tags: ['Maintenance', 'Tires'],
      ),
      Service(
        id: '4',
        name: 'Engine Diagnostic',
        description: 'Computer diagnostic of engine systems',
        price: 89.99,
        imageUrl: 'assets/images/engine_diagnostic.jpg',
        estimatedTime: const Duration(hours: 1),
        tags: ['Diagnostic', 'Engine'],
      ),
    ];
  }

  Service? getServiceById(String id) {
    try {
      return getServices().firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

final servicesProvider = Provider<List<Service>>((ref) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServices();
});

final serviceProvider = Provider.family<Service?, String>((ref, id) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServiceById(id);
});
