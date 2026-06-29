import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/repair_shop.dart';

class BookServiceScreen extends StatefulWidget {
  final String? vehicleId;
  final String? serviceType;

  const BookServiceScreen({super.key, this.vehicleId, this.serviceType});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int _currentStep = 0;
  String? _selectedVehicle;
  String? _selectedService;
  RepairShop? _selectedShop;
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicleId;
    _selectedService = widget.serviceType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            // Submit booking
            _confirmBooking();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Vehicle'),
            content: _buildVehicleStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Service'),
            content: _buildServiceStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Shop'),
            content: _buildShopStep(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Time'),
            content: _buildTimeStep(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Vehicle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // In a real app, fetch vehicles from VehicleService
        RadioListTile<String>(
          title: const Text('Honda Civic (2020)'),
          subtitle: const Text('ABC123'),
          value: '1',
          groupValue: _selectedVehicle,
          onChanged: (value) {
            setState(() {
              _selectedVehicle = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Toyota Camry (2018)'),
          subtitle: const Text('XYZ789'),
          value: '2',
          groupValue: _selectedVehicle,
          onChanged: (value) {
            setState(() {
              _selectedVehicle = value;
            });
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to add vehicle screen
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Vehicle'),
        ),
      ],
    );
  }

  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Common services
        const Text(
          'Common Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildServiceChip('Oil Change'),
            _buildServiceChip('Tire Rotation'),
            _buildServiceChip('Brake Service'),
            _buildServiceChip('Battery Replacement'),
          ],
        ),
        const SizedBox(height: 16),
        // Maintenance packages
        const Text(
          'Maintenance Packages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildServiceChip('Basic Maintenance'),
            _buildServiceChip('Premium Maintenance'),
            _buildServiceChip('Complete Tune-Up'),
          ],
        ),
        const SizedBox(height: 16),
        // Custom service
        const Text(
          'Custom Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Describe your service needs',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedService = 'Custom';
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildServiceChip(String service) {
    final isSelected = _selectedService == service;

    return ChoiceChip(
      label: Text(service),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedService = selected ? service : null;
        });
      },
    );
  }

  Widget _buildShopStep() {
    // In a real app, fetch shops from RepairShopService
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Repair Shop',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Shop options
        _buildShopOption(
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
        ),
        const SizedBox(height: 12),
        _buildShopOption(
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
            services: [
              'Oil Change',
              'Transmission',
              'AC Service',
              'Electrical',
            ],
            openHours: 'Open until 7:00 PM',
            isOpen: true,
            distance: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildShopOption(
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
            services: [
              'Oil Change',
              'Diagnostics',
              'Engine Repair',
              'Body Work',
            ],
            openHours: 'Open until 9:00 PM',
            isOpen: true,
            distance: 3.2,
          ),
        ),
      ],
    );
  }

  Widget _buildShopOption(RepairShop shop) {
    final isSelected = _selectedShop?.id == shop.id;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedShop = shop;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<String>(
                value: shop.id,
                groupValue: _selectedShop?.id,
                onChanged: (value) {
                  setState(() {
                    _selectedShop = shop;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toString(),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.distance} miles',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.address,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Date selection
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Appointment Date'),
          subtitle: Text(
            _selectedDate == null
                ? 'Select a date'
                : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
          ),
          onTap: () async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 30)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
        ),
        const Divider(),
        // Time selection
        const Text(
          'Available Time Slots',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimeChip('8:00 AM'),
            _buildTimeChip('9:30 AM'),
            _buildTimeChip('11:00 AM'),
            _buildTimeChip('1:30 PM'),
            _buildTimeChip('3:00 PM'),
            _buildTimeChip('4:30 PM'),
          ],
        ),
        const SizedBox(height: 24),
        // Additional notes
        const Text(
          'Additional Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Any special instructions for the shop',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTime == time;

    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTime = selected ? time : null;
        });
      },
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Service Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Vehicle: ${_selectedVehicle ?? 'Not selected'}'),
                  Text('Service: ${_selectedService ?? 'Not selected'}'),
                  Text('Shop: ${_selectedShop?.name ?? 'Not selected'}'),
                  Text(
                    'Date: ${_selectedDate != null ? DateFormat('MMM dd, yyyy').format(_selectedDate!) : 'Not selected'}',
                  ),
                  Text('Time: ${_selectedTime ?? 'Not selected'}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Please verify all details before confirming.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
