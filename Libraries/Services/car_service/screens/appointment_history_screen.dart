import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/appointment.dart';
import '../states/appointment_provider.dart';
import 'appointment_detail_screen.dart';

class AppointmentHistoryScreen extends ConsumerWidget {
  const AppointmentHistoryScreen({super.key});

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'blue';
      case AppointmentStatus.inProgress:
        return 'orange';
      case AppointmentStatus.completed:
        return 'green';
      case AppointmentStatus.cancelled:
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming we have a provider for user's appointment history
    final appointments = ref.watch(userAppointmentsProvider('currentUserId'));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment History')),
      body: appointments.isEmpty
          ? _buildEmptyState()
          : _buildAppointmentsList(context, appointments),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No appointment history',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your scheduled appointments will appear here',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<Appointment> appointments,
  ) {
    // Sort appointments by date (newest first)
    final sortedAppointments = List<Appointment>.from(appointments)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = sortedAppointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AppointmentDetailsScreen(appointment: appointment),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appointment #${appointment.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildStatusChip(appointment.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(_formatDate(appointment.dateTime)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Text(_formatTime(appointment.dateTime)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${appointment.vehicleMake} ${appointment.vehicleModel}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${appointment.serviceNames!.length} services',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        '\$${appointment.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    final statusColor = _getStatusColor(status);
    Color chipColor;
    Color textColor;

    switch (statusColor) {
      case 'blue':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'orange':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'green':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'red':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
