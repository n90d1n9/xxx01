import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/prayer.dart';
import '../states/quran_provider.dart';
import '../services/string_extension.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestLocation();
  }

  Future<void> _checkAndRequestLocation() async {
    final service = ref.read(prayerTimesServiceProvider);
    final location = await service.getSavedLocation();
    if (location == null) {
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    final latController = TextEditingController();
    final lonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your coordinates for accurate prayer times:'),
                const SizedBox(height: 16),
                TextField(
                  controller: latController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    hintText: '6.2088',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lonController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    hintText: '106.8456',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final lat = double.tryParse(latController.text);
                  final lon = double.tryParse(lonController.text);
                  if (lat != null && lon != null) {
                    await ref
                        .read(prayerTimesServiceProvider)
                        .saveLocation(lat, lon);
                    ref.invalidate(prayerTimesProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: _showLocationDialog,
            tooltip: 'Change Location',
          ),
        ],
      ),
      body: prayerTimesAsync.when(
        data: (times) {
          if (times == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64),
                  const SizedBox(height: 16),
                  const Text('Location not set'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _showLocationDialog,
                    icon: const Icon(Icons.add_location),
                    label: const Text('Set Location'),
                  ),
                ],
              ),
            );
          }
          final now = DateTime.now();
          final nextPrayer = times.getNextPrayer();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Next Prayer',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPrayerName(nextPrayer),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat.jm().format(
                            times.getTimeForPrayer(nextPrayer),
                          ),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'in ${_formatDuration(times.getTimeUntilNext())}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _PrayerTimeCard(
                  prayer: 'Fajr',
                  time: times.fajr,
                  isNext: nextPrayer == Prayer.fajr,
                  isPast: now.isAfter(times.fajr),
                ),
                _PrayerTimeCard(
                  prayer: 'Sunrise',
                  time: times.sunrise,
                  isNext: nextPrayer == Prayer.sunrise,
                  isPast: now.isAfter(times.sunrise),
                ),
                _PrayerTimeCard(
                  prayer: 'Dhuhr',
                  time: times.dhuhr,
                  isNext: nextPrayer == Prayer.dhuhr,
                  isPast: now.isAfter(times.dhuhr),
                ),
                _PrayerTimeCard(
                  prayer: 'Asr',
                  time: times.asr,
                  isNext: nextPrayer == Prayer.asr,
                  isPast: now.isAfter(times.asr),
                ),
                _PrayerTimeCard(
                  prayer: 'Maghrib',
                  time: times.maghrib,
                  isNext: nextPrayer == Prayer.maghrib,
                  isPast: now.isAfter(times.maghrib),
                ),
                _PrayerTimeCard(
                  prayer: 'Isha',
                  time: times.isha,
                  isNext: nextPrayer == Prayer.isha,
                  isPast: now.isAfter(times.isha),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _showLocationDialog,
                    child: const Text('Set Location'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  String _getPrayerName(Prayer prayer) {
    return prayer.toString().split('.').last.capitalize();
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final String prayer;
  final DateTime time;
  final bool isNext;
  final bool isPast;
  const _PrayerTimeCard({
    required this.prayer,
    required this.time,
    required this.isNext,
    required this.isPast,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: isNext ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: ListTile(
        leading: Icon(
          _getPrayerIcon(prayer),
          color: isPast ? Colors.grey : null,
        ),
        title: Text(
          prayer,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : null,
            color: isPast ? Colors.grey : null,
          ),
        ),
        trailing: Text(
          DateFormat.jm().format(time),
          style: TextStyle(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : null,
            color: isPast ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.light_mode;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}
