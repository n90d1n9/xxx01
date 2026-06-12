import '../models/maintenance_item.dart';
import '../models/service_record.dart';
import '../models/vehicle.dart';

class VehicleService {
  Future<List<Vehicle>> getVehicles() async {
    // In a real app, this would fetch from a database or API
    return [
      Vehicle(
        id: '1',
        make: 'Honda',
        model: 'Civic',
        year: '2020',
        licensePlate: 'ABC123',
        mileage: 32456,
        vinNumber: '1HGCM82633A123456',
      ),
      Vehicle(
        id: '2',
        make: 'Toyota',
        model: 'Camry',
        year: '2018',
        licensePlate: 'XYZ789',
        mileage: 45789,
        vinNumber: '4T1BF1FK7CU123456',
      ),
    ];
  }

  Future<List<MaintenanceItem>> getMaintenanceItems(String vehicleId) async {
    // In a real app, this would fetch from a database or API
    final now = DateTime.now();
    return [
      MaintenanceItem(
        id: '1',
        vehicleId: vehicleId,
        type: 'Oil Change',
        lastServiced: now.subtract(const Duration(days: 90)),
        lastServicedMileage: 30000,
        recommendedIntervalMonths: 6,
        recommendedIntervalMiles: 5000,
        health: 70,
        nextDueDate: now.add(const Duration(days: 90)),
        nextDueMileage: 35000,
      ),
      MaintenanceItem(
        id: '2',
        vehicleId: vehicleId,
        type: 'Tire Rotation',
        lastServiced: now.subtract(const Duration(days: 120)),
        lastServicedMileage: 28000,
        recommendedIntervalMonths: 12,
        recommendedIntervalMiles: 7500,
        health: 60,
        nextDueDate: now.add(const Duration(days: 60)),
        nextDueMileage: 35500,
      ),
      MaintenanceItem(
        id: '3',
        vehicleId: vehicleId,
        type: 'Brake Inspection',
        lastServiced: now.subtract(const Duration(days: 150)),
        lastServicedMileage: 25000,
        recommendedIntervalMonths: 12,
        recommendedIntervalMiles: 10000,
        health: 65,
        nextDueDate: now.add(const Duration(days: 30)),
        nextDueMileage: 35000,
      ),
    ];
  }

  Future<List<ServiceRecord>> getServiceHistory(String? vehicleId) async {
    // In a real app, this would fetch from a database or API
    final now = DateTime.now();
    return [
      ServiceRecord(
        id: '1',
        vehicleId: vehicleId ?? '1',
        serviceType: 'Oil Change & Tire Rotation',
        date: now.subtract(const Duration(days: 15)),
        mileage: 32000,
        cost: 65.99,
        description: 'Regular oil change with synthetic oil and tire rotation',
        shopName: 'AutoFix Garage',
        status: 'Completed',
      ),
      ServiceRecord(
        id: '2',
        vehicleId: vehicleId ?? '1',
        serviceType: 'Brake Pad Replacement',
        date: now.subtract(const Duration(days: 45)),
        mileage: 31500,
        cost: 220.00,
        description: 'Front brake pad replacement and rotor inspection',
        shopName: 'AutoFix Garage',
        status: 'Completed',
      ),
      ServiceRecord(
        id: '3',
        vehicleId: vehicleId ?? '2',
        serviceType: 'AC System Repair',
        date: now.subtract(const Duration(days: 60)),
        mileage: 44500,
        cost: 350.00,
        description: 'AC compressor replacement and system recharge',
        shopName: 'Pro Auto Service',
        status: 'Completed',
      ),
      ServiceRecord(
        id: '4',
        vehicleId: vehicleId ?? '2',
        serviceType: 'Engine Diagnostics',
        date: now.subtract(const Duration(days: 90)),
        mileage: 43800,
        cost: 80.00,
        description: 'Check engine light diagnosis and code clearing',
        shopName: 'City Mechanics',
        status: 'Completed',
      ),
    ];
  }
}
