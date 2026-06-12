import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

// Main App
class ParkingSecurityApp extends StatelessWidget {
  const ParkingSecurityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Parking Security System',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const ParkingManagementScreen(),
      ),
    );
  }
}

void main() {
  runApp(const ParkingSecurityApp());
}

// Models
class Vehicle {
  final String id;
  final String licensePlate;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String vehicleType;
  final String entryPhotoPath;
  final String? exitPhotoPath;
  final String status; // 'checked-in', 'checked-out'

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.entryTime,
    this.exitTime,
    required this.vehicleType,
    required this.entryPhotoPath,
    this.exitPhotoPath,
    required this.status,
  });

  Vehicle copyWith({
    String? id,
    String? licensePlate,
    DateTime? entryTime,
    DateTime? exitTime,
    String? vehicleType,
    String? entryPhotoPath,
    String? exitPhotoPath,
    String? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime,
      vehicleType: vehicleType ?? this.vehicleType,
      entryPhotoPath: entryPhotoPath ?? this.entryPhotoPath,
      exitPhotoPath: exitPhotoPath ?? this.exitPhotoPath,
      status: status ?? this.status,
    );
  }
}

// Barrier Control System
class BarrierSystem {
  final String id;
  final String location; // 'entry' or 'exit'
  final String status; // 'open', 'closed', 'error'
  final DateTime lastStatusChange;

  BarrierSystem({
    required this.id,
    required this.location,
    required this.status,
    required this.lastStatusChange,
  });

  BarrierSystem copyWith({
    String? id,
    String? location,
    String? status,
    DateTime? lastStatusChange,
  }) {
    return BarrierSystem(
      id: id ?? this.id,
      location: location ?? this.location,
      status: status ?? this.status,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
    );
  }
}

// Providers
final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  (ref) {
    return VehiclesNotifier();
  },
);

final barrierSystemsProvider =
    StateNotifierProvider<BarrierSystemsNotifier, List<BarrierSystem>>((ref) {
      return BarrierSystemsNotifier();
    });

final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);
final cameraControllerProvider = FutureProvider<CameraController>((ref) async {
  final cameras = await availableCameras();
  final camera = cameras.first;
  final controller = CameraController(camera, ResolutionPreset.high);
  await controller.initialize();
  return controller;
});

final capturedImageProvider = StateProvider<File?>((ref) => null);
final isCapturingProvider = StateProvider<bool>((ref) => false);
final securityModeProvider = StateProvider<String>(
  (ref) => 'entry',
); // 'entry' or 'exit'
final barrierOperationProvider = StateProvider<bool>(
  (ref) => false,
); // Track if barrier operation is in progress

// Notifiers
class VehiclesNotifier extends StateNotifier<List<Vehicle>> {
  VehiclesNotifier()
    : super([
        Vehicle(
          id: '1',
          licensePlate: 'ABC123',
          entryTime: DateTime.now().subtract(const Duration(hours: 2)),
          vehicleType: 'Sedan',
          entryPhotoPath: 'assets/sample_entry.jpg',
          status: 'checked-in',
        ),
        Vehicle(
          id: '2',
          licensePlate: 'XYZ789',
          entryTime: DateTime.now().subtract(const Duration(hours: 5)),
          exitTime: DateTime.now().subtract(const Duration(hours: 1)),
          vehicleType: 'SUV',
          entryPhotoPath: 'assets/sample_entry.jpg',
          exitPhotoPath: 'assets/sample_exit.jpg',
          status: 'checked-out',
        ),
      ]);

  void addVehicle(Vehicle vehicle) {
    state = [...state, vehicle];
  }

  void updateVehicle(Vehicle vehicle) {
    state = state.map((v) => v.id == vehicle.id ? vehicle : v).toList();
  }

  void checkOutVehicle(String id, String exitPhotoPath) {
    state =
        state.map((vehicle) {
          if (vehicle.id == id) {
            return vehicle.copyWith(
              exitTime: DateTime.now(),
              exitPhotoPath: exitPhotoPath,
              status: 'checked-out',
            );
          }
          return vehicle;
        }).toList();
  }
}

class BarrierSystemsNotifier extends StateNotifier<List<BarrierSystem>> {
  BarrierSystemsNotifier()
    : super([
        BarrierSystem(
          id: 'entry-gate-1',
          location: 'entry',
          status: 'closed',
          lastStatusChange: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        BarrierSystem(
          id: 'exit-gate-1',
          location: 'exit',
          status: 'closed',
          lastStatusChange: DateTime.now().subtract(
            const Duration(minutes: 30),
          ),
        ),
      ]);

  // Simulate API call to control the barrier
  Future<bool> controlBarrier(String id, String action) async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 2));

    // Update the state with the new barrier status
    state =
        state.map((barrier) {
          if (barrier.id == id) {
            return barrier.copyWith(
              status: action == 'open' ? 'open' : 'closed',
              lastStatusChange: DateTime.now(),
            );
          }
          return barrier;
        }).toList();

    // Auto-close after 10 seconds if opened
    if (action == 'open') {
      Future.delayed(const Duration(seconds: 10), () {
        state =
            state.map((barrier) {
              if (barrier.id == id && barrier.status == 'open') {
                return barrier.copyWith(
                  status: 'closed',
                  lastStatusChange: DateTime.now(),
                );
              }
              return barrier;
            }).toList();
      });
    }

    return true; // Success
  }
}

