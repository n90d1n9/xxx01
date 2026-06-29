import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Attendance State
final attendanceStateProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      return AttendanceNotifier();
    });

class AttendanceState {
  final bool isLoading;
  final Position? position;
  final String? errorMessage;
  final File? imageFile;
  final DateTime? checkInTime;
  final bool isCheckedIn;

  AttendanceState({
    this.isLoading = false,
    this.position,
    this.errorMessage,
    this.imageFile,
    this.checkInTime,
    this.isCheckedIn = false,
  });

  AttendanceState copyWith({
    bool? isLoading,
    Position? position,
    String? errorMessage,
    File? imageFile,
    DateTime? checkInTime,
    bool? isCheckedIn,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      errorMessage: errorMessage,
      imageFile: imageFile ?? this.imageFile,
      checkInTime: checkInTime ?? this.checkInTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Location permission denied',
          );
          return;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(position: position, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: $e',
      );
    }
  }

  Future<void> captureImage() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status.isDenied) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Camera permission denied',
        );
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        state = state.copyWith(
          imageFile: File(pickedFile.path),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No image selected',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to capture image: $e',
      );
    }
  }

  void checkIn() {
    if (state.position != null && state.imageFile != null) {
      state = state.copyWith(checkInTime: DateTime.now(), isCheckedIn: true);
      // Here you would typically send data to your API
    }
  }

  void reset() {
    state = AttendanceState();
  }
}

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceStateProvider);
    final notifier = ref.read(attendanceStateProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Attendance Check-In',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: attendanceState.isCheckedIn ? notifier.reset : null,
          ),
        ],
      ),
      body:
          attendanceState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : attendanceState.isCheckedIn
              ? _buildSuccessView(context, attendanceState)
              : _buildCheckInView(context, attendanceState, notifier),
    );
  }

  Widget _buildCheckInView(
    BuildContext context,
    AttendanceState state,
    AttendanceNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (state.position != null) ...[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              state.position!.latitude,
                              state.position!.longitude,
                            ),
                            zoom: 16,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('current_location'),
                              position: LatLng(
                                state.position!.latitude,
                                state.position!.longitude,
                              ),
                            ),
                          },
                          myLocationEnabled: true,
                          compassEnabled: true,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${state.position!.latitude.toStringAsFixed(6)}\nLng: ${state.position!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: notifier.getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Get Current Location'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (state.imageFile != null) ...[
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(state.imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: notifier.captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Selfie'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed:
                state.position != null && state.imageFile != null
                    ? notifier.checkIn
                    : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Check In',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, AttendanceState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 16),
        const Text(
          'Check-In Successful!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Checked in at ${DateFormat('yyyy-MM-dd HH:mm').format(state.checkInTime!)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${state.position!.latitude.toStringAsFixed(6)}\nLng: ${state.position!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            state.imageFile!,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Main app (for reference)
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const AttendanceScreen(),
      ),
    );
  }
}

void main(List<String> args) {
  runApp(AttendanceApp());
}
