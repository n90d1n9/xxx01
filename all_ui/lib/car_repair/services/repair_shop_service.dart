import '../models/repair_shop.dart';

class RepairShopService {
  Future<List<RepairShop>> getNearbyShops() async {
    // In a real app, this would fetch from a database or API with location services
    return [
      RepairShop(
        id: '1',
        name: 'AutoFix Garage',
        address: '123 Main St, Anytown, USA',
        latitude: 37.7749,
        longitude: -122.4194,
        phoneNumber: '(555) 123-4567',
        website: 'https://autofixgarage.example.com',
        rating: 4.8,
        reviewCount: 245,
        services: ['Oil Change', 'Brake Service', 'Tires', 'Engine Repair'],
        openHours: 'Open until 8:00 PM',
        isOpen: true,
        distance: 1.2,
      ),
      RepairShop(
        id: '2',
        name: 'Pro Auto Service',
        address: '456 Oak St, Anytown, USA',
        latitude: 37.7848,
        longitude: -122.4294,
        phoneNumber: '(555) 987-6543',
        website: 'https://proautoservice.example.com',
        rating: 4.6,
        reviewCount: 187,
        services: ['Oil Change', 'Transmission', 'AC Service', 'Electrical'],
        openHours: 'Open until 7:00 PM',
        isOpen: true,
        distance: 2.5,
      ),
      RepairShop(
        id: '3',
        name: 'City Mechanics',
        address: '789 Pine St, Anytown, USA',
        latitude: 37.7947,
        longitude: -122.4394,
        phoneNumber: '(555) 456-7890',
        website: 'https://citymechanics.example.com',
        rating: 4.5,
        reviewCount: 132,
        services: ['Oil Change', 'Diagnostics', 'Engine Repair', 'Body Work'],
        openHours: 'Open until 9:00 PM',
        isOpen: true,
        distance: 3.2,
      ),
    ];
  }
}