// Helper Widgets
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Main Widget
class ParkingManagementScreen extends ConsumerWidget {
  const ParkingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityMode = ref.watch(securityModeProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final barriers = ref.watch(barrierSystemsProvider);
    final activeVehicles =
        vehicles.where((v) => v.status == 'checked-in').toList();
    final completedVehicles =
        vehicles.where((v) => v.status == 'checked-out').toList();

    // Find relevant barrier for current mode
    final currentBarrier = barriers.firstWhere(
      (b) => b.location == securityMode,
      orElse:
          () => BarrierSystem(
            id: 'unknown',
            location: securityMode,
            status: 'error',
            lastStatusChange: DateTime.now(),
          ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Smart Parking Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Mode Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.indigo,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () =>
                            ref.read(securityModeProvider.notifier).state =
                                'entry',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            securityMode == 'entry'
                                ? Colors.white
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'ENTRY CHECK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                securityMode == 'entry'
                                    ? Colors.indigo
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () =>
                            ref.read(securityModeProvider.notifier).state =
                                'exit',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            securityMode == 'exit'
                                ? Colors.white
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'EXIT CHECK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                securityMode == 'exit'
                                    ? Colors.indigo
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barrier Status
          Container(
            color: _getBarrierStatusColor(currentBarrier.status),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _getBarrierStatusIcon(currentBarrier.status),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gate Status: ${currentBarrier.status.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Consumer(
                  builder: (context, ref, child) {
                    final isBarrierOperating = ref.watch(
                      barrierOperationProvider,
                    );

                    if (isBarrierOperating) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    return TextButton(
                      onPressed: () async {
                        // Toggle barrier
                        final newAction =
                            currentBarrier.status == 'open' ? 'close' : 'open';
                        ref.read(barrierOperationProvider.notifier).state =
                            true;

                        try {
                          await ref
                              .read(barrierSystemsProvider.notifier)
                              .controlBarrier(currentBarrier.id, newAction);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error controlling barrier: $e'),
                            ),
                          );
                        } finally {
                          ref.read(barrierOperationProvider.notifier).state =
                              false;
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        currentBarrier.status == 'open'
                            ? 'CLOSE GATE'
                            : 'OPEN GATE',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child:
                securityMode == 'entry'
                    ? const EntrySecurityWidget()
                    : const ExitSecurityWidget(),
          ),

          // Stats Panel
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Active Vehicles',
                    value: activeVehicles.length.toString(),
                    icon: Icons.directions_car,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Completed Today',
                    value: completedVehicles.length.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Available Spots',
                    value: '42',
                    icon: Icons.local_parking,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraCapturePage()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Color _getBarrierStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getBarrierStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.door_front_door_outlined;
      case 'closed':
        return Icons.door_front_door;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.question_mark;
    }
  }
}

// Entry Security Widget
class EntrySecurityWidget extends ConsumerWidget {
  const EntrySecurityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedImage = ref.watch(capturedImageProvider);
    final barriers = ref.watch(barrierSystemsProvider);
    final entryBarrier = barriers.firstWhere(
      (b) => b.location == 'entry',
      orElse:
          () => BarrierSystem(
            id: 'entry-gate-1',
            location: 'entry',
            status: 'error',
            lastStatusChange: DateTime.now(),
          ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Entry Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Camera Preview or Captured Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                capturedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(capturedImage, fit: BoxFit.cover),
                    )
                    : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Tap the camera button to capture\nentry photo',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
          ),

          const SizedBox(height: 24),

          // Entry Form
          const Text(
            'Vehicle Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              labelText: 'License Plate',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
              DropdownMenuItem(value: 'SUV', child: Text('SUV')),
              DropdownMenuItem(value: 'Truck', child: Text('Truck')),
              DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
            ],
            onChanged: (value) {},
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              // Submit Button
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      capturedImage != null
                          ? () async {
                            // Process entry
                            final newVehicle = Vehicle(
                              id:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              licensePlate: 'Test123', // Get from form
                              entryTime: DateTime.now(),
                              vehicleType: 'Sedan', // Get from form
                              entryPhotoPath: capturedImage.path,
                              status: 'checked-in',
                            );

                            ref
                                .read(vehiclesProvider.notifier)
                                .addVehicle(newVehicle);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vehicle entry recorded successfully',
                                ),
                              ),
                            );

                            // Reset captured image
                            ref.read(capturedImageProvider.notifier).state =
                                null;

                            // Open barrier
                            ref.read(barrierOperationProvider.notifier).state =
                                true;
                            try {
                              await ref
                                  .read(barrierSystemsProvider.notifier)
                                  .controlBarrier(entryBarrier.id, 'open');

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entry gate opened'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error opening gate: $e'),
                                ),
                              );
                            } finally {
                              ref
                                  .read(barrierOperationProvider.notifier)
                                  .state = false;
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM & OPEN GATE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Emergency Open Button
              ElevatedButton(
                onPressed: () async {
                  // Emergency opening
                  ref.read(barrierOperationProvider.notifier).state = true;
                  try {
                    await ref
                        .read(barrierSystemsProvider.notifier)
                        .controlBarrier(entryBarrier.id, 'open');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency gate open activated'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening gate: $e')),
                    );
                  } finally {
                    ref.read(barrierOperationProvider.notifier).state = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'EMERGENCY',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Exit Security Widget
class ExitSecurityWidget extends ConsumerWidget {
  const ExitSecurityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedImage = ref.watch(capturedImageProvider);
    final vehicles = ref.watch(vehiclesProvider);
    final barriers = ref.watch(barrierSystemsProvider);
    final activeVehicles =
        vehicles.where((v) => v.status == 'checked-in').toList();
    final selectedVehicle = ref.watch(selectedVehicleProvider);

    final exitBarrier = barriers.firstWhere(
      (b) => b.location == 'exit',
      orElse:
          () => BarrierSystem(
            id: 'exit-gate-1',
            location: 'exit',
            status: 'error',
            lastStatusChange: DateTime.now(),
          ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Exit Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // License Plate Search
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by License Plate',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle List
          const Text(
            'Active Vehicles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: activeVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = activeVehicles[index];
                final isSelected = selectedVehicle?.id == vehicle.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        isSelected
                            ? const BorderSide(color: Colors.indigo, width: 2)
                            : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      vehicle.licensePlate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Entry: ${DateFormat('HH:mm').format(vehicle.entryTime)} • ${vehicle.vehicleType}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(selectedVehicleProvider.notifier).state =
                          vehicle;
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Camera Preview or Captured Image for Exit
          if (selectedVehicle != null) ...[
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  capturedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(capturedImage, fit: BoxFit.cover),
                      )
                      : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the camera button to capture\nexit photo',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Check Out Button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        capturedImage != null && selectedVehicle != null
                            ? () async {
                              // Process exit
                              if (selectedVehicle != null &&
                                  capturedImage != null) {
                                ref
                                    .read(vehiclesProvider.notifier)
                                    .checkOutVehicle(
                                      selectedVehicle.id,
                                      capturedImage.path,
                                    );

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vehicle exit recorded successfully',
                                    ),
                                  ),
                                );

                                // Open barrier
                                ref
                                    .read(barrierOperationProvider.notifier)
                                    .state = true;
                                try {
                                  await ref
                                      .read(barrierSystemsProvider.notifier)
                                      .controlBarrier(exitBarrier.id, 'open');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Exit gate opened'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error opening gate: $e'),
                                    ),
                                  );
                                } finally {
                                  ref
                                      .read(barrierOperationProvider.notifier)
                                      .state = false;
                                }

                                // Reset state
                                ref.read(capturedImageProvider.notifier).state =
                                    null;
                                ref
                                    .read(selectedVehicleProvider.notifier)
                                    .state = null;
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONFIRM EXIT & OPEN GATE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Emergency Open Button
                ElevatedButton(
                  onPressed: () async {
                    // Emergency opening
                    ref.read(barrierOperationProvider.notifier).state = true;
                    try {
                      await ref
                          .read(barrierSystemsProvider.notifier)
                          .controlBarrier(exitBarrier.id, 'open');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency gate open activated'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error opening gate: $e')),
                      );
                    } finally {
                      ref.read(barrierOperationProvider.notifier).state = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'EMERGENCY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Camera Capture Page
class CameraCapturePage extends ConsumerStatefulWidget {
  const CameraCapturePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends ConsumerState<CameraCapturePage> {
  @override
  Widget build(BuildContext context) {
    final cameraControllerAsync = ref.watch(cameraControllerProvider);
    final isCapturing = ref.watch(isCapturingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Capture Photo'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cameraControllerAsync.when(
        data: (cameraController) {
          return Stack(
            children: [
              // Camera Preview
              Positioned.fill(child: CameraPreview(cameraController)),

              // Overlay UI
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    // Instructions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Position the vehicle clearly in frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Capture Button
                    Center(
                      child: GestureDetector(
                        onTap:
                            isCapturing
                                ? null
                                : () async {
                                  ref.read(isCapturingProvider.notifier).state =
                                      true;

                                  try {
                                    final image =
                                        await cameraController.takePicture();
                                    ref
                                        .read(capturedImageProvider.notifier)
                                        .state = File(image.path);
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error capturing image: $e',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    ref
                                        .read(isCapturingProvider.notifier)
                                        .state = false;
                                  }
                                },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color:
                                isCapturing
                                    ? Colors.grey
                                    : Colors.white.withValues(alpha: 0.2),
                          ),
                          child:
                              isCapturing
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                'Error loading camera: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
      ),
    );
  }
}
