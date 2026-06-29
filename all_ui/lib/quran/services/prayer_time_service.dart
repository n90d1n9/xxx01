import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer.dart';

class PrayerTimesService {
  static const String _prayerTimesKey = 'prayer_times_cache';
  static const String _locationKey = 'user_location';

  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final cached = await _getCachedPrayerTimes();
      if (cached != null && _isSameDay(cached.date, DateTime.now())) {
        return cached;
      }

      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings/${now.day}-${now.month}-${now.year}'
          '?latitude=$latitude&longitude=$longitude&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        final prayerTimes = PrayerTimes(
          fajr: _parseTime(timings['Fajr']),
          sunrise: _parseTime(timings['Sunrise']),
          dhuhr: _parseTime(timings['Dhuhr']),
          asr: _parseTime(timings['Asr']),
          maghrib: _parseTime(timings['Maghrib']),
          isha: _parseTime(timings['Isha']),
          date: DateTime.now(),
        );

        await _cachePrayerTimes(prayerTimes);
        return prayerTimes;
      }

      throw Exception('Failed to fetch prayer times');
    } catch (e) {
      throw Exception('Failed to get prayer times: $e');
    }
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _cachePrayerTimes(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prayerTimesKey, json.encode(times.toJson()));
  }

  Future<PrayerTimes?> _getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prayerTimesKey);
    if (cached != null) {
      return PrayerTimes.fromJson(json.decode(cached));
    }
    return null;
  }

  Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _locationKey,
      json.encode({'latitude': latitude, 'longitude': longitude}),
    );
  }

  Future<Map<String, double>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString(_locationKey);
    if (location != null) {
      final decoded = json.decode(location);
      return {
        'latitude': decoded['latitude'],
        'longitude': decoded['longitude'],
      };
    }
    return null;
  }
}
