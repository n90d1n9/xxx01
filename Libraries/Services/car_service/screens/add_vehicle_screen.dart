import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/vehicle.dart';
import '../states/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);

      // Create new vehicle
      final vehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        licensePlate: _licensePlateController.text.trim(),
        imageUrl: 'assets/images/default_car.jpg', // Default image
        ownerId: 'user123', // Assuming user ID for demo purposes
      );

      // Save vehicle
      final savedVehicle = await vehicleRepository.addVehicle(vehicle);

      // Set as selected vehicle
      ref.read(selectedVehicleProvider.notifier).state = savedVehicle;

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding vehicle: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make',
                hintText: 'e.g. Toyota, Honda, Ford',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the make';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g. Camry, Civic, F-150',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the model';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g. 2020',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the year';
                }
                try {
                  final year = int.parse(value);
                  if (year < 1900 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                } catch (e) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                hintText: 'e.g. ABC123',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the license plate';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveVehicle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
