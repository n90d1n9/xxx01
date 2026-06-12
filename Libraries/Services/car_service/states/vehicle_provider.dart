import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/vehicle.dart';

class VehicleRepository {
  List<Vehicle> getUserVehicles(String userId) {
    // This would typically come from an API or database
    return [
      Vehicle(
        id: '1',
        make: 'Toyota',
        model: 'Camry',
        year: 2018,
        licensePlate: 'ABC123',
        imageUrl: 'assets/images/toyota_camry.jpg',
        ownerId: userId,
      ),
      Vehicle(
        id: '2',
        make: 'Honda',
        model: 'Civic',
        year: 2020,
        licensePlate: 'XYZ789',
        imageUrl: 'assets/images/honda_civic.jpg',
        ownerId: userId,
      ),
    ];
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    // In a real app, this would save to a database or API
    return vehicle;
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

final userVehiclesProvider = Provider.family<List<Vehicle>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getUserVehicles(userId);
});

final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);
