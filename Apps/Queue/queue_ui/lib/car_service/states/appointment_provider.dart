import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment.dart';

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]);

  void cancelAppointment(String id) {
    state =
        state.map((appointment) {
          if (appointment.id == id) {
            return appointment.copyWith(status: AppointmentStatus.cancelled);
          }
          return appointment;
        }).toList();
  }
}

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, List<Appointment>>(
      (ref) => AppointmentNotifier(),
    );

class AppointmentRepository {
  final List<Appointment> _appointments = [];

  List<Appointment> getUserAppointments(String userId) {
    // Typically, this would filter appointments for the specific user
    // using an API call or database query
    return _appointments;
  }

  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    // In a real app, this would save to a database or API
    _appointments.add(appointment);
    return appointment;
  }

  Future<Appointment> updateAppointment(Appointment appointment) async {
    // In a real app, this would update in a database or API
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index >= 0) {
      _appointments[index] = appointment;
    }
    return appointment;
  }
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

final userAppointmentsProvider = Provider.family<List<Appointment>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getUserAppointments(userId);
});

final appointmentFormProvider =
    StateNotifierProvider<AppointmentFormNotifier, Appointment?>((ref) {
      return AppointmentFormNotifier();
    });

class AppointmentFormNotifier extends StateNotifier<Appointment?> {
  AppointmentFormNotifier() : super(null);

  void setVehicle(String vehicleId) {
    if (state == null) {
      state = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: vehicleId,
        serviceIds: [],
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: AppointmentStatus.scheduled,
      );
    } else {
      state = state!.copyWith(vehicleId: vehicleId);
    }
  }

  void setDateTime(DateTime dateTime) {
    if (state != null) {
      state = state!.copyWith(dateTime: dateTime);
    }
  }

  void addService(String serviceId) {
    if (state != null) {
      final serviceIds = List<String>.from(state!.serviceIds);
      if (!serviceIds.contains(serviceId)) {
        serviceIds.add(serviceId);
        state = state!.copyWith(serviceIds: serviceIds);
      }
    }
  }

  void removeService(String serviceId) {
    if (state != null) {
      final serviceIds = List<String>.from(state!.serviceIds);
      serviceIds.remove(serviceId);
      state = state!.copyWith(serviceIds: serviceIds);
    }
  }

  void setNotes(String? notes) {
    if (state != null) {
      state = state!.copyWith(notes: notes);
    }
  }

  void reset() {
    state = null;
  }
}
